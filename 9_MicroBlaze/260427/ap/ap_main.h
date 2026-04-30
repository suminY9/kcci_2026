/*
 * ap_main.h
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#ifndef SRC_AP_AP_MAIN_H_
#define SRC_AP_AP_MAIN_H_

#include <stdint.h>

typedef enum {
	UPCOUNTER,
	CLOCK
}mode_t;

typedef enum {
	HOURMIN,
	SECMSEC
}clock_mode_t;

void ap_init();
void ap_execute();

#endif /* SRC_AP_AP_MAIN_H_ */
