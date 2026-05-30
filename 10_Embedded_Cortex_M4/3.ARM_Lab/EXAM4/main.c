#include "device_driver.h"
#include <stdio.h>

#define INT_KEY 13
#define EXT_KEY 7

void Key_Enable(void);
int Key_Pressed(int);
void Key_Wait_Pressed(int);
void Key_Wait_Released(int);
void LED_Enable(void);
void LED_On(void);
void LED_Off(void);
void Systick_Run(unsigned int);
int Systick_Check_Timeout(void);


static void Sys_Init(int baud) 
{
	SCB->CPACR |= (0x3 << 10*2)|(0x3 << 11*2); 
	Clock_Init();
	Uart2_Init(baud);
	setvbuf(stdout, NULL, _IONBF, 0);
	LED_Init();
}


void Main(void)
{
	Sys_Init(115200);

	for(;;)
	{
		int state = 0; 		// 0: key_flag updat, 1: now key work 1 - timer start, 2: now key work 2 - timer triggered
		int key_1st = 0;	// now key
		int key_2nd = 0;	// input key during now key working -> can change
		int led_phase = 0;	// 0: led on, 1: led off & go to state 0

		switch(state){
			case 0:
				if(!key_2nd){
					key_1st = key_2nd;
					state = 1;
				}
				break;
			case 1:
				switch(key_1st){
					case INT_KEY:
						Systick_Run(1000);
						if(led_phase == 0) LED_On();
						else if(led_phase == 1) LED_Off();
						break;
					case EXT_KEY:
						Systick_Run(4000);
						if(led_phase == 0) LED_On();
						else if (led_phase == 1) LED_Off();
						break;
				}
				state = 2;
				break;
			case 2:
				if(Systick_Check_Timeout()){
					if(led_phase == 0){
						led_phase = 1;
						state = 1;
					}
					else if(led_phase == 1) state = 0;
				}
				break;
		}
		
		if(Key_Pressed(EXT_KEY)){
			Key_Wait_Released(EXT_KEY);
			key_2nd = EXT_KEY;
		}
		if(Key_Pressed(INT_KEY)){
			Key_Wait_Released(INT_KEY);
			key_2nd = INT_KEY;
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
}

void LED_On(void){
	Macro_Set_Bit(GPIOA->ODR, 5);
}

void LED_Off(void){
	Macro_Clear_Bit(GPIOA->ODR, 5);
}

void Systick_Run(unsigned int msec)
{
	// Timer 설정 : 인터럽트 발생 안함, clock source는 HCLK/8, Timer 정지
	Macro_Write_Block(SysTick->CTRL, 0x7, 0x0, 0);
	// 주어진 msec 값 만큼의 msec를 count하는 초기값 설정 (LOAD)
	Macro_Write_Block(SysTick->LOAD, 0xFFFFFF, (unsigned int)(msec*(HCLK/8000.)), 0);
	/* HCLK / 8 sec = HCLK / 8000 */
	// VAL 레지스터 값 초기화(0) 및 COUNTFLAG Clear
	Macro_Set_Bit(SysTick->VAL, 0);
	// Timer Start (시작이 되면 자동으로 LOAD의 값을 VAL로 가져간다)
	Macro_Set_Bit(SysTick->CTRL, 0);
}

int Systick_Check_Timeout(void)
{
	// Timer의 Timeout이 발생하면 참(1)리턴, 아니면 거짓(0) 리턴
	while(!Macro_Check_Bit_Set(SysTick->CTRL, 16)){
		return 0;
	}
	return 1;
}