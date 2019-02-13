/********************************************************************************
* benchNIOSII.s (ver 0.1)
*
* EC - Práctica 4 - Ejercicio 4
*
* Programa para medidas de prestaciones de NIOS II/{e, s, f}
* Mide el tiempo que el procesador se encuentra ocioso en un programa 
* de generación de sonido sintético en placas DE2 y DE2-115.
*
* subrutinas: audioOUT, ESCRIBIR_JTAG, activaTimer, desactivaTimer, PRINT_JTAG 
*
* Domingo Benitez, Noviembre 2015
*
*
********************************************************************************/
.global _start
_start:
	movia 	r17, ATASCO	/* puntero a la zona de memoria donde se guardan medidas: ATASCO y entraATASCO  */
	movi  	r20, 97		/* codigo ASCII de la letra 'a' */
	movia 	r21, 24000	/* límite intervalo de nota, 1/4 segundo */
	movia 	r22, 0x10001000	/* JTAG data register*/
	movia 	r23, 0x10003040	/* audio */
	movia   	  sp, 0x007FFFFC	/* inicio de pila */

verTEXTO: /* muestra un texto de entradilla en la terminal de Altera Monitor Program */
	movia 	r3, TEXTOentrada	/* paso parametro a rutina: r3, puntero memoria de la string */
	call  	ESCRIBE_TEXTO_JTAG /* printf de strings constantes */

LOOP:	/* esperar por tecla pulsada en el teclado */
	ldwio 	  r2, 0(r22)	/* lee el data register del puerto JTAG */
	andi  	  r3,  r2, 0x8000	/* extrae el bit 15: RVALID */
	beq   	  r3,  r0, LOOP	/* RVALID=0 -> no dato pulsado */
	andi  	r10, r2, 0xFF	/* extrae bits 0..7: DATA */
	call  	ESCRIBIR_JTAG
	bne   	r10, r20, verTEXTO /* si no es la ‘a’ sigue encuestando JTAG */

	/* zona de inicializaciones de cada ejecucion del benchmark */
	add  	r7, r0, r0		/* indica numero de iteraciones de ATASCOs en el CODEC */
	stw  	r0, 0(r17)		/* ATASCO = 0 */	
	stw 	r0, 4(r17)		/* entraATASCO = 0 */	

	addi 	r4, r0, 3		/* numero de tonos seguidos que se escuchan, parte del benchmark */
	add  	r5, r0, r0		/* indice para apuntar a la muestra de la secuencia de TONO que se escucha */

	stw  	r0, TIEMPOacumulado(r0) 		/* variable t_sb: tiempo del procesador en atascos */
	stw  	r0, tiempoTotal_acumulado(r0) 	/* variable t_T: tiempo de ejecución total del benchmark */

	call 	activaTimer	/* se configura el Timer y se pone en marcha */

	/* marca inicial de tiempo total de una ejecución del benchmark */
	call 	LEER_TIMER_SNAPSHOT 	/* se toma una marca inicial para luego calcular el tiempo total */
	movia 	r8, TIEMPO		/* TIEMPO guarda la lectura actual del Timer de los ciclos */
	ldw   	r9, 0(r8)
	movia 	r8, tiempoTotal_antes 	/* variable t_1: tiempoTotal_antes <- TIEMPO */
	stw   	r9, 0(r8) 			/* se guarda marca de tiempo variable t_1 */

secuencia: /* bucle que establece los punteros al inicio de las secuencias de las muestras de los tonos a enviar al puerto de audio de DE2 */
	/* paso parametro a rutina: r19, puntero memoria del inicio del tono */
	movia  	r19, DO(r0)	/* tono DO */
miraRE: 	
	cmpeqi  	r6, r5, 1
	beq     	r6, r0, miraMI 
	movia  	r19, RE(r0)	/* tono RE */
miraMI: 	
	cmpeqi  	r6, r5, 2
	beq     	r6, r0, hazCall 
	movia  	r19, MI(r0)	/* tono MI */

hazCall:
	call 	audioOUT		/* salto a rutina que lee la memoria con el tono y lo envia al CODEC */
	addi 	r5, r5, 1		/* TONO++ */
	bne  	r5, r4, secuencia  	/* fin de bucle */

	/* marca final de tiempo total de una ejecución del benchmark */
	call  	LEER_TIMER_SNAPSHOT 	/* accede al Timer para leer el numero de ciclos actuales */
	movia 	r8, TIEMPO		/* variable : TIEMPO guarda la lectura de ciclos del Timer */
	ldw   	r9, 0(r8)
	movia 	r8, tiempoTotal_despues 	/* variable t_2: tiempoTotal_despues <- TIEMPO */
	stw   	r9, 0(r8)
	movia 	r8, tiempoTotal_antes
	ldw          r10, 0(r8)
	sub  	r9, r10, r9			/* tiempoTotal_despues = tiempoTotal_antes - tiempoTotal_despues, el cambio de signo de los operandos es porque Timer empieza a contar desde FFFFFFFF y sub los considera valores negativos */
	movia 	r8, tiempoTotal_acumulado
	stw  	r9, 0(r8) 			/* variable t_T: tiempoTotal_despues = t_2 - t_1 */

	/* salida de la prueba del benchmark */
	call 	desactivaTimer	/* paramos el Timer */
	call 	PRINT_JTAG	/* se muestra las medidas de prestaciones en terminal de AMP */
	br 	verTEXTO	/* fin de la prueba, volvemos a encuestar si se quiere otra prueba */


/* ----------------------------------------------------------------------------- 
* subrutina: audioOUT 
*
* Envia al puerto de audio de DE2 un sonido durante un intervalo de tiempo.
* Se incluye una monitorizacion del tiempo en el que el puerto no acepta muestras.
*
* Parametros entrada: 	r17, puntero de variable ATASCO
*			r19, puntero memoria del tono
*		    	r21, límite intervalo de nota
*			r23, puerto de audio
*
* Parametros salida:  ninguno
*  -----------------------------------------------------------------------------
*/
audioOUT:
	subi 	  sp, sp, 52	/* guardamos registros en pila */
	stw 	  r2, 16(sp)
	stw  	  r3, 12(sp)
	stw  	  r4,   8(sp)
	stw 	  r5,   4(sp)
	stw 	  r6, 36(sp)
	stw 	  r7, 48(sp)
	stw 	  r8, 20(sp)
	stw 	  r9, 24(sp)
	stw 	r10, 28(sp)
	stw 	r11, 40(sp)
	stw 	r12, 44(sp)
	stw 	r13, 52(sp)
	stw  	  ra,  32(sp)

	movia  	r9, 0x10002000	/* direccion base del Timer */
	ldw 	r5, 0(r19) 		/* r5 = numero muestras del tono */
	add 	r4, r0, r0 		/* r4=0, indice de muestra dentro del intervalo de tiempo del tono */

	ldw  	r12, TIEMPOacumulado(r0) 	/* variable que guarda el tiempo del procesador en atascos */

LOOP4:	add 	r2, r0, r0 		/* r2=0, indice de la muestra dentro del patron del tono */

LOOP2:	addi 	r2, r2, 1 		/* inicialización que indica la primera muestra del patron de la nota */
	addi 	r4, r4, 1 		/* inicialización que indica la primera muestra del intervalo de tiempo de la nota */

LOOP3:	/* comprobar espacio en cola de lectura del puerto de audio */
	ldwio 	r3,  4(r23)  	/* registro audio en 0x10003044 */
	srli  	r3, r3, 16   	/* elimina la parte que indica cola lectura y se queda con escritura*/
	bne  	r3, r0, LOOP5 	/* salta si tiene espacio para escribir en cola*/

	/* similar a rutina LEER_TIMER_SNAPSHOT pero via registros, no se hace call porque se atasca en memoria en NIOSII/{e,s}, esto costo un tiempo descubrirlo */
	/* ---------- LEER_TIMER_SNAPSHOT: marca inicial de tiempo, T_1_i ----------*/

	stwio  	r0, 16(r9) 		/* snapshot del Timer, captura ciclos actuales del Timer */	
	ldwio  	r6, 16(r9)		/* lee 16 bits menos significativos del snapshot */
	ldwio  	r8, 20(r9)		/* lee 16 bits mas significativos del snapshot */
	slli   	r8,  r8, 16		/* 16 bits mas significativos en su sitio para combinarlos con 16 menos significativos */
	or             r11, r8, r6		/* r11: se guarda la marca de tiempo antes, T_1_i  */

	ldw    	  r7,   0(r17)	/* carga valor actual de numero de ATASCOs */
	ldw  	r13,  4(r17)	/* carga valor actual de numero de entraATASCOs */
	addi  	r13, r13, 1	/* entraATASCO ++ */

LOOP6: /* bucle en el que el procesador no puede enviar muestras al puerto de audio  */
	ldwio  	r3, 4(r23)  	/* registro audio en 0x10003044 */
	addi   	r7, r7, 1		/* ATASCO++ */
	srli   	r3, r3, 16   	/* elimina la parte de cola lectura y se queda con escritura */
	addi   	r6, r6, 16		/* DUMY: esta instruccion no hace nada, es para engordar el bucle ocioso y reducir dependencias de datos*/
	beq    	r3, r0, LOOP6 	/* salta si no tiene espacio para escribir en FIFO del puerto audio */

	stw    	  r7,  0(r17)	/* guarda ATASCO */
	stw   	r13,  4(r17)	/* guarda entraATASCO */

	/* similar a LEER_TIMER_SNAPSHOT pero via registros, no hace call porque se atasca en memoria en NIOSII/{e,s}, esto costo un tiempo descubrirlo */
	/* ---------- LEER_TIMER_SNAPSHOT : marca final de tiempo, T_2_i ----------*/
	stwio  	  r0, 16(r9) 	/* se vuelve a hacer un snapshot */	
	ldwio  	  r6, 16(r9)
	ldwio  	  r8, 20(r9)
	slli  	  r8,  r8, 16
	or   	  r8,  r8,  r6	/* r8: se guarda la marca de tiempo después, T_1_i */
	sub  	  r11, r11,  r8	/* r11: se calcula el intervalo de tiempo i, T_2_i – T_1_i  */
	add 	  r12, r12, r11	/* r12: se acumula el intervalo de tiempo i, t_sb= Si(T_2_i – T_1_i) */


LOOP5:	/* reproducir tono */
	slli  	r3, r2,  2  	 	/* calcula puntero relativo de memoria de la muestra: x 4 */
	add   	r6, r19, r3  	/* calcula puntero absoluto de memoria de la muestra */
	ldw   	r3,   0(r6)    	/* carga valor de la muestra del tono de audio */
	stwio 	r3,   8(r23)	/* lo envía a las FIFOs de salida */
	stwio 	r3, 12(r23)
	
	bne   	r2,  r5, LOOP2 	/* salta si no se ha llegado a leer todas las muestras del patron de la nota */

	blt   	r4, r21, LOOP4 	/* salta si no se ha pasado el intervalo de reproducción del tono */

	stw 	r12, TIEMPOacumulado(r0)	/* se guarda en memoria el tiempo acumulado de atasco, t_sb */

	ldw   r2, 16(sp)		/* restauramos registros desde pila */
	ldw   r3, 12(sp)
	ldw   r4,   8(sp)
	ldw   r5,   4(sp)
	ldw   r6, 36(sp)
	ldw   r7, 48(sp)
	ldw   r8, 20(sp)		
	ldw   r9, 24(sp)
	ldw r10, 28(sp)
	ldw r11, 40(sp)
	ldw r12, 44(sp)
	ldw r13, 52(sp)
	ldw   ra, 32(sp)
	addi  sp, sp, 52		

	ret

/* ----------------------------------------------------------------------------- 
* subrutina: activaTimer
*
* Configura el Timer de DE2 para que cuente pulsos de reloj
*
* Parametros entrada: ninguno
*
* Parametros salida:  ninguno
*  -----------------------------------------------------------------------------
*/
activaTimer:
	subi  	  sp, sp, 16	/* guardamos registros en pila */
	stw   	  ra, 16(sp)
	stw 	r12, 12(sp)
	stw  	r15, 8(sp)
	stw  	r16, 4(sp)

	/* configuracion del Timer */
	movia 	r16, 0x10002000 	/* direccion base del Timer */
	movia 	r12, 0xffffffff 	/* inicializa el Timer con la mayor cuenta ya que se configura para hacer snapshots */
	sthio 	r12, 8(r16) 	/* inicializa la media palabra menos significativa del valor inicial del Timer */
	srli  	r12, r12, 16
	sthio 	r12, 0xC(r16) 	/* inicializa la media palabra mas significativa del valor inicial del Timer */

	movi  	r15, 0b0110 	/* START = 1, CONT = 1, ITO = 0 */
	sthio 	r15, 4(r16)	/* configuracion del Timer sin interrupciones */

	ldw  	r12, 12(sp)	/* restauramos registros desde pila */
	ldw  	r15,  8(sp)
	ldw  	r16,  4(sp)
	ldw     	  ra, 16(sp)
	addi  	  sp, sp, 16		

	ret

/* ----------------------------------------------------------------------------- 
* subrutina: desactivaTimer
*
* Desconfigura el Timer de DE2 
*
* Parametros entrada: ninguno
*
* Parametros salida:  ninguno
*  -----------------------------------------------------------------------------
*/
desactivaTimer:
	subi  	  sp, sp, 12	/* guardamos registros en pila */
	stw  	r15,  4(sp)
	stw  	r16, 12(sp)
	stw   	  ra,  8(sp)

	
	movia 	r16, 0x10002000 	/* direccion base del Timer  */
	sthio 	r0, 4(r16)		/* START = 0, CONT = 0, ITO = 0 */

	ldw  	r15,   4(sp)
	ldw  	r16, 12(sp)
	ldw   	  ra,    8(sp)
	addi  	  sp, sp, 12	/* restauramos registros desde pila */

	ret

/* ----------------------------------------------------------------------------- 
* rutina: LEER_TIMER_SNAPSHOT
*
* Lee el registro de ciclos del Timer haciendo snapshot.
*
* Parametros entrada: ninguno
*
* Parametros de salida: TIEMPO, variable global
*
*  -----------------------------------------------------------------------------
*/
.global LEER_TIMER_SNAPSHOT
LEER_TIMER_SNAPSHOT:
	subi 	sp, sp, 16 		/* guardamos registros en pila */
	stw  	r2,  4(sp)
	stw  	r3, 12(sp)
	stw          r10,  8(sp)
	stw  	ra, 16(sp)

	movia     r10, 0x10002000 	/* direccion base del Timer  */
	stwio  	r0, 16(r10) 	/* snapshot del Timer: hacemos una foto del contador de ciclos  */
	ldwio  	r3, 16(r10)	/* 16 bits menos significativos de la cuenta */
	ldwio  	r2, 20(r10)	/* 16 bits mas significativos de la cuenta */
	slli   	r2, r2, 16		/* desplaza a izquierda los mas significativos para alinear */
	or    	r2, r2, r3		/* se componen los 32 bits de la cuenta */
	movia     r10, TIEMPO	
	stw    	r2, 0(r10)		/* se guarda la cuenta en variable TIEMPO */

	ldw   	r3, 12(sp)		/* restauramos registros desde pila */
	ldw   	r2,  4(sp)
	ldw          r10,  8(sp)
	ldw   	ra, 16(sp)
	addi  	sp, sp, 16 	

	ret

/* ----------------------------------------------------------------------------- 
*  Zona de datos
*  -----------------------------------------------------------------------------
*/	
.org 0x1000

.global ATASCO
ATASCO:
	.skip 4 		/* numero iteraciones del bucle donde el CODEC estas saturado */
entraATASCO:
	.skip 4

.global TIEMPO
TIEMPO:
	.skip 4 		/* variable para guardar el valor actual del contador de pulsos del Timer */

TIEMPOantes:
	.skip 4 		/* variable con la marca de intervalo de tiempo antes */
TIEMPOdespues:
	.skip 4 		/* variable con la marca de intervalo de tiempo despues */

.global TIEMPOacumulado 
TIEMPOacumulado:
	.skip 4 		/* posicion de memoria que guarda el contador de intervalos del Timer */

tiempoTotal_antes:
	.skip 4
tiempoTotal_despues:
	.skip 4

.global tiempoTotal_acumulado
tiempoTotal_acumulado:
	.skip 4

TEXTOentrada:
.ascii "\n   "
.asciz "\nAprieta la tecla a para empezar el benchmark: "

/* zona de includes de las muestras de los tonos */
.include "DO.s"
.include "RE.s"
.include "MI.s"

.end
