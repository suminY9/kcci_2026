#include "stm32f4xx.h"
#include "option.h"
#include "macro.h"
#include "malloc.h"
#include <stdio.h>


void Key_Enable(void);
int Key_Get_Pressed(void);
void Key_Wait_Key_Pressed(void);
void Key_Wait_Key_Released(void);
void LED_Enable(void);
void LED_Toggle(void);


void Clock_Init(void)
{
	RCC->CR |= (1 << 0); 
    while(!Macro_Check_Bit_Set(RCC->CR, 1));
	
    FLASH->ACR = (1<<12)|(1<<11);
    FLASH->ACR = (1<<10)|(1<<9)|(1<<8)|(0x3 << 0);
	
    RCC->PLLCFGR = (8<<24)|(0<<22)|(1<<16)|(192<<6)|(8<<0);
	
    Macro_Set_Bit(RCC->CR, 24);
    while(!Macro_Check_Bit_Set(RCC->CR, 25));
	
    RCC->CFGR = (0<<13)|(4<<10)|(0<<4);
	
    Macro_Write_Block(RCC->CFGR, 0x3, 0x2, 0);
    while(Macro_Extract_Area(RCC->CFGR, 0x3, 2) != 0x2);
}

static void Sys_Init(int baud) 
{
	SCB->CPACR |= (0x3 << 10*2)|(0x3 << 11*2); 
	Clock_Init();
	setvbuf(stdout, NULL, _IONBF, 0);
}


void Main(void)
{
	int cnt = 0;

	Sys_Init(115200);
	Key_Enable();
	LED_Enable();
	
	for(;;)
	{
		if(Key_Get_Pressed()){
			Key_Wait_Key_Released();
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

int Key_Get_Pressed(void)
{
	if(Macro_Check_Bit_Clear(GPIOC->IDR, 13)) return 1;
	else return 0;
}

void Key_Wait_Key_Pressed(void)
{
	while(!Macro_Check_Bit_Clear(GPIOC->IDR, 13));
}

void Key_Wait_Key_Released(void){
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