# AXI4-Lite Protocol 기반 I2C, SPI 직렬 통신 FPGA 설계 및 검증 📡

## 1. 프로젝트 개요
- 수행 기간: 2026.04.27 ~ 05.08
- 수행 내용: AXI4-Lite 기반, I2C 및 SPI 통신 IP 설계
- 사용 기술: `SystemVerilog` `C` `MicroBlaze` `UVM` `Basys3`
- 담당 역할: AXI Slave, SPI, I2C RTL 설계 & SPI UVM 검증

<br>

## 2. 주요 설계 내용
### 1) AXI4-Lite 기반 IP 설계
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="AXI" src="https://github.com/user-attachments/assets/17f2de0b-c4d5-4c56-85d9-3b0e2a7d2dc0" />
    </td>
  </tr>
  <tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <b>그림 1-1:</b> AXI Block Diagram
    </td>
  </tr>
</table>

VALID, READY 핸드셰이크 신호를 주고받는 AW, W, B, AR, R 채널 동작 구현. <br>
AXI Slave에 SPI, I2C 모듈을 연결하여 MicroBlaze MCU의 AXI 기반 Peripheral IP 설계.

<br>

### 2) I2C Protocol 구현
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <img width="600" alt="I2C" src="https://github.com/user-attachments/assets/3678f4a9-241d-4b3b-9c3d-5367dde5abcd" />
    </td>
  </tr>
  <tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-1:</b> I2C Block Design
    </td>
  </tr>
</table>
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="I2C" src="https://github.com/user-attachments/assets/a37e031c-c291-42f6-9ad4-da13fa57037b" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="I2C" src="https://github.com/user-attachments/assets/e0008b52-20f7-4103-9ed7-f5f211a24b47" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="I2C" src="https://github.com/user-attachments/assets/0fab49a3-b446-45c2-84c6-1938974fbaa9" />
    </td>
  </tr>
  <tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-2:</b> I2C Block Diagram
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-3:</b> I2C Register Map
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-4:</b> I2C Layer Architecture
    </td>
  </tr>
</table>

SDA/SCL 타이밍 설계를 통한 8-bit 직렬 전송 I2C 프로토콜 FSM 구현.

<br>

### 3) SPI Protocol 구현
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <img width="600" alt="SPI" src="https://github.com/user-attachments/assets/5c05a11c-18a4-4b3d-a736-7d8a019e4b28" />
    </td>
  </tr>
  <tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-1:</b> SPI Block Design
    </td>
  </tr>
</table>
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="SPI" src="https://github.com/user-attachments/assets/33c072c7-4b2e-4d69-a5f9-e494f1addf3a" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="SPI" src="https://github.com/user-attachments/assets/e0b8626f-19b8-45fe-bdc2-38876f7a3888" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="SPI" src="https://github.com/user-attachments/assets/57bb03d7-8b54-46aa-864a-7959324dc6ea" />
    </td>
  </tr>
  <tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-2:</b> SPI Block Diagram
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-3:</b> SPI Register Map
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-4:</b> SPI Layer Architecture
    </td>
  </tr>
</table>

CPOL/CPHA에 따른 SCLK 타이밍 구현을 통한 8-bit 데이터 직렬 전송 SPI 프로토콜 FSM 구현.

<br>

### 4) SPI Slave UVM 검증
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="SPI UVM" src="https://github.com/user-attachments/assets/e1a456f6-d244-44b4-8f24-ccf129240bf1" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="SPI UVM" src="https://github.com/user-attachments/assets/b948a7d3-c722-48fd-ab6e-c545c546a697" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="400" alt="SPI UVM" src="https://github.com/user-attachments/assets/a5950ae7-55f0-4595-afce-0845d6601452" />
    </td>
  </tr>
  <tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-1:</b> SPI UVM Structure
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-2:</b> SPI UVM Result
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-3:</b> SPI UVM Coverage
    </td>
  </tr>
</table>

데이터 무결성 검증 및 최대 동작 주파수 검증 수행 결과, ALL Pass.

<br>

## 3. 문제 해결
### 1) UVM 검증을 통한 SPI Master 타이밍 설계 오류 발견 및 개선
<table style="width: 100%; border: none; border-collapse: collapse;">
  <tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="500" alt="SPI Error" src="https://github.com/user-attachments/assets/c24a7d99-f52b-4ee4-aea7-6696210e73ec" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="500" alt="SPI Fixed" src="https://github.com/user-attachments/assets/0d52ea78-1254-4e56-9bcb-5403258f6c76" />
    </td>
  </tr>
  <tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 5-1:</b> SPI Master Simulation (Error)
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 5-2:</b> SPI Master Simulation (Fixed)
    </td>
  </tr>
</table>

- **문제**: SPI Master의 데이터 무결성 UVM 검증 결과 특정 데이터 수신 시 마지막 bit가 무시되는 오류 발견
- **해결**: FSM(IDLE-START-WAIT_CMD-DATA-ACK-STOP) state 중 DATA state에서 8-bit를 완성하면 STOP state로 진행하도록 설계하여 타이밍이 어긋났던 것으로 판단. 마지막 bit를 STOP state에서 수신하도록 수정
- **결과**: 모든 bit가 누락 없이 정상 수신되는 것을 확인. UVM 검증 결과 ALL Pass
- **배운점**: 통신 모듈은 '신호의 타이밍'이 가장 중요하다는 것을 많이 느꼈고, 설계 뿐만 아니라 디버깅을 하는 데에 있어서도 각각의 신호에 대한 충분한 이해가 필수적으로 동반되어야 함을 체감했다. <br>


<br>

## 4. 프로젝트 결과물
### 1) I2C 동작 시연 영상
https://github.com/user-attachments/assets/ebe45d4e-4f98-49ba-b4d6-450f4cd766c6
1. Master 보드의 SW를 조작한다.
2. Master 보드의 start 버튼을 누르면 Slave 보드의 FND에 SW로 조작한 수가 십진수 형태로 출력된다.


### 2) SPI 동작 시연 영상
https://github.com/user-attachments/assets/3434e3e1-f6f3-4c69-8609-32a21b23f7e6
1. Master 보드의 SW를 조작한다.
2. Master 보드의 start 버튼을 누르면 Slave 보드의 FND에 SW로 조작한 수가 십진수 형태로 출력된다.


<br>

---
## Note. Directory Map

```text
kcci_2026/09_MicroBlaze/260508_project/
├── I2C_Master/
│   ├── Vitis/
│   │   ├── XSA/
│   │   │   └── design_1_wrapper.xsa
│   │   └── src/
│   │       ├── HAL/
│   │       │   ├── GPIO/
│   │       │   │   ├── GPIO.c
│   │       │   │   └── GPIO.h
│   │       │   ├── I2C/
│   │       │   │   ├── I2C.c
│   │       │   │   └── I2C.h
│   │       │   └── TMR/
│   │       │       ├── TMR.c
│   │       │       └── TMR.h
│   │       ├── ap/
│   │       │   ├── I2Cmaster/
│   │       │   │   ├── I2Cmaster.c
│   │       │   │   └── I2Cmaster.h
│   │       │   ├── ap_main.c
│   │       │   ├── ap_main.h
│   │       │   ├── interrupt.c
│   │       │   └── interrupt.h
│   │       ├── common/
│   │       │   ├── common.c
│   │       │   └── common.h
│   │       ├── driver/
│   │       │   ├── Button/
│   │       │   │   ├── Button.c
│   │       │   │   └── Button.h
│   │       │   ├── FND/
│   │       │   │   ├── FND.c
│   │       │   │   └── FND.h
│   │       │   └── LED/
│   │       │       ├── LED.c
│   │       │       └── LED.h
│   │       └── main.c
│   └── Vivado/
│       ├── design_1/
│       └── Basys-3-Master.xdc
├── I2C_Slave/
│   ├── bd_top_i2c_slave.sv
│   ├── bd_top_i2c_slave.xdc
│   ├── i2c_fnd.sv
│   └── i2c_slave.sv
├── SPI_Master/
│   ├── Vitis/
│   │   ├── XSA/
│   │   │   └── design_1_wrapper.xsa
│   │   └── src/
│   │       ├── HAL/
│   │       │   ├── GPIO/
│   │       │   │   ├── GPIO.c
│   │       │   │   └── GPIO.h
│   │       │   ├── SPI/
│   │       │   │   ├── SPI.c
│   │       │   │   └── SPI.h
│   │       │   └── TMR/
│   │       │       ├── TMR.c
│   │       │       └── TMR.h
│   │       ├── ap/
│   │       │   ├── ap_main.c
│   │       │   ├── ap_main.h
│   │       │   ├── interrupt.c
│   │       │   └── interrupt.h
│   │       ├── common/
│   │       │   ├── common.c
│   │       │   └── common.h
│   │       ├── driver/
│   │       │   ├── Button/
│   │       │   │   ├── Button.c
│   │       │   │   └── Button.h
│   │       │   ├── FND/
│   │       │   │   ├── FND.c
│   │       │   │   └── FND.h
│   │       │   └── LED/
│   │       │       ├── LED.c
│   │       │       └── LED.h
│   │       └── main.c
│   └── Vivado/
│       ├── design_1/
│       └── Basys-3-Master.xdc
├── SPI_Slave/
│   ├── bd_top_spi_slave.sv
│   ├── bd_top_spi_slave.xdc
│   ├── spi_fnd.sv
│   └── spi_slave.sv
└── README.md
```
