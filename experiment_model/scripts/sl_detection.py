from os.path import exists
import json
import os
import cv2
import numpy as np
import urllib.request
from flask import Flask, flash, request, redirect, url_for, render_template
from werkzeug.utils import secure_filename
import flask_cors
from statistics import mode
import mediapipe as mp
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from tensorflow.keras.callbacks import TensorBoard
from scipy import stats
from flask_cors import CORS
import datetime



app = Flask(__name__)
CORS(app)


@app.route('/', methods=['POST','GET'])
def detect():
	token = json.loads(request.data)

	# parentdir = "D:\\MySL_Model\\Model\\flask_for_model_test"
	parentdir = "C:\\CPE\\model"
	name_words_path = os.path.join(parentdir,'word_name', token['catid'], token['lessonid'])
	model_name = os.path.join(parentdir, 'model', token['catid'] +'_'+ token['lessonid']+'.h5')
	# model_name = os.path.join(parentdir, 'model', 'general_3(1).h5')
	video = os.path.join(parentdir, 'clip', token["userid"]+".mp4")
	# video = os.path.join(parentdir, 'clip', '375107'+".mp4")

	checkfile = exists(video)
	

	mp_holistic = mp.solutions.holistic
	mp_drawing = mp.solutions.drawing_utils

	def mediapipe_detection(image, model):
		image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB) 
		image.flags.writeable = False                 
		results = model.process(image)                 
		image.flags.writeable = True                    
		image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR) 
		return image, results

	def draw_landmarks(image, results):
		mp_drawing.draw_landmarks(image, results.face_landmarks, mp_holistic.FACEMESH_TESSELATION,
                              mp_drawing.DrawingSpec(thickness=1, circle_radius=1), 
                              mp_drawing.DrawingSpec(thickness=1, circle_radius=1)) 
		mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS) 
		mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS) 
		mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS)

	def extract_keypoints(results):
		pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(33*4)
		face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten() if results.face_landmarks else np.zeros(468*3)
		lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten() if results.left_hand_landmarks else np.zeros(21*3)
		rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten() if results.right_hand_landmarks else np.zeros(21*3)
		return np.concatenate([pose, face, lh, rh])

	def get_length(data):
		# count the number of frames
		frames = data.get(cv2.CAP_PROP_FRAME_COUNT)
		fps = int(data.get(cv2.CAP_PROP_FPS))

		# calculate dusration of the video
		seconds = int(frames / fps)
		# print("duration in seconds:", seconds)
		return seconds

	if checkfile:

		name_words = np.array(os.listdir(name_words_path))

		model = Sequential()
		model.add(LSTM(64, return_sequences=True, activation='relu', input_shape=(30,1662)))
		model.add(LSTM(128, return_sequences=True, activation='relu'))
		model.add(LSTM(64, return_sequences=False, activation='relu'))
		model.add(Dense(64, activation='relu'))
		model.add(Dense(32, activation='relu'))
		model.add(Dense(len(name_words), activation='softmax'))

		model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=['categorical_accuracy'])
		model.load_weights(model_name)

		array_post = []
		all_frame = []
		all_result = []
		ans = "null"

		cap = cv2.VideoCapture(video)
		if (cap.isOpened()== False): 
			print('Error')
		else:
			len_video = get_length(cap)
		with mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holistic:
			
			while(cap.isOpened()):
				# Read feed
				ret, frame = cap.read()
				if(ret == False):
					break
					
				# Make detections
				image, results = mediapipe_detection(frame, holistic)
				
				# Draw landmarks
				draw_landmarks(image, results) 

				tmp = extract_keypoints(results)
				all_frame.append(tmp)
				array_post.append(tmp)
				array_post = array_post[-30:]

				if(len(all_frame)>30):
					cv2.imshow('OpenCV Feed', image)
					print(len(all_frame))

				if(len(all_frame) > 70):
					break
				
				tmp = None
				if(len(array_post) == 30 and (len(all_frame)>60)):
					res = model.predict(np.expand_dims(array_post, axis=0))[0]
					print('res',res)

					for i in range(len(name_words)):
							if(res[i]>0.7):
								tmp = i
					all_result.append(tmp)
					
				
				# Break gracefully
				if cv2.waitKey(10) & 0xFF == ord('q') & False:
					break

			cap.release()
			cv2.destroyAllWindows()

		try:
			ans = name_words[mode(all_result)]
		except:
			ans = 'no result'

		# os.remove(video)
		lines = [name_words_path,model_name]
		with open(os.path.join(parentdir,'readme.txt'), 'w') as f:
			for line in lines:
				f.write(line)
				f.write('\n')

		return {'ans': ans, 'all_result': len(all_frame), 'len_video':len_video}

	else:
		return {"no file":True}

if __name__ == "__main__":
    app.run(debug=True)

flask_cors.CORS(app, expose_headers='Authorization')