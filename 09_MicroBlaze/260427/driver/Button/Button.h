/*
 * Button.h
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#ifndef SRC_DRIVER_BUTTON_BUTTON_H_
#define SRC_DRIVER_BUTTON_BUTTON_H_


/*****Button Info******/
/* ButtonU: Run/Stop
 * ButtonD: Clear(Only when Stop)
 */

#include "../../HAL/GPIO/GPIO.h"
#include "../../common/common.h"

typedef enum {
	RELEASED = 0,
	PUSHED   = 1
}button_state_t;

typedef enum {
	NO_ACT 	  	 = 0,
	ACT_RELEASED = 1,
	ACT_PUSHED   = 2
}button_act_t;

typedef struct {
	GPIO_Typedef_t *GPIOx;
	uint32_t GPIO_Pin;
	button_state_t prevState;
}hBtn_t; // button handler


void Button_Init(hBtn_t *hbtn, GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin);
button_act_t Button_GetState(hBtn_t *hbtn);


#endif /* SRC_DRIVER_BUTTON_BUTTON_H_ */
