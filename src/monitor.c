#include "mini_uart.h"
#include <stddef.h> 						// Include de lib para usar tipo size_t	
#include <stdint.h>
#include <stdio.h>
#include "utils.h"
#include "peripherals/gpio.h"

void* memset(void* s, int c, size_t n) {			//Criando funcao memset para nao usarmos lib padroes.
    unsigned char* p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}
static uint8_t GPIOs_s[30] = {
            0b00000000,			//GPIO 0
            0b00001000,			//GPIO 1
            0b00010000,			//GPIO 2
            0b00011000,			//GPIO 3
            0b00100000,			//GPIO 4
            0b00101000,			//GPIO 5
            0b00110000,			//GPIO 6
            0b00111000,			//GPIO 7
            0b01000000,			//GPIO 8
            0b01001000,			//GPIO 9
            0b01010000,			//GPIO 10
            0b01011000,			//GPIO 11		
            0b01100000,			//GPIO 12
            0b01101000,			//GPIO 13
            0b01110000,			//GPIO 14
            0b01111000,			//GPIO 15
            0b10000000,			//GPIO 16
            0b10001000,			//GPIO 17
            0b10010000,			//GPIO 18
            0b10011000,			//GPIO 19
            0b10100000,			//GPIO 20
            0b10101000,			//GPIO 21
            0b10110000,			//GPIO 22
            0b10111000,			//GPIO 23
            0b11000000,			//GPIO 24
            0b11001000,			//GPIO 25
            0b11010000,			//GPIO 26
            0b11011000,			//GPIO 27
            0b11100000,			//GPIO 28
            0b11101000          //GPIO 29
};

void monitored_gpio_set(uint32_t gpio, uint32_t value) {
    if (value) {
        GPIO_REG(gpset[gpio / 32]) = 1 << (gpio % 32);
        GPIOs_s[gpio] = (GPIOs_s[gpio] & 0xF8) | 0x3;
    }
    else {
        GPIO_REG(gpclr[gpio / 32]) = 1 << (gpio % 32);
        GPIOs_s[gpio] = (GPIOs_s[gpio] & 0xF8) | 0x1;
    }
}



void monitor_init(void) {
    // Uses GPIO registers to initialize the GPIOs
    // so, if other code uses the same registers, it may cause conflicts
    uart_init();
}

int monitor_get_states() {
    // This uses the GPIO registers to read the GPIOs
    // so, if other code uses the same registers, it may cause conflicts
    int count = 0;
    for (int i = 0; i < 30; i++) {
        if ((GPIOs_s[i] & 0x1) == 0x1) {
            if ((GPIOs_s[i] & 0x7) == 0x3)
                count++;
        }
        else if ((GPIO_REG(gplev[i / 32]) & (0x1 << (i % 32))) != 0) {
            GPIOs_s[i] = (GPIOs_s[i] & 0xF8) | 0x6;
            count++;
        }
        else {
            GPIOs_s[i] = (GPIOs_s[i] & 0xF8) | 0x4;
        }
    }
    return count;
}

void monitor_step(void)
{
    uart_send('S');					//bit de inicio de mensagem 
    int count = monitor_get_states();
    uart_send((char)count);	//bit de numero de gpios ativas
    for (int i = 0; i < 30; i++) {
        if (((GPIOs_s[i] & 0x7) == 0x3) || ((GPIOs_s[i] & 0x7) == 0x6)) {
            uart_send((char)GPIOs_s[i]);	//bit de estado do gpio
        }
    }
    uart_send('E');					//bit de termino de mensagem
}


