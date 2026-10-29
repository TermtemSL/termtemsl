package auth

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/lestrrat-go/jwx/v3/jwa"
	"github.com/lestrrat-go/jwx/v3/jwk"
	"github.com/lestrrat-go/jwx/v3/jws"
	"github.com/lestrrat-go/jwx/v3/jwt"
)

const (
	testIssuer   = "https://test-project.supabase.co/auth/v1"
	testAudience = "authenticated"
)

type rotatingJWKSServer struct {
	server *httptest.Server

	mu       sync.Mutex
	set      jwk.Set
	requests int
}

func newRotatingJWKSServer(t *testing.T, initialSet jwk.Set) *rotatingJWKSServer {
	t.Helper()
	s := &rotatingJWKSServer{set: initialSet}
	s.server = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		s.mu.Lock()
		defer s.mu.Unlock()
		s.requests++
		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(s.set); err != nil {
			t.Errorf("encode JWKS response: %v", err)
		}
	}))
	t.Cleanup(s.server.Close)
	return s
}

func (s *rotatingJWKSServer) replace(set jwk.Set) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.set = set
}

func (s *rotatingJWKSServer) requestCount() int {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.requests
}

func newTestVerifier(t *testing.T, server *rotatingJWKSServer) *JWKSVerifier {
	t.Helper()
	lifecycleCtx, cancel := context.WithCancel(context.Background())
	verifier, err := newJWKSVerifier(
		lifecycleCtx,
		testIssuer,
		testAudience,
		server.server.URL,
		server.server.Client(),
	)
	if err != nil {
		cancel()
		t.Fatalf("newJWKSVerifier(): %v", err)
	}
	t.Cleanup(func() {
		shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer shutdownCancel()
		if err := verifier.Shutdown(shutdownCtx); err != nil {
			t.Errorf("shutdown verifier: %v", err)
		}
		cancel()
	})
	return verifier
}

func generateSigningKey(t *testing.T, kid string) (*ecdsa.PrivateKey, jwk.Key) {
	t.Helper()
	privateKey, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatalf("generate ECDSA key: %v", err)
	}
	publicJWK, err := jwk.Import(&privateKey.PublicKey)
	if err != nil {
		t.Fatalf("import public JWK: %v", err)
	}
	for name, value := range map[string]any{
		jwk.KeyIDKey:     kid,
		jwk.AlgorithmKey: jwa.ES256(),
		jwk.KeyUsageKey:  "sig",
	} {
		if err := publicJWK.Set(name, value); err != nil {
			t.Fatalf("set JWK %s: %v", name, err)
		}
	}
	return privateKey, publicJWK
}

func keySet(t *testing.T, keys ...jwk.Key) jwk.Set {
	t.Helper()
	set := jwk.NewSet()
	for _, key := range keys {
		if err := set.AddKey(key); err != nil {
			t.Fatalf("add public JWK: %v", err)
		}
	}
	return set
}

func signES256Token(t *testing.T, privateKey *ecdsa.PrivateKey, kid, issuer, audience, subject string, expiration time.Time) string {
	t.Helper()
	token := jwt.New()
	claims := map[string]any{
		jwt.IssuerKey:     issuer,
		jwt.AudienceKey:   []string{audience},
		jwt.SubjectKey:    subject,
		jwt.ExpirationKey: expiration,
	}
	for name, value := range claims {
		if err := token.Set(name, value); err != nil {
			t.Fatalf("set token claim %s: %v", name, err)
		}
	}

	headers := jws.NewHeaders()
	if err := headers.Set(jws.KeyIDKey, kid); err != nil {
		t.Fatalf("set token kid: %v", err)
	}
	signed, err := jwt.Sign(token, jwt.WithKey(jwa.ES256(), privateKey, jws.WithProtectedHeaders(headers)))
	if err != nil {
		t.Fatalf("sign ES256 token: %v", err)
	}
	return string(signed)
}

func signHS256Token(t *testing.T, kid string) string {
	t.Helper()
	token := jwt.New()
	if err := token.Set(jwt.ExpirationKey, time.Now().Add(time.Hour)); err != nil {
		t.Fatalf("set HMAC token expiration: %v", err)
	}
	headers := jws.NewHeaders()
	if err := headers.Set(jws.KeyIDKey, kid); err != nil {
		t.Fatalf("set HMAC token kid: %v", err)
	}
	signed, err := jwt.Sign(
		token,
		jwt.WithKey(jwa.HS256(), []byte("test-only-key-with-at-least-32-bytes"), jws.WithProtectedHeaders(headers)),
	)
	if err != nil {
		t.Fatalf("sign HS256 token: %v", err)
	}
	return string(signed)
}

func TestJWKSVerifierValidToken(t *testing.T) {
	privateKey, publicJWK := generateSigningKey(t, "current-key")
	server := newRotatingJWKSServer(t, keySet(t, publicJWK))
	verifier := newTestVerifier(t, server)
	wantUserID := uuid.New()
	rawToken := signES256Token(t, privateKey, "current-key", testIssuer, testAudience, wantUserID.String(), time.Now().Add(time.Hour))

	identity, err := verifier.Verify(context.Background(), rawToken)
	if err != nil {
		t.Fatalf("Verify() error = %v", err)
	}
	if identity.UserID != wantUserID {
		t.Fatalf("Verify() user ID = %v, want %v", identity.UserID, wantUserID)
	}
}

func TestJWKSVerifierRejectsInvalidTokens(t *testing.T) {
	privateKey, publicJWK := generateSigningKey(t, "current-key")
	wrongKey, _ := generateSigningKey(t, "unused-key")
	server := newRotatingJWKSServer(t, keySet(t, publicJWK))
	verifier := newTestVerifier(t, server)
	userID := uuid.New().String()

	tests := []struct {
		name      string
		rawToken  string
		wantError error
	}{
		{name: "malformed", rawToken: "not-a-jwt", wantError: ErrMalformedToken},
		{name: "disallowed HS256 algorithm", rawToken: signHS256Token(t, "current-key"), wantError: ErrInvalidToken},
		{name: "expired", rawToken: signES256Token(t, privateKey, "current-key", testIssuer, testAudience, userID, time.Now().Add(-time.Minute)), wantError: ErrExpiredToken},
		{name: "wrong issuer", rawToken: signES256Token(t, privateKey, "current-key", "https://other.supabase.co/auth/v1", testAudience, userID, time.Now().Add(time.Hour)), wantError: ErrInvalidToken},
		{name: "wrong audience", rawToken: signES256Token(t, privateKey, "current-key", testIssuer, "other", userID, time.Now().Add(time.Hour)), wantError: ErrInvalidToken},
		{name: "invalid signature", rawToken: signES256Token(t, wrongKey, "current-key", testIssuer, testAudience, userID, time.Now().Add(time.Hour)), wantError: ErrInvalidToken},
		{name: "invalid UUID subject", rawToken: signES256Token(t, privateKey, "current-key", testIssuer, testAudience, "not-a-uuid", time.Now().Add(time.Hour)), wantError: ErrInvalidToken},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, err := verifier.Verify(context.Background(), test.rawToken)
			if !errors.Is(err, test.wantError) {
				t.Fatalf("Verify() error = %v, want errors.Is(_, %v)", err, test.wantError)
			}
		})
	}
}

func TestJWKSVerifierRefreshesForRotatedKey(t *testing.T) {
	_, oldPublicJWK := generateSigningKey(t, "old-key")
	newPrivateKey, newPublicJWK := generateSigningKey(t, "new-key")
	server := newRotatingJWKSServer(t, keySet(t, oldPublicJWK))
	verifier := newTestVerifier(t, server)

	server.replace(keySet(t, oldPublicJWK, newPublicJWK))
	wantUserID := uuid.New()
	rawToken := signES256Token(t, newPrivateKey, "new-key", testIssuer, testAudience, wantUserID.String(), time.Now().Add(time.Hour))

	identity, err := verifier.Verify(context.Background(), rawToken)
	if err != nil {
		t.Fatalf("Verify() after rotation error = %v", err)
	}
	if identity.UserID != wantUserID {
		t.Fatalf("Verify() user ID = %v, want %v", identity.UserID, wantUserID)
	}
	if got := server.requestCount(); got != 2 {
		t.Fatalf("JWKS requests = %d, want 2 (initial fetch plus one refresh)", got)
	}
}

func TestJWKSVerifierRejectsUnknownKeyAfterOneRefresh(t *testing.T) {
	_, publicJWK := generateSigningKey(t, "current-key")
	unknownPrivateKey, _ := generateSigningKey(t, "unknown-key")
	server := newRotatingJWKSServer(t, keySet(t, publicJWK))
	verifier := newTestVerifier(t, server)
	rawToken := signES256Token(t, unknownPrivateKey, "unknown-key", testIssuer, testAudience, uuid.NewString(), time.Now().Add(time.Hour))

	if _, err := verifier.Verify(context.Background(), rawToken); !errors.Is(err, ErrInvalidToken) {
		t.Fatalf("Verify() error = %v, want ErrInvalidToken", err)
	}
	if got := server.requestCount(); got != 2 {
		t.Fatalf("JWKS requests = %d, want exactly 2", got)
	}
}
