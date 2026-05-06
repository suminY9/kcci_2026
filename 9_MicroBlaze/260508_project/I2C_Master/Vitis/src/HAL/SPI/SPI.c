/*
 * SPI.c
 *
 *  Created on: 2026. 5. 6.
 *      Author: user
 */

#include "SPI.h"

void SPI_Init(){
	SPI_CR = 0x0044;
	// clk_div = 4
	// mode = 0
	// intr_en = HIGH
}

void SPI_SetSW(){
	SPI_TX = GPIO_ReadPort(SW) & 0xff;
}

void SPI_Start(){
	SPI_TX |= 0x0100;
}

void SPI_RxRead(){
	LED_AllOff();
	LED_SetON(SPI_RX & 0xff);
	FND_SetNum(SPI_RX & 0xff);
}
