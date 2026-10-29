package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"project-backend/auth"
)

// RequireAuth returns Gin middleware that authenticates a Supabase bearer
// access token before allowing the request to reach a protected handler.
func RequireAuth(verifier auth.Verifier) gin.HandlerFunc {
	return func(c *gin.Context) {
		rawToken, ok := bearerToken(c.Request.Header)
		if !ok {
			abortUnauthorized(c)
			return
		}

		identity, err := verifier.Verify(c.Request.Context(), rawToken)
		if err != nil {
			// Do not return the verifier error: issuer, signature, expiry, and
			// key-selection details are intentionally hidden from API clients.
			abortUnauthorized(c)
			return
		}

		SetIdentity(c, identity)
		c.Next()
	}
}

// bearerToken accepts exactly one header in the form
// "Authorization: Bearer <token>". EqualFold permits the case-insensitive
// authentication scheme required by HTTP while keeping the token unchanged.
func bearerToken(header http.Header) (string, bool) {
	values := header.Values("Authorization")
	if len(values) != 1 {
		return "", false
	}

	parts := strings.Fields(values[0])
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") || parts[1] == "" {
		return "", false
	}
	return parts[1], true
}

func abortUnauthorized(c *gin.Context) {
	c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
		"error": "unauthorized",
	})
}
