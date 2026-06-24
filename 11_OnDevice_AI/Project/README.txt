### 00_data
# 학습에 쓸 데이터들

class.csv
data.yaml
Dataset.zip   <- 학습시킬 데이터셋



### 01_ready_dataset
# 데이터셋 준비할 때 활용할 수 있는 참고 코드

import yaml.py
:  class.csv에서 클래스 개수, 이름을 뽑아서 yaml 파일로 import

resize_images.py
: 학습시킬 이미지 파일들의 size를 일괄적으로 변경해서 출력
: 변환 시 폴더명에 일련번호만 남김

resize_labels.py
: 학습시킬 이미지 파일들의 size를 일괄적으로 변경해서 출력
: 변환 시 폴더명에 일련번호만 남김



### 02_training
# YOLO training 및 on device program

AutoCasherSystem.py
: jetson 보드에 카메라를 연결 후 실행

YOLO_Trainig_Products.jpynb
: Colab에서 dataset을 학습시킴
: 2-1. xml to txt convert 단계에서 cp949 인식 오류 발생 시!
공유 드라이브에서 class.csv 파일을 엑셀 파일로 다운로드 -> 엑셀로 열어서 다른이름으로 저장>csv(쉼표로 구분) 형식으로 저장 -> 변환된 class.csv 사용