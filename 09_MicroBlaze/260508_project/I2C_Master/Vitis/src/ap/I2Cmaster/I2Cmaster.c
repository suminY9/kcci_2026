/*
 * I2Cmaster.c
 *
 *  Created on: 2026. 5. 7.
 *      Author: user
 */

#include "I2Cmaster.h"
#include "../ap_main.h"
#include "xil_printf.h"

void MASTER_Write(){
	xil_printf("now: MASTER_Write() \n");
	if(Button_GetState(&hBtnStart) == ACT_PUSHED) {
		xil_printf("now: Start Button PUSHED \n");
		I2C_SendAddr(0x40, 0);
		if(!I2C_IsACK()) return;


	while(1){
		if(Button_GetState(&hBtnWrite) == ACT_PUSHED){
			xil_printf("now: Write Button PUSHED \n");
			I2C_TX = GPIO_ReadPort(SWA) & 0xff;
			xil_printf("now: I2C_TX = %d \n", I2C_TX);
			I2C_Write();
			I2C_WaitDone();
			if(I2C_IsACK()) {
				LED_SetON(LED_PORT_B, LED_PIN_15);
				xil_printf("now: Done \n");
			}
		}
		if(Button_GetState(&hBtnStop) == ACT_PUSHED){
			xil_printf("now: Stop Button PUSHED \n");
			LED_AllOff();
			I2C_Stop();
			I2C_WaitDone();
			return;
		}
		LED_AllOff();
		LED_SetON(LED, I2C_RX & 0xff);
	}
	}
}

void MASTER_Read(){
	xil_printf("now: MASTER_Read() \n");
	if(Button_GetState(&hBtnStart) == ACT_PUSHED){
		xil_printf("now: Start Button PUSHED \n");
		I2C_SendAddr(0x40, 1);


	while(1){
		if(Button_GetState(&hBtnRead) == ACT_PUSHED){
			xil_printf("now: Read Button PUSHED \n");
			I2C_Read();
			I2C_WaitDone();
			xil_printf("now: Done \n");

			uint8_t data = I2C_RX & 0xff;
			xil_printf("now: I2C_RX = %d \n", data);
			LED_AllOff();
			LED_SetON(LED_PORT_A, data);
			FND_SetNum(data);
		}
		if(Button_GetState(&hBtnStop) == ACT_PUSHED){
			xil_printf("now: Stop Button PUSHED \n");
			I2C_Stop();
			I2C_WaitDone();
			xil_printf("now: Done \n");
			return;
		}
		LED_AllOff();
		LED_SetON(LED, I2C_RX & 0xff);
	}
	}
}
