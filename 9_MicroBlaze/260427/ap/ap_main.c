/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "ap_main.h"
#include "../common/common.h"
#include "../driver/Button/Button.h"
#include "UpCounter/UpCounter.h"
#include "Clock/Clock.h"

hBtn_t hBtnClock;

void ap_init(){
	UpCounter_Init();
	Clock_Init();
	Button_Init(&hBtnClock, GPIOA, GPIO_PIN_5);  // Button R
}
void ap_execute(){
	while(1){
		UpCounter_Execute();

		millis_inc();
		delay_ms(1);
	}
}

void UpCounter_Execute(){
	UpCounter_DispLoop();

	static upcounter_state_t upCounterState = STOP;

	switch(upCounterState){
	case STOP:
		UpCounter_Stop();
		if(Button_GetState(&hBtnRunStop) == ACT_PUSHED) {
			upCounterState = RUN;
		}
		else if(Button_GetState(&hBtnClear) == ACT_PUSHED) {
			upCounterState = CLEAR;
		}
		break;
	case RUN:
		UpCounter_Run();
		if(Button_GetState(&hBtnRunStop) == ACT_PUSHED) {
			upCounterState = STOP;
		}
		break;
	case CLEAR:
		UpCounter_Clear();
		upCounterState = STOP;
		break;
	default: break;
	}
}
