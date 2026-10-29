package routes

import (
	"encoding/json"
	"testing"

	"project-backend/docs"
)

func TestSwaggerBearerSecurity(t *testing.T) {
	var spec struct {
		SecurityDefinitions map[string]struct {
			Type string `json:"type"`
			Name string `json:"name"`
			In   string `json:"in"`
		} `json:"securityDefinitions"`
		Paths map[string]struct {
			Get struct {
				Security []map[string][]string `json:"security"`
			} `json:"get"`
		} `json:"paths"`
	}

	if err := json.Unmarshal([]byte(docs.SwaggerInfo.ReadDoc()), &spec); err != nil {
		t.Fatalf("parse generated Swagger document: %v", err)
	}

	bearer, ok := spec.SecurityDefinitions["BearerAuth"]
	if !ok {
		t.Fatal("Swagger is missing the BearerAuth security definition")
	}
	if bearer.Type != "apiKey" || bearer.Name != "Authorization" || bearer.In != "header" {
		t.Fatalf("BearerAuth = %+v, want apiKey Authorization header", bearer)
	}

	meSecurity := spec.Paths["/api/me"].Get.Security
	if len(meSecurity) != 1 {
		t.Fatalf("/api/me security = %#v, want one BearerAuth requirement", meSecurity)
	}
	if _, ok := meSecurity[0]["BearerAuth"]; !ok {
		t.Fatalf("/api/me security = %#v, want BearerAuth", meSecurity)
	}

	if healthSecurity := spec.Paths["/health"].Get.Security; len(healthSecurity) != 0 {
		t.Fatalf("/health unexpectedly requires authentication: %#v", healthSecurity)
	}
}
