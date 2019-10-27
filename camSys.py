import cv2
import sys
import time
from google.cloud import vision
from google.cloud.vision import types
from PIL import Image, ImageDraw
from pudb import set_trace; 
from google.protobuf.json_format import MessageToJson
from scipy.spatial import distance
import threading 
from firebase_admin import credentials
from firebase_admin import db
import firebase_admin

client = vision.ImageAnnotatorClient()


def updateDistance(res,lastDistance):
	dst = 0
	xCord = res.position.x
	yCord = res.position.y
	zCord = res.position.z
	if lastDistance is None:
		lastDistance = {'x': xCord, 'y': yCord, 'z': zCord}
	else:
		a = (lastDistance['x'], lastDistance['y'], lastDistance['z'])
		b = (xCord,yCord,zCord)
		delta = distance.euclidean(a, b)
		lastDistance = {'x': xCord, 'y': yCord, 'z': zCord}
		result = abs(delta-dst)
		if result < 20:
			result = 20
		if result > 100:
			result = 100
		upLoadtoFireBase(result)
		dst = delta
	return lastDistance , dst





def getMachineInfo(face_file):
	with open (face_file, 'rb') as image:
		faceInfo = image.read()
		gcpImg = types.Image(content=faceInfo)
		response = client.face_detection(image=gcpImg,max_results=1)
		faces = response.face_annotations
		return faces
		
def upLoadtoFireBase(val):
	ref = db.reference("Speed")
	ref.set(val)

def bootVideo():
	# lastDistance = None
	# dst = 0
	video_capture = cv2.VideoCapture(0)
	cur = 0
	def captureThread():
		lastDistance = None
		dst = 0
		while True:
			curRet,curFrame = video_capture.read()
			out = cv2.imwrite('capture.jpg',curFrame)
			faces = getMachineInfo('capture.jpg')
			if len(faces) > 0:
				res = faces[0].landmarks[7]
				#cur += 1
				lastDistance ,dst = updateDistance(res,lastDistance)
				#upLoadtoFireBase(dst)
	t1 = threading.Thread(target = captureThread)
	t1.start()
	while True:
		ret, frame = video_capture.read()
		rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA)
		#out = cv2.imwrite('capture.jpg', frame)
		#time.sleep(1)
		cv2.imshow('frame', rgb)
		
	

# When everything is done, release the capture
	video_capture.release()
	cv2.destroyAllWindows()
cred = credentials.Certificate("dodgemonster.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://dodgemonster.firebaseio.com/'
	})

bootVideo()
#upLoadtoFireBase(69)
