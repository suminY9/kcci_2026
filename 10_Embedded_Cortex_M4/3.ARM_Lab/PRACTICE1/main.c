#include "device_driver.h"
#include <stdio.h>

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
volatile int TIM2_Expired = 0;
int cnt_1sec_led = 1;
int cnt_500msec = 1;
int cnt_1sec_uart = 1;
int uart_tag = 0;

void Main(void)
{
	Sys_Init(115200);
	printf("\n***PRACTICE 1***\n");

	Key_ISR_Enable(1);
	Uart2_RX_Interrupt_Enable(1);
	TIM2_Repeat_Interrupt_Enable(1, 100);

	for(;;)
	{
		if(TIM2_Expired)
	    {
			// Internal LED Toggle
			if(cnt_1sec_led%10) {
				cnt_1sec_led++;
			} else {
				LED_INT_Toggle();
				cnt_1sec_led = 1;
			}

			// External LED Toggle When Key pressed
			if(Key_Pressed){
				if(cnt_500msec%5) cnt_500msec++;
				else{
					if(Key_Pressed > 3){
						Key_Pressed = 0;
						LED_EXT_Off();
					} else {
						LED_EXT_Toggle();
						Key_Pressed++;
					}
					cnt_500msec = 1;
				}
			}

			// Send 'h', 'i' When 'a' Recieved
			if(Uart_Data_In){
				if(!uart_tag) {
					Uart2_Send_Byte('h');
					uart_tag = 1;
					cnt_1sec_uart = 1;
				}
				else if(cnt_1sec_uart%10) cnt_1sec_uart++;
				else if(uart_tag) {
					Uart2_Send_Byte('i');
					uart_tag = 0;
					Uart_Data_In = 0;
					cnt_1sec_uart = 1;
				}
			}

			TIM2_Expired = 0;
	    }
	}
}
