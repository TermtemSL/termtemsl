package middleware

import (
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"project-backend/auth"
)

func TestIdentityContext(t *testing.T) {
	c, _ := gin.CreateTestContext(nil)
	want := uuid.New()

	// This reproduces the handoff from authentication middleware to a protected
	// handler: store one verified identity, then read it in either typed form.
	SetIdentity(c, auth.Identity{UserID: want})

	identity, ok := IdentityFromContext(c)
	if !ok || identity.UserID != want {
		t.Fatalf("IdentityFromContext() = (%v, %v), want UUID %v", identity, ok, want)
	}

	userID, ok := UserIDFromContext(c)
	if !ok || userID != want {
		t.Fatalf("UserIDFromContext() = (%v, %v), want (%v, true)", userID, ok, want)
	}
}

func TestIdentityContextMissingOrInvalid(t *testing.T) {
	c, _ := gin.CreateTestContext(nil)

	// A handler must not treat a route as authenticated just because the helper
	// was called; the middleware must have stored a valid, non-nil user UUID.
	if _, ok := IdentityFromContext(c); ok {
		t.Fatal("IdentityFromContext() unexpectedly found an identity")
	}

	SetIdentity(c, auth.Identity{UserID: uuid.Nil})
	if _, ok := UserIDFromContext(c); ok {
		t.Fatal("UserIDFromContext() accepted a nil UUID")
	}
}
