/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "xil_printf.h"

#include "ap_main.h"
#include "../HAL/TMR/TMR.h"
#include "UpCounter/UpCounter.h"
#include "TimeClock/TimeClock.h"
#include "interrupt.h"


typedef enum {
	UPCOUNTER,
	CLOCK
}mode_t;

hBtn_t hBtnMode, hBtnClockMode;

void ap_init() {
	UpCounter_Init();
	TimeClock_Init();
	SetupInterruptSystem();

	// 1MHz -> 1us 간격으로 count 증가, interrupt 발생 안함.
	TMR_SetPSC(TMR0, 100-1);
	TMR_SetARR(TMR0, 0xffffffff);
	TMR_StopIntr(TMR0);
	TMR_StartTimer(TMR0);

	// 1kHz -> 1ms 간격으로 interrupt 발생
	TMR_SetPSC(TMR1, 100-1);
	TMR_SetARR(TMR1, 1000-1);
	TMR_StartIntr(TMR1);
	TMR_StartTimer(TMR1);

	// 100Hz -> 10ms 간격으로 interrupt 발생
	TMR_SetPSC(TMR2, 100-1);
	TMR_SetARR(TMR2, 10000-1);
	TMR_StartIntr(TMR2);
	TMR_StartTimer(TMR2);

	Button_Init(&hBtnMode, GPIOA, GPIO_PIN_5);
	Button_Init(&hBtnClockMode, GPIOA, GPIO_PIN_6);
}

void ap_excute() {

	static mode_t mode = UPCOUNTER;
	static clock_mode_t clock_mode = SECMSEC;

	while (1) {
		switch (mode) {
			case UPCOUNTER:
				UpCounter_Excute();
				if (Button_GetState(&hBtnMode) == ACT_RELEASED) {
					mode = CLOCK;
				}
				break;
			case CLOCK:
				TimeClock_Execute(clock_mode);
				if (Button_GetState(&hBtnMode) == ACT_RELEASED) {
					mode = UPCOUNTER;
					FND_SetDP(FND_DIGIT_100,FND_DP_OFF);
				}
				else if (Button_GetState(&hBtnClockMode) == ACT_RELEASED){
					switch (clock_mode){
					case SECMSEC:
						clock_mode = HOURMIN;
						break;
					case HOURMIN:
						clock_mode = SECMSEC;
						break;
					default: clock_mode = SECMSEC; break;
					}
				}
				break;
			}
		}
}
