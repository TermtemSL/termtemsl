package config

import (
	"fmt"
	"net/url"
	"os"
	"strings"
)

type Config struct {
	Port                string
	DatabaseURL         string
	SupabaseURL         string
	SupabaseJWTIssuer   string
	SupabaseJWTAudience string
	AIServiceURL        string
}

func Load() (Config, error) {
	cfg := Config{
		Port:                getEnv("PORT", "8080"),
		DatabaseURL:         os.Getenv("DATABASE_URL"),
		SupabaseURL:         os.Getenv("SUPABASE_URL"),
		SupabaseJWTIssuer:   os.Getenv("SUPABASE_JWT_ISSUER"),
		SupabaseJWTAudience: os.Getenv("SUPABASE_JWT_AUDIENCE"),
		AIServiceURL:        strings.TrimRight(getEnv("AI_SERVICE_URL", "http://127.0.0.1:8000"), "/"),
	}

	switch {
	case cfg.DatabaseURL == "":
		return Config{}, fmt.Errorf("DATABASE_URL is required")
	case cfg.SupabaseURL == "":
		return Config{}, fmt.Errorf("SUPABASE_URL is required")
	case cfg.SupabaseJWTIssuer == "":
		return Config{}, fmt.Errorf("SUPABASE_JWT_ISSUER is required")
	case cfg.SupabaseJWTAudience == "":
		return Config{}, fmt.Errorf("SUPABASE_JWT_AUDIENCE is required")
	}

	cfg.SupabaseURL = strings.TrimRight(cfg.SupabaseURL, "/")
	cfg.SupabaseJWTIssuer = strings.TrimRight(cfg.SupabaseJWTIssuer, "/")
	projectURL, err := url.Parse(cfg.SupabaseURL)
	if err != nil || projectURL.Scheme != "https" || projectURL.Host == "" {
		return Config{}, fmt.Errorf("SUPABASE_URL must be a valid HTTPS URL")
	}
	if expected := cfg.SupabaseURL + "/auth/v1"; cfg.SupabaseJWTIssuer != expected {
		return Config{}, fmt.Errorf("SUPABASE_JWT_ISSUER must equal %s", expected)
	}

	// Local development uses loopback; Compose uses the ai-python service name.
	aiURL, err := url.Parse(cfg.AIServiceURL)
	if err != nil || (aiURL.Scheme != "http" && aiURL.Scheme != "https") || aiURL.Host == "" || aiURL.User != nil || aiURL.RawQuery != "" || aiURL.Fragment != "" || aiURL.Path != "" {
		return Config{}, fmt.Errorf("AI_SERVICE_URL must be an HTTP(S) origin without credentials, path, query, or fragment")
	}

	return cfg, nil
}

func getEnv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	return value
}
