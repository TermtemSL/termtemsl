import cv2
import mediapipe as mp
import json
import os
from typing import Tuple, Dict, Any

mp_holistic = mp.solutions.holistic

class MediaPipeService:
    def __init__(self):
        self.output_dir = "outputs"
        os.makedirs(self.output_dir, exist_ok=True)

    def extract_landmarks(self, video_path: str, video_id: str) -> Tuple[int, bool, str]:
        """
        Process video, extract landmarks, and save to JSON.
        Returns: (frame_count, landmarks_detected, coordinates_file_path)
        """
        # Use OpenCV read the video
        cap = cv2.VideoCapture(video_path)
        if not cap.isOpened():
            return 0, False, ""

        frame_count = 0
        landmarks_data = []
        landmarks_detected = False

        with mp_holistic.Holistic(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        ) as holistic:
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                
                frame_count += 1
                
                # Convert BGR to RGB
                image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                image.flags.writeable = False
                
                # Make prediction
                results = holistic.process(image)
                
                frame_data = {"frame": frame_count}
                
                # Pose landmarks
                if results.pose_landmarks:
                    landmarks_detected = True
                    frame_data["pose"] = [{"x": lm.x, "y": lm.y, "z": lm.z, "visibility": lm.visibility} for lm in results.pose_landmarks.landmark]
                
                # Left hand landmarks
                if results.left_hand_landmarks:
                    landmarks_detected = True
                    frame_data["left_hand"] = [{"x": lm.x, "y": lm.y, "z": lm.z} for lm in results.left_hand_landmarks.landmark]
                
                # Right hand landmarks
                if results.right_hand_landmarks:
                    landmarks_detected = True
                    frame_data["right_hand"] = [{"x": lm.x, "y": lm.y, "z": lm.z} for lm in results.right_hand_landmarks.landmark]
                
                landmarks_data.append(frame_data)

        cap.release()

        # Save to JSON
        output_filename = f"{video_id}.json"
        output_filepath = os.path.join(self.output_dir, output_filename)
        
        with open(output_filepath, "w") as f:
            json.dump(landmarks_data, f)

        return frame_count, landmarks_detected, output_filepath
