package routes

import (
	"context"
	"database/sql"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"project-backend/model"
)

// RegisterHealthRoutes attaches health-related routes to the router.
func RegisterHealthRoutes(r *gin.Engine, db *sql.DB) {
	r.GET("/health", HealthCheck)
	r.GET("/health/db", DatabaseHealthCheck(db))
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

// DatabaseHealthCheck godoc
// @Summary Check database health
// @Description Check whether the backend can connect to PostgreSQL
// @Tags Health
// @Produce json
// @Success 200 {object} model.DatabaseHealthResponse
// @Failure 503 {object} model.DatabaseHealthResponse
// @Router /health/db [get]
func DatabaseHealthCheck(db *sql.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
		defer cancel()

		if err := db.PingContext(ctx); err != nil {
			c.JSON(http.StatusServiceUnavailable, model.DatabaseHealthResponse{
				Status:   "error",
				Database: "unavailable",
			})
			return
		}

		c.JSON(http.StatusOK, model.DatabaseHealthResponse{
			Status:   "ok",
			Database: "connected",
		})
	}
}
