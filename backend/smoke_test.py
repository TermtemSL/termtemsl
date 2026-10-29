"""Run inside the AI container: verifies startup, model inference, and bad video input."""
import json
import os
import tempfile
import unittest
import urllib.request

import cv2
import numpy as np

from app.services.model_prediction_service import ModelPredictionService


class AISmokeTest(unittest.TestCase):
    def test_health_and_upload_schema(self):
        with urllib.request.urlopen("http://127.0.0.1:8000/health") as response:
            self.assertEqual(json.load(response), {"status": "ok"})
        with urllib.request.urlopen("http://127.0.0.1:8000/openapi.json") as response:
            self.assertIn("/api/video/upload", json.load(response)["paths"])

    def test_real_model_inference(self):
        # Synthetic coordinates verify wiring and tensor shape, not sign accuracy.
        service = ModelPredictionService(os.environ["MODEL_PATH"])
        frames = [{"left_hand": [{"x": i / 60, "y": 0.2, "z": 0.0}] * 21}
                  for i in range(60)]
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json") as coordinates:
            json.dump(frames, coordinates)
            coordinates.flush()
            result = service.predict(coordinates.name)
        self.assertEqual(result["mode"], "model")
        self.assertIn(result["label"], service.class_names)
        self.assertTrue(0 <= result["confidence"] <= 1)

    def test_blank_video_is_not_a_translation(self):
        # Exercise decoding and MediaPipe through the real HTTP upload endpoint.
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "blank.mp4")
            writer = cv2.VideoWriter(path, cv2.VideoWriter_fourcc(*"mp4v"), 10, (128, 128))
            self.assertTrue(writer.isOpened())
            for _ in range(5):
                writer.write(np.zeros((128, 128, 3), dtype=np.uint8))
            writer.release()
            with open(path, "rb") as video:
                payload = video.read()
        boundary = "termtem-smoke-boundary"
        body = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"file\"; "
                'filename="blank.mp4"\r\nContent-Type: video/mp4\r\n\r\n').encode()
        body += payload + f"\r\n--{boundary}--\r\n".encode()
        request = urllib.request.Request(
            "http://127.0.0.1:8000/api/video/upload", data=body,
            headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
        )
        with urllib.request.urlopen(request, timeout=60) as response:
            result = json.load(response)
        self.assertFalse(result["success"])
        self.assertIn("No pose or hand landmarks", result["message"])


if __name__ == "__main__":
    unittest.main()
