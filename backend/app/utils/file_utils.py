import os
import uuid
import shutil
from fastapi import UploadFile

UPLOAD_DIR = "uploads"
OUTPUT_DIR = "outputs"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_video_id() -> str:
    return str(uuid.uuid4())

def save_upload_file(upload_file: UploadFile, video_id: str) -> str:
    extension = os.path.splitext(upload_file.filename)[1]
    filename = f"{video_id}{extension}"
    filepath = os.path.join(UPLOAD_DIR, filename)
    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(upload_file.file, buffer)
    return filepath

def is_valid_video(filename: str) -> bool:
    valid_extensions = {".mp4", ".mov", ".avi", ".mkv"}
    extension = os.path.splitext(filename)[1].lower()
    return extension in valid_extensions
