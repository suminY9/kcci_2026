import cv2
from ultralytics import YOLO
import time
import csv

# 1. Jetson Orin에서 직접 빌드한 TensorRT 엔진 로드 (.engine)
# Ultralytics가 내부 전처리 및 NMS 플러그인을 자동으로 핸들링합니다.
model = YOLO("Project_TEAM6_test.engine", task="detect")

# 카메라인 경우 (0번 웹캠)
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH,320)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT,240)
cap.set(cv2.CAP_PROP_BUFFERSIZE,1)

# 윈도우 설정
cv2.namedWindow('cam', cv2.WINDOW_NORMAL)
cv2.resizeWindow('cam', 320+40, 240+60)
ansToText = {}
Price = {}
with open('class.csv', mode='r', encoding='cp949') as f:
    reader = csv.reader(f)
    next(reader) # 헤더(class_id, class_name) 건너뛰기
    for row in reader:
        ansToText[int(row[0])] = row[3]
        Price[int(row[0])] = int(row[2])

# model.names = ansToText
# model.predictor.model.names = ansToText

# FPS 측정 초기값
prev_time = time.time()
fps = 0.0

while cap.isOpened():
    success, frame = cap.read()
    # frame = cv2.resize(frame, (320, 240)) # 좌우 반전 (웹캠이 거울처럼 보이도록)
    if not success:
        break

    # 2. 추론 실행 
    # conf: 신뢰도 임계값을 0.5 이상으로 올려 잡다한 박스를 제거합니다.
    # device=0: 확실하게 GPU를 사용하도록 지정합니다.
    results = model(frame, imgsz=640, conf=0.5, iou=0.45, device=0,
                    verbose=False)
    
    results[0].names = ansToText # class id를 텍스트로 매핑
    
    # 3. 결과 시각화 (Ultralytics가 올바른 위치에 깔끔하게 그려줌)
    frame = results[0].plot()

    # FPS 계산
    cur_time = time.time()
    dt = cur_time - prev_time
    if dt > 0:
        fps = 1.0 / dt
    prev_time = cur_time

    # 화면 좌상단에 FPS 출력
    fps_text = f"FPS: {fps:.1f}"
    cv2.putText(frame, fps_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                0.8, (0, 255, 0), 2, lineType=cv2.LINE_AA)

    cv2.imshow("cam", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()