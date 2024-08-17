.global memzero
memzero:
	str r0, [r1], #4    // Store zero (r0 is assumed to contain zero) and post-increment r1 by 4
	subs r2, r2, #4     // Subtract 4 from r2 (size remaining)
	bgt memzero         // Branch to memzero if r2 > 0
	bx lr               // Return from the function

// 