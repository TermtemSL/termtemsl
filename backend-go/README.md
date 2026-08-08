# Backend Go — TermtemSL

REST API backend for the Thai Sign Language AI project, written in Go (Gin framework).  
The database and AI model service are **not yet connected** — this service handles HTTP routing
and file utilities and is ready to be extended.

---

## Project Structure

```
backend-go/
├── main.go                  # Entry point; HTTP server on :8080
├── go.mod / go.sum          # Module: project-backend (Go 1.26.4)
├── model/
│   └── response.go          # Shared response structs
├── routes/
│   └── video_routes.go      # Video endpoint route stubs (in progress)
├── services/
│   └── video_service.go     # Video business logic stubs (in progress)
├── utils/
│   └── file_utils.go        # File helpers; defines uploads/ and outputs/ dirs
├── Dockerfile               # Multi-stage Docker build
├── .dockerignore
└── .env.example             # Placeholder env vars for future use
```

Runtime directories (`uploads/`, `outputs/`) are created automatically by the application
and mounted as named Docker volumes when running via Compose.

---

## API Endpoints

| Method | Path          | Description                  |
|--------|---------------|------------------------------|
| GET    | `/api/health` | Health check — returns `{ "message": "Go backend is running" }` |

---

## Running Locally (without Docker)

**Prerequisites:** Go 1.26.4+

```powershell
cd backend-go

# Download dependencies
go mod download

# Run the server
go run .
```

The server starts at **http://localhost:8080**.

---

## Docker

> All Docker Compose commands are run from the **project root** (`termtemsl/`),
> not from inside `backend-go/`.

### Build the image

```powershell
docker compose build
```

### Start the container

```powershell
docker compose up -d
```

### Rebuild after code changes

```powershell
docker compose build
docker compose up -d
```

Or in one step:

```powershell
docker compose up -d --build
```

### View logs

```powershell
docker compose logs -f backend-go
```

### Stop the container

```powershell
docker compose down
```

### Stop and wipe named volumes (uploads + outputs)

```powershell
docker compose down -v
```

---

## Testing the API

**PowerShell:**

```powershell
Invoke-RestMethod -Uri http://localhost:8080/api/health
```

Expected response:

```json
{ "message": "Go backend is running" }
```

**curl (Git Bash / WSL):**

```bash
curl http://localhost:8080/api/health
```

---

## Running Tests

```powershell
cd backend-go
go test ./...
```

> No test files exist yet. Output will be: `no test files` — this is expected.

---

## Backend Workflow

```
Flutter app
    │
    ▼ HTTP
Go Backend (:8080)
    │
    ├── /api/health          → healthcheck
    └── /api/video/*         → (in progress) video upload & sign language processing
              │
              ├── uploads/   → incoming video files (Docker named volume)
              └── outputs/   → processed results  (Docker named volume)
```

Future services (database, AI model) will be added as separate Docker Compose services.
