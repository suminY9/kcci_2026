#include <stdint.h>
#include "xparameters.h"
#include "sleep.h"
#include "xil_printf.h"

typedef struct {
	uint32_t CR;
	uint32_t IDR;
	uint32_t ODR;
}GPIO_Typedef_t;

#define GPIOA_BASE_ADDR	0x44A00000
#define GPIOB_BASE_ADDR 0x44A10000

#define GPIOA_CR	(*(uint32_t *) (GPIOA_BASE_ADDR + 0x00))
#define GPIOA_IDR	(*(uint32_t *) (GPIOA_BASE_ADDR + 0x04))
#define GPIOA_ODR	(*(uint32_t *) (GPIOA_BASE_ADDR + 0x08))
#define GPIOB_CR	(*(uint32_t *) (GPIOB_BASE_ADDR + 0x00))
#define GPIOB_IDR	(*(uint32_t *) (GPIOB_BASE_ADDR + 0x04))
#define GPIOB_ODR	(*(uint32_t *) (GPIOB_BASE_ADDR + 0x08))

#define GPIOA	((GPIO_Typedef_t *) (GPIOA_BASE_ADDR))
#define GPIOB	((GPIO_Typedef_t *) (GPIOB_BASE_ADDR))

#define GPIO_PIN_0	0x01 // 0b00000001
#define GPIO_PIN_1	0x02 // 0b00000010
#define GPIO_PIN_2	0x04 // 0b00000100
#define GPIO_PIN_3	0x08 // 0b00001000
#define GPIO_PIN_4	0x10 // 0b00010000
#define GPIO_PIN_5	0x20 // 0b00100000
#define GPIO_PIN_6	0x40 // 0b01000000
#define GPIO_PIN_7	0x80 // 0b10000000

#define INPUT	0x00
#define OUTPUT	0x01

#define RESET	0
#define	SET		1

void GPIO_SetMode(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin, itn gpio_dir){  // GPIO의 주소, 32-bit register이므로 uint32_t, direction
	if(GPIO_dir == OUTPUT)	GPIOx->CR |= GPIO_Pin;
	else					GPIOx->CR &= ~(GPIO_Pin);
}
void GPIO_WritePin(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin, int level){
	if(level == SET)		GPIOx->ODR |= GPIO_Pin;
	else					GPIOx->ODR &= ~(GPIO_Pin);
}
uint32_t GPIO_ReadPin(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin){
	return (GPIOx->IDR & GPIO_Pin) ? 1 : 0;
}
void GPIO_WritePort(GPIO_Typedef_t *GPIOx, uint32_t GPIO_Pin, int data){
	GPIOx->ODR = data;
}
uint32_t GPIO_ReadPort(GPIO_Typedef_t *GPIOx){
	return GPIOx->IDR;
}

int main(){
	GPIOA_CR = 0x0f; // 상위 4-bit는 입력, 하위 4-bit는 출력
	GPIOB_CR = 0xff;

	while(1){
		GPIOA->CR = 0x0f;
		GPIOB->CR = 0xff;

		GPIO_SetMode(GPIOA, GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, OUTPUT);
		GPIO_SetMode(GPIOA, GPIO_PIN_4|GPIO_PIN_5|GPIO_PIN_6|GPIO_PIN_7, INPUT);

		GPIOB_ODR = 0x00;
		if ((GPIOA->IDR & (1<<4))) {
			GPIOA->ODR &= ~(1<<0);
			GPIO_WritePin(GPIOA, GPIO_PIN_1, SET);
		}
		else if ((GPIOA->IDR & (1<<5))) {
			GPIOA->ODR &= ~(1<<1);
		}
		else if ((GPIOA->IDR & (1<<6))) {
			GPIOA->ODR &= ~(1<<2);
		}
		else if ((GPIOA->IDR & (1<<7))) {
			GPIOA->ODR &= ~(1<<3);
		}
		else {
			GPIOA->ODR |= (0x0f);
		}
	}

	return 0;
}
