# RISC-V 기반 Single-cycle CPU 설계 🧮

## 1. 프로젝트 개요
- 수행 기간: 2026.03.04 ~ 03.16
- 수행 내용: RV32I 명령어를 RTL로 구현, Single-cycle CPU 설계
- 사용 기술: `SystemVerilog` `C`
- 담당 역할: Single-cycle CPU RTL 설계 및 동작 검증

<br>

## 2. 주요 설계 내용
### 1) RV32I 명령어 동작 구현
<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
  <tr>
    <td style="text-align: center; border: none;">
      <img width="700" alt="System B/D" src="https://github.com/user-attachments/assets/613de519-ace6-4d7c-b311-272a03b518c6" style="max-width: 100%; height: auto;" />
    </td>
  </tr>
  <tr>
    <td style="text-align: center; border: none; padding-top: 5px;">
      <b>그림 1:</b> System Block Diagram
    </td>
  </tr>
</table>

- Havard 구조를 기반으로 명령어 메모리와 데이터 메모리 분리 설계
- 32-bit Datapath 구성. RISC-V 기반 RV32I 기본 명령어 셋 동작 구현 (R, I, S, L, B, U, J type 명령어 지원)

<br>

1. **R-type**
<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="R_B/D" src="https://github.com/user-attachments/assets/8d49a6bd-51f9-4851-81aa-9079366418f8" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="R_Scenario" src="https://github.com/user-attachments/assets/960d4130-8b05-461b-9e77-0e86e55c575b" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-1:</b> R-type Block Diagram
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-2:</b> R-type Simulation Scenario
    </td>
</tr>
  <tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="R_sim1" src="https://github.com/user-attachments/assets/9c99c358-f185-4d42-b6a2-3cef02aabfbc" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="R_sim2" src="https://github.com/user-attachments/assets/128b6a0e-b9aa-421d-8e48-f406f29ec615" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-3:</b> R-type Simulation 1
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 2-4:</b> R-type Simulation 2
    </td>
  </tr>
</table>

<br>

2. **S-type**
<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="S_B/D" src="https://github.com/user-attachments/assets/b3a073f8-1984-4cb9-8494-570748333b3f" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="S_Scenario" src="https://github.com/user-attachments/assets/e994190a-d7df-46b4-a217-e21b7b5f17f7" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-1:</b> S-type Block Diagram
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-2:</b> S-type Simulation Scenario
    </td>
</tr>
  <tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="S_sim1" src="https://github.com/user-attachments/assets/a55e021b-98aa-4e60-b6b5-96922708c185" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="S_sim2" src="https://github.com/user-attachments/assets/c86ea4a9-aedb-427d-b234-e76c2b82cb85" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-3:</b> S-type Simulation 1
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 3-4:</b> S-type Simulation 2
    </td>
  </tr>
</table>

<br>

3. **IL-type**
<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="IL_B/D" src="https://github.com/user-attachments/assets/592b6a5c-5fbe-4ccf-aec7-e26273334f5f" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="IL_Scenario" src="https://github.com/user-attachments/assets/a2ba6430-742f-444a-869d-60eb6dc643ad" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-1:</b> IL-type Block Diagram
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-2:</b> IL-type Simulation Scenario
    </td>
</tr>
  <tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="IL_sim1" src="https://github.com/user-attachments/assets/2819e4e1-1ca2-45dc-a8e2-d146dd86ed30" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="IL_sim2" src="https://github.com/user-attachments/assets/5d0fee6e-810d-4793-8e36-ee40fd4eb0b0" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-3:</b> IL-type Simulation 1
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 4-4:</b> IL-type Simulation 2
    </td>
  </tr>
</table>

<br>

4. **I-type**
<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="I_B/D" src="https://github.com/user-attachments/assets/14584f6b-852b-48ed-b582-8c1d1abd9920" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="I_Scenario" src="https://github.com/user-attachments/assets/056d3c0f-a0b7-4fcc-b9ee-044eef9d373a" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 5-1:</b> I-type Block Diagram
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 5-2:</b> I-type Simulation Scenario
    </td>
</tr>
  <tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="I_sim1" src="https://github.com/user-attachments/assets/3c507d73-4f11-4355-8e66-ee899fd366c9" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="I_sim2" src="https://github.com/user-attachments/assets/0a466633-15f5-4ecf-85cf-7c020467070f" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 5-3:</b> I-type Simulation 1
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 5-4:</b> I-type Simulation 2
    </td>
  </tr>
</table>

<br>

5. **B-type**
<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="B_B/D" src="https://github.com/user-attachments/assets/54d2d002-f3d2-4734-bc5a-d867b6cd307e" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="B_Scenario" src="https://github.com/user-attachments/assets/1afbe44e-f1e6-49d2-9004-2ff80bcb270f" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 6-1:</b> B-type Block Diagram
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 6-2:</b> B-type Simulation Scenario
    </td>
</tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="B_sim1" src="https://github.com/user-attachments/assets/c34c7dad-4fd7-408b-80a4-90bee6686acc" />
    </td>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 6-3:</b> B-type Simulation
    </td>
</table>

<br>

6. **U-type(LUI)**
<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
<tr>
    <td text-align: center; padding: 5px; border: none;">
      <img width="400" alt="LUI_B/D" src="https://github.com/user-attachments/assets/195ffa54-7054-4432-87ad-21c2cf8042d0" />
    </td>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 7:</b> U-type(LUI) Block Diagram
    </td>
</table>

<br>

7. **U-type(AUIPC)**
<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
<tr>
    <td text-align: center; padding: 5px; border: none;">
      <img width="400" alt="AUIPC_B/D" src="https://github.com/user-attachments/assets/50658c45-38b9-4082-aee1-3a90b3d2d5e3" />
    </td>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 8:</b> U-type(AUIPC) Block Diagram
    </td>
</table>

<br>

8. **J-type(JAL)**
<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
<tr>
    <td text-align: center; padding: 5px; border: none;">
      <img width="400" alt="JAL_B/D" src="https://github.com/user-attachments/assets/90675959-aba1-4806-bb23-d5cb6c39fc7c" />
    </td>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 9:</b> J-type(JAL) Block Diagram
    </td>
</table>

<br>

9. **J-type(JALR)**
<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
<tr>
    <td text-align: center; padding: 5px; border: none;">
      <img width="400" alt="JALR_B/D" src="https://github.com/user-attachments/assets/2eb1ec91-1733-4c5c-b317-9cb44668df9e" />
    </td>
<tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <b>그림 10:</b> J-type(JALR) Block Diagram
    </td>
</table>

<br>

<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="UJ_Scenario" src="https://github.com/user-attachments/assets/c15cd074-e160-464c-b3dd-69d96a054596" />
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="UJ_sim" src="https://github.com/user-attachments/assets/4023bbe6-2345-4c9a-83ae-8cdf36678b28" />
    </td>
  </tr>
<tr>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 11-1:</b> U,J-type Simulation Scenario
    </td>
    <td style="width: 50%; text-align: center; padding: 5px; border: none;">
      <b>그림 11-2:</b> U,J-type Simulation
    </td>
</table>

<br>

### 2) C -> Assembly -> hex 변환하여 CPU 동작 검증
<table style="width: 100%; border: none; border-collapse: collapse;">
<tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="100%" alt="C code" src="https://github.com/user-attachments/assets/b7124210-3551-4448-a1cc-84be8e726e5d" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="70%" alt="Assembly" src="https://github.com/user-attachments/assets/4f1f31ff-2aa2-4daf-863f-64969a0f31aa" />
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <img width="50%" alt="Hex" src="https://github.com/user-attachments/assets/a90fd068-20c1-44a1-a91b-61431387fe05" />
    </td>
<tr>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 12-1:</b> C code
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 12-2:</b> Assembly
    </td>
    <td style="width: 33%; text-align: center; padding: 5px; border: none;">
      <b>그림 12-3:</b> Hex code
    </td>
</table>

<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
<tr>
    <td text-align: center; padding: 5px; border: none;">
      <img width="700" alt="register file" src="https://github.com/user-attachments/assets/8c798ca7-52e5-49e0-8449-40e8ee5b0b62" />
    </td>
<tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <b>그림 12-4:</b> Register File
    </td>
</table>

- 1부터 10까지의 정수를 누적 덧셈하는 코드를 for문을 사용하여 C 코드 설계. Assembly 번역 후 명령어 메모리에 입력하여 시뮬레이션 진행. R, I, S, L, B, U, J 모든 type의 명령어가 정상 작동하여 최종 결과 값 '55'가 데이터 메모리에 저장된 것을 확인.

<br>

## 3. 프로젝트 결과물
### CPU 동작 검증 결과
<table style="width: 100%; border: none; border-collapse: collapse; margin-bottom: 20px;">
<tr>
    <td text-align: center; padding: 5px; border: none;">
      <img width="700" alt="memory" src="https://github.com/user-attachments/assets/cf7e93ad-31ef-4666-9fb2-2a6bece7bcec" />
    </td>
<tr>
    <td style="width: 100%; text-align: center; padding: 5px; border: none;">
      <b>그림 13:</b> Memory
    </td>
</table>

1부터 10까지 누적 덧셈하여 최종적으로 결과 값 '55'가 메모리에 저장됨.

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
