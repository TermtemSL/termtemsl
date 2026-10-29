package model

// MeResponse is the authenticated identity returned by GET /api/me.
type MeResponse struct {
	ID string `json:"id" example:"550e8400-e29b-41d4-a716-446655440000" format:"uuid"`
}
