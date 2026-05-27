/*
 * I2C.c
 *
 *  Created on: 2026. 5. 7.
 *      Author: user
 */

#include "I2C.h"
#include "xil_printf.h"

void I2C_Init(){
    I2C_CR = 0x0010;
    I2C_SR = 0x0000;
    I2C_RX = 0x0000;
    // intr_en = 1
    // cmd_start, cmd_write, cmd_read, cmd_stop = 0
}

void I2C_SetSW(){
    I2C_TX = GPIO_ReadPort(SWA) & 0xff;
}

void I2C_Start(){
	xil_printf("now: I2C_Start \n");
	I2C_CR |= (1<<0) | (1<<1);
    xil_printf("now: I2C_Start: I2C_CR = %d \n", I2C_CR);
}

void I2C_Write(){
	xil_printf("now: I2C_Write \n");
    I2C_CR |= (1<<1);
    xil_printf("now: I2C_Start: I2C_CR = %d \n", I2C_CR);
}

void I2C_Read(){
	xil_printf("now: I2C_Read \n");
    I2C_CR |= (1<<2);
    xil_printf("now: I2C_Start: I2C_CR = %d \n", I2C_CR);
}

void I2C_Stop(){
	xil_printf("now: I2C_Stop \n");
    I2C_CR |= (1<<3);
    xil_printf("now: I2C_Start: I2C_CR = %d \n", I2C_CR);
}

uint8_t I2C_IsDone(){
    if(I2C_SR == 0x0003) return 1;
    else if (I2C_SR == 0x0002) return 1;
    return 0;
}

void I2C_WaitDone(){
	xil_printf("now: WaitDone() \n");
	xil_printf("now: I2C_SR = %d \n", I2C_SR);
    while(!I2C_IsDone());
    xil_printf("now: done! \n");
}

uint8_t I2C_IsACK(){
    if(I2C_RX & (1<<8)) return 1;
    return 0;
}

void I2C_SendAddr(uint8_t addr, uint8_t is_read) {
    I2C_TX = (addr << 0) | ((is_read & 0x01) << 7);
    xil_printf("now: Send Addr: I2C_TX = %d \n", I2C_TX);
    I2C_CR |= (1<<0) | (1<<1);
    I2C_WaitDone();
}
