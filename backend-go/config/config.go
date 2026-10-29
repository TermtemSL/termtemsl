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
}

func Load() (Config, error) {
	cfg := Config{
		Port:                getEnv("PORT", "8080"),
		DatabaseURL:         os.Getenv("DATABASE_URL"),
		SupabaseURL:         os.Getenv("SUPABASE_URL"),
		SupabaseJWTIssuer:   os.Getenv("SUPABASE_JWT_ISSUER"),
		SupabaseJWTAudience: os.Getenv("SUPABASE_JWT_AUDIENCE"),
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

	return cfg, nil
}

func getEnv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	return value
}
