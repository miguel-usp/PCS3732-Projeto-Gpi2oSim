#ifndef	_P_GPIO_H
#define	_P_GPIO_H

#include "peripherals/base.h"
#include <stdint.h>

#define GPFSEL1         (PBASE+0x00200004)
#define GPSET0          (PBASE+0x0020001C)
#define GPCLR0          (PBASE+0x00200028)
#define GPPUD           (PBASE+0x00200094)
#define GPPUDCLK0       (PBASE+0x00200098)



#define PERIPH_BASE 0x3f000000 // no RPi 2
#define GPIO_ADDR (PERIPH_BASE + 0x200000)

typedef struct {
    uint32_t gpfsel[6]; // Function select (3 bits/gpio)
    unsigned : 32;
    uint32_t gpset[2]; // Output set (1 bit/gpio)
    unsigned : 32;
    uint32_t gpclr[2]; // Output clear (1 bit/gpio)
    unsigned : 32;
    uint32_t gplev[2]; // Input read (1 bit/gpio)
    unsigned : 32;
    uint32_t gpeds[2]; // Event detect status
    unsigned : 32;
    uint32_t gpren[2]; // Rising-edge detect enable
    unsigned : 32;
    uint32_t gpfen[2]; // Falling-edge detect enable
    unsigned : 32;
    uint32_t gphen[2]; // High level detect enable
    unsigned : 32;
    uint32_t gplen[2]; // Low level detect enable
    unsigned : 32;
    uint32_t gparen[2]; // Async rising-edge detect
    unsigned : 32;
    uint32_t gpafen[2]; // Async falling-edge detect
    unsigned : 32;
    uint32_t gppud; // Pull-up/down enable
    uint32_t gppudclk[2]; // Pull-up/down clock enable
} gpio_reg_t;
#define GPIO_REG(X) ((gpio_reg_t*)(GPIO_ADDR))->X

// void init_gpio(int gpio);

#endif  /*_P_GPIO_H */
