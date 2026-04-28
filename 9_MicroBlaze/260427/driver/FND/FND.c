/*
 * FND.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#include "FND.h"

uint16_t fndNumData = 0;
uint8_t fndFont[16] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90, 0x88, 0x83, 0xc6, 0xa1, 0x86, 0x8e};
uint8_t fndDot = 0x7f;

void FND_Init(){
	// GPIO 설정, GPIOA 0, 1, 2, 3 COM(common port) 연결
	GPIO_SetMode(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OUTPUT);
	// GPIO 설정, GPIOB seg a~f, dp 연결
	GPIO_SetMode(FND_FONT_PORT, SEG_PIN_A|SEG_PIN_B|SEG_PIN_C|SEG_PIN_D|SEG_PIN_E|SEG_PIN_F|SEG_PIN_G|SEG_PIN_DP, OUTPUT);
}
void FND_SetComPort(GPIO_Typedef_t *GPIOx, uint32_t Seg_Pin, int OnOFF){
	GPIO_WritePin(FND_COM_PORT, Seg_Pin, OnOFF);
}
void FND_DispDigit(){
	static uint8_t fndDigState = 0;
	fndDigState = (fndDigState + 1) % 4;

	switch(fndDigState){
		case 0:
			FND_DispDigit_1();
			break;
		case 1:
			FND_DispDigit_10();
			break;
		case 2:
			FND_DispDigit_100();
			break;
		case 3:
			FND_DispDigit_1000();
			break;
		default: break;
	}
}
void FND_DispDigit_1(){
	// data의 자릿수 분리
	uint8_t digitData1 = fndNumData % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData1]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1, ON);
}
void FND_DispDigit_10(){
	// data의 자릿수 분리
	uint8_t digitData10 = fndNumData / 10 % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData10]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_2, ON);
}
void FND_DispDigit_100(){
	// data의 자릿수 분리
	uint8_t digitData100 = fndNumData / 100 % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData100]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_3, ON);
}
void FND_DispDigit_1000(){
	// data의 자릿수 분리
	uint8_t digitData1000 = fndNumData / 1000 % 10;
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndFont[digitData1000]);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_4, ON);
}
void FND_DispDigit_DP() {
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
	GPIO_WritePort(FND_FONT_PORT, fndDot);
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_3, ON);
}
void FND_SetNum(uint16_t num){
	fndNumData = num;
}
void FND_DispOn(){
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, ON);
}
void FND_DispOFF(){
	FND_SetComPort(FND_COM_PORT, FND_COM_DIG_1|FND_COM_DIG_2|FND_COM_DIG_3|FND_COM_DIG_4, OFF);
}
