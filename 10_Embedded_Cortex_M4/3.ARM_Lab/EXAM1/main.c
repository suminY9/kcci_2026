#include "stm32f4xx.h"
#include "option.h"
#include "macro.h"
#include <stdio.h>


void Key_Enable(void);
int Key_Pressed(void);
void Key_Wait_Pressed(void);
void Key_Wait_Released(void);
void LED_Enable(void);
void LED_Toggle(void);


void Main(void)
{
	int cnt = 0;

	Key_Enable();
	LED_Enable();
	
	for(;;)
	{
		if(Key_Pressed()){
			Key_Wait_Released();
			cnt++;

			if(cnt == 2) {
				LED_Toggle();
				cnt = 0;
			}
		}
	}
}


void Key_Enable(void){
	Macro_Set_Bit(RCC->AHB1ENR, 2); // GPIOC clock on
	Macro_Write_Block(GPIOC->MODER, 0x3, 0x0, 26); // PC13 input
}

int Key_Pressed(void)
{
	if(Macro_Check_Bit_Clear(GPIOC->IDR, 13)) return 1;
	else return 0;
}

void Key_Wait_Pressed(void)
{
	while(!Macro_Check_Bit_Clear(GPIOC->IDR, 13));
}

void Key_Wait_Released(void){
	while(!Macro_Check_Bit_Set(GPIOC->IDR, 13));
}

void LED_Enable(void){
	Macro_Set_Bit(RCC->AHB1ENR, 0); // GPIOA clock on

	// Internal LED Enable
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x1, 10);
	Macro_Clear_Bit(GPIOA->OTYPER, 5);
	Macro_Clear_Bit(GPIOA->ODR, 5); 
}

void LED_Toggle(void){
	Macro_Invert_Bit(GPIOA->ODR, 5);
}