# Root build context includes the trained model shared with the Python service.
FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# OpenCV/MediaPipe need these shared libraries even without a desktop UI.
RUN apt-get update && apt-get install -y --no-install-recommends libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend
COPY backend/requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

COPY backend/app ./app
COPY models/lstm_model.keras models/model_info.json /app/models/

# Keep uploaded videos and landmark output writable without running as root.
RUN useradd --create-home ai && mkdir -p uploads outputs \
    && chown -R ai:ai /app
USER ai
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
