/* Dados tres valores enteros almacenados a partir de la dirección de memoria 0x1000, 	*/
/* diseñar un programa ensamblador que sume los tres valores y almacene el resultado 	*/ 
/* en la siguiente palabra de memoria. El programa debe utilizar subrutinas:		*/
/* 	– SUMA_DOS: realiza la operación r2=r2+r3.					*/
/* 	– SUMA_TRES: realiza la operación r5=r2+r3+r4 llamando a SUMA_DOS.		*/
/*	– Programa principal: realiza la operación pedida llamando a SUMA_TRES. 	*/

.equ SUMANDOS, 0x1000 /* Starting address of the list */
.global _start

_start:
	movia r6, SUMANDOS
	ldw r2, 0(r6)
	ldw r3, 4(r6)
	ldw r4, 8(r6)

	call SUMA_TRES

SUMA_DOS:
	add r2, r2, r3
	ret

SUMA_TRES:
	call SUMA_DOS
	add r5, r2 + r4
	stw r5, 12(r6)

STOP:
	br STOP

/*	.data	NO PONER, PUNTERO QUE DA POR SACO */
.org 0x1000
	.word 7, 4, 10
RESULT:
	.skip 1  			/* Reservamos memoria */ 


.end
