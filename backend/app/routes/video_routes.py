from fastapi import APIRouter, UploadFile, File, HTTPException
from ..schemas.response_schema import VideoUploadResponse
from ..services.video_service import VideoService
from ..utils.file_utils import is_valid_video

router = APIRouter()
video_service = VideoService()
# Send to VideoService
@router.post("/upload", response_model=VideoUploadResponse)
async def upload_video(file: UploadFile = File(...)):
    if not is_valid_video(file.filename):
        return VideoUploadResponse(
            success=False,
            message="Invalid file type. Please upload a valid video file (.mp4, .mov, .avi, .mkv)."
        )

    try:
        data = video_service.process_video(file)
        return VideoUploadResponse(
            success=True,
            data=data,
            message="Video processed successfully"
        )
    except Exception as e:
        return VideoUploadResponse(
            success=False,
            message=f"An error occurred during video processing: {str(e)}"
        )
