/* Diseñar un programa ensamblador que encienda alternativamente todos los leds verdes  */
/* en posiciones pares y todos los leds rojos en posiciones impares de la placa DE2. 	*/
/* Nota: observar la asignación de la dirección del espacio de direccionamiento del     */
/* procesador NIOS II de la interfaz paralela de los leds rojos (LEDG)                  */                                  

.global _start

_start:
	/* Inicialización de los puertos paralelos */
	movia r15, 0x10000010	/* Dirección base de los ledsG                  */
	movia r16, HEX_bits		
	ldw r4, 0(r16)			/* Cargamos el pattern para encender los ledsG  */

ENCENDER_LEDS:
	stwio r4, 0(r15)		/* cargamos el patrón en el reg. de los ledsG	*/

	roli r4, r4, 1			/* rotate the displayed pattern                 */

	movia r5, 500000
DELAY:
	subi r5, r5, 1
	bne r5, r0, DELAY
	br ENCENDER_LEDS

HEX_bits:
	.word 0xAAAAAAAA
.end
