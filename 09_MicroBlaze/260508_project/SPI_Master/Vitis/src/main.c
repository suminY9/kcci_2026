/*
 * main.c
 *
 *  Created on: 2026. 5. 6.
 *      Author: user
 */

#include "ap/ap_main.h"
#include "xparameters.h"


int main()
{
	ap_init();

	while(1)
	{
		ap_excute();
	}

	return 0;
}
