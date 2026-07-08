# SCCB_Data_Controller.sv

### 2026.07.08

ResetSW(IDLE -> P1 -> (P2 -> P3) -> P4 -> (P2 -> P3) -> P5 -> P6)

  <br>

```text
Project/
├── ResetSW/
│   ├── IDLE : WriteSCCB(REG_COM7, 0x80)
│   ├── P1 : delay30ms
│   ├── P2 : Config()
│   ├── P3 : delay1ms
│   ├── P4 : delay10ms
│   ├── P5 : SetResolution(QVGA)_SetFrameControl
│   ├── P6 : SetColorFormat
│   ├── WRITE
│   ├── READ1 : READ 1st Phase
│   └── READ2 : READ 2nd Phase
├── ShowColorBar/
├── AutoExposureMode/
│   ├── P1
│   ├── WRITE
│   ├── READ1 : READ 1st Phase
│   └── READ2 : READ 2nd Phase
├── SetBrightness/
│   ├── P1
│   └── WRITE
├── AutoGainMode/
│   ├── P1
│   ├── WRITE
│   ├── READ1 : READ 1st Phase
│   └── READ2 : READ 2nd Phase
└── README.md
```

  <br>
  <br>


### 26.07.09
no READ

  <br>

```text
Project/
├── ResetSW/
│   ├── IDLE : WriteSCCB(REG_COM7, 0x80)
│   ├── P1 : delay30ms
│   ├── P2 : Config()
│   ├── P3 : delay1ms
│   ├── P4 : delay10ms
│   ├── P5 : SetResolution(QVGA)_SetFrameControl
│   ├── P6 : SetColorFormat
│   └── WRITE
├── ShowColorBar/
├── AutoExposureMode/
│   ├── P1 : Use READ
│   ├── P2 : No READ
│   ├── WRITE
│   ├── READ1 : READ 1st Phase
│   └── READ2 : READ 2nd Phase
├── SetBrightness/
│   ├── P1
│   └── WRITE
├── AutoGainMode/
│   ├── P1 : Use READ
│   ├── P2 : No READ
│   ├── WRITE
│   ├── READ1 : READ 1st Phase
│   └── READ2 : READ 2nd Phase
└── README.md
```