# Vision AI를 활용한 Auto Cashier System 🛒

## 1. 프로젝트 개요
- 수행 기간: 2026.06.22 ~ 06.30
- 수행 내용: YOLO 모델 활용, 객체를 탐지 및 인식하는 무인 결제 시스템 개발
- 사용 기술: ```Python``` ```YOLO``` ```Ubuntu``` ```Google Colab``` ```Jetson Orin Nano```
- 역할 분장: [팀명: 로저 해적단]

| 김민기 | 서어진 | 윤수민 | 조유진 |
|:---:|:---:|:---:|:---:|
| Web 서비스 개발 | 데이터 전처리 | YOLO 학습 | 데이터 후처리 |

<br>

## 2. 주요 설계 내용
### Dataset 전처리 과정 자동화 코드 구현

### YOLO 딥러닝 모델 학습

### Auto Cashier System 코드 구현

<br>

## 3. 문제 해결
### YOLO 모델 학습 정확도 개선
- **문제**: 여러 오브젝트가 함께 있을 때 작은 오브젝트 탐지 능력 미흡, 상품 식별 정확도 미흡
- **해결**:
1. validation loss가 지속적인 하향세를 나타낸 점에서 학습 가능성이 남은 것으로 판단, epoch을 기존 65회에서 200회로 대폭 조정
2. 상품 식별 정확도 상승을 위해 데이터셋 Aumentation 추가
3. yolo11n 모델에서 yolo11m 모델로 변경
- **결과**: 여러 오브젝트가 있을 때 작은 오브젝트 탐지 능력이 우수하게 개선됨, 상품을 정확하게 식별하도록 개선됨

<br>

## 4. 프로젝트 결과물
### 동작 시연 영상
1. 상품을 웹캠에 비춘다. 상품이 인식되면 Web 장바구니에 자동으로 상품이 담긴다.
2. 모든 상품을 장바구니에 담은 후, Web 장바구니의 '결제' 버튼을 누른다.
3. 영수증 파일(.txt)이 생성된다.

<br>

---
## Note. Directory Map

```text
Project/
├── 00_data/
│   ├── class.csv
│   ├── data.yaml
│   └── Dataset.zip
├── 01_ready_dataset/
│   ├── ansToText2CSV.py
│   ├── DatasetAugmentation.py
│   ├── import_yaml.py
│   ├── resize_images.py
│   └── resize_labels.py
├── 02_training/
│   ├── AutoCasherSystem.py
│   ├── trt_module.py
│   ├── YOLO_Training_Products.ipynb
│   └── YOLO_Training_Continue.ipynb
├── 03_result/
└── README.md
```


### 00_data
**학습에 쓸 데이터들**

`class.csv`<br> 
`data.yaml`<br> 
`Dataset.zip`   <- 학습시킬 데이터셋<br> 



<br>
  
### 01_ready_dataset
**데이터셋 준비할 때 활용할 수 있는 참고 코드**

`ansToText2CSV.py`<br> 
ansToText list 변수를 CSV 파일로 저장

`import yaml.py`<br> 
class.csv에서 클래스 개수, 이름을 뽑아서 yaml 파일로 import<br> 

`resize_images.py`<br> 
학습시킬 이미지 파일들의 size를 일괄적으로 변경해서 출력<br>
변환 시 폴더명에 일련번호만 남김<br> 

`resize_labels.py`<br> 
학습시킬 이미지 파일들의 size를 일괄적으로 변경해서 출력<br> 
변환 시 폴더명에 일련번호만 남김<br> 

`DatasetAugmentation.py`<br> 
dataset을 augmentation함<br> 


<br>
  
### 02_training
**YOLO training 및 on device program**

`AutoCasherSystem.py`<br> 
jetson 보드에 카메라를 연결 후 실행<br> 

`YOLO_Trainig_Products.jpynb`<br> 
Colab에서 dataset을 학습시킴<br> 
2-1. xml to txt convert 단계에서 cp949 인식 오류 발생 시!<br> 
공유 드라이브에서 class.csv 파일을 엑셀 파일로 다운로드 -> 엑셀로 열어서 다른이름으로 저장>csv(쉼표로 구분) 형식으로 저장 -> 변환된 class.csv 사용<br> 

`YOLO_Training_Continue.ipynb`<br> 
중단된 학습을 last.pt를 이용해서 이어서 학습시킴.<br> 
학습 안정화를 위해 epoch을 15 이상 학습시키는 것 추천.<br> 
