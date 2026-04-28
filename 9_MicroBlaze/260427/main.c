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

int main(){
	GPIOA_CR = 0x0f; // ���� 4-bit�� �Է�, ���� 4-bit�� ���
	GPIOB_CR = 0xff;

	while(1){
		//GPIOB_CR = 0xff;
		GPIOB->CR = 0xff;

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
