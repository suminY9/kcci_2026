/*
 * LED.h
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_LED_LED_H_
#define SRC_DRIVER_LED_LED_H_


#include "../../HAL/GPIO/GPIO.h"


#define LED_PORT_A	LED
#define LED_PORT_B	GPIO

#define LED_PIN_0  	    GPIO_PIN_0
#define LED_PIN_1   	GPIO_PIN_1
#define LED_PIN_2      	GPIO_PIN_2
#define LED_PIN_3      	GPIO_PIN_3
#define LED_PIN_4      	GPIO_PIN_4
#define LED_PIN_5      	GPIO_PIN_5
#define LED_PIN_6      	GPIO_PIN_6
#define LED_PIN_7     	GPIO_PIN_7
#define LED_PIN_12		GPIO_PIN_4
#define LED_PIN_13		GPIO_PIN_5
#define LED_PIN_14		GPIO_PIN_6
#define LED_PIN_15		GPIO_PIN_7

#define LED_ON	1
#define LED_OFF	0

#define RightShift	0
#define LeftShift	1


void LED_Init();
void LED_SetON(GPIO_Typedef_t *GPIOx, uint32_t LED_Pin);
void LED_SetOFF(GPIO_Typedef_t *GPIOx, uint32_t LED_Pin);
void LED_AllOff();


#endif /* SRC_DRIVER_LED_LED_H_ */
