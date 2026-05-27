// 여기에 사용자 임의의 define을 작성하시오

#define GPIOA_MODER		(*(int *)0x40020000)
#define GPIOA_OTYPER	(*(int *)0x40020004) 
#define GPIOA_ODR		(*(int *)0x40020014)

void Main(void)
{
	volatile int i;

	// LED GPA[5]를 출력(General Push Pull) 모드로 설정하시오

	GPIOA_MODER = 0x00005400;
	GPIOA_OTYPER = 0x000000C0;

	// GPA[5] LED를 ON 시키도록 설정하시오

	// GPIOA_ODR = 0x00000020;

	// LED toggle
	while(1){
		GPIOA_ODR = 0x000000E0; //GREED ON
		for(i = 0; i < 10000000; i++){}
		GPIOA_ODR = 0x000000A0; //YELLOW on
		for(i = 0; i < 1000000; i++){}
		GPIOA_ODR = 0x000000E0; //YELLOW on
		for(i = 0; i < 1000000; i++){}
		GPIOA_ODR = 0x000000A0; //YELLOW on
		for(i = 0; i < 1000000; i++){}
		GPIOA_ODR = 0x00000040; // RED on
		for(i = 0; i < 10000000; i++){}
	}
}
