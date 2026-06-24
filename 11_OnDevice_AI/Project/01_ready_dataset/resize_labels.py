import os
import xml.etree.ElementTree as ET
from tqdm import tqdm

# [수정] 하위 폴더들이 담겨있는 최상위 부모 폴더 경로를 지정하세요.
input_xml_dir = r"D:\dataset\images\Training\[라벨]음료3"
output_xml_dir = r"D:\dataset\images\Training\[라벨]음료3_resized"
target_size = (640, 640)  # (target_width, target_height)

# 1. 모든 하위 디렉토리를 돌며 XML 파일 경로 수집
xml_tasks = []
for root_dir, dirs, files in os.walk(input_xml_dir):
    for file in files:
        if file.lower().endswith(".xml"):
            # 입력 파일의 전체 경로
            full_input_path = os.path.join(root_dir, file)
            
            # 하위 폴더 구조를 그대로 유지하기 위한 상대 경로 계산
            rel_path = os.path.relpath(root_dir, input_xml_dir)
            
            # 만약 폴더명이 '10001_유어스광동어성초500ml' 라면 앞의 숫자(10001)만 추출하여 출력 폴더로 지정
            # (원치 않으시면 이 부분을 수정하거나 단순히 rel_path를 사용하시면 됩니다)
            folder_name = os.path.basename(root_dir)
            if "_" in folder_name:
                folder_code = folder_name.split("_")[0]  # '10001' 추출
                full_output_dir = os.path.join(output_xml_dir, folder_code)
            else:
                full_output_dir = os.path.join(output_xml_dir, rel_path)
                
            full_output_path = os.path.join(full_output_dir, file)
            
            xml_tasks.append((full_input_path, full_output_path, full_output_dir))

print(f"총 {len(xml_tasks)}개의 XML 라벨 데이터를 발견했습니다. 변환 시작...")

saved_count = 0

# tqdm으로 전체 파일 진행률 표시
for input_path, output_path, output_dir in tqdm(xml_tasks):
    # 출력 서브 폴더가 없으면 생성
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    try:
        # XML 파일 파싱
        tree = ET.parse(input_path)
        root = tree.getroot()
        
        # 1. 기존 이미지 사이즈 정보 가져오기
        size_element = root.find(".//size")
        if size_element is None:
            continue
            
        orig_width = int(size_element.find("width").text)
        orig_height = int(size_element.find("height").text)
        
        # 가로, 세로 리사이즈 비율 계산
        scale_x = target_size[0] / orig_width
        scale_y = target_size[1] / orig_height
        
        # XML 내의 size 정보 업데이트
        size_element.find("width").text = str(target_size[0])
        size_element.find("height").text = str(target_size[1])
        
        # 2. 모든 object의 bounding box 좌표 변환
        for obj in root.findall(".//object"):
            bndbox = obj.find("bndbox")
            if bndbox is None:
                continue
                
            xmin = int(bndbox.find("xmin").text)
            ymin = int(bndbox.find("ymin").text)
            xmax = int(bndbox.find("xmax").text)
            ymax = int(bndbox.find("ymax").text)
            
            new_xmin = max(0, min(int(round(xmin * scale_x)), target_size[0]))
            new_ymin = max(0, min(int(round(ymin * scale_y)), target_size[1]))
            new_xmax = max(0, min(int(round(xmax * scale_x)), target_size[0]))
            new_ymax = max(0, min(int(round(ymax * scale_y)), target_size[1]))
            
            bndbox.find("xmin").text = str(new_xmin)
            bndbox.find("ymin").text = str(new_ymin)
            bndbox.find("xmax").text = str(new_xmax)
            bndbox.find("ymax").text = str(new_ymax)
            
        # 변환된 XML 파일 저장
        tree.write(output_path, encoding="utf-8", xml_declaration=True)
        saved_count += 1
        
    except Exception as e:
        print(f"\n에러 발생 ({os.path.basename(input_path)}): {e}")

print(f"\n모든 작업 완료! (총 {len(xml_tasks)}개 중 {saved_count}개 성공적으로 변환 및 저장됨)")