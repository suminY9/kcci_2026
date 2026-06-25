import os
import glob
import cv2
import numpy as np
import xml.etree.ElementTree as ET
import imgaug as ia
import imgaug.augmenters as iaa
from imgaug.augmentables.bbs import BoundingBox, BoundingBoxesOnImage

# ==========================================
# [중요] 기준 데이터셋 경로 설정
# ==========================================
BASE_TRAINING_DIR = "./Dataset/Training"

IMAGE_DIR = os.path.join(BASE_TRAINING_DIR, "images")
LABEL_DIR = os.path.join(BASE_TRAINING_DIR, "label")

# 결과 폴더 하위에 images와 label 폴더를 각각 분리 정의
OUTPUT_DIR = "./Dataset/Augmented"
OUT_IMAGE_DIR = os.path.join(OUTPUT_DIR, "images")
OUT_LABEL_DIR = os.path.join(OUTPUT_DIR, "label")

os.makedirs(OUT_IMAGE_DIR, exist_ok=True)
os.makedirs(OUT_LABEL_DIR, exist_ok=True)

# ==========================================
# 증강 기법(Augmentation) 정의
# ==========================================
seq_brightness = iaa.Sequential([iaa.Multiply((0.5, 1.5))])
seq_noise = iaa.Sequential([iaa.AdditiveGaussianNoise(scale=(10, 30))])
seq_complex = iaa.Sequential([
    iaa.Multiply((0.7, 1.3)),
    iaa.AdditiveGaussianNoise(scale=(0, 15))
])

augmentations = {
    "bright": seq_brightness,
    "noise": seq_noise,
    "complex": seq_complex
}

# ==========================================
# XML 파싱 및 업데이트 함수
# ==========================================
def read_xml(xml_path):
    """XML 파일에서 Bounding Box 정보를 읽어옴"""
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    bbs = []
    for obj in root.findall('object'):
        name = obj.find('name').text
        bndbox = obj.find('bndbox')
        if bndbox is None:
            continue
        xmin = float(bndbox.find('xmin').text)
        ymin = float(bndbox.find('ymin').text)
        xmax = float(bndbox.find('xmax').text)
        ymax = float(bndbox.find('ymax').text)
        bbs.append(BoundingBox(x1=xmin, y1=ymin, x2=xmax, y2=ymax, label=name))
    return tree, bbs

def save_augmented_xml(original_tree, aug_bbs, output_path, new_filename):
    """변환된 좌표를 반영하여 새 XML 파일로 저장"""
    root = original_tree.getroot()
    
    root.find('filename').text = new_filename
    if root.find('path') is not None:
        root.find('path').text = output_path.replace(".xml", ".jpg")
        
    for obj in root.findall('object'):
        root.remove(obj)
        
    for bb in aug_bbs:
        obj = ET.SubElement(root, 'object')
        ET.SubElement(obj, 'name').text = bb.label
        ET.SubElement(obj, 'pose').text = 'Unspecified'
        ET.SubElement(obj, 'truncated').text = '0'
        ET.SubElement(obj, 'difficult').text = '0'
        
        bndbox = ET.SubElement(obj, 'bndbox')
        ET.SubElement(bndbox, 'xmin').text = str(int(bb.x1))
        ET.SubElement(bndbox, 'ymin').text = str(int(bb.y1))
        ET.SubElement(bndbox, 'xmax').text = str(int(bb.x2))
        ET.SubElement(bndbox, 'ymax').text = str(int(bb.y2))
        
    tree = ET.ElementTree(root)
    tree.write(output_path, encoding='utf-8', xml_declaration=False)

# ==========================================
# 메인 루프 (대칭적 폴더 구조 자동 생성 및 저장)
# ==========================================
image_paths = []
for ext in ['*.jpg', '*.jpeg', '*.png', '*.JPG', '*.JPEG', '*.PNG']:
    image_paths.extend(glob.glob(os.path.join(IMAGE_DIR, "**", ext), recursive=True))

print(f"총 {len(image_paths)}개의 이미지를 찾았습니다. 대칭 구조 분류 증강을 시작합니다...\n")

for img_path in image_paths:
    base_name = os.path.splitext(os.path.basename(img_path))[0]
    
    # 상대 경로 계산 (예: 'sub_folder/001.jpg' 혹은 그냥 '001.jpg')
    rel_path = os.path.relpath(img_path, IMAGE_DIR)
    rel_dir = os.path.dirname(rel_path) 
    
    xml_path = os.path.join(LABEL_DIR, rel_dir, f"{base_name}.xml")
    
    if not os.path.exists(xml_path):
        xml_path_caps = os.path.join(LABEL_DIR, rel_dir, f"{base_name}.XML")
        if os.path.exists(xml_path_caps):
            xml_path = xml_path_caps
            
    if not os.path.exists(xml_path):
        print(f"[건너뜀] 매칭되는 XML 없음: {base_name}")
        continue
        
    image = cv2.imread(img_path)
    if image is None:
        continue
    
    h, w, c = image.shape
    tree, bbs = read_xml(xml_path)
    bbs_on_image = BoundingBoxesOnImage(bbs, shape=image.shape)
    
    # ------------------------------------------
    # 결과물이 저장될 하위 디렉토리 미리 자동 생성
    # ------------------------------------------
    target_img_dir = os.path.join(OUT_IMAGE_DIR, rel_dir)
    target_lbl_dir = os.path.join(OUT_LABEL_DIR, rel_dir)
    os.makedirs(target_img_dir, exist_ok=True)
    os.makedirs(target_lbl_dir, exist_ok=True)
    
    # 원본 복사본도 각 대칭 폴더에 분리 저장
    cv2.imwrite(os.path.join(target_img_dir, f"{base_name}.jpg"), image)
    tree.write(os.path.join(target_lbl_dir, f"{base_name}.xml"))
    
    # 증강 데이터 저장 생성
    for aug_name, seq in augmentations.items():
        image_aug, bbs_aug = seq(image=image, bounding_boxes=bbs_on_image)
        
        # 1. 이미지 안으로 박스 제한
        bbs_aug = bbs_aug.clip_out_of_image()

        # 2. 유효한 박스 필터링
        valid_bbs = []
        for bb in bbs_aug.bounding_boxes:
            if bb.x2 <= bb.x1 or bb.y2 <= bb.y1:
                continue
            if bb.x2 > 0 and bb.y2 > 0 and bb.x1 < w and bb.y1 < h:
                valid_bbs.append(bb)
        bbs_aug.bounding_boxes = valid_bbs
        
        new_base_name = f"{base_name}_{aug_name}"
        
        # 분리된 각각의 타겟 폴더 경로에 저장
        out_img_path = os.path.join(target_img_dir, f"{new_base_name}.jpg")
        out_xml_path = os.path.join(target_lbl_dir, f"{new_base_name}.xml")
        
        cv2.imwrite(out_img_path, image_aug)
        save_augmented_xml(tree, bbs_aug, out_xml_path, f"{new_base_name}.jpg")

print("\n데이터 증강 완료!")