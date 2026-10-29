from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import video_routes

app = FastAPI(
    title="TermtemSL API Backend",
    description="Backend API for Thai Sign Language AI",
    version="1.0.0"
)

# Enable CORS for local Flutter development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Include routes (For testing /api/video/upload)
app.include_router(video_routes.router, prefix="/api/video", tags=["video"])

# Separate liveness check for Docker; model mode loads its model at startup.
@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/")
def read_root():
    return {"message": "Welcome to TermtemSL API Backend"}
