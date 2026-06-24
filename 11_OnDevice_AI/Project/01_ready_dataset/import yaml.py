import yaml
import csv

# --- 1. CSV 파일에서 'names' 데이터 추출 ---
csv_file_path = r'D:\OnDeviceAI_C_Python_AI\Project_Team6\class.csv'
names_list = []
with open(csv_file_path, mode='r', encoding='cp949') as f:
    reader = csv.reader(f)

    next(reader, None)

    for row in reader:
        if len(row) > 1:  # 행에 최소 2개 이상의 열이 있는지 확인
            names_list.append(row[1].strip())  # 2번째 열(인덱스 1) 데이터 추가 (공백 제거)

# --- 2. yaml 파일에 들어갈 사전(dictionary) 데이터 정의 ---
data = {
    'train': r'/content/Dataset/Training/images',
    'val': r'/content/Dataset/Validation/images',
    'nc': len(names_list),  # 클래스 개수(nc)도 불러온 데이터 길이에 맞춰 자동 지정
    'names': names_list
}

# --- 3. yaml 파일 저장 경로 지정 ---
yaml_file_path = r'D:\OnDeviceAI_C_Python_AI\Project_Team6\data.yaml'

# --- 4. 파일 쓰기 ---
with open(yaml_file_path, 'w', encoding='utf-8') as f:
    yaml.dump(data, f, default_flow_style=False, allow_unicode=True)

print(f"data.yaml 파일이 성공적으로 생성되었습니다: {yaml_file_path}")