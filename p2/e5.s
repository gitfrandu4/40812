
.text
.global _start
_start:

	/* initalize base addresses of parallel ports */
	movia r15, 0x10000020			/* HEX3_HEX0 base address */
	movia r16, 0x10000050			/* pushbutton key base address */
	movia r17, N_bits				
	ldw r6, 0(r17)					/* load base address for HEX displays */

	stwio r6, 0(r15)				/* load initial pattern for HEX displays*/
DO_DISPLAY:
	ldwio r4, 0(r16)				/* load input from slider pushbuttons */
	stwio r6, 0(r15)				/* load pattern for HEX displays*/

    bne r4, r0, BUTTON1
	br DO_DISPLAY

BUTTON1:
	addi r5, r0, 0b0010
	bne r4, r5, BUTTON2
	ldw r6, 4(r17)
	br DO_DISPLAY
BUTTON2:
	addi r5, r0, 0b0100
	bne r4, r5, BUTTON3
	ldw r6, 8(r17)
	br DO_DISPLAY
BUTTON3:
	addi r5, r0, 0b1000
	bne r4, r5, ERROR
	ldw r6, 0xC(r17)
	br DO_DISPLAY
ERROR:
	add r6, r0, r0
	br DO_DISPLAY
.data								/* data follows */
N_bits:
	.word 0x3F, 0x06, 0x5B, 0x4F
.end
