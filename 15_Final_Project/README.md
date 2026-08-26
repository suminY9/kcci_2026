# Smart Parking Lot 🚗

## 1. 프로젝트 개요
- 팀명: Cars대라
- 수행 기간: 2026.07.22 ~ 08.20
- 수행 내용: 차량 번호판 인식, 차량 맞춤 빈 자리 안내, 주차 요금 자동 정산. 스마트 무인 주차장 시스템 개발
- 사용 기술: `SystemVerilog` `C` `Python` `MicroBlaze` `UVM` `Zybo Z7-20` `ESP32` `Jetson Orin Nano`
- 담당 역할: PreProcess(SR04, SG90, VGA, UART, Wi-Fi) RTL Design & VGA UVM Verification
- 역할 분장:

| 김수빈 | 김지홍 | 문태성 | 서어진 | 송주연 | 윤수민 | 조준호 |
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
| zybo 통합, SR04 Controller 설계, PCAM 스트리밍 | CNN 통합, CNN Control Unit & Conv3 & FC1 & FC2 설계 및 검증 | CNN Ref. model 설계, Conv1 & Conv2 검증 | Wi-Fi 수신 설계, 차량 추적 모델 학습, 차량 안내 서비스, 주차장 내부 관리 총괄 | Pooling Layer 설계, Conv & Pool 통합 | PreProcess 통합, SG90 Controller & VGA 설계, UART & Wi-Fi 송신 설계, VGA_top UVM 검증 | Conv1 & Conv2 설계, AI Dataset Labeling |

<br>

## 2. 주요 설계 내용
### 1) PCAM 이미지 처리 모듈 설계
SR04 Controller에서 vga_start 신호가 들어오면 Pcam의 스트림 영상을 1 frame 캡쳐하고 가공하는 모듈. <br>
1. **FrameCrop**: 화면 중앙의 특정 영역만큼 이미지를 잘라낸 후 1/4 down scale. <br>
                  원하는 좌표일 때에만 Valid 신호가 1이 되도록 함.
2. **FrameMono**: RGB888 형식의 Pixel Data를 Binary 형식으로 변환. <br>
                  24-bit Pixel Data를 Gray Scale로 변환한 후, 임계값 이상이면 1, 이하이면 0으로 변환.
3. **FrameRegister**: Binary Pixel Data가 28-bit 모이면 PixelBuffer의 알맞은 주소에 저장. <br>
                      28-bit가 모이면 MSB와 LSB에 각각 00을 padding하여 32-bit의 word data를 PixelBuffer에 저장. <br>
                      pos 변수를 두어 word를 저장할 때마다 1씩 증가시킴으로써 4자리 숫자 이미지를 자릿수별로 저장함. <br>


### 2) PCAM 이미지 처리 모듈 UVM 검증
VGA_top의 데이터 무결성 검증. <br>
1080*720 RGB888 이미지를 입력으로 넣었을 때, <br>
(1) FrameRegister의 o_data가 이론 값과 일치하는지 검증. -> PASS <br>
(2) PixelBuffer에 저장된 이미지 데이터를 출력하여 의도한 결과대로 저장되었는지 확인. -> PASS <br>


### 3) SG90(서보모터) Controller 설계
20ms의 주기를 갖는 PWM 신호의 Duty Cycle을 변경시켜 모터의 각도를 조절함. <br>
1. **Close(0도, 차단바 닫힘)**: 0.5ms 동안 HIGH를 유지하고, 19.5ms동안 LOW를 유지.
2. **Open(90도, 차단바 열림)**: 1.5ms 동안 HIGH를 유지하고, 18.5ms동안 LOW를 유지.


### 4) UART 설계
CNN 모듈에서 추론한 4자리 숫자를 16-bit 입력으로 넣어주면, 8-bit씩 분리하여 TX로 2회 송신하는 모듈. <br>
1. **InfDataController**: 16-bit 입력을 8-bit 출력 두 번으로 분리하여 FIFO에 넣음.
2. **FIFO**: bit width 8 / depth 4
3. **UART_TX**: 8-bit씩 tx로 전송.

<br>

## 3. 문제 해결
### 1) Negative Slack 오류 해결
- **문제**: 보드에 올린 후 동작시켰을 때 PixelBuffer에 비정상 값이 저장되어 있는 문제
- **해결**: Pixel Data를 처리하는 과정 전반(FrameCrop, FrameMono, FrameRegister)을 모두 한 클럭의 조합회로로 연산했기 때문에 Negative Slack이 발생한 것으로 분석. FrameCrop에서 한 클럭을 끊어주어 클럭 당 연산량을 줄임.
- **결과**: PixelBuffer에 정상적으로 이미지 데이터가 저장되는 것을 확인.
- **배운점**: 시뮬레이션에서는 정상적으로 동작하더라도, 실제 보드 환경에서는 여러 가지 원인으로 인해 정상 동작하지 않을 수 있으며, 클럭 타이밍도 중요한 디버깅 요소라는 점을 배웠다. <br>

### 2) 이미지 처리 모듈 빛 저항성 개선
- **문제**: PixelBuffer에 저장된 이미지 데이터에서 번호판 영역의 글자가 흐릿하게 나타나는 문제
- **해결**: FrameMono 모듈에서 Gray Scale로 변환했을 때 RGB 값이 8'b0111_1111 이상이면 binary 1로 변환하도록 임계값을 설정했었는데, 빛의 영향을 받아 번호판이 밝게 촬영된 것이 원인이 되어 검은색 글자의 영역도 흰색으로 변환해버린 것이 원인인 것으로 분석. 임계값을 8'b1100_0000으로 높였음.
- **결과**: PixelBuffer에 자장저자된 이미지 데이터에서 번호판 영역의 글자가 선명하게 나타나는 것을 확인.
- **배운점**: Pixel Data를 받아서 처리하는 모듈을 설계하고, 처리 결과를 보며 디버깅하는 과정에서 Pixel Data를 다루는 것에 능숙해졌다. Display의 RGB 값은 실제 눈에 보이는 것보다 빛에 더욱 민감하다는 것을 알게 되었다.

<br>

## 4. 프로젝트 결과물
### 시연 환경 세팅

### 동작 시연 영상


<br>

---
## Note. Directory Map

```text
Project/
├── 0_TEAM/
│   ├── System_Integration/
│   ├── cctv_gui/
│   └── python_code/
├── SG90/
│   ├── src/
│   │   ├── test/
│   │   │   └── SG90_test.sv
│   │   └── SG90_Controller.sv
│   └── xdc/
│       └── SG90test.xdc
├── SR04/
│   ├── src/
│   │   ├── sr04.sv
│   │   ├── SR04_Controller.sv
│   │   └── SR04_testTOP.sv
│   └── tb/
│       └── tb_SR04_testTOP.sv
├── UART/
│   ├── src/
│   │   ├── test/
│   │   │   ├── btn_debounce.v
│   │   │   └── UART_test.sv
│   │   ├── fifo.sv
│   │   ├── InfDataController.sv
│   │   ├── UART_top.sv
│   │   └── uart_tx.sv
│   ├── src/
│   │   ├── tb_uart.sv
│   │   └── tb_uart_behav.wcfg
│   └── xdc/
│       └── UARTtest.xdc
├── VGA/
│   ├── RGB1-bit_test/
│   │   ├── src/
│   │   │   ├── ip/
│   │   │   ├── frameBuffer.sv
│   │   │   ├── FrameManager.sv
│   │   │   ├── FrameManager2.sv
│   │   │   ├── i2c_master.sv
│   │   │   ├── OV7670MemController.sv
│   │   │   ├── OV7670setting.mem
│   │   │   ├── SCCB_Controller.sv
│   │   │   ├── SCCB_sender.sv
│   │   │   ├── VGA_Decoder.sv
│   │   │   └── VGAtest_top.sv
│   │   └── xdc/
│   │       └── Basys-3-Master_CAM0.xdc
│   ├── UVM/
│   │   ├── rtl/
│   │   │   ├── FrameController.sv
│   │   │   ├── PixelBuffer.sv
│   │   │   └── VGA_top.sv
│   │   ├── tb/
│   │   │   ├── tb_vga.sv
│   │   │   ├── testImage.JPG
│   │   │   ├── testImage2.jpg
│   │   │   ├── testImage2_UVM.mem
│   │   │   ├── testImage3.jpg
│   │   │   ├── testImage3_UVM.mem
│   │   │   ├── testImage_UVM.mem
│   │   │   ├── uvm_component.sv
│   │   │   ├── vga_agent.sv
│   │   │   ├── vga_coverage.sv
│   │   │   ├── vga_driver.sv
│   │   │   ├── vga_env.sv
│   │   │   ├── vga_interface.sv
│   │   │   ├── vga_monitor.sv
│   │   │   ├── vga_scoreboard.sv
│   │   │   ├── vga_seq_item.sv
│   │   │   ├── vga_sequence.sv
│   │   │   └── vga_test.sv
│   │   ├── Makefile
│   │   ├── filelist.f
│   │   ├── simv_log.tar
│   │   ├── simv_random.log
│   │   └── simv_random_coverage.log
│   ├── src/
│   │   ├── FrameController.sv
│   │   ├── PixelBuffer.sv
│   │   └── VGA_top.sv
│   └── tb/
│       ├── tb_VGA_top.sv
│       ├── tb_VGA_top_behav.wcfg
│       └── testImage.mem
├── Wi-Fi/
│   ├── src/
│   │   ├── WiFi/
│   │   │   └── WiFi.ino
│   │   └── WiFi.c
│   └── test/
│       ├── Basys-3-Master_WiFi.xdc
│       ├── btn_debounce.v
│       └── Wi-Fi_UART_top.sv
├── test/
│   ├── FrameDataController.sv
│   ├── PL_top.sv
│   ├── PL_top_TestManual.md
│   ├── UART_test_top.sv
│   ├── Zybo-Z7.xdc
│   └── btn_debounce.v
├── PreProcess.sv
├── SYNC_2FF.sv
└── README.md
```