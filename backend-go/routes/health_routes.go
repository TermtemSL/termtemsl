package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"project-backend/model"
)

// RegisterHealthRoutes attaches health-related routes to the router.
func RegisterHealthRoutes(r *gin.Engine) {
	r.GET("/health", HealthCheck)
}

// HealthCheck godoc
// @Summary Check API health
// @Description Check whether the backend server is running
// @Tags Health
// @Produce json
// @Success 200 {object} model.HealthResponse
// @Router /health [get]
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, model.HealthResponse{
		Status: "ok",
	})
}