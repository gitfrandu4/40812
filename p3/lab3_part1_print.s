/********************************************************************************
* lab3_part1_print.s
*
* Subrutina: Muestra en el display HEX de DE2 el contenido de la posición de memoria externa CONTADOR
*
* Llamada desde: lab3_part1_main.s
* Subrutina: BCD (lsb3_part1_BCD.s)
*
********************************************************************************/

.extern CONTADOR
.text
.global PRINT_HEX
PRINT_HEX:
	subi sp,  sp, 28 	/* reserva de espacio en el Stack */
	stw  r17, 0(sp)
	stw  r18, 4(sp)
	stw  r19, 8(sp)
	stw  r20, 12(sp)
	stw  r21, 16(sp)
	stw  r22, 20(sp)
	stw  r23, 24(sp)
	stw  r4,  28(sp)
	stw  r2,  32(sp)

	add  r23, r0, r0 	/* inicializa r23 = 0 */

	movia r20, 0x10000020 	/* dirección base del periférico HEX3_HEX0 */
	movia r21, 0x10000030 	/* dirección base del periférico HEX7_HEX4 */

	movia r17, CODIGO_ESTATICO /* inicializa el puntero de datos */
	ldw   r18, 0(r17) 	/* carga el código 7-segmentos correspondiente */
	stwio r18, 0(r21) 	/* envía R18 que tiene el código "t=" a HEX7 ... HEX4 */

	movia r17, CONTADOR 	/* direccion base del contador de intervalos del Timer */
	ldw   r4, 0(r17)
	call  BCD		/* r4= valor binario, r2= valor BCD */

LOOP:	beq   r2, r0, END 	/* si valor BCD=0, goto END */
	andi  r17, r2, 0xF 	/* extrae los 4 bits menos significativos */

	slli  r18, r17, 2 	/* multiplica por 4 para calcular el desplazamiento de palabras en la zona de datos*/
	movia r17, CODIGOS_HEX 	/* inicializa el puntero de datos */
	add   r18, r18, r17 	/* suma el puntero de datos con el desplazamiento correspondiente al número a mostrar en HEX */
	ldw   r19, 0(r18) 	/* carga el código 7-segmentos correspondiente al valor de r18 */
	sll   r19, r19, r23 	/* desplaza el código 8 bits x orden cifra decimal */
	or    r22, r22, r19 	/* acumula en r22 */
	stwio r22, 0(r20) 	/* envía R22 a HEX3 ... HEX0 */

	srli  r2, r2, 4		/* desplaza a la derecha 4 bits el valor BCD */
	addi  r23, r23, 8 	/* actualiza r23 en 8 porque HEX utiliza 8 bits para cada valor */
	jmpi  LOOP:

END:	
	ldw r17, 0(sp)
	ldw r18, 4(sp)
	ldw r19, 8(sp)
	ldw r20, 12(sp)
	ldw r21, 16(sp)
	ldw r22, 20(sp)
	ldw r23, 24(sp)
	addi sp, sp, 28 	/* libera el stack reservado */

	ret
.data
CODIGOS_HEX:
/* códigos 7-segmentos de los primeros 10 números en binario 
(ver DE2_Basic_Computer.pdf, pp.4)
	0: 0111111 = 0x3f
	1: 0000110 = 0x06
	2: 1011011 = 0x5B 
	3: 1001111 = 0x4F 
	4: 1100110 = 0x66 
	5: 1101101 = 0x6D 
	6: 1111101 = 0x7D 
	7: 0000111 = 0x07 
	8: 1111111 = 0x7F 
	9: 1100111 = 0x67
*/
.word 0x3f,0x6,0x5b,0x4f,0x66,0x6d,0x7d,0x7,0x7f,0x67

CODIGO_ESTATICO: /* t=, t: 0111 0000, =: 0100 1000 (ver DE2_Basic_Computer.pdf, pp.4)*/
.word 0x7848

.end
