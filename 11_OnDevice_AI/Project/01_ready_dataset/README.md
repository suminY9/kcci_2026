## [ DatasetAugmentation.py ]

### 실행 전 OS에 imagaug install 필요.
``` 
$ pip install imgaug opencv-python numpy```

## Augmentation manual
1. 상하 반전
```python
seq_flip_h = iaa.Sequential([iaa.Fliplr(1.0)])```

2. 좌우 반전
```python
seq_flip_v = iaa.Sequential([iaa.Flipud(1.0)])```

3. 노이즈
```python
seq_noise  = iaa.Sequential([iaa.AdditiveGaussianNoise(scale=(10, 30))])```

4. 밝기 조절 (0.5 ~ 1.5 배 사이로 무작위 밝기 조절)
```python
seq_brightness = iaa.Sequential([iaa.Multiply((0.5, 1.5))])```

5. 회전 (안전한 바운딩 박스 변환을 위해 -15도 ~ 15도 사이 회전)
```python
seq_rotate = iaa.Sequential([iaa.Affine(rotate=(-15, 15))])```

6. 가우시안 블러 (초점 흐림 효과, 커널 크기 1.0 ~ 3.0 사이)
```python
seq_blur = iaa.Sequential([iaa.GaussianBlur(sigma=(1.0, 3.0))])```

7. 복합 변형 (밝기 조정 + 가우시안 노이즈를 동시에 랜덤 적용)
```python
seq_complex = iaa.Sequential([
    iaa.Multiply((0.7, 1.3)),
    iaa.AdditiveGaussianNoise(scale=(0, 15))
])```

```python
augmentations = {
    "flip_h": seq_flip_h,
    "flip_v": seq_flip_v,
    "noise": seq_noise,
    "bright": seq_brightness,
    "rotate": seq_rotate,
    "blur": seq_blur,
    "complex": seq_complex
}```
