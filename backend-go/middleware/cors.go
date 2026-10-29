package middleware

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// BrowserCORS allows the documented local Flutter web origin and bearer header.
func BrowserCORS() gin.HandlerFunc {
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:3000", "http://127.0.0.1:3000"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Authorization"}
	return cors.New(config)
}
