package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"project-backend/middleware"
	"project-backend/model"
)

// RegisterAuthRoutes attaches endpoints that require a verified Supabase user.
// The caller must pass a RouterGroup configured with RequireAuth.
func RegisterAuthRoutes(protected *gin.RouterGroup) {
	protected.GET("/me", Me)
}

// Me godoc
// @Summary Return the authenticated user
// @Description Returns the UUID from the verified Supabase access token
// @Tags Authentication
// @Produce json
// @Security BearerAuth
// @Success 200 {object} model.MeResponse
// @Failure 401 {object} map[string]string "missing or invalid bearer token"
// @Router /api/me [get]
func Me(c *gin.Context) {
	userID, ok := middleware.UserIDFromContext(c)
	if !ok {
		// This defensive check keeps the endpoint safe if it is accidentally
		// registered outside the protected route group in the future.
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	c.JSON(http.StatusOK, model.MeResponse{ID: userID.String()})
}
