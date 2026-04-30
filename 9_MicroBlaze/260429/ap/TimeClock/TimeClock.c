/*
 * TimeClock.c
 *
 *  Created on: 2026. 4. 30.
 *      Author: kccistc
 */


#include "timeClock.h"

timeClock_t timeClock;

void TimeClock_Init(){
	TimeClock_SetTime(12, 0, 0, 0);
}

void TimeClock_SetTime(uint8_t hh, uint8_t mm, uint8_t ss, uint8_t ms){
	timeClock.hour = 12;
	timeClock.min  = 0;
	timeClock.sec  = 0;
	timeClock.msec = 0;
}

void TimeClock_Execute(clock_mode_t ClockMode){
	TimeClock_DispTime(ClockMode);
}

void TimeClock_IncTime(){
	if(timeClock.msec < 100-1){
		timeClock.msec++;
		return;
	}
	timeClock.msec = 0;

	if(timeClock.sec < 60-1){
		timeClock.sec++;
		return;
	}
	timeClock.sec = 0;

	if(timeClock.min < 60-1){
		timeClock.min++;
		return;
	}
	timeClock.min = 0;

	if(timeClock.hour < 24-1){
		timeClock.hour++;
		return;
	}
	timeClock.hour = 0;
}

void TimeClock_DispTime(clock_mode_t ClockMode){
	if (timeClock.msec < 50) {
		FND_SetDP(FND_DIGIT_100, FND_DP_ON);
	}
	else {
		FND_SetDP(FND_DIGIT_100,FND_DP_OFF);
	}

	if(ClockMode == HOURMIN)	  	TimeClock_DispHourMin();
	else if(ClockMode == SECMSEC)	TimeClock_DispSecMsec();
}

void TimeClock_DispHourMin(){
	uint16_t timeNum;
	timeNum = timeClock.hour * 100 + timeClock.min;

	FND_SetNum(timeNum);
}

void TimeClock_DispSecMsec(){
	uint16_t timeNum;
	timeNum = timeClock.sec * 100 + timeClock.msec;

	FND_SetNum(timeNum);
}
