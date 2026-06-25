import cv2
from ultralytics import YOLO
import time
import csv
from PIL import ImageFont, ImageDraw, Image
import numpy as np
from datetime import datetime  # 일시 자동 기록을 위해 추가

# ================= [설정 및 초기화] =================
model_path = "epochs65.engine"
csv_path = "class.csv"
camera_id = 0
kor_font_path = "/usr/share/fonts/truetype/nanum/NanumGothic.ttf"

# 1. TensorRT 엔진 로드
model = YOLO(model_path, task="detect")

# 한글 폰트 로드
try:
    pil_font = ImageFont.truetype(kor_font_path, 24)
except IOError:
    print(f"폰트 파일을 찾을 수 없습니다: {kor_font_path}")
    exit()

# CSV 데이터 로드 및 딕셔너리 생성
ansToText = {}
Price = {}
idToName = {} # txt 저장을 위한 순수 상품명 딕셔너리
with open(csv_path, mode='r', encoding='cp949') as f:
    reader = csv.reader(f)
    next(reader)  # 헤더 건너뛰기
    for row in reader:
        class_id = int(row[0])
        name = row[1]
        price = int(row[2])
        
        ansToText[class_id] = f"{name} : {price}원"
        Price[class_id] = price
        idToName[class_id] = name # 영수증 텍스트용

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

def pad_korean(text, total_len):
    """한글은 2글자, 영문/숫자는 1글자로 취급하여 남은 길이만큼 공백을 채웁니다."""
    current_len = sum(2 if ord(char) > 128 else 1 for char in text)
    padding = total_len - current_len
    return text + (' ' * max(0, padding))

# ================= [메인 루프] =================
while cap.isOpened():
    success, frame = cap.read()
    if not success:
        break

    # 2. 추론 실행
    results = model(frame, imgsz=640, conf=0.5, iou=0.45, device=0, verbose=False)
    results[0].names = ansToText
    frame = results[0].plot(font=kor_font_path)

    # 4. 화면에 인식된 상품들의 총 가격 계산 및 개수 집계
    total_price = 0
    current_items = {} # 현재 프레임 상품 집계 {class_id: 개수}
    
    if results[0].boxes is not None:
        for cls_id in results[0].boxes.cls:
            cid = int(cls_id.item())
            total_price += Price.get(cid, 0)
            current_items[cid] = current_items.get(cid, 0) + 1

    # 5. FPS 계산
    cur_time = time.time()
    dt = cur_time - prev_time
    if dt > 0:
        fps = 1.0 / dt
    prev_time = cur_time

    # 화면 좌상단에 FPS 출력
    fps_text = f"FPS: {fps:.1f}"
    cv2.putText(frame, fps_text, (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                0.8, (0, 255, 0), 2, lineType=cv2.LINE_AA)

    # ================= [Total 가격 한글 출력 처리] =================
    total_text = f"총 금액: {total_price} 원"
    img_pil = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    draw = ImageDraw.Draw(img_pil)
    draw.text((10, 60), total_text, font=pil_font, fill=(255, 255, 0))
    frame = cv2.cvtColor(np.array(img_pil), cv2.COLOR_RGB2BGR)

    cv2.imshow("cam", frame)

    # 키 입력 처리
    key = cv2.waitKey(1) & 0xFF
    
    # 's'를 누르면 현재 화면 데이터를 기준으로 영수증 포맷 저장
    if key == ord('s'):
        if current_items:
            # 현재 시간을 YYYY/MM/DD/HH:MM:SS 서식으로 획득
            current_date_str = datetime.now().strftime("%Y/%M/%d/%H:%M:%S")
            receipt_filename = f"receipt_{int(time.time())}.txt"
            
            with open(receipt_filename, "w", encoding="utf-8") as rf:
                rf.write("===================== AutoCasherSystem =====================\n")
                rf.write(f"일시: {current_date_str}\n")
                rf.write("상호: KCCI\n\n")
                
                # 상단 헤더 정렬 (상품명은 폭 30 고정, 개수와 가격 정렬)
                rf.write(f"  {pad_korean('상품명', 30)} |   개수   |   가격\n")
                rf.write("------------------------------------------------------------\n")
                
                for cid, count in current_items.items():
                    name = idToName.get(cid, "Unknown")
                    single_price = Price.get(cid, 0)
                    item_total_price = single_price * count
                    
                    # 상품명 별 가로 폭을 함수로 고정 처리
                    p_name = pad_korean(name, 30)
                    p_count = f"{count:>4}    "
                    p_price = f"{item_total_price:>9,} 원"
                    
                    rf.write(f"* {p_name} | {p_count} | {p_price}\n")
                    
                rf.write("------------------------------------------------------------\n")
                
                # 합계 금액 우측 정렬 맞춤
                total_price_str = f"{total_price:,} 원"
                rf.write(f"합계 {total_price_str:>49}\n")
                rf.write("============================================================\n")
                
            print(f"[안내] 현재 프레임의 영수증이 저장되었습니다: {receipt_filename}")
        else:
            print("[안내] 현재 화면에 인식된 상품이 없어 저장하지 않았습니다.")

    # 'q'를 누르면 프로그램 종료
    elif key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()