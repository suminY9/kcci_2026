/*
 * Clock.h
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#ifndef SRC_AP_CLOCK_CLOCK_H_
#define SRC_AP_CLOCK_CLOCK_H_


#include <stdint.h>
#include "../../driver/FND/FND.h"
#include "../../common/common.h"

typedef struct{
	uint32_t hour;
	uint32_t min;
	uint32_t sec;
	uint32_t msec;
}Clock_Data;

void Clock_Init();
void Clock_DispLoop();
void Clock_SetFND(Clock_Data *clock_data);
void Clock_Execute();


#endif /* SRC_AP_CLOCK_CLOCK_H_ */
