package model

type DatabaseHealthResponse struct {
	Status   string `json:"status" example:"ok"`
	Database string `json:"database" example:"connected"`
}
