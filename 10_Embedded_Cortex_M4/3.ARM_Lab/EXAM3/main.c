#include "device_driver.h"
#include <stdio.h>


void TIM4_Repeat(int);
int TIM4_Check_Timeout(void);
void TIM4_Stop(void);
void LED_Toggle(void);
int Is_Uart_Data_In(void);
void Uart2_Send_Char(char data);


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
	char Uart_Data;

	Sys_Init(115200);
	TIM4_Repeat(1000);

	for(;;)
	{
		if(TIM4_Check_Timeout()) LED_Toggle();

		if(Is_Uart_Data_In()){
			Uart_Data = (char)USART2->DR;
			Uart2_Send_Char(Uart_Data);
			Uart2_Send_Char(Uart_Data + 1);
		}
	}
}

void TIM4_Repeat(int time)
{
	Macro_Set_Bit(RCC->APB1ENR, 2);

	// TIM4 CR1: ARPE=0, down counter, repeat mode
	TIM4->CR1 = (0 << 7) | (1 << 4) | (0 << 3);
	// PSC(50KHz),  ARR(reload시 값) 설정
	TIM4->PSC = (unsigned int)(TIMXCLK / (1000000. / 20.) + 0.5) - 1;
	TIM4->ARR = (unsigned int)(time * (1. / 0.02));
	// UG 이벤트 발생
	Macro_Set_Bit(TIM4->EGR, 0);
	// Update Interrupt Pending Clear
	Macro_Clear_Bit(TIM4->SR, 0);
	// TIM4 start
	Macro_Set_Bit(TIM4->CR1, 0);
}

int TIM4_Check_Timeout(void)
{
	// 타이머가 timeout 이면 1 리턴, 아니면 0 리턴
	if(Macro_Check_Bit_Set(TIM4->SR, 0)){
		Macro_Clear_Bit(TIM4->SR, 0);
		return 1;
	}
	else return 0;
}

void TIM4_Stop(void)
{
	Macro_Clear_Bit(TIM4->CR1, 0);
}

void LED_Toggle(void){
	Macro_Invert_Bit(GPIOA->ODR, 5);
}

int Is_Uart_Data_In(void){
	if(Macro_Check_Bit_Set(USART2->SR, 5)) return 1;
	else return 0;
}

void Uart2_Send_Char(char data)
{
  if(data == '\n'){
    while(!Macro_Check_Bit_Set(USART2->SR, 7));
    USART2->DR = 0x0d;
  }

  while(!Macro_Check_Bit_Set(USART2->SR, 7));
  USART2->DR = data;
}