/*
 * ap_main.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "ap_main.h"
#include "../common/common.h"
#include "UpCounter/UpCounter.h"

void ap_init(){
	UpCounter_Init();
}
void ap_execute(){
	while(1){
		UpCounter_Execute();

		millis_inc();
		delay_us(10);
	}
}
