/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "xil_printf.h"

#include "ap_main.h"
#include "I2Cmaster/I2Cmaster.h"
#include "../HAL/TMR/TMR.h"
#include "../HAL/I2C/I2C.h"
#include "../driver/FND/FND.h"
#include "interrupt.h"



void ap_init() {
	SetupInterruptSystem();
	I2C_Init();
	FND_Init();
	LED_Init();
	Button_Init(&hBtnStart, GPIO, GPIO_PIN_0);
	Button_Init(&hBtnWrite, GPIO, GPIO_PIN_1);
	Button_Init(&hBtnRead, GPIO, GPIO_PIN_2);
	Button_Init(&hBtnStop, GPIO, GPIO_PIN_3);

	// 1MHz -> 1us 간격으로 count 증가, interrupt 발생 안함.
	TMR_SetPSC(TMR0, 100-1);
	TMR_SetARR(TMR0, 0xffffffff);
	TMR_StopIntr(TMR0);
	TMR_StartTimer(TMR0);

}

void ap_excute() {
	if(GPIO_ReadPin(SWB, GPIO_PIN_0)) MASTER_Write();
	else MASTER_Read();
//	FND_DispDigit();
}
