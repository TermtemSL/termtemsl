package config

import "testing"

func setRequiredEnvironment(t *testing.T) {
	t.Helper()
	t.Setenv("DATABASE_URL", "postgresql://example")
	t.Setenv("SUPABASE_URL", "https://project-ref.supabase.co")
	t.Setenv("SUPABASE_JWT_ISSUER", "https://project-ref.supabase.co/auth/v1")
	t.Setenv("SUPABASE_JWT_AUDIENCE", "authenticated")
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
