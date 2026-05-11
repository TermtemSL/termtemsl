import os
from fastapi import UploadFile
from dotenv import load_dotenv

from ..utils.file_utils import generate_video_id, save_upload_file
from .mediapipe_service import MediaPipeService
from .mock_prediction_service import MockPredictionService
from .model_prediction_service import ModelPredictionService
from ..schemas.response_schema import VideoUploadData, PredictionData

load_dotenv()
# Control everything on workflow (orchestrator)
class VideoService:
    def __init__(self):
        self.mediapipe_service = MediaPipeService()
        
        mode = os.getenv("PREDICTION_MODE", "mock").lower()
        if mode == "model":
            model_path = os.getenv("MODEL_PATH", "models/model.pth")
            self.prediction_service = ModelPredictionService(model_path)
        else:
            self.prediction_service = MockPredictionService()

    def process_video(self, upload_file: UploadFile) -> VideoUploadData:
        video_id = generate_video_id()
        
        # 1. Save uploaded file (uploads folder)
        filepath = save_upload_file(upload_file, video_id)
        
        try:
            # 2. Extract landmarks using MediaPipe
            frame_count, landmarks_detected, coordinates_file = self.mediapipe_service.extract_landmarks(filepath, video_id)
            
            # 3. Get prediction
            # We pass coordinates_file to the prediction service
            prediction_result = self.prediction_service.predict(coordinates_file)
            
            prediction_data = PredictionData(**prediction_result)
            
            # 4. Construct response data
            return VideoUploadData(
                video_id=video_id,
                filename=upload_file.filename,
                frame_count=frame_count,
                landmarks_detected=landmarks_detected,
                coordinates_file=coordinates_file,
                prediction=prediction_data
            )
        finally:
            pass
