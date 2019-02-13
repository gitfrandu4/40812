/* Diseñar un programa ensamblador que encienda en la placa DE2 los 		*/
/* leds rojos correspondientes a los interruptores que no estén activados.	*/

.global _start

_start:
	/* Inicialización de los puertos paralelos 								*/
	movia r15, 0x10000000	/* red LED base address							*/
	movia r16, 0x10000040	/* SW slider swith base address					*/
	movia r17, HEX_bits

	ldw r5, 0(r17)

LOOP:
	ldwio r4, 0(r16)		/* leemos el estado de los interruptores		*/

	xor r4, r4, r5

	stwio r4, 0(r15)

	movia r4, 5000		/* Introducimos un retardo pequeño */
DELAY:
	subi r4, r4, 1
	bne r4, r0, LOOP
	br LOOP

HEX_bits:
	.word 0x3FFFF
.end
