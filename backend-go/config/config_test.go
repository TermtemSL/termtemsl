package config

import "testing"

func setRequiredEnvironment(t *testing.T) {
	t.Helper()
	t.Setenv("DATABASE_URL", "postgresql://example")
	t.Setenv("SUPABASE_URL", "https://project-ref.supabase.co")
	t.Setenv("SUPABASE_JWT_ISSUER", "https://project-ref.supabase.co/auth/v1")
	t.Setenv("SUPABASE_JWT_AUDIENCE", "authenticated")
	t.Setenv("AI_SERVICE_URL", "")
}

func TestAIServiceURL(t *testing.T) {
	for _, origin := range []string{"", "http://ai-python:8000", "https://ai.example.com", "ftp://ai", "http://user:password@ai", "http://ai/path", "http://ai?token=secret"} {
		t.Run(origin, func(t *testing.T) {
			setRequiredEnvironment(t)
			t.Setenv("AI_SERVICE_URL", origin)
			cfg, err := Load()
			valid := origin == "" || origin == "http://ai-python:8000" || origin == "https://ai.example.com"
			if valid && err != nil {
				t.Fatal(err)
			}
			if !valid && err == nil {
				t.Fatal("accepted invalid AI origin")
			}
			if origin == "" && cfg.AIServiceURL != "http://127.0.0.1:8000" {
				t.Fatal("missing local default")
			}
		})
	}
}

func TestLoadSupabaseAuthConfiguration(t *testing.T) {
	setRequiredEnvironment(t)
	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}
	if cfg.SupabaseJWTAudience != "authenticated" {
		t.Fatalf("audience = %q, want authenticated", cfg.SupabaseJWTAudience)
	}
}

func TestLoadRejectsMismatchedIssuer(t *testing.T) {
	setRequiredEnvironment(t)
	t.Setenv("SUPABASE_JWT_ISSUER", "https://other-project.supabase.co/auth/v1")
	if _, err := Load(); err == nil {
		t.Fatal("Load() accepted an issuer from a different Supabase project")
	}
}
