package middleware

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"project-backend/auth"
)

type stubVerifier struct {
	identity  auth.Identity
	err       error
	gotToken  string
	callCount int
}

func (v *stubVerifier) Verify(_ context.Context, rawToken string) (auth.Identity, error) {
	v.callCount++
	v.gotToken = rawToken
	return v.identity, v.err
}

func TestRequireAuthAcceptsValidBearerToken(t *testing.T) {
	gin.SetMode(gin.TestMode)
	wantUserID := uuid.New()
	verifier := &stubVerifier{identity: auth.Identity{UserID: wantUserID}}
	handlerCalled := false

	router := gin.New()
	router.Use(RequireAuth(verifier))
	router.GET("/protected", func(c *gin.Context) {
		handlerCalled = true
		userID, ok := UserIDFromContext(c)
		if !ok || userID != wantUserID {
			t.Fatalf("UserIDFromContext() = (%v, %v), want (%v, true)", userID, ok, wantUserID)
		}
		c.Status(http.StatusNoContent)
	})

	request := httptest.NewRequest(http.MethodGet, "/protected", nil)
	request.Header.Set("Authorization", "Bearer signed.jwt.value")
	response := httptest.NewRecorder()
	router.ServeHTTP(response, request)

	if response.Code != http.StatusNoContent {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusNoContent)
	}
	if !handlerCalled {
		t.Fatal("protected handler was not called")
	}
	if verifier.callCount != 1 || verifier.gotToken != "signed.jwt.value" {
		t.Fatalf("verifier calls/token = (%d, %q), want (1, %q)", verifier.callCount, verifier.gotToken, "signed.jwt.value")
	}
}

func TestRequireAuthRejectsInvalidRequests(t *testing.T) {
	tests := []struct {
		name      string
		headers   []string
		verifyErr error
		wantCalls int
	}{
		{name: "missing header", wantCalls: 0},
		{name: "wrong scheme", headers: []string{"Basic credentials"}, wantCalls: 0},
		{name: "empty bearer", headers: []string{"Bearer"}, wantCalls: 0},
		{name: "extra components", headers: []string{"Bearer one two"}, wantCalls: 0},
		{name: "multiple headers", headers: []string{"Bearer one", "Bearer two"}, wantCalls: 0},
		{name: "verifier rejection", headers: []string{"Bearer bad.jwt.value"}, verifyErr: auth.ErrInvalidToken, wantCalls: 1},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			gin.SetMode(gin.TestMode)
			verifier := &stubVerifier{err: test.verifyErr}
			handlerCalled := false
			router := gin.New()
			router.Use(RequireAuth(verifier))
			router.GET("/protected", func(c *gin.Context) {
				handlerCalled = true
				c.Status(http.StatusNoContent)
			})

			request := httptest.NewRequest(http.MethodGet, "/protected", nil)
			for _, value := range test.headers {
				request.Header.Add("Authorization", value)
			}
			response := httptest.NewRecorder()
			router.ServeHTTP(response, request)

			if response.Code != http.StatusUnauthorized {
				t.Fatalf("status = %d, want %d", response.Code, http.StatusUnauthorized)
			}
			if response.Body.String() != "{\"error\":\"unauthorized\"}" {
				t.Fatalf("body = %q, want generic unauthorized response", response.Body.String())
			}
			if handlerCalled {
				t.Fatal("protected handler was called after authentication failed")
			}
			if verifier.callCount != test.wantCalls {
				t.Fatalf("verifier calls = %d, want %d", verifier.callCount, test.wantCalls)
			}
		})
	}
}

func TestRequireAuthDoesNotExposeVerifierError(t *testing.T) {
	gin.SetMode(gin.TestMode)
	verifier := &stubVerifier{err: errors.New("signature failed for sensitive token material")}
	router := gin.New()
	router.Use(RequireAuth(verifier))
	router.GET("/protected", func(c *gin.Context) { c.Status(http.StatusNoContent) })

	request := httptest.NewRequest(http.MethodGet, "/protected", nil)
	request.Header.Set("Authorization", "Bearer secret-token")
	response := httptest.NewRecorder()
	router.ServeHTTP(response, request)

	if response.Body.String() != "{\"error\":\"unauthorized\"}" {
		t.Fatalf("body exposed verifier details: %q", response.Body.String())
	}
}
