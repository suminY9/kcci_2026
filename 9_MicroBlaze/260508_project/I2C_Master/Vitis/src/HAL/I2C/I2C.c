/*
 * I2C.c
 *
 *  Created on: 2026. 5. 7.
 *      Author: user
 */

#include "I2C.h"

void I2C_Init(){
    I2C_CR = 0x0010;
    // intr_en = 1
    // cmd_start, cmd_write, cmd_read, cmd_stop = 0
}

void I2C_SetSW(){
    I2C_TX = GPIO_ReadPort(SWA) & 0xff;
}

void I2C_Start(){
    I2C_CR |= 0x0001;
}

void I2C_Write(){
    I2C_CR |= 0x0002;
}

void I2C_Read(){
    I2C_CR |= 0x0004;
}

void I2C_Stop(){
    I2C_CR |= 0x0008;
}

uint8_t I2C_IsDone(){
    if(I2C_SR == 0x0002) return 1;
    return 0;
}

void I2C_WaitDone(){
    while(!I2C_IsDone());
}

uint8_t I2C_IsACK(){
    if(I2C_RX & (1<<8)) return 1;
    return 0;
}

void I2C_SendAddr(uint8_t addr, uint8_t is_read) {
    I2C_TX = (addr << 1) | (is_read & 0x01);
    I2C_Start();
    I2C_Write();
    I2C_WaitDone();
}
