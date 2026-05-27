#include "device_driver.h"

void LED_Init(void)
{

	volatile int i;

	/* 아래 코드 수정 금지 : Port-A Clock Enable */
	Macro_Set_Bit(RCC->AHB1ENR, 0); 

	// LED를 출력으로 설정하고 초기 OFF
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x01, 10);
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x01, 14); // PA7
	Macro_Clear_Bit(GPIOA->OTYPER, 5);
	Macro_Set_Bit(GPIOA->OTYPER, 7);

	// Macro_Set_Bit(GPIOA->ODR, 5);
	Macro_Set_Bit(GPIOA->ODR, 5);
	Macro_Clear_Bit(GPIOA->ODR, 7);
	for(i = 0; i < 500000; i++);
	Macro_Clear_Bit(GPIOA->ODR, 5);
	Macro_Set_Bit(GPIOA->ODR, 7);
	for(i = 0; i < 500000; i++);
}

void LED_On(void)
{
	// LED On
	Macro_Set_Bit(GPIOA->ODR, 5);
}

void LED_Off(void)
{
	// LED Off
	Macro_Clear_Bit(GPIOA->ODR, 5);
}

void LED_Toggle(int * led){
	Macro_Invert_Bit(GPIOA->ODR, 5);
	*led ^= 1;
}

void LED_Display(int num){
	switch(num){
		case 0: Macro_Clear_Bit(GPIOA->ODR, 5); // All Off
				Macro_Set_Bit(GPIOA->ODR, 7);
		   		break;
		case 1: Macro_Set_Bit(GPIOA->ODR, 5); // PA5 On
				Macro_Set_Bit(GPIOA->ODR, 7);
		   		break;
		case 2: Macro_Clear_Bit(GPIOA->ODR, 5); // PA7 On
				Macro_Clear_Bit(GPIOA->ODR, 7);
		   		break;
		case 3: Macro_Set_Bit(GPIOA->ODR, 5); // All On
				Macro_Clear_Bit(GPIOA->ODR, 7);
		   		break;
	}
}
