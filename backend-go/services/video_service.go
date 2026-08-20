package services

import (
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"

	"project-backend/utils"
)

// SaveVideo saves an uploaded video file to the uploads directory.
// It validates the file extension and returns the saved filename.
func SaveVideo(fileHeader *multipart.FileHeader) (string, error) {
	originalName := fileHeader.Filename

	// Validate file extension
	if !utils.IsValidVideo(originalName) {
		return "", fmt.Errorf("unsupported file type: only mp4, mov, avi, mkv are allowed")
	}

	// Ensure uploads directory exists
	if err := os.MkdirAll(utils.UploadDir, 0755); err != nil {
		return "", fmt.Errorf("failed to create upload directory: %w", err)
	}

	// Generate a unique filename to avoid collisions
	videoID := utils.GenerateVideoID()
	ext := filepath.Ext(originalName)
	savedName := videoID + ext
	destPath := filepath.Join(utils.UploadDir, savedName)

	// Open the uploaded file
	src, err := fileHeader.Open()
	if err != nil {
		return "", fmt.Errorf("failed to open uploaded file: %w", err)
	}
	defer src.Close()

	// Create the destination file
	dst, err := os.Create(destPath)
	if err != nil {
		return "", fmt.Errorf("failed to create destination file: %w", err)
	}
	defer dst.Close()

	// Copy content
	buf := make([]byte, 32*1024)
	for {
		n, readErr := src.Read(buf)
		if n > 0 {
			if _, writeErr := dst.Write(buf[:n]); writeErr != nil {
				return "", fmt.Errorf("failed to write file: %w", writeErr)
			}
		}
		if readErr != nil {
			break
		}
	}

	return savedName, nil
}
