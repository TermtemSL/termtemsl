package routes

import (
	"context"
	"errors"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
	"project-backend/middleware"
	"project-backend/model"
	"project-backend/services"
	"project-backend/utils"
)

type VideoProcessor interface {
	ProcessVideo(context.Context, string, io.Reader) (*model.VideoUploadResponse, error)
}

type ProcessingHandler struct{ processor VideoProcessor }

// Call only on the group protected by RequireAuth; legacy upload stays public.
func RegisterProcessingRoutes(group *gin.RouterGroup, processor VideoProcessor) {
	handler := &ProcessingHandler{processor: processor}
	group.POST("/videos/process", handler.ProcessVideo)
}

// ProcessVideo godoc
// @Summary Process a sign-language video
// @Description Sends a video to Python for MediaPipe extraction and existing model inference. Mock mode is identified explicitly. Does not change the trained model.
// @Tags Videos
// @Accept multipart/form-data
// @Produce json
// @Security BearerAuth
// @Param video formData file true "Short sign-language video (mp4, mov, avi, mkv), maximum 32 MiB"
// @Success 200 {object} model.VideoUploadResponse
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 413 {object} map[string]string
// @Failure 422 {object} map[string]string
// @Failure 502 {object} map[string]string
// @Failure 504 {object} map[string]string
// @Router /api/videos/process [post]
func (h *ProcessingHandler) ProcessVideo(c *gin.Context) {
	if _, ok := middleware.UserIDFromContext(c); !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}
	const maxVideo = 32 << 20
	// Bound multipart parsing and remove any temporary files after the request.
	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, maxVideo+(1<<20))
	err := c.Request.ParseMultipartForm(4 << 20)
	if c.Request.MultipartForm != nil {
		defer c.Request.MultipartForm.RemoveAll()
	}
	if err != nil {
		var tooLarge *http.MaxBytesError
		if errors.As(err, &tooLarge) {
			c.JSON(413, gin.H{"error": "video exceeds upload limit"})
		} else {
			c.JSON(400, gin.H{"error": "invalid multipart video upload"})
		}
		return
	}
	file, err := c.FormFile("video")
	if err != nil {
		c.JSON(400, gin.H{"error": "provide a video in field 'video'"})
		return
	}
	if file.Size > maxVideo {
		c.JSON(413, gin.H{"error": "video exceeds 32 MiB"})
		return
	}
	if file.Size == 0 || !utils.IsValidVideo(file.Filename) {
		c.JSON(400, gin.H{"error": "provide a nonempty mp4, mov, avi, or mkv video"})
		return
	}
	source, err := file.Open()
	if err != nil {
		c.JSON(400, gin.H{"error": "could not read uploaded video"})
		return
	}
	defer source.Close()
	result, err := h.processor.ProcessVideo(c.Request.Context(), file.Filename, source)
	if err != nil {
		status, message := http.StatusBadGateway, "AI service unavailable or returned an invalid result"
		if errors.Is(err, services.ErrAITimeout) {
			status, message = 504, "AI processing timed out; try a shorter clip"
		}
		if errors.Is(err, services.ErrVideoProcessing) {
			status, message = 422, "video could not be processed; use a readable clip with visible hands and upper body"
		}
		c.JSON(status, gin.H{"error": message})
		return
	}
	c.JSON(http.StatusOK, result)
}
