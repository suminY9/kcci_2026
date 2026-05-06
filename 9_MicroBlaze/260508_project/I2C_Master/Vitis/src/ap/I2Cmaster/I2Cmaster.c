/*
 * I2Cmaster.c
 *
 *  Created on: 2026. 5. 7.
 *      Author: user
 */

#include "I2Cmaster.h"
#include "../ap_main.h"

void MASTER_Write(){
	if(Button_GetState(&hBtnStart) == ACT_PUSHED) {
		I2C_SendAddr(0x40, 0);
		if(!I2C_IsACK()) return;
	}

	while(1){
		if(Button_GetState(&hBtnWrite) == ACT_PUSHED){
			I2C_TX = GPIO_ReadPort(SWA) & 0xff;
			I2C_Write();
			I2C_WaitDone();
			if(I2C_IsACK()) LED_SetON(LED_PORT_B, LED_PIN_15);
		}
		if(Button_GetState(&hBtnStop) == ACT_PUSHED){
			LED_AllOff();
			I2C_Stop();
			I2C_WaitDone();
			break;
		}
		FND_DispDigit();
	}
}

void MASTER_Read(){
	if(Button_GetState(&hBtnStart) == ACT_PUSHED){
		I2C_SendAddr(0x40, 1);
	}

	while(1){
		if(Button_GetState(&hBtnRead) == ACT_PUSHED){
			I2C_Read();
			I2C_WaitDone();

			uint8_t data = I2C_RX & 0xff;
			LED_AllOff();
			LED_SetON(LED_PORT_A, data);
		}
		if(Button_GetState(&hBtnStop) == ACT_PUSHED){
			I2C_Stop();
			I2C_WaitDone();
			break;
		}
		FND_DispDigit();
	}
}
