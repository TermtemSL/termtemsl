package routes

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"project-backend/auth"
	"project-backend/middleware"
)

type routeVerifier struct {
	identity auth.Identity
	err      error
}

func (v routeVerifier) Verify(_ context.Context, _ string) (auth.Identity, error) {
	return v.identity, v.err
}

func authTestRouter(verifier auth.Verifier) *gin.Engine {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	protected := router.Group("/api")
	protected.Use(middleware.RequireAuth(verifier))
	RegisterAuthRoutes(protected)
	return router
}

func TestMeReturnsAuthenticatedUUID(t *testing.T) {
	wantUserID := uuid.New()
	router := authTestRouter(routeVerifier{identity: auth.Identity{UserID: wantUserID}})
	request := httptest.NewRequest(http.MethodGet, "/api/me", nil)
	request.Header.Set("Authorization", "Bearer test-token")
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	wantBody := `{"id":"` + wantUserID.String() + `"}`
	if strings.TrimSpace(response.Body.String()) != wantBody {
		t.Fatalf("body = %q, want %q", response.Body.String(), wantBody)
	}
}

func TestMeRequiresBearerToken(t *testing.T) {
	router := authTestRouter(routeVerifier{})
	request := httptest.NewRequest(http.MethodGet, "/api/me", nil)
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	if response.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusUnauthorized)
	}
}

func TestMeDefensivelyRejectsMissingIdentity(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.GET("/api/me", Me)
	request := httptest.NewRequest(http.MethodGet, "/api/me", nil)
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	if response.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusUnauthorized)
	}
}
