/*
 * Clock.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "Clock.h"

typedef struct{
	uint32_t hour;
	uint32_t min;
	uint32_t sec;
	uint32_t msec;
}Clock_Data;

Clock_Data ClockData;

void Clock_Init(){
	FND_Init();
	//ClockData = { }; /****current clock initialize****/
}
void Clock_DispLoop(){
	FND_DispDigit();
	if(!(millis() % 5)) FND_DispDot();
}
void ClockCount(Clock_Data *clock_data){
	if(clock_data->msec == 60) {
		clock_data->sec = 0;
		clock_data->sec++;
	}
	if(clock_data->sec == 60) {
		clock_data->sec = 0;
		clock_data->min++;
	}
	if(clock_data->min == 60) {
		clock_data->min = 0;
		clock_data->hour++;
	}
	if(!(clock_data->hour % 24)) {
		clock_data->msec = 0;
		clock_data->sec = 0;
		clock_data->min = 0;
		clock_data->hour = 0;
	}
}
void Clock_SetFND(Clock_data *clock_data){
	FND_SetNum((clock_data->min)*100 + (clock_data->sec));
}
void Clock_Execute(){
	Clock_DispLoop();
}

