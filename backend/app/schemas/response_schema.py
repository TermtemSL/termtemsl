from pydantic import BaseModel
from typing import Optional

class PredictionData(BaseModel):
    label: str
    confidence: float
    mode: str

class VideoUploadData(BaseModel):
    video_id: str
    filename: str
    frame_count: int
    landmarks_detected: bool
    coordinates_file: str
    prediction: PredictionData

class VideoUploadResponse(BaseModel):
    success: bool
    data: Optional[VideoUploadData] = None
    message: str
