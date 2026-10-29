package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"project-backend/auth"
)

// identityContextKey is private so other packages cannot accidentally overwrite
// a verified identity by reusing the same Gin context key directly.
const identityContextKey = "project-backend/auth.identity"

// SetIdentity stores a verified identity for the rest of the Gin request.
// The authentication middleware calls this only after JWT verification succeeds;
// handlers should read the value through the helpers below instead of setting it.
func SetIdentity(c *gin.Context, identity auth.Identity) {
	c.Set(identityContextKey, identity)
}

// IdentityFromContext safely converts Gin's untyped context value back into the
// application's Identity type. The boolean is false when authentication did not
// run, the stored value has the wrong type, or the identity contains a nil UUID.
func IdentityFromContext(c *gin.Context) (auth.Identity, bool) {
	value, exists := c.Get(identityContextKey)
	if !exists {
		return auth.Identity{}, false
	}

	identity, ok := value.(auth.Identity)
	if !ok || identity.UserID == uuid.Nil {
		return auth.Identity{}, false
	}
	return identity, true
}

// UserIDFromContext is the usual helper for protected handlers. It returns the
// verified Supabase auth.users UUID without requiring handlers to know how the
// full Identity value is stored in Gin.
func UserIDFromContext(c *gin.Context) (uuid.UUID, bool) {
	identity, ok := IdentityFromContext(c)
	if !ok {
		return uuid.Nil, false
	}
	return identity.UserID, true
}
