; Autor: Omar Dami�n
;---------------------------------------------
;---------------------------------------------
;Se usaran los pines fisicos PD2 y PD3 como entradas, PD6 como salida, y [PE0:PE5] como salidas
PORTE_P	EQU	0x400240FC
PORTD_P	EQU 0x40007130
;-------------------------------------
;Registros del puerto E
GPIO_PORTE_AMSEL_R	EQU 0x40024528
GPIO_PORTE_AFSEL_R	EQU 0x40024420
GPIO_PORTE_PCTL_R	EQU 0x4002452C
GPIO_PORTE_DIR_R	EQU	0x40024400
GPIO_PORTE_DEN_R	EQU	0x4002451C
;Registros del puerto D
GPIO_PORTD_AMSEL_R	EQU 0x40007528
GPIO_PORTD_AFSEL_R	EQU 0x40007420
GPIO_PORTD_PCTL_R	EQU 0x4000752C
GPIO_PORTD_DIR_R	EQU	0x40007400
GPIO_PORTD_DEN_R	EQU	0x4000751C
;Registros del sistema
SYSCTL_RCGCGPIO_R	EQU	0x400FE608
PE	EQU	0x3F
PD	EQU	0x4C
DISPE_0 EQU 0x01
DISPE_1	EQU 0x0F
DISPE_2	EQU 0x12
DISPE_3 EQU 0x06
DISPE_4 EQU 0x0C
DISPE_5 EQU 0x24
DISPE_6 EQU 0x20
DISPE_7 EQU 0x0F
DISPE_8 EQU 0x00
DISPE_9 EQU 0x0C
DISPD_1 EQU 0x40
DISPD_4 EQU 0x40
DISPD_00 EQU 0x00

;------------------------------------------
CONST_500MS EQU 2000000

		AREA codigo, CODE, READONLY,ALIGN=2
		THUMB
		EXPORT Start
Start
;----------------------------------------------------------------------------------------
	LDR R1,=SYSCTL_RCGCGPIO_R; Habilitacion del reloj para los puertos D y E
	LDR R0, [R1]
	ORR R0, R0, #0x18
	STR R0, [R1]
	NOP
	NOP
	NOP
	NOP
;-----------------Configuraciones iniciales-------------------------------------------
	LDR R1,=GPIO_PORTE_AMSEL_R;Deshabilitacion funcion analogica
	LDR R0,[R1]
	BIC R0, R0,#PE
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_AMSEL_R
	LDR R0,[R1]
	BIC R0, R0,#PD
	STR R0,[R1]
	LDR R1,=GPIO_PORTE_AFSEL_R;Habilitacion como GPIO
	LDR R0,[R1]
	BIC	R0,R0,#PE
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_AFSEL_R
	LDR R0,[R1]
	BIC R0, R0,#PD
	STR R0, [R1]
	LDR R1,=GPIO_PORTE_PCTL_R;Deshabilitacion de funcion alternativa
	LDR R0, [R1]
	BIC R0,R0,#0x000000FF
	BIC R0,R0,#0x00000F00
	BIC R0,R0,#0X00F00000
	BIC R0,R0,#0X000FF000
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_PCTL_R
	LDR R0,[R1]
	BIC R0,R0,#0x0F000000
	BIC R0,R0,#0x0000FF00
	STR R0,[R1]
	LDR R1,=GPIO_PORTE_DIR_R;Habilitacion como entrada o salida
	LDR R0,[R1]
	ORR R0,R0,#PE
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_DIR_R
	LDR R0,[R1]
	ORR R0,R0,#0x40
	BIC R0,R0,#0x0C
	STR R0,[R1]
	LDR R1,=GPIO_PORTE_DEN_R;Habilitacion de pines
	LDR R0,[R1]
	ORR R0,R0,#PE
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_DEN_R
	LDR R0,[R1]
	ORR R0,R0,#PD
	STR R0,[R1]
;----Declaracion de constantes y variables----------------------------
	LDR R3,=CONST_500MS;Constante de subrutina delay
	LDR R4,=0; variable de contador
	LDR R5,=0; variable de modo ascendente =0,descendente =1
	LDR R6,=0; constante de 0
	B Loop
;----------------------------------------------------------------------------------------

delay	; Rutina de retardo de 50ms.
	ADD R2, #1
	NOP
	NOP
	NOP
	NOP
	CMP R2, R3
	BNE delay
	BX LR

cont_des ; Configura el conteo descendente
	LDR R5,=0
	B Loop
	
cont_asc ; Configura el conteo ascendente
	LDR R5,=1
	B Loop
	
cont_sum ; Aumenta el contador en 1 unidad
	CMP R4,#9 ; Si ya llego al limite superior 
	BEQ res_asc ; subrutina de receteo de contador
	ADD R4,#1 
	BX LR

cont_rest; Decrementa el contador en 1 unidad
	CMP R4,R6 ; si ya llego al limite inferior
	BEQ res_des ; subrutina de receteo de contodor
	SUB R4,#1
	BX LR
	
res_asc; Receteo de contador ascendente
	LDR R4,=0 
	BX LR

res_des ; Receteo de contador descendente
	LDR R4,=9
	BX LR

display ; Comparador para seleccionar el numero a desplegar
	CMP R4,#0
	BEQ num_0
	CMP R4,#1
	BEQ num_1
	CMP R4,#2
	BEQ num_2
	CMP R4,#3
	BEQ num_3
	CMP R4,#4
	BEQ num_4
	CMP R4,#5
	BEQ num_5
	CMP R4,#6
	BEQ num_6
	CMP R4,#7
	BEQ num_7
	CMP R4,#8
	BEQ num_8
	CMP R4,#9
	BEQ num_9
num_0 ; Despliega el numero 0 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_0
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest	
num_1; Despliega el numero 1 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_1
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_1
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
num_2; Despliega el numero 2 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_2
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
num_3; Despliega el numero 3 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_3
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
num_4; Despliega el numero 4 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_4
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_4
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
	
num_5; Despliega el numero 5 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_5
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
	
num_6; Despliega el numero 6 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_6
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
	
num_7; Despliega el numero 7 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_7
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest

num_8; Despliega el numero 8 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_8
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest
	
num_9; Despliega el numero 9 en los pines [PE0:PE5] y el pin PD6 
	LDR R1,=PORTE_P
	LDR R0,=DISPE_9
	STR R0,[R1]
	LDR R1,=PORTD_P
	LDR R0,=DISPD_00
	STR R0,[R1]
	CMP R5,R6 ; compara el tipo de conteo si es ascendete o descendente
	BEQ cont_sum
	CMP R5,#1
	BEQ cont_rest

Loop
	LDR R2,=0
	;reinicio de constante de retardo D2->descendente D3-> ascendente
	LDR R1,=PORTD_P ;Lee los pines [PD2:PD3] para setear el conteo ascendente o descendente
	LDR R0,[R1]
	CMP R0,#0x04 
	BEQ cont_des; llama a la subrutina encargada de configurar el conteo como ascendente
	CMP R0,#0x08
	BEQ cont_asc; llama a la subrutina encargada de configurar el conteo como descendente
	BL display; Despliega el valor del contador
	BL delay; Retardo de 500ms aproximadamente para ver el conteo
	B Loop
	ALIGN
	END