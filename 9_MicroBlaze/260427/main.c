#include <stdint.h>
#include "xparameters.h"
#include "sleep.h"
#include "xil_printf.h"
#include "HAL/GPIO/GPIO.h"


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
