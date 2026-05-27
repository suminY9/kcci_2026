/*
 * I2Cmaster.h
 *
 *  Created on: 2026. 5. 7.
 *      Author: user
 */

#ifndef SRC_AP_I2CMASTER_I2CMASTER_H_
#define SRC_AP_I2CMASTER_I2CMASTER_H_


#include "../../driver/Button/Button.h"
#include "../../driver/FND/FND.h"
#include "../../driver/LED/LED.h"
#include "../../HAL/I2C/I2C.h"

void MASTER_Write();
void MASTER_Read();

#endif /* SRC_AP_I2CMASTER_I2CMASTER_H_ */
