/*
 * LED.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#include "LED.h"


void LED_Init(){
	GPIO_SetMode(LED_PORT, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, OUTPUT);
}

void LED_SetON(uint32_t LED_Pin){
	GPIO_WritePin(LED_PORT, LED_Pin, LED_ON);
}

void LED_SetOFF(uint32_t LED_Pin){
	GPIO_WritePin(LED_PORT, LED_Pin, LED_OFF);
}

void LED_AllOff(){
	GPIO_WritePin(LED_PORT, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, LED_OFF);
}

typedef struct{
	uint8_t Right;
	uint8_t Left;
}Shift_state_t;
Shift_state_t shift_state = { 3, 0 };

void LED_Shift(int RL){
	static uint8_t ShiftState;

	if(RL == RightShift) 			ShiftState = (shift_state.Right) % 4;
	else if(RL == LeftShift) 		ShiftState = shift_state.Left;

	switch (ShiftState) {
	case 0:
		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
		LED_SetON(LED_PIN_0);
		break;
	case 1:
		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
		LED_SetON(LED_PIN_1);
		break;
	case 2:
		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
		LED_SetON(LED_PIN_2);
		break;
	case 3:
		LED_SetOFF(LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3);
		LED_SetON(LED_PIN_3);
		break;
	}
}

void LED_IncShiftState(){
	if(shift_state.Left > 3) shift_state.Left = 0;
	else shift_state.Left++;
}

void LED_DecShiftState(){
	if(shift_state.Right < 0) shift_state.Right = 3;
	else shift_state.Right--;
}
