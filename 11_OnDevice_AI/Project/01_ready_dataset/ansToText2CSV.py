import csv

ansToText = {0: 'choco', 1: 'pizza', 2: 'postick', 3: 'crab_origin', 4: 'crab_fire', 5: 'crab_wasabi'}
Price = {0: 3000, 1: 1200}

# CSV 파일로 저장하기
with open('class.csv', mode='w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    # 헤더(컬럼명) 작성
    writer.writerow(['class_id', 'class_name', 'price']) 
    # 데이터 작성 (딕셔너리의 key, value를 한 줄씩 기록)
    for class_id, class_name in ansToText.items():
        writer.writerow([class_id, class_name, Price.get(class_id, 0)])

print("CSV 파일 저장 완료!")