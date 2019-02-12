/* Dado N un valor entero almacenado en la dirección de memoria 0xf0, diseñar un    */
/* programa ensamblador que almacene en memoria, a partir de la dirección 0x100, un */
/* vector de palabras formado por los N primeros números pares.			    */

.equ LIST, 0x100 /* Starting address of the list */
.global _start

_start:
	movia r4, N	/* Cargamos dirección del número deseado */
	ldw r5, 0(r4)	/* Cargamos el dato */
	movia r4, LIST	/* Cargamos el puntero del vector*/
	addi r6, r0, 0	/* Variable se incrementa 0 .. N */

LOOP:
	mul r7, r6, 2	/* Multiplicamos 2*n 	<- Instrucción no disponible */  
	add r7, r6, r6

	stw r7, 0(r4)	/* Guardamos el resultado */
	addi r4, r4, 4	/* Siguiente dirección del vector */
	addi r6, r6, 1	/* n+1 */
	beq r6, r5, STOP
	br LOOP

STOP:
	br STOP

/*	.data	NO PONER PUNTERO */
.org 0xf0
	N:
	.word 7 /* Número de pares a calcular */
.org 0x100
	.skip 7		/* reservamos tanta memoria como N */
.end
