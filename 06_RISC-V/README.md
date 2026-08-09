# RISC-V 기반 Single-cycle CPU 설계 🧮

## 1. 프로젝트 개요
- 수행 기간: 2026.03.04 ~ 03.16
- 수행 내용: RV32I 명령어를 RTL로 구현, Single-cycle CPU 설계
- 사용 기술: `SystemVerilog` `C`
- 담당 역할: Single-cycle CPU RTL 설계 및 동작 검증

<br>

## 2. 주요 설계 내용
### RV32I 명령어 동작 구현


### C -> Assembly -> hex 변환하여 CPU 동작 검증


<br>

## 3. 문제 해결



<br>

## 4. 프로젝트 결과물
### CPU 동작 검증 결과


<br>

---
## Note. Directory Map

```text
kcci_2026_06_RISC_V/
├── src/
│   ├── my_RISC-V/
│   │   ├── APB_GPI.sv
│   │   ├── APB_GPIO.sv
│   │   ├── APB_GPO.sv
│   │   ├── APB_Master.sv
│   │   ├── BRAM.sv
│   │   ├── U_APB_FND.sv
│   │   ├── U_APB_UART.sv
│   │   ├── data_mem.sv
│   │   ├── define.vh
│   │   ├── fifo.v
│   │   ├── instruction_mem.sv
│   │   ├── rv32i_cpu.sv
│   │   ├── rv32i_datapath.sv
│   │   └── rv32i_top.sv
│   └── practice/
├── tb/
│   ├── tb_apb_master.sv
│   ├── tb_dedicated_cpu.sv
│   ├── tb_dedicated_cpu1.sv
│   ├── tb_dedicated_cpu2.sv
│   └── tb_rv32i.sv
├── xdc/
│   └── Basys-3_Master.xdc
└── README.md
```