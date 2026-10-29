# TermtemSL API Backend

This is the Python AI service for TermtemSL. Go (`backend-go/`) is the main application
API. This service retains MediaPipe landmark extraction and Keras prediction.

## Run with Docker (Mac or Windows)

From the repository root, with Docker Desktop running:

```sh
docker compose up -d --build ai-python
docker compose ps ai-python
docker compose logs -f ai-python
```

The first build downloads Python and AI dependencies. No host Python installation
is needed. Only this service starts, so an existing Go server on port 8080 can stay running.

- Liveness: `http://localhost:8000/health`
- Python API documentation: `http://localhost:8000/docs`
- Go API documentation: `http://localhost:8080/swagger/index.html`

In Python's docs, execute `POST /api/video/upload`, choosing a short sign-language
video in the `file` field. Confirm `success: true`, a positive `frame_count`,
`landmarks_detected: true`, and `prediction.mode: model`. A random mock label is
not evidence of trained-model inference. Blank or unreadable videos should report
`success: false`; this legacy endpoint currently wraps processing errors in HTTP 200.

Compose defaults to real-model mode and copies `models/lstm_model.keras` and
`models/model_info.json` into the image. Missing model artifacts fail startup.
The JSON metadata supplies the Thai class names. Uploaded files and landmark JSON
are stored in separate Docker volumes, not in Supabase.

For an explicit mock smoke test, set `AI_PREDICTION_MODE=mock` in the root `.env`,
then recreate the service with the same Compose command. Restore `model` afterward.
Mock mode still performs MediaPipe extraction but returns random predictions.
No Supabase credentials are passed to Python.

Run automated container smoke checks from the repository root:

```sh
docker compose cp backend/smoke_test.py ai-python:/tmp/smoke_test.py
docker compose exec -e PYTHONPATH=/app/backend ai-python python /tmp/smoke_test.py
```

These check HTTP health/schema, model inference on synthetic coordinates, and
rejection of a generated blank video through MediaPipe. They do not measure sign
recognition accuracy; a real sign-language video still needs manual verification.

Verified on Apple Silicon: image build, dependency consistency (`pip check`),
container health, and all three smoke checks passed. A 60-frame excerpt of the
existing uploaded video decoded successfully but contained no detected landmarks,
so it was correctly rejected. Use a short clip with visible hands and upper body
for the next positive video test. Windows/AMD64 has not yet been tested.

```sh
docker compose stop ai-python
```

Go-to-Python forwarding and live-camera streaming are not implemented in this
milestone. Flutter still calls the original Python endpoint directly. Camera
capture belongs on the client; the container processes uploaded video/frames.

## Setup Instructions

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

2.  **Use Python 3.11 and create a virtual environment:**
    ```bash
    python -m venv venv
    venv\Scripts\activate  # On Windows
    # source venv/bin/activate  # On Linux/macOS
    ```

3.  **Install requirements:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Set up environment variables:**
    Copy `.env.example` to `.env` and configure it:
    ```bash
    cp .env.example .env
    ```

5.  **Run the application:**
    ```bash
    uvicorn app.main:app --reload
    ```

The API will be available at `http://127.0.0.1:8000`. You can test the endpoints at `http://127.0.0.1:8000/docs`.


# Project Structure

```text
Frontend (Flutter Web / Mobile)
        ↓ Upload Video
FastAPI Route Layer
        ↓
Video Service
        ↓
MediaPipe Service
        ↓
Extract Landmark Coordinates
        ↓
Save Landmark JSON
        ↓
Prediction Service
   ├── Mock Prediction Service
   └── Real Model Prediction Service
        ↓
Return Prediction Result
```



# Backend Workflow

1. User uploads a sign language video from the Flutter frontend.
2. FastAPI receives the uploaded video through API routes.
3. The Video Service saves and manages the uploaded file.
4. The MediaPipe Service processes the video frame-by-frame.
5. MediaPipe extracts:
   - Pose landmarks
   - Left hand landmarks
   - Right hand landmarks
6. Landmark coordinates are saved as JSON data.
7. The Prediction Service performs AI inference:
   - Mock prediction for testing
   - Real Keras model prediction (`PREDICTION_MODE=model`)
8. The backend returns the prediction result to the frontend.

# Main Components

## FastAPI Route Layer
Handles:
- API endpoints
- Video uploads
- Request validation
- Response formatting

Main file:
```text
app/routes/video_routes.py
```

---

## Video Service
Responsible for:
- Saving uploaded videos
- Managing processing workflow
- Connecting MediaPipe and prediction services

Main file:
```text
app/services/video_service.py
```

---

## MediaPipe Service
Uses MediaPipe Holistic for:
- Frame extraction
- Pose detection
- Hand landmark detection
- Coordinate extraction
- Landmark JSON generation

Main file:
```text
app/services/mediapipe_service.py
```

---

## Prediction Service
Handles AI prediction logic.

Includes:
- Mock prediction service
- Real model prediction service

Main files:
```text
app/services/mock_prediction_service.py
app/services/model_prediction_service.py
```
