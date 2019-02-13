/* Diseñar un programa ensamblador que muestre en la placa DE2 un cero en 	*/
/* el primer display "siete-segmentos" y lo rote por los cuatro primeros	*/
/* displays "siete-segmentos". 												*/                                  

.global _start

_start:
	/* Inicialización de los puertos paralelos 								*/
	movia r15, 0x10000020	/* HEX3_HEX0 base address						*/
	movia r16, HEX_bits		
	ldw r4, 0(r16)

MOSTRAR_DISPLAY:
	stwio r4, 0(r15)

	roli r4, r4, 8

	movia r5, 4200000		/* Introducimos un retardo de un seg. */
DELAY:
	subi r5, r5, 1
	bne r5, r0, DELAY
	br MOSTRAR_DISPLAY

HEX_bits:
	.word 0x3F
.end