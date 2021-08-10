; Autor: Omar Dami�n
;---------------------------------------------
;---------------------------------------------
GPIO_PORTF123      EQU 0x40025038 ;leds rgb: r->f1, g->f2, b->f3
GPIO_PORTD0	   EQU 0x40007004 ;Pulsadores D0,D1,D2 y D3
GPIO_PORTD1	   EQU 0x40007008
GPIO_PORTD2	   EQU 0x40007010
GPIO_PORTD3	   EQU 0x40007020
GPIO_PORTD0123 EQU 0x4000703C
;---------REGISTROS DEL PUERTO F--------	
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_DEN_R   EQU 0x4002551C
;GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
;---------REGISTROS DEL PUERTO D--------
GPIO_PORTD_DIR_R   EQU 0x40007400
GPIO_PORTD_AFSEL_R EQU 0x40007420
GPIO_PORTD_DEN_R   EQU 0x4000751C
GPIO_PORTD_AMSEL_R EQU 0x40007528
GPIO_PORTD_PCTL_R  EQU 0x4000752C
;---------------------------------------
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

CONSTANTE		   EQU 100000
	
		 AREA    codigo, CODE, READONLY,ALIGN=2
		 THUMB
		 EXPORT Start 

Start
	; Paso 1: activaci�n de reloj para puerto F y el puerto D
    LDR R1, =SYSCTL_RCGCGPIO_R
    LDR R0, [R1]                   
    ORR R0, R0, #0x28            
    STR R0, [R1]                   
    NOP
    NOP                          

	; Paso 3: deshabilitar funci�n anal�gica puerto F, pines f1,f2,f3
    LDR R1, =GPIO_PORTF_AMSEL_R   
	LDR R0, [R1] 	
    BIC R0, #0x0E                      
    STR R0, [R1]
	; Deshabilitaci�n de funci�n analogica en puerto D, pines d0,d1,d2,d3
	LDR R1,=GPIO_PORTD_AMSEL_R
	LDR R0,[R1]
	BIC R0,#0x0F
	STR R0,[R1]
	
	; Paso 4: configurar como GPIO, PCTL=0 puerto F
    LDR R1, =GPIO_PORTF_PCTL_R      
    LDR R0, [R1]                    
    BIC R0, R0, #0x00000FF0
    BIC R0, R0, #0x0000F000
    STR R0, [R1]
	;Configurar como GPIO, PCTL=0 puerto D
    LDR R1, =GPIO_PORTD_PCTL_R      
    LDR R0, [R1]                    
    BIC R0, R0, #0x00000FF0
	BIC R0, R0, #0x0000F000
	BIC R0, R0, #0x0000000F
    STR R0, [R1]
		
	; Paso 5: especificar direcci�n de f1,f2 y f3 como salidas.
    LDR R1, =GPIO_PORTF_DIR_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x0E              
    STR R0, [R1]
	;Especificar direcci�n de d0, d1, d2 y d3 como entradas
    LDR R1, =GPIO_PORTD_DIR_R      
    LDR R0, [R1]                   
    BIC R0, R0, #0x0F              
    STR R0, [R1]
	; Paso 6: limpiar bits en funci�n alternativa puerto F
    LDR R1, =GPIO_PORTF_AFSEL_R    
    LDR R0, [R1]                   
    BIC R0, R0, #0x0E              
    STR R0, [R1]
	;Limpiar bits en funcion alternativa puerto D
    LDR R1, =GPIO_PORTD_AFSEL_R    
    LDR R0, [R1]                   
    BIC R0, R0, #0x0F              
    STR R0, [R1]	
	
    ; Paso 7: habilitar como puerto digital F
    LDR R1, =GPIO_PORTF_DEN_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x0E               
    STR R0, [R1]                       
	;Habilitar coo puerto digital D
    LDR R1, =GPIO_PORTD_DEN_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x0F               
    STR R0, [R1]     
	LDR R3, =CONSTANTE
	B Loop 

Delay	; Rutina de retardo de 50ms.
	ADD R2, #1
	NOP
	NOP
	NOP
	NOP
	CMP R2, R3
	BNE Delay
	BX LR

on_r; Rutina de encendido de F1, Rojo
	
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4,R4,#0x02
	STR R4, [R5]
	B Loop
on_g	; Rutina de apagado de F3, Verde
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4, R4, #0x08
	STR R4, [R5]
	B Loop
on_b; Rutina de encendido de F2, Azul
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4, R4, #0x04
	STR R4, [R5]
	B Loop
on_amarillo; Rutina de encendido de Amarillo
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4, R4, #0x0A
	STR R4, [R5]
	B Loop	
on_magenta; Rutina de encendido de Magenta
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4, R4, #0x06
	STR R4, [R5]
	B Loop	
on_cian; Rutina de encendido de Cian
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4, R4, #0x0C
	STR R4, [R5]
	B Loop	
on_blanco; Rutina de encendido del Blanco
	LDR R5, =GPIO_PORTF123
	LDR R4, [R5]
	ORR R4, R4, #0x0E
	STR R4, [R5]
	B Loop	
off_rgb; Apaga el led RGb
	LDR R5, =GPIO_PORTF123
	LDR R4, =0x0
	STR R4, [R5]
	B Loop	
	
Loop	; Ciclo para lectura de switch.
	; Leer el valor del switch.
	LDR R1, =GPIO_PORTD0123	
	LDR R0, [R1]
	LDR R2, =0
	;Retardo antirrebote
	BL Delay
	;Ver que pulsador es el que se presiono
	CMP R0, #0x01; Rojo
	BEQ on_r
	CMP R0, #0x02; Verde
	BEQ on_g
	CMP R0, #0x04; Azul
	BEQ on_b
	CMP R0, #0x03; Amarillo
	BEQ on_amarillo
	CMP R0, #0x05; Magenta
	BEQ on_magenta
	CMP R0, #0x06; Cian
	BEQ on_cian;
	CMP R0, #0x07; Blanco
	CMP R0, #0x08; se apaga el rgb
	BEQ off_rgb	
	B Loop
	
    ALIGN                           
    END   