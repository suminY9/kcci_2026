import cv2
from ultralytics import YOLO
import time
import csv
from PIL import ImageFont, ImageDraw, Image
import numpy as np

# ================= [설정 및 초기화] =================
model_path = "epochs65.engine"  # 원본 클래스 코드의 메인 실행 파일 기준
csv_path = "class.csv"
camera_id = 0
kor_font_path = "/usr/share/fonts/truetype/nanum/NanumGothic.ttf"
price_kor_font_path = "usr/share/fonts/truetype/nanum/NanumSquareB.ttf"

# 1. TensorRT 엔진 로드
model = YOLO(model_path, task="detect")

# 한글 폰트 로드
try:
    pil_font = ImageFont.truetype(kor_font_path, 24)
    price_pil_font = ImageFont.truetype(price_kor_font_path, 20)
except IOError:
    print(f"폰트 파일을 찾을 수 없습니다: {kor_font_path}")
    exit()

# CSV 데이터 로드 및 딕셔너리 생성
ansToText = {}
Price = {}
with open(csv_path, mode='r', encoding='cp949') as f:
    reader = csv.reader(f)
    next(reader)  # 헤더 건너뛰기
    for row in reader:
        class_id = int(row[0])
        name = row[1]
        price = int(row[2])
        
        # 상자 라벨용 텍스트 및 가격 매핑 (원본 클래스 기능과 동일하게 맞춤)
        ansToText[class_id] = f"{name} : {price}원"
        Price[class_id] = price

# 카메라 및 윈도우 설정
cap = cv2.VideoCapture(camera_id)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

cv2.namedWindow('cam', cv2.WINDOW_NORMAL)
cv2.resizeWindow('cam', 640 + 40, 480 + 60)

# FPS 측정 초기값
prev_time = time.time()
fps = 0.0

# ================= [메인 루프] =================
while cap.isOpened():
    success, frame = cap.read()
    if not success:
        break

    # 2. 추론 실행
    results = model(frame, imgsz=640, conf=0.5, iou=0.45, device=0, verbose=False)
    
    # 클래스 이름을 한글 서식이 포함된 텍스트로 변경
    results[0].names = ansToText
    
    # 3. 결과 시각화 (YOLO 박스 내 한글 처리 포함)
    frame = results[0].plot(font=kor_font_path)

    # 4. 화면에 인식된 상품들의 총 가격 계산
    total_price = 0
    if results[0].boxes is not None:
        for cls_id in results[0].boxes.cls:
            total_price += Price.get(int(cls_id.item()), 0)

    # 5. FPS 계산
    cur_time = time.time()
    dt = cur_time - prev_time
    if dt > 0:
        fps = 1.0 / dt
    prev_time = cur_time

    # 화면 좌상단에 FPS 출력 (영문이므로 OpenCV 기본 출력 사용)
    fps_text = f"FPS: {fps:.1f}"
    cv2.putText(frame, fps_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                0.8, (0, 255, 0), 2, lineType=cv2.LINE_AA)

    # ================= [Total 가격 한글 출력 처리] =================
    total_text = f"총 금액: {total_price} 원"
    
    # OpenCV(BGR) 이미지를 PIL(RGB) 이미지로 변환
    img_pil = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    draw = ImageDraw.Draw(img_pil)
    
    # 한글 텍스트 그리기 (위치 (10, 60), 노란색 (255, 255, 0))
    draw.text((10, 45), total_text, font=price_pil_font, fill=(255, 255, 0))
    
    # PIL 이미지를 다시 OpenCV(BGR) 이미지로 복원
    frame = cv2.cvtColor(np.array(img_pil), cv2.COLOR_RGB2BGR)
    # =============================================================

    cv2.imshow("cam", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()