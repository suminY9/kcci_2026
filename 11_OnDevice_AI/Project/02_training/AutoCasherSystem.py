import cv2
from ultralytics import YOLO
import time
import csv
from PIL import ImageFont, ImageDraw, Image
import numpy as np
from datetime import datetime
import threading
import json
import urllib.parse
import mimetypes
from pathlib import Path
from http.server import HTTPServer, SimpleHTTPRequestHandler

# ================= [설정 및 전역 변수] =================
model_path = "epoch200_cls1.5.engine"
csv_path = str(Path(__file__).resolve().parent.parent / "00_data" / "class.csv")
camera_id = 0
kor_font_path = "/usr/share/fonts/truetype/nanum/NanumGothic.ttf"

# 전역 변수로 현재 인식된 상품 목록을 저장 (웹서버와 공유)
detected_items = {}
total_price = 0
detected_lock = threading.Lock()

# 웹 서버 경로 설정
BASE_DIR = Path(__file__).resolve().parent / "kiosk_web"
PORT = 8082

ansToText = {}
Price = {}
idToName = {}

# ================= [데이터 로드] =================
try:
    with open(csv_path, mode='r', encoding='cp949') as f:
        reader = csv.reader(f)
        next(reader)  # 헤더 건너뛰기
        for row in reader:
            class_id = int(row[0])
            name = row[1]
            price = int(row[2])
            ansToText[class_id] = f"{name} : {price}원"
            Price[class_id] = price
            idToName[class_id] = name
except Exception as e:
    print(f"[경고] CSV 로드 실패 (cp949): {e}. utf-8로 재시도합니다.")
    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)
        for row in reader:
            class_id = int(row[0])
            name = row[1]
            price = int(row[2])
            ansToText[class_id] = f"{name} : {price}원"
            Price[class_id] = price
            idToName[class_id] = name

def pad_korean(text, total_len):
    current_len = sum(2 if ord(char) > 128 else 1 for char in text)
    padding = total_len - current_len
    return text + (' ' * max(0, padding))

def generate_receipt():
    """현재 장바구니 데이터를 기준으로 영수증을 생성합니다."""
    with detected_lock:
        if not detected_items:
            print("[안내] 장바구니가 비어있어 영수증을 출력하지 않습니다.")
            return False

        # 수정됨: %m (Month) 로 변경하여 정상적인 날짜 출력
        current_date_str = datetime.now().strftime("%Y/%m/%d/%H:%M:%S")
        receipt_filename = f"receipt_{int(time.time())}.txt"
        
        with open(receipt_filename, "w", encoding="utf-8") as rf:
            rf.write("===================== KCCI 무인 키오스크 =====================\n")
            rf.write(f"일시: {current_date_str}\n")
            rf.write("상호: KCCI 서울기술교육센터 (Team 6)\n\n")
            
            rf.write(f"  {pad_korean('상품명', 30)} |   개수   |   가격\n")
            rf.write("------------------------------------------------------------\n")
            
            for cid, count in detected_items.items():
                name = idToName.get(cid, "Unknown")
                single_price = Price.get(cid, 0)
                item_total_price = single_price * count
                
                p_name = pad_korean(name, 30)
                p_count = f"{count:>4}    "
                p_price = f"{item_total_price:>9,} 원"
                
                rf.write(f"* {p_name} | {p_count} | {p_price}\n")
                
            rf.write("------------------------------------------------------------\n")
            total_price_str = f"{total_price:,} 원"
            rf.write(f"합계 {total_price_str:>49}\n")
            rf.write("============================================================\n")
            
        print(f"[안내] 결제 완료! 영수증이 저장되었습니다: {receipt_filename}")
        
        # 결제 후 장바구니 초기화
        detected_items.clear()
        return True

# ================= [웹 서버 핸들러] =================
class KioskAPIHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(BASE_DIR), **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = urllib.parse.unquote(parsed.path)

        if path == "/api/detected":
            with detected_lock:
                self.send_json(detected_items)
            return

        # /api/products : csv를 다시 읽어서 서빙 (server.py의 로직)
        if path == "/api/products":
            products = []
            for cid, name in idToName.items():
                # 간단한 카테고리 로직 (사이다, 콜라, 수 등은 음료)
                category = "drink" if any(x in name for x in ["사이다", "콜라", "수", "주스", "드링크"]) else "snack"
                products.append({
                    "class_id": cid,
                    "class_name": name,
                    "price": Price.get(cid, 0),
                    "category": category,
                    "image": None # 웹 시뮬레이터와 달리 실제 통합본은 텍스트 중심 또는 기본이미지 사용
                })
            self.send_json(products)
            return

        super().do_GET()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = urllib.parse.unquote(parsed.path)

        if path == "/api/checkout":
            success = generate_receipt()
            if success:
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b'{"status":"success"}')
            else:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(b'{"status":"empty"}')
            return

    def send_json(self, data):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
        
    def log_message(self, format, *args):
        # 폴링 로그 숨기기 (args[0]이 문자열이 아닐 수 있음)
        if len(args) > 0 and isinstance(args[0], str) and "/api/detected" in args[0]:
            return
        super().log_message(format, *args)

def run_web_server():
    server = HTTPServer(("0.0.0.0", PORT), KioskAPIHandler)
    print(f"[웹서버] http://localhost:{PORT} 포트에서 키오스크 화면이 열립니다!")
    server.serve_forever()

# ================= [메인 - 카메라 AI 루프] =================
def main():
    global total_price, detected_items
    
    # 웹 서버 스레드 시작
    web_thread = threading.Thread(target=run_web_server, daemon=True)
    web_thread.start()

    print("[AI] 모델을 불러오는 중입니다...")
    try:
        model = YOLO(model_path, task="detect")
    except Exception as e:
        print(f"[AI] 모델 로드 실패: {e}")
        print("[AI] 테스트용(모델없이 작동)으로 진행합니다. 화면만 띄웁니다.")
        model = None
        
    try:
        pil_font = ImageFont.truetype(kor_font_path, 24)
    except IOError:
        pil_font = ImageFont.load_default()

    cap = cv2.VideoCapture(camera_id)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)  # 버퍼 최소화 → 항상 최신 프레임 처리

    cv2.namedWindow('cam', cv2.WINDOW_NORMAL)
    cv2.resizeWindow('cam', 640 + 40, 480 + 60)

    prev_time = time.time()
    fps = 0.0

    print("[AI] 카메라 인식을 시작합니다. (종료: q 키)")
    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            break

        # 추론 실행
        if model:
            results = model(frame, imgsz=640, conf=0.5, iou=0.45, device=0, verbose=False)
            results[0].names = ansToText
            
            # 여기서 바운딩 박스를 그립니다
            # Ultralytics 내부 함수를 쓰되, 한글이 깨질 수 있으므로 OpenCV+PIL 수동그리기를 권장하나
            # 기존 v3 로직 유지를 위해 그대로 사용
            annotated_frame = results[0].plot() 
        else:
            annotated_frame = frame
            results = []

        # 장바구니 집계 
        current_total = 0
        current_items = {}
        
        if model and results[0].boxes is not None:
            for cls_id in results[0].boxes.cls:
                cid = int(cls_id.item())
                current_total += Price.get(cid, 0)
                current_items[cid] = current_items.get(cid, 0) + 1
        
        # 전역 변수 업데이트 (웹 서버로 전송됨)
        with detected_lock:
            # 새로운 아이템 추가 (기존 웹 장바구니와 동기화하기 위해 카메라에 잡힌 최대 수량 유지 등 로직 가능)
            # 여기서는 단순히 현재 화면에 잡힌 수량을 웹으로 던짐
            detected_items = current_items.copy()
            total_price = current_total

        # FPS 계산
        cur_time = time.time()
        dt = cur_time - prev_time
        if dt > 0:
            fps = 1.0 / dt
        prev_time = cur_time

        # 화면 좌상단에 FPS 출력
        cv2.putText(annotated_frame, f"FPS: {fps:.1f}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX,
                    0.8, (0, 255, 0), 2, lineType=cv2.LINE_AA)

        # Total 가격 출력 (PIL 사용)
        img_pil = Image.fromarray(cv2.cvtColor(annotated_frame, cv2.COLOR_BGR2RGB))
        draw = ImageDraw.Draw(img_pil)
        draw.text((10, 60), f"총 금액: {total_price} 원", font=pil_font, fill=(255, 255, 0))
        annotated_frame = cv2.cvtColor(np.array(img_pil), cv2.COLOR_RGB2BGR)

        cv2.imshow("cam", annotated_frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
