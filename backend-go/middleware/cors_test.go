package middleware

import (
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestBrowserUploadPreflight(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	router.Use(BrowserCORS())
	router.POST("/api/videos/process", func(c *gin.Context) { c.Status(200) })
	for _, origin := range []string{"http://localhost:3000", "http://127.0.0.1:3000", "https://untrusted.example"} {
		request := httptest.NewRequest("OPTIONS", "/api/videos/process", nil)
		request.Header.Set("Origin", origin)
		request.Header.Set("Access-Control-Request-Method", "POST")
		request.Header.Set("Access-Control-Request-Headers", "authorization,content-type")
		response := httptest.NewRecorder()
		router.ServeHTTP(response, request)
		if origin == "https://untrusted.example" {
			if response.Code != 403 {
				t.Fatalf("untrusted origin status = %d", response.Code)
			}
			continue
		}
		if response.Code != 204 || response.Header().Get("Access-Control-Allow-Origin") != origin || !strings.Contains(response.Header().Get("Access-Control-Allow-Headers"), "Authorization") {
			t.Fatalf("preflight failed: %d %v", response.Code, response.Header())
		}
	}
}
