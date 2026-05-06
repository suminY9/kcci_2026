/*
 * I2C.h
 *
 *  Created on: 2026. 5. 7.
 *      Author: user
 */

#ifndef SRC_HAL_I2C_I2C_H_
#define SRC_HAL_I2C_I2C_H_

#include <stdint.h>
#include "xparameters.h"
#include "../../driver/LED/LED.h"
#include "../../driver/FND/FND.h"
#include "../GPIO/GPIO.h"

#define I2C_CR  (*(uint32_t *)(XPAR_I2C_MASTER_0_S00_AXI_BASEADDR + 0x00))
#define I2C_TX	(*(uint32_t *)(XPAR_I2C_MASTER_0_S00_AXI_BASEADDR + 0x04))
#define I2C_RX	(*(uint32_t *)(XPAR_I2C_MASTER_0_S00_AXI_BASEADDR + 0x08))
#define I2C_SR	(*(uint32_t *)(XPAR_I2C_MASTER_0_S00_AXI_BASEADDR + 0x0C))

void I2C_Init();
void I2C_SetSW();
void I2C_Start();
void I2C_Write();
void I2C_Read();
void I2C_Stop();
uint8_t I2C_IsDone();
void I2C_WaitDone();
uint8_t I2C_IsACK();
void I2C_SendAddr(uint8_t addr, uint8_t is_read);

#endif /* SRC_HAL_I2C_I2C_H_ */
