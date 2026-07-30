### Test Manual

1. 초음파 센서가 3cm를 감지하고 2초 후,
2. btn(cnn_done)이 눌리면 차단바가 열림.
3. 차단바가 열린 뒤 2초 후 차단바가 닫힘.
4. vga가 동작을 마치면 led[0] (vga_done)이 켜짐.(tick signal)
5. 1초 간격으로 PixelBuffer에서 데이터를 한 줄씩 읽어오면서 데이터가 바뀌면 led[1]이 켜진 상태로 유지되고, 데이터가 바뀌지 않으면 꺼짐.

<br>

| Device | Description |
|:-:|:-|
| btn | cnn_done. 차단바 열림 제어. 초음파 센서가 3cm를 감지하고 2초 이상 경과되어야 작동함. |
| led[0] | vga_done(tick). vga가 캡처, 크롭, 바이너리 비트변환을 마치고 PixelBuffer에 4자리의 번호판 이미지를 저장 완료했음을 알리는 신호. |
| led[1] | PixelBuffer에서 32-bit씩 한 줄을 1초마다 읽어오고, 직전의 데이터와 비교하여 변경되었으면 켜지고, 변경되지 않았으면 꺼짐. |

<br>
<br>

```mermaid
pie title Post-Synthesis Utillization
    "LUT" : 1
    "FF" : 1
    "IO" : 6
    "BUFG" : 3
    "FREE" : 89