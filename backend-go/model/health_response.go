package model

// HealthResponse represents the health status of the API.
type HealthResponse struct {
	Status string `json:"status" example:"ok"`
}