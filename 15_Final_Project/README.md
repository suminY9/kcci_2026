# Smart Parking Lot 🚗

## 1. 프로젝트 개요
- 팀명: Cars대라
- 수행 기간: 2026.07.22 ~ 08.18
- 수행 내용: 차량 번호판 인식, 차량 맞춤 빈 자리 안내, 주차 요금 자동 정산. 스마트 무인 주차장 시스템 개발
- 사용 기술: `SystemVerilog` `C` `Python` `MicroBlaze` `UVM` `Zybo Z7-20` `ESP32` `Jetson Orin Nano`
- 담당 역할: PreProcess(SR04, SG90, VGA, UART, Wi-Fi) RTL Design & VGA UVM Verification
- 역할 분장:

| 김수빈 | 김지홍 | 문태성 | 서어진 | 송주연 | 윤수민 | 조준호 |
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|  |  |  |  |  |  |  |

<br>

## 2. 주요 설계 내용



<br>

## 3. 문제 해결



<br>

## 4. 프로젝트 결과물
### 시연 환경 세팅

### 동작 시연 영상


<br>

---
## Note. Directory Map

```text
Project/
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
├── PreProcess.sv
├── SYNC_2FF.sv
└── README.md
```