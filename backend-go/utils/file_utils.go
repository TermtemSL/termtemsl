package utils

import (
	"path/filepath"
	"strings"

	"github.com/google/uuid"
)

const UploadDir = "uploads"
const OutputDir = "outputs"

func GenerateVideoID() string {
	return uuid.New().String()
}

func IsValidVideo(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))

	validExtensions := map[string]bool{
		".mp4": true,
		".mov": true,
		".avi": true,
		".mkv": true,
	}

	return validExtensions[ext]
}