# TermtemSL API Backend

This is the FastAPI backend for the TermtemSL Thai Sign Language AI project.

## Setup Instructions

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

2.  **Create a virtual environment (optional but recommended):**
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

The API will be available at `http://127.0.0.from1:8000`. You can test the endpoints at `http://127.0.0.1:8000/docs`.


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
   - Real AI model prediction (future implementation)
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
