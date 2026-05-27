/*
 * LED.h
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_LED_LED_H_
#define SRC_DRIVER_LED_LED_H_


#include "../../HAL/GPIO/GPIO.h"


#define LED_PORT	GPIOC

#define LED_PIN_0  	    GPIO_PIN_0
#define LED_PIN_1   	GPIO_PIN_1
#define LED_PIN_2      	GPIO_PIN_2
#define LED_PIN_3      	GPIO_PIN_3
#define LED_PIN_4      	GPIO_PIN_4
#define LED_PIN_5      	GPIO_PIN_5
#define LED_PIN_6      	GPIO_PIN_6
#define LED_PIN_7     	GPIO_PIN_7

#define LED_ON	1
#define LED_OFF	0

#define RightShift	0
#define LeftShift	1


void LED_Init();
void LED_SetON(uint32_t LED_Pin);
void LED_SetOFF(uint32_t LED_Pin);
void LED_AllOff();
void LED_Shift(int RL);
void LED_IncShiftState();
void LED_DecShiftState();


#endif /* SRC_DRIVER_LED_LED_H_ */
