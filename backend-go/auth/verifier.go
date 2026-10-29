package auth

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/lestrrat-go/httprc/v3"
	"github.com/lestrrat-go/jwx/v3/jwa"
	"github.com/lestrrat-go/jwx/v3/jwk"
	"github.com/lestrrat-go/jwx/v3/jws"
	"github.com/lestrrat-go/jwx/v3/jwt"
)

const (
	jwksPath        = "/.well-known/jwks.json"
	maxTokenSize    = 16 * 1024
	maxJWKSSize     = 1 << 20
	jwksRefreshTTL  = 10 * time.Minute
	refreshCooldown = 30 * time.Second
)

type Verifier interface {
	Verify(ctx context.Context, rawToken string) (Identity, error)
}

// JWKSVerifier verifies Supabase access tokens locally with the project's
// asymmetric public signing keys. It never needs or accepts a JWT secret.
type JWKSVerifier struct {
	issuer   string
	audience string
	jwksURL  string
	cache    *jwk.Cache

	refreshMu   sync.Mutex
	lastRefresh time.Time
}

// NewJWKSVerifier creates a verifier and performs the initial JWKS fetch.
// Cancel lifecycleCtx or call Shutdown when the application stops.
func NewJWKSVerifier(lifecycleCtx context.Context, issuer, audience string) (*JWKSVerifier, error) {
	issuer = strings.TrimRight(strings.TrimSpace(issuer), "/")
	audience = strings.TrimSpace(audience)
	if issuer == "" || audience == "" {
		return nil, fmt.Errorf("issuer and audience are required")
	}

	issuerURL, err := url.Parse(issuer)
	if err != nil || issuerURL.Scheme != "https" || issuerURL.Host == "" {
		return nil, fmt.Errorf("issuer must be a valid HTTPS URL")
	}

	jwksURL := issuer + jwksPath
	return newJWKSVerifier(lifecycleCtx, issuer, audience, jwksURL, &http.Client{
		Timeout: 5 * time.Second,
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error {
			return http.ErrUseLastResponse
		},
	})
}

// newJWKSVerifier accepts an injected endpoint and client so tests can use a
// local JWKS server. Production callers must use NewJWKSVerifier, which derives
// the endpoint from a validated HTTPS issuer.
func newJWKSVerifier(lifecycleCtx context.Context, issuer, audience, jwksURL string, httpClient *http.Client) (*JWKSVerifier, error) {
	cache, err := jwk.NewCache(lifecycleCtx, httprc.NewClient())
	if err != nil {
		return nil, fmt.Errorf("create JWKS cache: %w", err)
	}

	if err := cache.Register(
		lifecycleCtx,
		jwksURL,
		jwk.WithHTTPClient(httpClient),
		jwk.WithConstantInterval(jwksRefreshTTL),
		jwk.WithMaxFetchBodySize(maxJWKSSize),
	); err != nil {
		_ = cache.Shutdown(context.Background())
		return nil, fmt.Errorf("register JWKS endpoint: %w", err)
	}

	return &JWKSVerifier{
		issuer:   issuer,
		audience: audience,
		jwksURL:  jwksURL,
		cache:    cache,
	}, nil
}

func (v *JWKSVerifier) Verify(ctx context.Context, rawToken string) (Identity, error) {
	if rawToken == "" || len(rawToken) > maxTokenSize {
		return Identity{}, ErrMalformedToken
	}

	algorithm, kid, err := protectedHeader(rawToken)
	if err != nil {
		return Identity{}, ErrMalformedToken
	}
	if algorithm != jwa.ES256() || kid == "" {
		return Identity{}, ErrInvalidToken
	}

	keySet, err := v.cache.Lookup(ctx, v.jwksURL)
	if err != nil {
		return Identity{}, ErrInvalidToken
	}

	key, ok := keySet.LookupKeyID(kid)
	if !ok {
		keySet, err = v.refreshForUnknownKey(ctx)
		if err != nil {
			return Identity{}, ErrInvalidToken
		}
		key, ok = keySet.LookupKeyID(kid)
		if !ok {
			return Identity{}, ErrInvalidToken
		}
	}

	if !validES256Key(key) {
		return Identity{}, ErrInvalidToken
	}

	token, err := jwt.Parse(
		[]byte(rawToken),
		jwt.WithKey(jwa.ES256(), key),
		jwt.WithValidate(true),
		jwt.WithIssuer(v.issuer),
		jwt.WithAudience(v.audience),
		jwt.WithContext(ctx),
	)
	if err != nil {
		// Preserve only the useful internal expiry category. All other library
		// errors collapse to ErrInvalidToken so callers cannot leak verification
		// details through an HTTP response.
		if errors.Is(err, jwt.TokenExpiredError()) {
			return Identity{}, ErrExpiredToken
		}
		return Identity{}, ErrInvalidToken
	}

	if _, ok := token.Expiration(); !ok {
		return Identity{}, ErrInvalidToken
	}

	subject, ok := token.Subject()
	if !ok {
		return Identity{}, ErrInvalidToken
	}
	userID, err := uuid.Parse(subject)
	if err != nil || userID == uuid.Nil {
		return Identity{}, ErrInvalidToken
	}

	return Identity{UserID: userID}, nil
}

func (v *JWKSVerifier) Shutdown(ctx context.Context) error {
	return v.cache.Shutdown(ctx)
}

func (v *JWKSVerifier) refreshForUnknownKey(ctx context.Context) (jwk.Set, error) {
	v.refreshMu.Lock()
	defer v.refreshMu.Unlock()

	// A cooldown prevents attacker-controlled kid values from turning token
	// verification into unbounded outbound requests.
	if time.Since(v.lastRefresh) < refreshCooldown {
		return v.cache.Lookup(ctx, v.jwksURL)
	}

	keySet, err := v.cache.Refresh(ctx, v.jwksURL)
	if err != nil {
		return nil, err
	}
	v.lastRefresh = time.Now()
	return keySet, nil
}

func protectedHeader(rawToken string) (jwa.SignatureAlgorithm, string, error) {
	message, err := jws.Parse([]byte(rawToken))
	if err != nil || len(message.Signatures()) != 1 {
		return jwa.EmptySignatureAlgorithm(), "", ErrInvalidToken
	}

	headers := message.Signatures()[0].ProtectedHeaders()
	if headers == nil {
		return jwa.EmptySignatureAlgorithm(), "", ErrInvalidToken
	}
	algorithm, ok := headers.Algorithm()
	if !ok {
		return jwa.EmptySignatureAlgorithm(), "", ErrInvalidToken
	}
	kid, ok := headers.KeyID()
	if !ok {
		return jwa.EmptySignatureAlgorithm(), "", ErrInvalidToken
	}
	return algorithm, kid, nil
}

func validES256Key(key jwk.Key) bool {
	if key.KeyType() != jwa.EC() {
		return false
	}
	algorithm, ok := key.Algorithm()
	if !ok || algorithm.String() != jwa.ES256().String() {
		return false
	}
	if usage, ok := key.KeyUsage(); ok && usage != "sig" {
		return false
	}
	return true
}
