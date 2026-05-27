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

/* Key 인식 */

#if 1

void Main(void)
{
	Sys_Init(115200);
	printf("KEY Input Test #1\n");

	/* 아래 코드 수정 금지 : Port-C Clock Enable */
	Macro_Set_Bit(RCC->AHB1ENR, 2); 
	
	// KEY(PC13)을 GPIO 입력으로 선언
	Macro_Write_Block(GPIOC->MODER, 0x3, 0x0, 26);
	Macro_Write_Block(GPIOC->PUPDR, 0x3, 0x1, 14); // PC7 pull-up 설정
	Macro_Write_Block(GPIOC->MODER, 0x3, 0x0, 14);
	
	for(;;)
	{
		// KEY가 눌렸으면 LED(PA5) ON, 안 눌렸으면 OFF
		// if(Macro_Check_Bit_Clear(GPIOC->IDR, 13)) LED_On();
		if(Macro_Check_Bit_Clear(GPIOC->IDR, 7) | Macro_Check_Bit_Clear(GPIOC->IDR, 13)) LED_On();
		else LED_Off();
	}
}

#endif

/* Key에 의한 LED Toggling */

#if 0

void Main(void)
{
	Sys_Init(115200);
	printf("KEY Input Toggling #1\n");

	int lock = 0;

	Macro_Set_Bit(RCC->AHB1ENR, 2); 
	Macro_Write_Block(GPIOC->MODER, 0x3, 0x0, 26);

	for(;;)
	{
		// KEY(PC13)이 눌릴때마다 LED(PA5)가 Toggling하도록 코드 작성		
		// if(tmp && Macro_Check_Bit_Clear(GPIOC->IDR, 13)) {
		// 	tmp = 0;
		// 	Macro_Invert_Bit(GPIOA->ODR, 5);
		// }
		// else if(!tmp) tmp = 1;

		// 방법 1
		if(Macro_Check_Bit_Clear(GPIOC->IDR, 13)){
			Macro_Invert_Bit(GPIOA->ODR, 5);
			while(Macro_Check_Bit_Set(GPIOC->IDR, 13));
		}

		// 방법 2
		int prev_state, cur_state;
		prev_state = 1;		// 1: pushed, 0: released
		for(;;){
			cur_state = Macro_Check_Bit_Set(GPIOC->IDR, 13);
			if(prev_state == 1 && cur_state == 0) Macro_Invert_Bit(GPIOA->ODR, 5);
			prev_state = cur_state;
		}

		// 방법 3
		for(;;){
			if((lock == 0) && (Macro_Check_Bit_Clear(GPIOC->IDR, 13))){
				Macro_Invert_Bit(GPIOA->ODR, 5);
				lock = 1;
			}
			else if((lock == 1) && (Macro_Check_Bit_Set(GPIOC->IDR, 13))){
				lock = 0;
			}
		}
	}
}

#endif
