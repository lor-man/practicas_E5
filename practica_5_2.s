SYSCTL_RCGCGPIO_R		EQU	0x400FE608
GPIO_PORTD012  		    EQU 0x4000701C    ;SALIDAS DE LOS LED EN LOS PINES D0, D1, D2
GPIO_PORTC456  		    EQU 0x400061C0	  ;ENTRADAS DE LOS PULSADORES C4, C5, C6


;---------REGISTROS DEL PUERTO D--------
GPIO_PORTD_DIR_R   		EQU 0x40007400 ; DIR; establece so el GPIO funcionará como entrada o salida 
GPIO_PORTD_AFSEL_R 		EQU 0x40007420 ; AFSEL; deshabilita otras funciones, lo establece como i/o
GPIO_PORTD_DEN_R   		EQU 0x4000751C ; DEN; habilita la funcion digital
GPIO_PORTD_AMSEL_R 		EQU 0x40007528 ; AMSEL Elimina las funciones analogicas para utilizarlo como funciones digitales
GPIO_PORTD_PCTL_R 	    EQU 0x4000752C ; PCTL;	HABILITA LOS PUERTOS COMO GPIO osea entrada o salida

;---------REGISTROS DEL PUERTO C--------
GPIO_PORTC_DIR_R   		EQU 0x40006400 ; DIR; establece so el GPIO funcionará como entrada o salida 
GPIO_PORTC_AFSEL_R 		EQU 0x40006420 ; AFSEL; deshabilita otras funciones, lo establece como i/o
GPIO_PORTC_DEN_R   		EQU 0x4000651C ; DEN; habilita la funcion digital
GPIO_PORTC_AMSEL_R 		EQU 0x40006528 ; AMSEL Elimina las funciones analogicas para utilizarlo como funciones digitales
GPIO_PORTC_PCTL_R 	    EQU 0x4000652C ; PCTL;	HABILITA LOS PUERTOS COMO GPIO osea entrada o salida


CONST_50ms				EQU 2000000		; constante para el antirrebote
CTE						EQU 2500000   ; CTE; constante 1M == 1s tiva C.

		AREA	codigo, CODE, READONLY,ALIGN=2
		THUMB
		EXPORT Start
Start
;-----------------------------------------Configuraciones iniciales---------------------------------------------------------------
		;Paso 1. Reloj en Puerto C y D
	LDR R1, =SYSCTL_RCGCGPIO_R
	LDR R0, [R1]
	ORR R0, R0, #0x0C
	STR R0, [R1]
	NOP 
	NOP

		;Paso 2. Deshabilitación de las funciones analógicas de los puertos C y D
	
	;Puerto C
	LDR R1,=GPIO_PORTC_AMSEL_R 
	LDR R0,[R1]
	BIC R0,#0xF0
	STR R0,[R1]

	;puerto D
	LDR R1,=GPIO_PORTD_AMSEL_R
	LDR R0,[R1]
	BIC R0,#0x0F
	STR R0,[R1]

		;Paso 3. Habilitación de los puertos GPIOS
	
	;Puerto C
    LDR R1, =GPIO_PORTC_PCTL_R      
    LDR R0, [R1]
	BIC R0, R0, #0x0F000000
    BIC R0, R0, #0x00F00000
    BIC R0, R0, #0x000F0000
    STR R0, [R1]

	;Puerto D
    LDR R1, =GPIO_PORTD_PCTL_R      
    LDR R0, [R1]                    
    BIC R0, R0, #0x000000FF
	BIC R0, R0, #0x00000F00
	STR R0, [R1]
	
		;Paso 4. Configuración de entradas y salidas 
	
	;Puerto C, entradas
	LDR R1, =GPIO_PORTC_DIR_R      
    LDR R0, [R1]                   
    BIC R0, R0, #0x70              
    STR R0, [R1]  

	;Puerto D, salidas
	LDR R1, =GPIO_PORTD_DIR_R 
    
	LDR R0, [R1]                   
    ORR R0, R0, #0x07              
    STR R0, [R1]

		;Paso 5. Limpiar la función alternativa
	
	;Puerto C
    LDR R1, =GPIO_PORTC_AFSEL_R    
    LDR R0, [R1]                   
    BIC R0, R0, #0x70            
    STR R0, [R1]
	;Puerto D
    LDR R1, =GPIO_PORTD_AFSEL_R    
    LDR R0, [R1]                   
    BIC R0, R0, #0x07              
    STR R0, [R1]
	
		;Paso 6. Habilitación de la función digital
	;Puerto C
    LDR R1, =GPIO_PORTC_DEN_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x70              
    STR R0, [R1]
	;Puerto D
    LDR R1, =GPIO_PORTD_DEN_R      
    LDR R0, [R1]                   
    ORR R0, R0, #0x07               
    STR R0, [R1] 

;--------------------------------------------------------------------------------------------------------------------
	
	LDR R3, =CONST_50ms  ;Constante antirrebote
	LDR R8, =CTE		 ;Constante de encendido
		LTORG
	LDR R10,=0
	
	LDR R6,=0

	B Loop 


Delay
		ADD R2, #1
		NOP
		NOP
		NOP
		NOP
		CMP R2, R3
		BNE Delay
		BX LR

Delay_on
			ADD R10, #1
			NOP
			NOP
			NOP
			NOP
			CMP R10, R8
			BNE Delay_on
			BX LR

;---------------------------------------SECUENCIAS----------------------------------------------------------
;                Led1                Led2              Led3
; Sec1:          Led1, Led2, Led3, Led2, Led1
; Sec2:          Led2, Led3, Led1, led3, led2
; Sec3:          Led3, led1, led2, led1, led3

;-----------------------------------------Secuencia 1-------------------------------------------------------
Sec_1     					;Patrón 1 en los leds
	LDR R6, =0
	;paso 1
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x01
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	;paso 2
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x02
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	;paso 3
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x04
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0		
	;paso 4
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x02
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0			
	;paso 5
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x01
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	B Sec_2
;------------------------------------------------------------------------------------

;-----------------------------------------Secuencia 2-------------------------------------------------------
Sec_2     					;Patrón 1 en los leds
	LDR R6, =0
	;paso 1
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x02
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	;paso 2
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x04
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	;paso 3
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x01
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0		
	;paso 4
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x04
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0			
	;paso 5
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x02
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	B Sec_3
;------------------------------------------------------------------------------------

;-----------------------------------------Secuencia 3-------------------------------------------------------
Sec_3								;Patrón 3, en la salida de los leds
	LDR R6, =0
	;paso 1
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x04
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	;paso 2
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x01
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	;paso 3
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x02
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0		
	;paso 4
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x01
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0			
	;paso 5
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0x04
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	B Final 
;------------------------------------------------------------------------------------

Final 
	LDR R4, =GPIO_PORTD012
	LDR R5, [R4]
	ORR R5, R5, #0xff
	STR R5, [R4]
		BL Delay_on
		LDR R10, =0
	LDR R4,= GPIO_PORTD012
    LDR R5,=0x0
    STR R5,[R4]
		BL Delay_on
		LDR R10, =0	
	B Loop

;-----------------------------Patrón 1------------------------------------------------------------

Pat_1    ;ingreso de la primera secuencia

		;Lectura en el puerto C
		LDR R1, =GPIO_PORTC456	
		LDR R0, [R1]

		;Retardo antirrebote
		BL Delay
		LDR R2, =0
		
		;Pin de entrada
		CMP R0, #0x10; lectura en el pin C4
			BEQ Val_1_1
			
		CMP R0, #0x20; lectura en el pin C5
			BEQ Val_1_2

		CMP R0, #0x40; lectura en el pin C6
			BEQ Val_1_3
		
		CMP R6, #5
			BEQ Decision_1
		
		B Pat_1

;--------------------------Rutina que permitirá definir si el patrón ingresado es correcto-------------------------------
Decision_1
;Operación utilizada para la toma de decisión, si se cumple o no el patrón
			ADD R9, R9, R11 ;Operación C=Pos1*Pos2+Pos3*Pos4+Pos5
			ADD R9, R9, R1  ; Valor final
		
				CMP R9, #68          ;Para cumplir con el patrón, el resultado de la operación debe ser 68
				BEQ Sec_2
				BNE.W Loop
		


;-----------------------------Asignación de valores para cada pin-----------------------------------------------------------

Val_1_1
			LDR R4, =3      ;Valor específico decimal del pin
			ADD R6, R6, #1 ;Contador de la secuencia correlativa
			B Control_1

Val_1_2
			LDR R4, =5
			ADD R6, R6, #1
			B Control_1
Val_1_3
			LDR R4, =10
			ADD R6, R6, #1	
			B Control_1
			
;------------------------------Subrutina acumuladora--------------------------------------------
Control_1
			CMP R6, #1
				BEQ Op_1_1
			CMP R6, #2
				BEQ Op_1_2
			CMP R6, #3
				BEQ Op_1_3
			CMP R6, #4
				BEQ Op_1_4			

;------------------------------Operaciones para tomar decisiones---------------------------------

Op_1_1
			MOV R7, R1       ;C=Pos1
			B Pat_1
Op_1_2
			MUL R11, R7, R1  ;Pos1*Pos2
			B Pat_1
Op_1_3
			MOV R12, R1		 ;Pos3
			B Pat_1
Op_1_4
			MUL R9, R12, R1 ;Pos3*Pos4
			B Pat_1


;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------Patrón 2------------------------------------------------------------

Pat_2    ;ingreso de la primera secuencia


		;Lectura en el puerto C
		LDR R1, =GPIO_PORTC456	
		LDR R0, [R1]

		;Retardo antirrebote
		BL Delay
		LDR R2, =0
		
		;Pin de entrada
		CMP R0, #0x10; lectura en el pin C4
			BEQ Val_2_1
			
		CMP R0, #0x20; lectura en el pin C5
			BEQ Val_2_2

		CMP R0, #0x40; lectura en el pin C6
			BEQ Val_2_3
		
		CMP R6, #5
			BEQ Decision_2
		
		B Pat_2

;--------------------------Rutina que permitirá definir si el patrón ingresado es correcto-------------------------------
Decision_2
;Operación utilizada para la toma de decisión, si se cumple o no el patrón
			ADD R9, R9, R11 ;Operación C=Pos1*Pos2+Pos3*Pos4+Pos5
			ADD R9, R9, R1  ; Valor final
		
				CMP R9, #85          ;Para cumplir con el patrón, el resultado de la operación debe ser 85
				BEQ Sec_3
				BNE Loop
		


;-----------------------------Asignación de valores para cada pin-----------------------------------------------------------

Val_2_1
			LDR R4, =3      ;Valor específico decimal del pin
			ADD R6, R6, #1 ;Contador de la secuencia correlativa
			B Control_2

Val_2_2
			LDR R4, =5
			ADD R6, R6, #1
			B Control_2
Val_2_3
			LDR R4, =10
			ADD R6, R6, #1	
			B Control_2
			
;------------------------------Subrutina acumuladora--------------------------------------------
Control_2
			CMP R6, #1
				BEQ Op_2_1
			CMP R6, #2
				BEQ Op_2_2
			CMP R6, #3
				BEQ Op_2_3
			CMP R6, #4
				BEQ Op_2_4			

;------------------------------Operaciones para tomar decisiones---------------------------------

Op_2_1
			MOV R7, R1       ;C=Pos1
			B Pat_2
Op_2_2
			MUL R11, R7, R1  ;Pos1*Pos2
			B Pat_2
Op_2_3
			MOV R12, R1		 ;Pos3
			B Pat_2
Op_2_4
			MUL R9, R12, R1 ;Pos3*Pos4
			B Pat_2


;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------Patrón 3------------------------------------------------------------

Pat_3    ;ingreso de la primera secuencia

		;Lectura en el puerto C
		LDR R1, =GPIO_PORTC456	
		LDR R0, [R1]

		;Retardo antirrebote
		BL Delay
		LDR R2, =0
		
		;Pin de entrada
		CMP R0, #0x10; lectura en el pin C4
			BEQ Val_3_1
			
		CMP R0, #0x20; lectura en el pin C5
			BEQ Val_3_2

		CMP R0, #0x40; lectura en el pin C6
			BEQ Val_3_3
		
		CMP R6, #5
			BEQ Decision_3
		
		B Pat_3

;--------------------------Rutina que permitirá definir si el patrón ingresado es correcto-------------------------------
Decision_3
;Operación utilizada para la toma de decisión, si se cumple o no el patrón
			ADD R9, R9, R11 ;Operación C=Pos1*Pos2+Pos3*Pos4+Pos5
			ADD R9, R9, R1  ; Valor final
		
				CMP R9, #85          ;Para cumplir con el patrón, el resultado de la operación debe ser 85
				BEQ Final
				BNE Loop
		


;-----------------------------Asignación de valores para cada pin-----------------------------------------------------------

Val_3_1
			LDR R4, =3      ;Valor específico decimal del pin
			ADD R6, R6, #1 ;Contador de la secuencia correlativa
			B Control_3

Val_3_2
			LDR R4, =5
			ADD R6, R6, #1
			B Control_3
Val_3_3
			LDR R4, =10
			ADD R6, R6, #1	
			B Control_3
			
;------------------------------Subrutina acumuladora--------------------------------------------
Control_3
			CMP R6, #1
				BEQ Op_3_1
			CMP R6, #2
				BEQ Op_3_2
			CMP R6, #3
				BEQ Op_3_3
			CMP R6, #4
				BEQ Op_3_4			

;------------------------------Operaciones para tomar decisiones---------------------------------

Op_3_1
			MOV R7, R1       ;C=Pos1
			B Pat_3
Op_3_2
			MUL R11, R7, R1  ;Pos1*Pos2
			B Pat_3
Op_3_3
			MOV R12, R1		 ;Pos3
			B Pat_3
Op_3_4
			MUL R9, R12, R1 ;Pos3*Pos4
			B Pat_3

;-----------------------------------------------------------------
;-----------------------------------------------------------------	

;-------------------------------------------------------------------------------------------------
Loop
	
	B Sec_1
	B Loop

    ALIGN                           
    END       