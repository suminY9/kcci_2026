#include "device_driver.h"

void LED_Init(void)
{
	/* 아래 코드 수정 금지 : Port-A Clock Enable */
	Macro_Set_Bit(RCC->AHB1ENR, 0);  // GPIOA Clock on

	// LED를 출력으로 설정하고 초기 OFF
	// 내부 LED
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x1, 10);
	Macro_Clear_Bit(GPIOA->OTYPER, 5);
	Macro_Clear_Bit(GPIOA->ODR, 5); 
	// 외부 LED (PA7)
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x1, 14);
	Macro_Clear_Bit(GPIOA->OTYPER, 7);
	Macro_Clear_Bit(GPIOA->ODR, 7);
}

void LED_On(int num)
{
	// LED On
	Macro_Set_Bit(GPIOA->ODR, num); 
}

void LED_Off(int num)
{
	// LED Off
	Macro_Clear_Bit(GPIOA->ODR, num); 
}

void LED_Toggle(int num)
{
	// LED Toggle
	Macro_Invert_Bit(GPIOA->ODR, num);
}

void LED_INT_On(void){
	LED_On(5);
}

void LED_INT_Off(void){
	LED_Off(5);
}

void LED_INT_Toggle(void){
	LED_Toggle(5);
}

void LED_EXT_On(void){
	LED_On(7);
}

void LED_EXT_Off(void){
	LED_Off(7);
}

void LED_EXT_Toggle(void){
	LED_Toggle(7);
}