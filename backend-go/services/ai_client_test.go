package services

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestAIClientTimeoutAndCancellation(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { time.Sleep(30 * time.Millisecond) }))
	defer server.Close()
	client := NewAIClient(server.URL)
	client.httpClient.Timeout = time.Millisecond
	_, err := client.ProcessVideo(context.Background(), "clip.mp4", strings.NewReader("video"))
	if !errors.Is(err, ErrAITimeout) {
		t.Fatalf("error = %v", err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	_, err = client.ProcessVideo(ctx, "clip.mp4", strings.NewReader("video"))
	if !errors.Is(err, ErrAIUnavailable) {
		t.Fatalf("cancel error = %v", err)
	}
}
