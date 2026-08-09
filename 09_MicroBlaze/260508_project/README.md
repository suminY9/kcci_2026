# AXI4-Lite Protocol 기반 I2C, SPI 직렬 통신 FPGA 설계 및 검증 📡

## 1. 프로젝트 개요
- 수행 기간: 2026.04.27 ~ 05.08
- 수행 내용: AXI4-Lite 기반, I2C 및 SPI 통신 IP 설계
- 사용 기술: `SystemVerilog` `C` `MicroBlaze` `UVM` `Basys3`
- 담당 역할: AXI Slave, SPI, I2C RTL 설계 & SPI UVM 검증

<br>

## 2. 주요 설계 내용



<br>

## 3. 문제 해결



<br>

## 4. 프로젝트 결과물
### 동작 시연 영상


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