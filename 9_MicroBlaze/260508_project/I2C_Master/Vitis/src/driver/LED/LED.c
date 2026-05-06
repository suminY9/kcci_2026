/*
 * LED.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#include "LED.h"


void LED_Init(){
	GPIO_SetMode(LED_PORT_A, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, OUTPUT);
	GPIO_SetMode(LED_PORT_B, LED_PIN_12|LED_PIN_13|LED_PIN_14|LED_PIN_15, OUTPUT);
}

void LED_SetON(GPIO_Typedef_t *GPIOx, uint32_t LED_Pin){
	GPIO_WritePin(GPIOx, LED_Pin, LED_ON);
}

void LED_SetOFF(GPIO_Typedef_t *GPIOx, uint32_t LED_Pin){
	GPIO_WritePin(GPIOx, LED_Pin, LED_OFF);
}

void LED_AllOff(){
	GPIO_WritePin(LED_PORT_A, LED_PIN_0|LED_PIN_1|LED_PIN_2|LED_PIN_3|LED_PIN_4|LED_PIN_5|LED_PIN_6|LED_PIN_7, LED_OFF);
	GPIO_WritePin(LED_PORT_B, LED_PIN_12|LED_PIN_13|LED_PIN_14|LED_PIN_15, LED_OFF);
}
