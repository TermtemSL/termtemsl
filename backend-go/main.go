package main

import (
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"project-backend/config"
	"project-backend/database"
	_ "project-backend/docs"
	"project-backend/routes"
)

// @title TermtemSL Backend API
// @version 1.0
// @description Backend API for TermtemSL Sign Language Application
// @host localhost:8080
// @BasePath /
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

	r := gin.Default()

	// CORS middleware
	r.Use(cors.Default())

	// Health route
	routes.RegisterHealthRoutes(r, db)

	// Video routes (placeholder for next step)
	routes.RegisterVideoRoutes(r)

	// Swagger UI
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	log.Println("Server running on http://localhost:8080")
	log.Println("Swagger UI: http://localhost:8080/swagger/index.html")

	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal(err)
	}
}
