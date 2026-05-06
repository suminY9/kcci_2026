/*
 * interrupt.h
 *
 *  Created on: 2026. 4. 29.
 *      Author: kccistc
 */

#ifndef SRC_COMMON_INTERRUPT_H_
#define SRC_COMMON_INTERRUPT_H_


#include "xparameters.h"
#include "xintc.h"
#include "xil_exception.h" // 인터럽트 사용하려면 필요 함.
#include "../common/common.h"
#include "../driver/LED/LED.h"
#include "../HAL/I2C/I2C.h"

#define INTC_DEV_ID 	XPAR_INTC_0_DEVICE_ID
#define TMR_DEV_ID 		XPAR_TMR_0_DEVICE_ID
#define I2C_DEV_ID 		XPAR_I2C_MASTER_0_DEVICE_ID

void TMR_ISR(void *CallbackRef);
void I2C_ISR(void *CallbackRef);
int SetupInterruptSystem();


#endif /* SRC_COMMON_INTERRUPT_H_ */
