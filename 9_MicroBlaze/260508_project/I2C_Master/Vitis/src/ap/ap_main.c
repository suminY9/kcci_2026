/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "xil_printf.h"

#include "ap_main.h"
#include "../HAL/TMR/TMR.h"
#include "../HAL/SPI/SPI.h"
#include "../driver/FND/FND.h"
#include "../driver/Button/Button.h"
#include "interrupt.h"

hBtn_t hBtnStart;

void ap_init() {
	SetupInterruptSystem();
	SPI_Init();
	FND_Init();
	LED_Init();
	Button_Init(&hBtnStart, GPIO, GPIO_PIN_0);

	// 1MHz -> 1us 간격으로 count 증가, interrupt 발생 안함.
	TMR_SetPSC(TMR0, 100-1);
	TMR_SetARR(TMR0, 0xffffffff);
	TMR_StopIntr(TMR0);
	TMR_StartTimer(TMR0);

}

void ap_excute() {
	if (Button_GetState(&hBtnStart) == ACT_PUSHED) {
		SPI_SetSW();
		SPI_Start();
	}
	FND_DispDigit();
}
