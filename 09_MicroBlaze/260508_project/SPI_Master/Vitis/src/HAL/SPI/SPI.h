/*
 * SPI.h
 *
 *  Created on: 2026. 5. 6.
 *      Author: user
 */

#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_

#include "xparameters.h"
#include "../../driver/LED/LED.h"
#include "../../driver/FND/FND.h"
#include "../GPIO/GPIO.h"

#define SPI_CR	(*(uint32_t *)(XPAR_SPI_MATER_0_S00_AXI_BASEADDR + 0x00))
#define SPI_TX	(*(uint32_t *)(XPAR_SPI_MATER_0_S00_AXI_BASEADDR + 0x04))
#define SPI_RX	(*(uint32_t *)(XPAR_SPI_MATER_0_S00_AXI_BASEADDR + 0x08))
#define SPI_SR	(*(uint32_t *)(XPAR_SPI_MATER_0_S00_AXI_BASEADDR + 0x0C))

void SPI_Init();
void SPI_SetSW();
void SPI_Start();
void SPI_RxRead();

#endif /* SRC_HAL_SPI_SPI_H_ */
