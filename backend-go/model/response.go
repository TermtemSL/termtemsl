package model

type PredictionData struct {
	Label      string  `json:"label"`
	Confidence float64 `json:"confidence"`
	Mode       string  `json:"mode"`
}

type VideoUploadData struct {
	VideoID           string         `json:"video_id"`
	Filename          string         `json:"filename"`
	FrameCount        int            `json:"frame_count"`
	LandmarksDetected bool           `json:"landmarks_detected"`
	CoordinatesFile   string         `json:"coordinates_file"`
	Prediction        PredictionData `json:"prediction"`
}

type VideoUploadResponse struct {
	Success bool             `json:"success"`
	Data    *VideoUploadData `json:"data,omitempty"`
	Message string           `json:"message"`
}