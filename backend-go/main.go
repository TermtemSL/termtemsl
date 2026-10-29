package main

import (
	"context"
	"log"
	"time"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"project-backend/auth"
	"project-backend/config"
	"project-backend/database"
	_ "project-backend/docs"
	"project-backend/middleware"
	"project-backend/routes"
	"project-backend/services"
)

// @title TermtemSL Backend API
// @version 1.0
// @description Backend API for TermtemSL Sign Language Application
// @host localhost:8080
// @BasePath /
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Enter a Supabase access token as: Bearer <token>
func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatal(err)
	}

	db, err := database.Open(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("database initialization failed: %v", err)
	}
	defer db.Close()

	log.Println("Database connection established")

	// The verifier downloads only Supabase's public signing keys. Go never
	// receives the private signing key, legacy JWT secret, or user passwords.
	verifierCtx, cancelVerifier := context.WithCancel(context.Background())
	defer cancelVerifier()

	authVerifier, err := auth.NewJWKSVerifier(
		verifierCtx,
		cfg.SupabaseJWTIssuer,
		cfg.SupabaseJWTAudience,
	)
	if err != nil {
		log.Fatalf("authentication verifier initialization failed: %v", err)
	}
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := authVerifier.Shutdown(shutdownCtx); err != nil {
			log.Printf("authentication verifier shutdown failed: %v", err)
		}
	}()

	r := gin.Default()

	// CORS middleware
	r.Use(middleware.BrowserCORS())

	// Public routes: health, the legacy upload endpoint, and Swagger remain
	// accessible without an access token during this milestone.
	routes.RegisterHealthRoutes(r, db)
	routes.RegisterVideoRoutes(r)
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Every route registered on this group receives a verified Supabase user
	// identity before its handler runs.
	protectedAPI := r.Group("/api")
	protectedAPI.Use(middleware.RequireAuth(authVerifier))
	routes.RegisterAuthRoutes(protectedAPI)
	// Python handles AI only; this protected Go route is the application entry point.
	routes.RegisterProcessingRoutes(protectedAPI, services.NewAIClient(cfg.AIServiceURL))

	log.Println("Server running on http://localhost:8080")
	log.Println("Swagger UI: http://localhost:8080/swagger/index.html")

	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
