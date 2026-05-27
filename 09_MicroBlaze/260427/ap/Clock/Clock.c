/*
 * Clock.c
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */


#include "Clock.h"

Clock_Data ClockData;

void Clock_Init(){
	FND_Init();
	ClockData.hour = 12;
	ClockData.min  = 0;
	ClockData.sec  = 0;
	ClockData.msec = 0;
}
void ClockCount(Clock_Data *clock_data){
	clock_data->msec++;
	if(!(clock_data->msec < 1000)) {
		clock_data->sec++;
		clock_data->msec = 0;
	}
	if(!(clock_data->sec < 60)) {
		clock_data->min++;
		clock_data->sec = 0;
	}
	if(!(clock_data->min <= 60)) {
		clock_data->hour++;
		clock_data->min = 0;
	}
	if(!(clock_data->hour <= 24)) {
		clock_data->hour = 0;
	}
}
void Clock_DispLoop(){
	ClockCount(&ClockData);
	Clock_SetFND(&ClockData);
	if(!(millis() % 50)) FND_DispDP();
	else FND_DispDigit();
}
void Clock_SetFND(Clock_Data *clock_data){
	FND_SetNum((clock_data->min)*100 + (clock_data->sec));
}
void Clock_Execute(){
	Clock_DispLoop();
}
