/*
 * GPIO.h
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#ifndef SRC_HAL_GPIO_GPIO_H_
#define SRC_HAL_GPIO_GPIO_H_


#include <stdint.h>

typedef struct {
	uint32_t CR;
	uint32_t IDR;
	uint32_t ODR;
} GPIO_Typedef_t; 

#define GPIO8A_BASE_ADDR 0x44A00000
#define GPIO8B_BASE_ADDR 0x44A10000
#define GPIO8C_BASE_ADDR 0x44A20000
#define GPIO4A_BASE_ADDR 0x44A30000
#define GPIO4B_BASE_ADDR 0x44A40000

#define GPIO8A_CR  (*(uint32_t *) (GPIO8A_BASE_ADDR + 0x00))
#define GPIO8A_IDR (*(uint32_t *) (GPIO8A_BASE_ADDR + 0x04))
#define GPIO8A_ODR (*(uint32_t *) (GPIO8A_BASE_ADDR + 0x08))

#define GPIO8B_CR  (*(uint32_t *) (GPIO8B_BASE_ADDR + 0x00))
#define GPIO8B_IDR (*(uint32_t *) (GPIO8B_BASE_ADDR + 0x04))
#define GPIO8B_ODR (*(uint32_t *) (GPIO8B_BASE_ADDR + 0x08))

#define GPIO8C_CR  (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x00))
#define GPIO8C_IDR (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x04))
#define GPIO8C_ODR (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x08))

#define GPIO4C_CR  (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x00))
#define GPIO4C_IDR (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x04))
#define GPIO4C_ODR (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x08))

#define GPIO4C_CR  (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x00))
#define GPIO4C_IDR (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x04))
#define GPIO4C_ODR (*(uint32_t *) (GPIO8C_BASE_ADDR + 0x08))

#define LED 	  ((GPIO_Typedef_t *) (GPIO8A_BASE_ADDR))
#define SW  	  ((GPIO_Typedef_t *) (GPIO8B_BASE_ADDR))
#define FND_DATA  ((GPIO_Typedef_t *) (GPIO8C_BASE_ADDR))
#define FND_DIGIT ((GPIO_Typedef_t *) (GPIO4A_BASE_ADDR))
#define GPIO	  ((GPIO_Typedef_t *) (GPIO4B_BASE_ADDR))

#define GPIO_PIN_0 0x01 // 0b00000001
#define GPIO_PIN_1 0x02 // 0b00000010
#define GPIO_PIN_2 0x04 // 0b00000100
#define GPIO_PIN_3 0x08 // 0b00001000
#define GPIO_PIN_4 0x10 // 0b00010000
#define GPIO_PIN_5 0x20 // 0b00100000
#define GPIO_PIN_6 0x40 // 0b01000000
#define GPIO_PIN_7 0x80 // 0b10000000

#define INPUT   0
#define OUTPUT  1

#define RESET   0
#define SET     1


void GPIO_SetMode(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin, int GPIO_Dir); // �����ݷ� �� �ٿ��� �Ѵ�!!!
void GPIO_WritePin(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin, int level);
uint32_t GPIO_ReadPin(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin);
void GPIO_WritePort(GPIO_Typedef_t *GPIOx, int data);
uint32_t GPIO_ReadPort(GPIO_Typedef_t *GPIOx);


#endif /* SRC_HAL_GPIO_GPIO_H_ */
