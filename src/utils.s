.globl put32
put32:
    str r1, [r0]    // Store the value in r1 to the address in r0
    bx lr           // Return from the function

.globl get32
get32:
    ldr r0, [r0]    // Load the value from the address in r0 into r0
    bx lr           // Return from the function
.globl delay

delay:
    subs r0, r0, #1 // Subtract 1 from r0
    bne delay       // Branch to delay if r0 is not zero
    bx lr           // Return from the function
