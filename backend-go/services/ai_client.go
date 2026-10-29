package services

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"mime/multipart"
	"net/http"
	"time"

	"project-backend/model"
)

var (
	ErrAIUnavailable   = errors.New("AI service unavailable")
	ErrAITimeout       = errors.New("AI processing timed out")
	ErrAIResponse      = errors.New("invalid AI service response")
	ErrVideoProcessing = errors.New("video could not be processed")
)

type AIClient struct {
	baseURL    string
	httpClient *http.Client
}

func NewAIClient(baseURL string) *AIClient {
	return &AIClient{baseURL: baseURL, httpClient: &http.Client{
		Timeout: 120 * time.Second,
		// Never forward uploaded video to a redirected destination.
		CheckRedirect: func(_ *http.Request, _ []*http.Request) error { return http.ErrUseLastResponse },
	}}
}

func (a *AIClient) ProcessVideo(ctx context.Context, filename string, video io.Reader) (*model.VideoUploadResponse, error) {
	// Translate Go's public "video" field to Python's existing "file" contract.
	var body bytes.Buffer
	writer := multipart.NewWriter(&body)
	part, err := writer.CreateFormFile("file", filename)
	if err != nil {
		return nil, ErrVideoProcessing
	}
	if _, err = io.Copy(part, video); err != nil {
		return nil, ErrVideoProcessing
	}
	if err = writer.Close(); err != nil {
		return nil, ErrVideoProcessing
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, a.baseURL+"/api/video/upload", &body)
	if err != nil {
		return nil, ErrAIUnavailable
	}
	request.Header.Set("Content-Type", writer.FormDataContentType())
	// Supabase tokens and database credentials are not forwarded to Python.
	response, err := a.httpClient.Do(request)
	if err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			return nil, ErrAITimeout
		}
		return nil, ErrAIUnavailable
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return nil, ErrAIUnavailable
	}
	const maxResponse = 1 << 20
	raw, err := io.ReadAll(io.LimitReader(response.Body, maxResponse+1))
	if err != nil || len(raw) > maxResponse {
		return nil, ErrAIResponse
	}
	var result model.VideoUploadResponse
	if json.Unmarshal(raw, &result) != nil {
		return nil, ErrAIResponse
	}
	// Python's legacy endpoint returns HTTP 200 even for processing failures.
	if !result.Success {
		return nil, ErrVideoProcessing
	}
	if result.Data == nil {
		return nil, ErrAIResponse
	}
	prediction := result.Data.Prediction
	if result.Data.FrameCount <= 0 || !result.Data.LandmarksDetected || prediction.Label == "" || prediction.Confidence < 0 || prediction.Confidence > 1 || (prediction.Mode != "model" && prediction.Mode != "mock") {
		return nil, ErrAIResponse
	}
	return &result, nil
}
