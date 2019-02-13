/********************************************************************************
* lab3_part1_fibo.s
*
* Subrutina: Ejecuta el cómputo de la Serie Fibonacci para 8 números
* x=p*e
* LLamada desde: lab3_part1_main.s
*
********************************************************************************/

.text
.global FIBONACCI
FIBONACCI:
	subi sp, sp, 24 	/* reserva de espacio para el Stack */
	stw r4, 0(sp)
	stw r5, 4(sp)
	stw r6, 8(sp)
	stw r7, 12(sp)
	stw r8, 16(sp)
	stw r9, 20(sp)

	movi r4, 0
	movia r5, 32768    /*cambia x */
LOOP: 
	bge r4, r5, STOP
	ldb r0, V(r4)
	addi r4, r4, 8      /*cambia p*/
	br LOOP

STOP:	
	ldw r4, 0(sp)
	ldw r5, 4(sp)
	ldw r6, 8(sp)
	ldw r7, 12(sp)
	ldw r8, 16(sp)
	ldw r9, 20(sp)
	addi sp, sp, 24 	/* libera el stack reservado */

	ret

.data
V:
.skip 65536 

.end
