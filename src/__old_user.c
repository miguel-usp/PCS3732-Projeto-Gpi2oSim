// #include <stddef.h> 						// Include de lib para usar tipo size_t	
// #include <stdint.h>
// #include <stdio.h>
#include "peripherals/gpio.h"

void init_gpio() {
    // configure GPIO 16 as output
    GPIO_REG(gpfsel[1]) = (GPIO_REG(gpfsel[1]) & ~(0x7 << 18)) | (0x1 << 18);
}

#define BLINK_GPIO 16
void user_main(void)
{
    init_gpio();
    while (1) {
        GPIO_REG(gpset[0]) = 1 << BLINK_GPIO;
        for (int i = 0; i < 5000000; i++) {}			//Timer rustico 
        GPIO_REG(gpclr[0]) = 1 << BLINK_GPIO;
        for (int i = 0; i < 5000000; i++) {}			//Timer rustico 
    }
}


