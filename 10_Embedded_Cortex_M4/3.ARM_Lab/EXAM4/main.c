#include "device_driver.h"
#include <stdio.h>

#define INT_KEY 13
#define EXT_KEY 7

void LED_Enable(void);
void LED_On(void);
void LED_Off(void);
void SysTick_Run(unsigned int);
int SysTick_Check_Timeout(void);


static void Sys_Init(int baud) 
{
	SCB->CPACR |= (0x3 << 10*2)|(0x3 << 11*2); 
	Clock_Init();
	Uart2_Init(baud);
	setvbuf(stdout, NULL, _IONBF, 0);
	LED_Init();
}

volatile int Key_Pressed = 0;
volatile int Uart_Data_In = 0;
volatile unsigned char Uart_Data = 0;
volatile int TIM4_Expired = 0;

int cnt = 1;

void Main(void)
{
	Sys_Init(115200);
	printf("\nTimer 4 Interrupt Test\n");

	// Key_ISR_Enable(1);
	// Uart2_RX_Interrupt_Enable(0);
	// TIM4_Repeat_Interrupt_Enable(1, 200);

	for(;;)
	{
		int key_1st_flag;
		int key_2nd_flag;

		switch(key_1st_flag){
			INT_KEY:
				LED_On();
				SysTick_Run(1000);
				key_1st_flag = 0;
				break;
			EXT_KEY:
				LED_On();
				SysTick_Run(4000);
				key_1st_flag = 0;
				break;
			0:
				if(SysTick_Check_Timeout())	LED_Off();
		}
		
		switch(key_2nd_flag){
			INT_KEY:
				SysTick_Run(1000);
				break;
			EXT_KEY:
				SysTick_Run(4000);
				break;
			0: 
				if(SysTick_Check_Timeout())	LED_On();
		}
		
		if(Key_Get_Pressed(EXT_KEY)){
			Key_Wait_Key_Released(EXT_KEY);
			if(!key_1st_flag) key_2nd_flag = EXT_KEY;
			else key_1st_flag = EXT_KEY;
		}
		if(Key_Get_Pressed(INT_KEY)){
			Key_Wait_Key_Released(INT_KEY);
			if(!key_1st_flag) key_2nd_flag = INT_KEY;
			else key_1st_flag = INT_KEY;
		}
	}
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

void SysTick_Run(unsigned int msec)
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

int SysTick_Check_Timeout(void)
{
	// Timer의 Timeout이 발생하면 참(1)리턴, 아니면 거짓(0) 리턴
	while(!Macro_Check_Bit_Set(SysTick->CTRL, 16)){
		return 0;
	}
	return 1;
}