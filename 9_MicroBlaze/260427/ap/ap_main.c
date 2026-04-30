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

hBtn_t hBtnMode;

void ap_init(){
	UpCounter_Init();
	Clock_Init();
	Button_Init(&hBtnMode, GPIOA, GPIO_PIN_5);
}
void ap_execute(){
	static mode_t mode = UPCOUNTER;

	while(1){
		if(mode == UPCOUNTER)	UpCounter_Execute();
		else if(mode == CLOCK)	Clock_Execute();

		millis_inc();
		delay_ms(1);

		switch (mode) {
			case UPCOUNTER:
				if (Button_GetState(&hBtnMode) == ACT_PUSHED) {
					mode = CLOCK;
				}
				break;
			case CLOCK:
				if (Button_GetState(&hBtnMode) == ACT_PUSHED) {
					mode = UPCOUNTER;
				}
				break;
		}
	}
}

