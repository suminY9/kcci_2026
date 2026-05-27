/*
 * ap_main.h
 *
 *  Created on: 2026. 4. 28.
 *      Author: kccistc
 */

#ifndef SRC_AP_AP_MAIN_H_
#define SRC_AP_AP_MAIN_H_


#include <stdint.h>
#include "../driver/Button/Button.h"

hBtn_t hBtnStart;
hBtn_t hBtnWrite;
hBtn_t hBtnRead;
hBtn_t hBtnStop;

void ap_init();
void ap_excute();


#endif /* SRC_AP_AP_MAIN_H_ */
