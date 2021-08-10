; Autor: Omar Dami�n
;---------------------------------------------
;---------------------------------------------
GPIO_PORTD_012  EQU 0x4000703C ;Pulsadores de lectura Y led

;---------Registros del puerto D--------
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_AFSEL_R EQU 0x40007420
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTD_AMSEL_R EQU 0x40007528
GPIO_PORTD_PCTL_R  EQU 0x4000752C
;---------Registro del reloj------------
SYSCTL_RCGCGPIO_R EQU 0x400FE608

CONSTANTE EQU 800000; Para retraso de 50ms

        AREA codigo, CODE, READONLY,ALIGN=2
        THUMB
        EXPORT Start
Start
;Habilitacion de reloj para D
    LDR R1, = SYSCTL_RCGCGPIO_R
    LDR R0, [R1]
    ORR R0, R0, #0x28
    STR R0, [R1]
    NOP
    NOP
    NOP
    NOP
;Pines a utilizar d3 led rgb azul, d0, d1 y d2, decremento, aumento e inicio respectivamente
;Deshabilitacion funcion analogica  D
;D
	LDR R1,=GPIO_PORTD_AMSEL_R
	LDR R0,[R1]
	BIC R0,#0x0F
	STR R0,[R1]
;Configuracion como GPIO D
;D
    LDR R1, =GPIO_PORTD_PCTL_R      
    LDR R0, [R1]                    
    BIC R0, R0, #0x000000FF
	BIC R0, R0, #0x0000FF00
	STR R0, [R1]
; Salidas y entradas de los puertos  D
;D
    LDR R1, =GPIO_PORTD_DIR_R      
    LDR R0, [R1]                   
    BIC R0, R0, #0x07              
    STR R0, [R1]
    LDR R1, =GPIO_PORTD_DIR_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x08              
    STR R0, [R1]	
;Limpiar funcion alternativa puerto D
;D
    LDR R1, =GPIO_PORTD_AFSEL_R    
    LDR R0, [R1]                   
    BIC R0, R0, #0x0F              
    STR R0, [R1]
;Habilitacion funcion digital puerto D

;D
    LDR R1, =GPIO_PORTD_DEN_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x0F               
    STR R0, [R1]     
	LDR R3, =CONSTANTE
    LDR R5, = 0
    LDR R6,=4000000 ;Constante de 4M->1s
    LDR R7,=20000000 ;Constante de 20M->5s
    MOV R8,R6
	LDR R10,=0
	B Loop 

delay_50ms
	ADD R2, #1
	NOP
	NOP
	NOP
	NOP
	CMP R2, R3
	BNE delay_50ms
	BX LR

r8_1s
    LDR R8,=4000000
    B Loop
r8_5s
    LDR R8,=20000000
    B Loop

disminucion
    CMP R8,R6
    BEQ r8_1s
    SUB R8,R6
    B Loop

aumento
    CMP R8,R7
    BEQ r8_5s
    ADD R8,R6+
    B Loop
delay_xs
	ADD R10, #1
	NOP
	NOP
	NOP
	NOP
	CMP R10, R8
	BNE delay_xs
	BEQ fin

fin
    LDR R5,= GPIO_PORTD_012
    LDR R4,=0x0
    STR R4,[R5]
    B Loop

inicio
	LDR R5, =GPIO_PORTD_012
	LDR R4, [R5]
	ORR R4, R4, #0x08
	STR R4, [R5]
	B delay_xs

Loop	; Ciclo para lectura de switch.
	; Leer el valor del switch.
	LDR R1, =GPIO_PORTD_012	
	LDR R0, [R1]
	LDR R2, =0;reinicio de contador para retardo de 50 ms
	LDR R10, = 0; reinicio contador de retardo 1s-5s
	;Retardo antirrebote
;	BL delay_50ms
	;Ver que pulsador es el que se presiono
	CMP R0, #0x01; Disminucion de tiempo
	BEQ disminucion
	CMP R0, #0x02; Aumento de tiempo
	BEQ aumento
	CMP R0, #0x04; Inicio de temporizador
	BEQ inicio	
	B Loop
	
    ALIGN                           
    END      