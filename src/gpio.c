#include "peripherals/gpio.h"


// void init_gpio(int gpio) {
//     // configure GPIO as output
//     GPIO_REG(gpfsel[gpio / 10]) = (GPIO_REG(gpfsel[gpio / 10]) & ~(0x7 << ((gpio % 10) * 3))) | (0x1 << ((gpio % 10) * 3));
// }

// init specific gpio 16


// void init_gpio() {
//     // configure GPIO 16 as output
//     GPIO_REG(gpfsel[1]) = (GPIO_REG(gpfsel[1]) & ~(0x7 << 18)) | (0x1 << 18);
// }