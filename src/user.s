.equ PERIPH_BASE, 0x3F000000
.equ GPIO_BASE, PERIPH_BASE + 0x200000
.equ GPFSEL1, GPIO_BASE + 0x04
.equ GPFSEL2, GPIO_BASE + 0x08
.equ GPSET0, GPIO_BASE + 0x1C
.equ GPLEV0, GPIO_BASE + 0x34
.equ GPCLR0, GPIO_BASE + 0x28
.equ GPPUD, GPIO_BASE + 0x94
.equ GPPUDCLK0, GPIO_BASE + 0x98

.equ MAILBOX_BASE, 0x4000008C  @ Base address for the mailboxes
.equ CORE1_MAILBOX, MAILBOX_BASE

@ lock_init:
@     mov r1, #0                   // Initialize the lock as unlocked (0)
@     str r1, [r0]
@     mov pc, lr

@ lock_acquire:
@     dmb                          // Data Memory Barrier
@ lock_acquire__try:
@     bx lr                        // Return
@     ldrex r2, [r0]               // Load-exclusive the lock value
@     cmp r2, #0                   // Check if lock is free (0 means unlocked)
@     bne lock_acquire__try        // If not, retry

@     mov r1, #1                   // Prepare the value to set the lock
@     strex r2, r1, [r0]           // Try to set the lock (write 1)
@     cmp r2, #0                   // Was the store-exclusive successful?
@     bne lock_acquire__try        // If not, retry
@     dmb                          // Data Memory Barrier
@     mov pc, lr                   // Return

@ lock_release:
@     dmb                          // Data Memory Barrier
@     mov r1, #0                   // Prepare the value to unlock
@     str r1, [r0]                 // Release the lock
@     dmb                          // Data Memory Barrier
@     mov pc, lr                   // Return


init_core:
    and r0, r0, #0x03
    ldr r2, =0x400000cc
    mov r3, #-1
    str r3, [r2, r0, lsl #4]
    ldr r2, =0x4000008c
    str r1, [r2, r0, lsl #4]
    sev
    mov pc, lr

.align 8
gpio_lock:
    .word 0


main_core1:
    ldr sp, =stack_usr_1              // Set stack pointer for core 1 (secondary)
    // run monitor_init with gpio_lock acquired
    @ ldr r0, =gpio_lock
    @ bl lock_acquire
    @ bl monitor_init
    @ bl lock_release
main_core1__monitor_loop: 
    bl monitor_step                     // Jump to user function
    mov r0, #0x50000
    bl delay
    b main_core1__monitor_loop

.global main
main:
    @ mrc p15, 0, r0, c0, c0, 5       // Read MPIDR
    @ and r0, r0, #0xFF               // Check processor id
    @ cmp r0, #0                      // Compare with 0 (primary CPU)
    @ bne panic                       // If not 0, panic
    ldr sp, =stack_usr_0              // Set stack pointer for core 0 (primary)  
    
    // init gpio lock
    @ ldr r0, =gpio_lock
    @ bl lock_init
    
    @ // start core 1 with its main function

    bl monitor_init

    mov r0, #1
    ldr r1, =main_core1
    bl init_core

    @ // acquire gpio lock
    @ ldr r0, =gpio_lock
    @ bl lock_acquire

    @ set up gpio pin 16 for output
    ldr r0, =GPFSEL1
    ldr r1, [r0]
    bic r1, r1, #(0b111 << 18)
    orr r1, r1, #(0b001 << 18)
    str r1, [r0]

    // set gpio pin 27 for input
    ldr r0, =GPFSEL2
    ldr r1, [r0]
    bic r1, r1, #(0b111 << 21)
    str r1, [r0]
    
    @ // release gpio lock
    @ ldr r0, =gpio_lock
    @ bl lock_release
    @ blink the led
main__blink_loop:
    @ ldr r0, =GPSET0
    @ mov r1, #(1 << 16)
    @ str r1, [r0]
    mov r0, #0x10
    mov r1, #0x1
    bl monitored_gpio_set
    mov r0, #0x400000
    bl  delay
    @ ldr r0, =GPCLR0
    @ mov r1, #(1 << 16)
    @ str r1, [r0]
    mov r0, #0x10
    mov r1, #0x0
    bl monitored_gpio_set

@     // copy the value of gpio 27 to gpio 16
@     ldr r0, =GPLEV0
@     ldr r1, [r0]
@     and r1, r1, #(1 << 27)
@ // call monitored_gpio_set
@     mov r0, #0x10
@     bl monitored_gpio_set
@     b main__blink_loop


    // delay
    mov r0, #0x400000
    bl  delay
    b  main__blink_loop
    b proc_hang

delay:
    cmp r0, #0
    bxeq lr
    sub r0, r0, #1
    b delay
