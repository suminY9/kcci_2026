## [ AutoCasherSystem.py ] -version 1
**내용**
1. 좌상단에 실시간 fps 출력
2. YOLO로 상품을 detect하면 화면에 box와 함께 class name 출력  


<br>
  
## [ AutoCahserSystem.py ]  -version 2
**개선 사항**
1. 상품의 가격 합계를 fps 아래에 출력되도록 함.
2. 상품명이 한글로 출력되도록 함.  


  
**실행 전 필수 사항**
1. OS에 한글 폰트 설치 필요. 다음 명령어를 순서대로 실행.  
```
$ sudo apt-get update
$ sudo apt-get install -y fonts-nanum
$ sudo fc-cache -fv
```


<br>
  
## [ AutoCasherSystem.py ] -version 3
**개선 사항**
1. 영수증을 저장하도록 함.
실행중일 때 's'를 누르면 영수증이 txt 파일로 출력됨.  


<br>
  
---  


   
## [ YOLO_Training_Continue.ipynb ]
YOLO_Training_Products.ipynb 실행 중 중단되었을 때 last.pt를 사용해서 이어서 돌리기 위함.  


