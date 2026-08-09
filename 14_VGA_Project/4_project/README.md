# Rhythm Game 🎥

## 1. 프로젝트 개요
- 팀명: 3팀
- 수행 기간: 2026.07.09 ~ 07.21
- 수행 내용: VGA 활용, 색상 탐지 방식 리듬 게임 개발
- 사용 기술: `SystemVerilog` `Python` `UVM` `Basys3`
- 담당 역할: SCCB Controller, VGA 설계 및 동작 검증
- 역할 분장:

| 김수빈 | 김지홍 | 문태성 | 서어진 | 송주연 | 윤수민 | 조준호 |
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
| GameResult, UVM | UART Sender, Music ROM data | Line Counter | Python UI | UART Receiver, Music ROM data | SCCB Controller, VGA | MainController |

<br>

## 2. 주요 설계 내용
### SCCB Controller 설계

### VGA 설계


<br>

## 3. 문제 해결
### SCCB Controller ACK_IN 처리
- **문제**: 
- **해결**: 
- **결과**: 

### VGA 색상 처리
- **문제**: 
- **해결**: 
- **결과**: 

<br>

## 4. 프로젝트 결과물
### 동작 시연 영상


<br>

---
## Note. Directory Map

```text
Project/
├── UVM/
│   ├── rtl/
│   │   ├── GameResult.sv
│   │   ├── line_count.sv
│   │   ├── score.sv
│   │   └── top_game.sv
│   ├── tb/
│   │   ├── rhythmGame_agent.sv
│   │   ├── rhythmGame_coverage.sv
│   │   ├── rhythmGame_driver.sv
│   │   ├── rhythmGame_env.sv
│   │   ├── rhythmGame_interface.sv
│   │   ├── rhythmGame_monitor.sv
│   │   ├── rhythmGame_scoreboard.sv
│   │   ├── rhythmGame_seq_item.sv
│   │   ├── rhythmGame_sequence.sv
│   │   ├── rhythmGame_test.sv
│   │   ├── tb_rhythmGame.sv
│   │   └── uvm_component.sv
│   ├── closure_sim.log
│   ├── random_70_sim.log
│   └── random_single_40_sim.log
├── python/
│   ├── music_data/
│   │   ├── rom_data/
│   │   │   ├── convert_notes.py
│   │   │   └── rom_format.md
│   │   └── sing_main_image/
│   └── rhythm_game/
│       ├── __pycache__/
│       ├── screens/
│       ├── config.py
│       ├── leaderboard.json
│       ├── leaderboard.py
│       ├── main.py
│       └── uart_handler.py
├── src/
│   ├── VGA/
│   │   ├── OV7670MemController.sv
│   │   ├── OV7670_SCCB_Controller.sv
│   │   ├── OV767setting.mem
│   │   ├── Region_Detector.sv
│   │   ├── SCCB_sender.sv
│   │   ├── VGA_Decoder.sv
│   │   ├── VGAcam.sv
│   │   ├── frameBuffer.sv
│   │   ├── frameController.sv
│   │   ├── framePrinter.sv
│   │   └── i2c_master.sv
│   ├── maincontroller/
│   │   ├── BtnDebouncer.sv
│   │   ├── GameResult.sv
│   │   ├── MainControl.sv
│   │   └── score.sv
│   └── uart receiver/
│       ├── MainController.py
│       ├── fifo.py
│       ├── linecounter.py
│       ├── receiver.py
│       ├── sender.py
│       ├── top.py
│       ├── top_module.py
│       └── uart_rx.py
├── xdc/
│   └── Basys-3_Master.xdc
└── README.md
```