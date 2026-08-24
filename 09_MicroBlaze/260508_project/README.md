# AXI4-Lite Protocol 기반 I2C, SPI 직렬 통신 FPGA 설계 및 검증 📡

## 1. 프로젝트 개요
- 수행 기간: 2026.04.27 ~ 05.08
- 수행 내용: AXI4-Lite 기반, I2C 및 SPI 통신 IP 설계
- 사용 기술: `SystemVerilog` `C` `MicroBlaze` `UVM` `Basys3`
- 담당 역할: AXI Slave, SPI, I2C RTL 설계 & SPI UVM 검증

<br>

## 2. 주요 설계 내용
### 1) AXI Protocol
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


<br>

### 2) I2C Protocol
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


<br>

### 3) SPI Protocol
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


<br>

### 4) SPI Slave UVM Verification
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


<br>

## 3. 문제 해결



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
