/* Escribe un programa en lenguaje ensamblador de NIOS II que calcule la 	*/
/* serie de Fibonacci de los 8 primeros números (0, 1, 1, 2, 3, 5, 8, 13). 	*/
/* Observar que los dos primeros números son 0, 1.							*/

.global _start

_start:
	/* Guardamos los valores iniciales de la serie */
	movia r4, SUMANDOS	/* Cargamos dirección del número deseado 	*/
	ldw r5, 0(r4)		/* Cargamos el primer valor de la serie		*/
	ldw r7, 4(r4)		/* Cargamos el segundo valor de la lista 	*/
	movia r4, RESULT	/* Cargamos el puntero del vector resultado	*/
	addi r6, r0, 0		/* Variable se incrementa 0 .. 7 			*/
	addi r8, r0, 8		/* Variable cantidad de valores serie 		*/

loop:
	beq r6, r0, sumaIni	/* branch si casoInicial	*/
	beq r6, r8, STOP	/* branch si ha teminado 	*/

	add r5, r5, r7		/* Nuevo valor de la serie 						*/
	ldw r7, 0(r4)		/* Actualizamos r7 al último elemento calculado */

	addi r4, r4, 4		/* Siguiente dirección del vector resultado	*/
	stw r5, 0(r4)		/* Guardamos el último elemento calculado	*/

	addi r6, r6, 1		/* Siguiente elemento de la lista	*/
	br loop					

sumaIni:
	stw r5, 0(r4)	/* Guardamos primer elemento de la serie (0)	*/
	addi r6, r6, 1	/* Actualizamos puntero							*/
	br loop

STOP:
	br STOP


SUMANDOS:
	.word 0, 1 	/* Valores iniciales serie fibonacci */
RESULT:
	.skip 8		/* reservamos tanta memoria como N */
.end
