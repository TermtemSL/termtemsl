package routes

import (
	"bytes"
	"encoding/json"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"project-backend/auth"
	"project-backend/middleware"
	"project-backend/services"
)

func TestProcessingWithLivePython(t *testing.T) {
	// Opt-in smoke test: real Python/model, deterministic local auth fixture.
	origin, path := os.Getenv("TERMTEM_AI_TEST_URL"), os.Getenv("TERMTEM_AI_TEST_VIDEO")
	if origin == "" || path == "" {
		t.Skip("set TERMTEM_AI_TEST_URL and TERMTEM_AI_TEST_VIDEO for live AI check")
	}
	video, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	gin.SetMode(gin.TestMode)
	router := gin.New()
	group := router.Group("/api")
	group.Use(middleware.RequireAuth(routeVerifier{identity: auth.Identity{UserID: uuid.New()}}))
	RegisterProcessingRoutes(group, services.NewAIClient(origin))
	var body bytes.Buffer
	writer := multipart.NewWriter(&body)
	part, err := writer.CreateFormFile("video", filepath.Base(path))
	if err != nil {
		t.Fatal(err)
	}
	part.Write(video)
	writer.Close()
	request := httptest.NewRequest("POST", "/api/videos/process", &body)
	request.Header.Set("Content-Type", writer.FormDataContentType())
	request.Header.Set("Authorization", "Bearer local-test-fixture")
	response := httptest.NewRecorder()
	router.ServeHTTP(response, request)
	if response.Code != 200 {
		t.Fatalf("live processing status %d: %s", response.Code, response.Body.String())
	}
	var result struct {
		Success bool `json:"success"`
		Data    struct {
			FrameCount int `json:"frame_count"`
			Prediction struct {
				Mode string `json:"mode"`
			} `json:"prediction"`
		} `json:"data"`
	}
	if err := json.Unmarshal(response.Body.Bytes(), &result); err != nil {
		t.Fatal(err)
	}
	if !result.Success || result.Data.FrameCount <= 0 || result.Data.Prediction.Mode != "model" {
		t.Fatalf("unexpected real-model response: %s", response.Body.String())
	}
}

func TestVideoProcessingThroughGo(t *testing.T) {
	for _, tc := range []struct {
		name, token, filename, upstream string
		status, want                    int
	}{
		{"success", "Bearer test", "ขอโทษ.mp4", `{"success":true,"data":{"video_id":"example","filename":"ขอโทษ.mp4","frame_count":64,"landmarks_detected":true,"prediction":{"label":"ขอโทษ","confidence":0.8,"mode":"model"}},"message":"Video processed successfully"}`, 200, 200},
		{"missing auth", "", "clip.mp4", `{}`, 200, 401},
		{"wrong bearer format", "test", "clip.mp4", `{}`, 200, 401},
		{"invalid extension", "Bearer test", "clip.txt", `{}`, 200, 400},
		{"upstream processing failure", "Bearer test", "clip.mp4", `{"success":false,"message":"private internal details"}`, 200, 422},
		{"upstream down", "Bearer test", "clip.mp4", `private details`, 503, 502},
		{"malformed json", "Bearer test", "clip.mp4", `invalid`, 200, 502},
		{"missing data", "Bearer test", "clip.mp4", `{"success":true}`, 200, 502},
		{"model error", "Bearer test", "clip.mp4", `{"success":true,"data":{"frame_count":64,"landmarks_detected":true,"prediction":{"label":"prediction_error","mode":"model_error"}}}`, 200, 502},
	} {
		t.Run(tc.name, func(t *testing.T) {
			calls := 0
			upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				calls++
				if r.URL.Path != "/api/video/upload" {
					t.Errorf("unexpected path %s", r.URL.Path)
				}
				if r.Header.Get("Authorization") != "" {
					t.Error("user token leaked to Python")
				}
				f, h, err := r.FormFile("file")
				if err != nil {
					t.Error(err)
					return
				}
				defer f.Close()
				if h.Filename != tc.filename {
					t.Errorf("filename = %s", h.Filename)
				}
				w.WriteHeader(tc.status)
				w.Write([]byte(tc.upstream))
			}))
			defer upstream.Close()
			gin.SetMode(gin.TestMode)
			router := gin.New()
			group := router.Group("/api")
			group.Use(middleware.RequireAuth(routeVerifier{identity: auth.Identity{UserID: uuid.New()}}))
			RegisterProcessingRoutes(group, services.NewAIClient(upstream.URL))
			var body bytes.Buffer
			writer := multipart.NewWriter(&body)
			part, _ := writer.CreateFormFile("video", tc.filename)
			part.Write([]byte("video-bytes"))
			writer.Close()
			request := httptest.NewRequest("POST", "/api/videos/process", &body)
			request.Header.Set("Content-Type", writer.FormDataContentType())
			request.Header.Set("Authorization", tc.token)
			response := httptest.NewRecorder()
			router.ServeHTTP(response, request)
			if response.Code != tc.want {
				t.Fatalf("status %d: %s; want %d", response.Code, response.Body.String(), tc.want)
			}
			if tc.want == 200 {
				var result map[string]any
				if json.Unmarshal(response.Body.Bytes(), &result) != nil || result["success"] != true {
					t.Fatal(response.Body.String())
				}
			}
			if tc.want == 401 || tc.want == 400 {
				if calls != 0 {
					t.Fatal("rejected request reached Python")
				}
			}
		})
	}
}

func TestProcessingRequiresVideoAndBoundsRequest(t *testing.T) {
	gin.SetMode(gin.TestMode)
	router := gin.New()
	group := router.Group("/api")
	group.Use(middleware.RequireAuth(routeVerifier{identity: auth.Identity{UserID: uuid.New()}}))
	RegisterProcessingRoutes(group, services.NewAIClient("http://127.0.0.1:1"))
	for _, size := range []int{0, 33<<20 + 1} {
		var body bytes.Buffer
		writer := multipart.NewWriter(&body)
		if size > 0 {
			part, _ := writer.CreateFormFile("video", "large.mp4")
			part.Write(make([]byte, size))
		}
		writer.Close()
		request := httptest.NewRequest("POST", "/api/videos/process", &body)
		request.Header.Set("Content-Type", writer.FormDataContentType())
		request.Header.Set("Authorization", "Bearer test")
		response := httptest.NewRecorder()
		router.ServeHTTP(response, request)
		want := 400
		if size > 0 {
			want = 413
		}
		if response.Code != want {
			t.Fatalf("status %d, want %d", response.Code, want)
		}
	}
}
