# 다기능 시계 시스템 FPGA 설계 및 검증 ⏱️

## 1. 프로젝트 개요
- 팀명: 7조
- 수행 기간: 2026.01.26 ~ 02.23
- 수행 내용: SR04(초음파센서), DHT11(온습도센서), UART, Stopwatch/Watch 다기능 FPGA 설계
- 사용 기술: `SystemVerilog` `C` `UVM` `Basys3`
- 담당 역할: SR04 Controller RTL 설계, UART 동작 검증
- 역할 분장:

| 윤수민 | 윤수현 | 윤정원 | 최수영 |
|:-----:|:-----:|:-----:|:-----:|
| SR04 Controller RTL 설계, UART 동작 검증 | DHT11 Controller RTL 설계, Stopwatch/Watch Datapath 동작 검증 | Stopwatch/Watch 추가 기능 RTL 설계, FPGA 통합 동작 검증 | Stopwatch/Watch Datapath 통합, UART RTL 설계 |

<br>

## 2. 주요 설계 내용
### 1) SR04 Controller


### 2) UART 동작 검증


<br>

## 3. 문제 해결



<br>

## 4. 프로젝트 결과물
### 동작 시연 영상


<br>

---
## Note. Directory Map

```text
kcci_2026/04_top_project/0_team_project/
├── src/
│   ├── rtl/
│   │   ├── btn_debounce.v
│   │   ├── control_unit.v
│   │   ├── dht11_controller.v
│   │   ├── fifo.v
│   │   ├── fnd_controller.v
│   │   ├── sr04_controller.v
│   │   ├── top_stopwatch_watch.v
│   │   ├── top_uart_wsw.v
│   │   ├── uart_top.v
│   │   └── watch_datapath.v
│   ├── sim/
│   │   ├── sim_1/
│   │   │   ├── tb_sr04_controller.v
│   │   │   ├── tb_stopwatch_datapath.v
│   │   │   ├── tb_top_uart_wsw_sr04.v
│   │   │   └── tb_uart_loop_back.v
│   │   └── sim_2/
│   │       └── tb_stopwatch_timeout.v
│   └── xdc/
│       └── Basys-3-Master.xdc
└── README.md
```