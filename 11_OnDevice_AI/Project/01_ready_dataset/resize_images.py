import os
from PIL import Image
from tqdm import tqdm

# 경로 설정 (하위 폴더들이 담겨있는 최상위 부모 폴더 경로 지정)
input_dir = r"D:\dataset\images\Training\[원천]음료3"
output_dir = r"D:\dataset\images\Training\[원천]음료3_resized"
target_size = (640, 640)  # XML 변환 크기(1280x1280)와 맞추기 위해 수정 (원하시면 640으로 변경 가능)

# 이미지 확장자 목록
valid_extensions = (".jpg", ".jpeg", ".png", ".bmp", ".webp")

# 1. 모든 하위 디렉토리를 돌며 이미지 파일 경로 수집
image_tasks = []
for root_dir, dirs, files in os.walk(input_dir):
    for file in files:
        if file.lower().endswith(valid_extensions):
            # 입력 파일 전체 경로
            full_input_path = os.path.join(root_dir, file)
            
            # 하위 폴더 구조 상대 경로 계산
            rel_path = os.path.relpath(root_dir, input_dir)
            
            # 폴더명에서 상품 코드(앞자리 숫자)만 추출하여 출력 폴더 구조 매칭
            folder_name = os.path.basename(root_dir)
            if "_" in folder_name:
                folder_code = folder_name.split("_")[0]  # '10001' 추출
                full_output_dir = os.path.join(output_dir, folder_code)
            else:
                full_output_dir = os.path.join(output_dir, rel_path)
                
            full_output_path = os.path.join(full_output_dir, file)
            
            image_tasks.append((full_input_path, full_output_path, full_output_dir))

print(f"총 {len(image_tasks)}장의 이미지 파일을 발견했습니다. 리사이즈 시작...")

saved_count = 0

# 2. 이미지 리사이즈 및 저장 진행
for input_path, output_path, target_output_dir in tqdm(image_tasks):
    # 출력 서브 폴더가 없으면 생성
    if not os.path.exists(target_output_dir):
        os.makedirs(target_output_dir)
        
    try:
        with Image.open(input_path) as img:
            # 고품질 리사이즈를 위해 LANCZOS 필터 사용
            resized_img = img.resize(target_size, Image.Resampling.LANCZOS)
            
            # 원본 포맷 유지하여 저장 (RGBA -> RGB 예외처리)
            if img.mode in ("RGBA", "P") and input_path.lower().endswith((".jpg", ".jpeg")):
                resized_img = resized_img.convert("RGB")
                
            resized_img.save(output_path, quality=95)  # 품질 95% 유지
            saved_count += 1
            
    except Exception as e:
        print(f"\n에러 발생 ({os.path.basename(input_path)}): {e}")

print(f"\n모든 이미지 리사이즈 완료! (총 {len(image_tasks)}장 중 {saved_count}장 성공적으로 저장됨)")