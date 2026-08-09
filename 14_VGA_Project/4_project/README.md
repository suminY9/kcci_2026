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
OV7670의 설정을 세팅하기 위한 C code의 WriteSCCB(), ReadSCCB(), ResetSW(), SetResolution(), SetColorFormat(), AutoExposureMode(), SetBrightness(), AutoGainMode() 함수 동작을 SystemVerilog로 구현. <br>
SCCB는 I2C와 동작 원리가 같지만, ACK 신호가 모두 X라는 차이가 있음. <br>
System 구동 시 최초 1회만 실행되도록 설계. 함수 단위로 FSM의 state를 나눠서 함수의 수행을 마치면 tag를 1로 올려 IDLE상태일 때 tag가 하나라도 1이면 다음 state로 넘어가지 않도록 설계. 함수의 동작은 이중 FSM으로 구현. <br>
1. SCCB Write: 3-phase Write 동작, 한 번에 8-bit만 write. <br>
  1-phase: 7-bit IP address + Write(0) + ACK(X) <br>
  2-phase: 8-bit Register(sub) address + ACK(X) <br>
  3-phase: 8-bit Write data + ACK(X) <br>
2. SCCB Read: 2-Phase Write 후 2-Phase Read 동작, 한 번에 8-bit만 read. <br>
  Write 1-phase: 7-bit IP address + Write(0) + ACK(X) <br>
  Write 2-phase: 8-bit Register(sub) address + ACK(X) <br>
  Read 1-phase: 7-bit IP address + Read(1) + ACK(X) <br>
  Read 2-phase: 8-bit Read data + ACK(X) <br>

### VGA 설계
**VGA의 동작 순서**
1. OV7670 초기 설정 세팅.
2. 1 frame마다 FrameBuffer에 저장. RGB565 -> 16 bit/frame. <br>
  OV7670의 pixel clock과 VGA system의 clock이 다르므로 CDC 해결을 위해 Dual-Port RAM 사용.
3. Region Detector: Region 0~3 안에 빨간 색 물체가 있는지 확인. <br>
  붉은 색을 탐지하기 위해 RGB 중 `R > 4'b0100, G < 4'b0111, B < 4'b0111`를 만족하는 경우의 pixel이 50개가 넘을 때의 영역을 체크.
4. Filter_Region: 빨간 색 물체가 있는 영역을 붉게 필터링. <br>
  자연스러운 붉은 색 필터링을 위해 RGB 중 R 값을 유지하고, G, B 값을 1 bit right shift.
5. Filter_NOTE: 리듬 게임의 노트가 떠 있는 영역을 흰 색으로 필터링.
6. Filter_GAME: 리듬 게임의 탐지 영역 및 영역 구분선을 필터링해서 표시.


<br>

## 3. 문제 해결
### SCCB Controller ACK_IN 처리
- **문제**: 시뮬레이션에서는 Write, Read 모두 정상 동작을 하지만 실제로 보드에 올리면 정상 동작하지 않는 문제.
- **해결**: Logic Analyzer 분석 결과, Write가 잘 동작하다가 Read를 한 후에 ACK 신호가 제대로 나오지 않고 신호가 꼬여버리는 현상 발견. SCCB_Sender에서 I2C_Master를 instance할 때 ack_in을 1'bx로 설정했던 것을 1'b1로 변경.
- **결과**: Read 후에 NACK 신호가 발생하는 것 확인. 신호가 꼬이지 않고 Write, Read 모두 정상 동작하는 것을 확인.

I2C랑 동작이 같되, 모든 ACK 신호를 don't care로 주고 받는다고 생각해서 I2C_Master의 ack_in 신호를 1'bx로 설정했었는데 이것이 에러의 원인이었다. ACK 신호가 don't care인 것이 아니라 사용하지 않는 신호이므로 기본 대기 상태인 HIGH로 항상 올려주고 있어야 한다. 한 글자 차이인 이 오류를 찾기 위해 3일간 밤낮 코드를 재점검하면서, 설계에 있어서 통신 프로토콜의 정확한 숙지가 중요하다는 것을 크게 느꼈다.


### VGA 색상 처리
- **문제**: Filter_Region에서 빨간 색 물체가 있는 영역을 붉은 색으로 필터링 할 때, 붉은 색을 강조하기 위해 RGB 중 R 값에 4를 더하도록 했더니 붉은 색의 일부가 청록색으로 표시되는 문제 발생.
- **해결**: R값을 유지하고, G와 B 값을 1 bit 씩 right shift 하는 방식으로 변경.
- **결과**: 투명도 낮은 붉은 필터를 씌운 것처럼 자연스러운 붉은 색으로 필터링되고, 청록색이 나타나지 않게 개선됨.

R 값만 4를 증가시키면 R 값이 `4'b1100`이상일 때 오버플로우가 발생하여 의도하지 않은 색상이 출력되었던 것이 원인이었다. R값을 건드리는 것이 아니라 G, B 값을 낮춤으로써 붉은 색이 도드라지도록 수정하였더니, 의도했던 대로 자연스러운 붉은 색 필터를 완성할 수 있었다. 프레임 영역 감지와 색상 필터링을 설계하면서 영상 송출 원리에 대한 이해를 한 층 높일 수 있었다.

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