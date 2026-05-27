#include "device_driver.h"

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

unsigned int SysTick_Get_Time(void)
{
	// Timer의 현재 count 값 리턴
	unsigned int tim = 0;
	for(int i = 0; i < 24; i++){
		tim |= (Macro_Check_Bit_Set(SysTick->VAL, i) << i);
	}

	return tim;
}

unsigned int SysTick_Get_Load_Time(void)
{
	// Timer에 설정된 초기값을 리턴
	unsigned int tim = 0;
	for(int i = 0; i < 24; i++){
		tim |= (Macro_Check_Bit_Set(SysTick->LOAD, i) << i);
	}	

	return tim;
}

void SysTick_Stop(void)
{
	// Timer Stop
	Macro_Clear_Bit(SysTick->CTRL, 0);
}
