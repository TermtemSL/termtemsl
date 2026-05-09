from .prediction_service import PredictionService
from typing import Dict, Any
import random

class MockPredictionService(PredictionService):
    def predict(self, landmarks_file: str) -> Dict[str, Any]:
        # Return a mock prediction
        mock_signs = ["hello", "thank you", "yes", "no", "love"]
        return {
            "label": random.choice(mock_signs),
            "confidence": round(random.uniform(0.7, 0.99), 2),
            "mode": "mock"
        }
