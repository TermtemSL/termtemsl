from abc import ABC, abstractmethod
from typing import Dict, Any

class PredictionService(ABC):
    @abstractmethod
    def predict(self, landmarks_file: str) -> Dict[str, Any]:
        """
        Takes the path to the extracted landmarks JSON file and returns a prediction dictionary.
        Format: {"label": str, "confidence": float, "mode": str}
        """
        pass
