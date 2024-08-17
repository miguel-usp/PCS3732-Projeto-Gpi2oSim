

.equ PERIPH_BASE, 0x3F000000
.equ GPIO_BASE, PERIPH_BASE + 0x200000
.equ GPFSEL1, GPIO_BASE + 0x04
.equ GPSET0, GPIO_BASE + 0x1C
.equ GPCLR0, GPIO_BASE + 0x28
.equ GPPUD, GPIO_BASE + 0x94
.equ GPPUDCLK0, GPIO_BASE + 0x98

.equ MAILBOX_BASE, 0x4000008C  @ Base address for the mailboxes
.equ CORE1_MAILBOX, MAILBOX_BASE

.global _start
_start:
    /*
    * Vetor de interrupções
    * Deve ser copiado no enderço 0x0000
    */
    ldr pc, _reset
    ldr pc, _undef
    ldr pc, _swi
    ldr pc, _iabort
    ldr pc, _dabort
    nop
    ldr pc, _irq
    ldr pc, _fiq

    _reset:    .word   reset
    _undef:    .word   panic
    _swi:      .word   panic
    _iabort:   .word   panic
    _dabort:   .word   panic
    _irq:      .word   panic
    _fiq:      .word   panic

/*
 * Vetor de reset: início do programa aqui.
 */
reset:
    mov r0, #0
    bl enable_irq
    /*
    * configura os stacks pointers do sistema
    */
    @ mov r0, #0xd2           // Modo IRQ
    @ msr cpsr, r0
    @ ldr sp, =stack_irq

    @ mov r0, #0xd3           // Modo SVC, interrupções mascaradas
    @ msr cpsr, r0
    @ ldr sp, =stack_sys

    /*
    * Move o vetor de interrupções para o endereço 0
    */
    ldr r0, =_start
    mov r1, #0x0000
    ldmia r0!, {r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!, {r2,r3,r4,r5,r6,r7,r8,r9}
    ldmia r0!, {r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!, {r2,r3,r4,r5,r6,r7,r8,r9}

    /*
    *   Zera segmento BSS
    */
    ldr r0, =bss_begin
    ldr r1, =bss_end
    mov r2, #0

reset__loop_bss:
    cmp r0, r1
    bge reset__done_bss
    strb r2, [r0], #1
    b reset__loop_bss

reset__done_bss:
    mov r0, #0x1      
    bl enable_irq         // Habilita interrupções
    b main



/**
 * Habilita ou desabilita interrupções
 * param r0 0 = desabilita, diferente de zero = habilita
 */
.global enable_irq
enable_irq:
   movs r0, r0
   beq enable_irq__disable
   mrs r0, cpsr
   bic r0, r0, #(1 << 7)
   msr cpsr, r0
   mov pc, lr
enable_irq__disable:
   mrs r0, cpsr
   orr r0, r0, #(1 << 7)
   msr cpsr, r0
   mov pc, lr

.global proc_hang
proc_hang:
    b  proc_hang

.global panic
panic:
    // set gpio 17 as output
    ldr r0, =GPFSEL1
    ldr r1, [r0]
    bic r1, r1, #(0b111 << 21)
    orr r1, r1, #(0b001 << 21)
    str r1, [r0]
    // set gpio 17 high
    ldr r0, =GPSET0
    mov r1, #(1 << 17)
    str r1, [r0]

   wfe
   b panic