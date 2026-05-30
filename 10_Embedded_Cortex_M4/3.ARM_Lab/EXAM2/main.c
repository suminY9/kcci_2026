#include "device_driver.h"
#include <stdio.h>


void Key_Enable(void);
int Key_Pressed(int);
void Key_Wait_Pressed(int);
void Key_Wait_Released(int);
void LED_Enable(void);
void LED_INT_On(void);
void LED_INT_Off(void);
void LED_EXT_On(void);
void LED_EXT_Off(void);


#define INT_KEY 13
#define EXT_KEY 7


static void Sys_Init(int baud) 
{
	SCB->CPACR |= (0x3 << 10*2)|(0x3 << 11*2); 
	Clock_Init();
	Uart2_Init(baud);
	setvbuf(stdout, NULL, _IONBF, 0);
}


int phase = 1;

void Main(void)
{
	Sys_Init(115200);
	for(;;)
	{
		switch(phase){
			case 0:
				LED_INT_Off();
				LED_EXT_Off();
				break;
			case 1:
			case 3:
				LED_INT_Off();
				LED_EXT_On();
				break;
			case 2:
			case 4:
				LED_INT_On();
				LED_EXT_Off();
				break;
		}

		if(Key_Pressed(EXT_KEY)){
			Key_Wait_Released(EXT_KEY);
			phase = 0;
		}
		if(Key_Pressed(INT_KEY)){
			Key_Wait_Released(INT_KEY);
			phase++;
			if(phase == 4) phase = 1;
		}
	}
}


void Key_Enable(void){
	Macro_Set_Bit(RCC->AHB1ENR, 2); // GPIOC clock on
	Macro_Write_Block(GPIOC->MODER, 0x3, 0x0, 26); // PC13 input
	Macro_Write_Block(GPIOC->MODER, 0x3, 0x0, 14); // PC7 input
}

int Key_Pressed(int key_num)
{
	if(Macro_Check_Bit_Clear(GPIOC->IDR, key_num)) return 1;
	else return 0;
}

void Key_Wait_Pressed(int key_num)
{
	while(!Macro_Check_Bit_Clear(GPIOC->IDR, key_num));
}

void Key_Wait_Released(int key_num){
	while(!Macro_Check_Bit_Set(GPIOC->IDR, key_num));
}

void LED_Enable(void){
	Macro_Set_Bit(RCC->AHB1ENR, 0); // GPIOA clock on

	// Internal LED Enable
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x1, 10);  // PA5
	Macro_Clear_Bit(GPIOA->OTYPER, 5);
	Macro_Clear_Bit(GPIOA->ODR, 5); 

	// External LED Enable
	Macro_Write_Block(GPIOA->MODER, 0x3, 0x1, 14);  // PA7
	Macro_Clear_Bit(GPIOA->OTYPER, 7);
	Macro_Clear_Bit(GPIOA->ODR, 7);
}

void LED_INT_On(void){
	Macro_Set_Bit(GPIOA->ODR, 5);
}

void LED_INT_Off(void){
	Macro_Clear_Bit(GPIOA->ODR, 5);
}

void LED_EXT_On(void){
	Macro_Set_Bit(GPIOA->ODR, 7);
}

void LED_EXT_Off(void){
	Macro_Clear_Bit(GPIOA->ODR, 7);
}