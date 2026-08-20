package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"project-backend/services"
)

// RegisterVideoRoutes attaches video-related routes to the router.
func RegisterVideoRoutes(r *gin.Engine) {
	api := r.Group("/api/videos")
	{
		api.POST("/upload", UploadVideo)
	}
}

// UploadVideo godoc
// @Summary      Upload a video file
// @Description  Accepts a multipart/form-data video upload and saves it to disk
// @Tags         Videos
// @Accept       multipart/form-data
// @Produce      json
// @Param        video  formData  file  true  "Video file to upload (mp4, mov, avi, mkv)"
// @Success      200    {object}  map[string]string  "video uploaded successfully"
// @Failure      400    {object}  map[string]string  "bad request - no file or invalid type"
// @Failure      500    {object}  map[string]string  "internal server error"
// @Router       /api/videos/upload [post]
func UploadVideo(c *gin.Context) {
	// Retrieve the uploaded file
	fileHeader, err := c.FormFile("video")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "no video file provided; use field name 'video'",
		})
		return
	}

	// Delegate saving to the service
	savedName, err := services.SaveVideo(fileHeader)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "video uploaded successfully",
		"filename": savedName,
	})
}
