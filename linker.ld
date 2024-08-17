SECTIONS {
    . = 0x8000;   /* para Raspberry Pi, 0x40000000 para qemu */
    .text : { 
        out/boot.o(.text)
        *(.text) 
    }

    . = ALIGN(4);
    .data : { *(.data) }

    . = ALIGN(4);
    bss_begin = .;
    .bss : { *(.bss*) }
    bss_end = .;

    . = ALIGN(8);
    . = . + 4K;
    stack_usr_0 = .;
    . = ALIGN(4);
    . = . + 4K;
    stack_usr_1 = .;

}