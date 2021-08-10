; Autor: Omar Dami�n
;---------------------------------------------
;---------------------------------------------
;Generador de numeros aleatorios
;Xn+1=(aXn+c)(mod m)
;4 grupos de 3 numeros aleatorios
; SRAM 0x2000.0000 -> 0x2000.7FFF
;LDR Rx,[Ry],#4 para leer cada 4 bytes,
;STR Rx,[Ry],#4 para escribir cada 4 bytes
;    a=1
;    c=x
;    m=128
;Se usaran los pines fisicos [PD0:PD3] y [PB4:PB5] como entradas, [PD6] como salida, y [PE0:PE5] como salidas
PORTE	EQU	0x400240FC
PORTD_O	EQU 0x40007100
PORTD_I EQU 0x4000703C
PORTB 	EQU 0x400050C0
PORTC	EQU	0x40006200
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
;Registros del puerto B
GPIO_PORTB_AMSEL_R	EQU 0x40005528
GPIO_PORTB_AFSEL_R	EQU 0x40005420
GPIO_PORTB_PCTL_R	EQU 0x4000552C
GPIO_PORTB_DIR_R	EQU	0x40005400
GPIO_PORTB_DEN_R	EQU	0x4000551C
;Registros del puerto c
GPIO_PORTC_AMSEL_R	EQU 0x40006528
GPIO_PORTC_AFSEL_R	EQU 0x40006420
GPIO_PORTC_PCTL_R	EQU 0x4000652C
GPIO_PORTC_DIR_R	EQU	0x40006400
GPIO_PORTC_DEN_R	EQU	0x4000651C
;Registros del sistema
SYSCTL_RCGCGPIO_R	EQU	0x400FE608

PE	EQU	0x3F
PD	EQU	0x4F
POC EQU 0X80
PB  EQU 0x30
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
sec_1   EQU 0x20000008
sec_2   EQU 0x20000014
sec_3   EQU 0x20000020
sec_4   	  EQU 0x2000002C
sec_usuario   EQU 0x20000038
a_cst		EQU	1
c_cst       EQU 7
m_cst       EQU 128
        AREA codigo, CODE, READONLY,ALIGN=2
        THUMB
        EXPORT Start
Start
;----------------------------------------------------------------------------------------
	LDR R1,=SYSCTL_RCGCGPIO_R; Habilitacion del reloj para los puertos D y E
	LDR R0, [R1]
	ORR R0, R0, #0x1E
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
	LDR R1,=GPIO_PORTE_AFSEL_R;Habilitacion como GPIO
	LDR R0,[R1]
	BIC	R0,R0,#PE
	STR R0,[R1]
	LDR R1,=GPIO_PORTE_PCTL_R;Deshabilitacion de funcion alternativa
	LDR R0, [R1]
	BIC R0,R0,#0x000000FF
	BIC R0,R0,#0x00000F00
	BIC R0,R0,#0x00F00000
	BIC R0,R0,#0x000FF000
	STR R0,[R1]
	LDR R1,=GPIO_PORTE_DIR_R;Habilitacion como salida
	LDR R0,[R1]
	ORR R0,R0,#PE
	STR R0,[R1]
	LDR R1,=GPIO_PORTE_DEN_R;Habilitacion de pines
	LDR R0,[R1]
	ORR R0,R0,#PE
	STR R0,[R1]
;------------------------------------------------------------------------
	LDR R1,=GPIO_PORTC_AMSEL_R
	LDR R0,[R1]
	BIC R0, R0,#POC
	STR R0,[R1]
	LDR R1,=GPIO_PORTC_AFSEL_R
	LDR R0,[R1]
	BIC R0, R0,#POC
	STR R0, [R1]
	LDR R1,=GPIO_PORTC_PCTL_R
	LDR R0,[R1]
	BIC R0,R0,#0xF0000000
	STR R0,[R1]
	LDR R1,=GPIO_PORTC_DIR_R
	LDR R0,[R1]
	ORR R0,R0,#0x80 ; Salida
	STR R0,[R1]
	LDR R1,=GPIO_PORTC_DEN_R
	LDR R0,[R1]
	ORR R0,R0,#POC
	STR R0,[R1]
;------------------------------------------------------------------------
	LDR R1,=GPIO_PORTD_AMSEL_R
	LDR R0,[R1]
	BIC R0, R0,#PD
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_AFSEL_R
	LDR R0,[R1]
	BIC R0, R0,#PD
	STR R0, [R1]
	LDR R1,=GPIO_PORTD_PCTL_R
	LDR R0,[R1]
	BIC R0,R0,#0x0F000000
	BIC R0,R0,#0xF0000000
	BIC R0,R0,#0x0000FF00
    BIC R0,R0,#0x000000FF
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_DIR_R
	LDR R0,[R1]
	ORR R0,R0,#0x40 ; Salida
	BIC R0,R0,#0x0F ; Entrada
	STR R0,[R1]
	LDR R1,=GPIO_PORTD_DEN_R
	LDR R0,[R1]
	ORR R0,R0,#PD
	STR R0,[R1]
;---------------------------------------------------------------------     
	LDR R1,=GPIO_PORTB_AMSEL_R
	LDR R0,[R1]
	BIC R0, R0,#PB
	STR R0,[R1]
	LDR R1,=GPIO_PORTB_AFSEL_R
	LDR R0,[R1]
	BIC R0, R0,#PB
	STR R0, [R1]
	LDR R1,=GPIO_PORTB_PCTL_R
	LDR R0,[R1]
	BIC R0,R0,#0x000F0000
	BIC R0,R0,#0x00F00000
	STR R0,[R1]
	LDR R1,=GPIO_PORTB_DIR_R
	LDR R0,[R1]
	BIC R0,R0,#PB ; Entrada
	STR R0,[R1]
	LDR R1,=GPIO_PORTB_DEN_R
	LDR R0,[R1]
	ORR R0,R0,#PB
	STR R0,[R1]
;---------------------------------------------------------------------                                
;----Declaracion de constantes y variables----------------------------
;---Generacion de numeros aleatorios
    LDR R9,=sec_1 ; inicio de memoria, las secuencias se guardan consecutivamente   
    LDR R2,=1	; Se carga la constante para la primera secuecnia de la ecuacion Xn+1=(aXn+c)(mod m)
    LDR R3,=c_cst
    LDR R4,=m_cst
    LDR R8,=0
    LDR R7,=7
    MOV R0,R7
    BL rand  ; con las constantes se calculan los numeros aleatorios en la subrutina rand
	LDR R2,=3 ; Se carga la constante para la segunda secuecnia de la ecuacion Xn+1=(aXn+c)(mod m)
    LDR R8,=0
    LDR R7,=7
    MOV R0,R7
    BL rand; con las constantes se calculan los numeros aleatorios en la subrutina rand
	LDR R2,=9 ; Se carga la constante para la tercera secuecnia de la ecuacion Xn+1=(aXn+c)(mod m)
    LDR R8,=0
    LDR R7,=7
    MOV R0,R7
    BL rand; con las constantes se calculan los numeros aleatorios en la subrutina rand
	LDR R2,=13 ; Se carga la constante para la cuarta secuecnia de la ecuacion Xn+1=(aXn+c)(mod m)
    LDR R8,=0
    LDR R7,=7
    MOV R0,R7
    BL rand; con las constantes se calculan los numeros aleatorios en la subrutina rand
	B main

rand;Generador de numeros aleatorios
    MUL R7,R2
    ADD R7,R3
    UDIV R5,R7,R4
    MUL R5,R4
    SUB R0,R7,R5
    MOV R7,R0
	CMP R0,#5 ; Se compara si el valor obtenido de la secuencia es menor a 5 si no se calcula el siguiente y se compara de nuevo
    BLS rand_num 
    B rand

rand_num; Se guardan los numeros en memoria
    ADD R8,#1
    MOV R1,R0
    STR R1,[R9],#4 ; Se guardan las secuencias separando la siguiente direccion por 4 bytes
    CMP R8,#3      ; Se compara si ya se lleno 3 numeros de una secuencia
    BNE rand		; Si se llenaron los 3 numeros se pasa a la siguiente carga de valores para la ecuacion y se calculan otros 3 numeros aleatorios
	BX LR

delay	; Rutina de retardo de 50ms.
	ADD R2, #1
	NOP
	NOP
	NOP
	NOP
	CMP R2, R3
	BNE delay
	BX LR

display ; Comparador para seleccionar el numero a desplegar el cual se encuentra en el registro R4
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
; En las siguientes rutinas num_x se cambian los valores a desplegar en las salidas E y D para un display catodo comun	
num_0 
	LDR R0,=DISPE_0
	LDR R12,=DISPD_00
	B led_disp

num_1
	LDR R0,=DISPE_1
	LDR R12,=DISPD_1
	B led_disp
	
num_2
	LDR R0,=DISPE_2
	LDR R12,=DISPD_00
	B led_disp

num_3
	LDR R0,=DISPE_3
	LDR R12,=DISPD_00
	B led_disp

num_4
	LDR R0,=DISPE_4
	LDR R12,=DISPD_4
	B led_disp

num_5
	LDR R0,=DISPE_5
	LDR R12,=DISPD_00
	B led_disp

num_6
	LDR R0,=DISPE_6
	LDR R12,=DISPD_00
	B led_disp

num_7
	LDR R0,=DISPE_7
	LDR R12,=DISPD_00
	B led_disp

num_8
	LDR R0,=DISPE_8
	LDR R12,=DISPD_00
	B led_disp

num_9
	LDR R0,=DISPE_9
	LDR R12,=DISPD_00
	B led_disp
; Cada rutina num_x manda a llamar a la rutina led_disp la encargada de cambiar los registros con los valores necesarios para desplegar el numero
led_disp
	LDR R1,=PORTE
	STR R0,[R1]
	LDR R1,=PORTD_O
	STR R12,[R1]
	BX LR
;Esta rutina manda a llamar de memoria en la posicion que indica el registro R11, puede ser sec_1, sec_2, sec_3 o sec_4 para desplegar en el display
secuencia_1
	LDR R4,[R11],#4; Se carga el primer numero de la secuencia indicada
	BL display
	BL delay
	LDR R2,=0
	LDR R4,[R11],#4; Se carga el segundo numero de la secuencia indicada
	BL display
	BL delay
	LDR R2,=0
	LDR R4,[R11],#4; Se carga el tercer numero de la secuencia indicada
	BL display
	BL delay
	LDR R2,=0
	LDR R4,=8; Se carga en R4 el valor de 8 para borrar el ultimo digito del display
	BL display
	B control

led_on
	LDR R0,=PORTC
	LDR R1,[R0]
	ORR R1,R1,#0x80
	STR R1,[R0]
	BX LR

led_off
	LDR R0,=PORTC
	LDR R1,[R0]
	BIC R1,R1,#0x80
	STR R1,[R0]
	BX LR
; Esta sub rutina se utiliza para obtener los digitos que el usuario ingrese
control
	LDR R6,=PORTD_I
	LDR R7,[R6]
	LDR R6,=PORTB
	LDR R10,[R6]
	ORR R7,R10 ; se concatenan los valores de los puertos D y B de las entradas para leer en 1 registro el valor ingresado
	CMP R7,#0 ; se compara el registro R7 para saber si no se ha presionado algun boton si es el caso regresa a al inicio de la subrutina desde este punto
	BEQ control
	ADD R8,#1	; si se presiono algun boton o combinacion esta variable se utiliza para saber si se ingresaron los 3 numeros si no se siguen aceptando los numeros ingresados
	BL numero_memoria ; cambia el valor del registro R7 dependiendo del boton que se presiono debido a que en el registro se toma el valor en hexadecimal de la posicion del boton
	STR R7,[R5],#4   ; se guarda la secuencia ingresada por el 
	BL led_on       ; esto es una secuecnia indicadora para saber cuando se puede ingresar el siguiente digito
	BL delay
	LDR R2,=0
	LDR R3,=CONST_500MS
	BL led_off ; hasta aca termina la secuencia indicadora
	CMP R8,#3 ; se compara para saber si ya se han ingresado los 3 digitos
	BNE control ; si no se han ingresado regresa al inicio de la sub rutina para obtener el siguiente valor
	BEQ comp

numero_memoria ; cambia el valor del registro R7 a uno entre 0 y 5 dependiendo del boton pulsado
	CMP R7,#0x01
	BEQ set_r7_0
	CMP R7,#0x02
	BEQ set_r7_1
	CMP R7,#0x04
	BEQ set_r7_2
	CMP R7,#0x08
	BEQ set_r7_3
	CMP R7,#0x10
	BEQ set_r7_4
	CMP R7,#0x20
	BEQ set_r7_5
	BNE desechado
; En las subrutinas set_r7_x se cambian los valores de R7 
set_r7_0
	LDR R7,=0
	BX LR
set_r7_1
	LDR R7,=1
	BX LR
set_r7_2
	LDR R7,=2
	BX LR
set_r7_3
	LDR R7,=3
	BX LR
set_r7_4
	LDR R7,=4
	BX LR
set_r7_5
	LDR R7,=5
	BX LR
desechado ; si se presiona alguna combinacion de botones se guarda el valor en hexadecimal de la combinacion
	BX LR
; Al momento de obtenerse los 3 digitos de cualquier secuencia del usuario, se compara para saber que secuencia es la que se le mostro y asi saber que comparaciones de las secuecnias en memoria deben de hacerse	
comp    ; Se mandan a llamar a las subrutinas set_secX para resetear los valores de inicio de memoria de cada secuencia para compararla con la del usuario
	LDR R8,=0
	LDR R7,=0
	CMP R9,#1; la secuencia actual es la 1
	BEQ set_sec1
	CMP R9,#2; la secuencia actual es la 2
	BEQ set_sec2
	CMP R9,#3; la secuencia actual es la 3
	BEQ set_sec3
	CMP R9,#4; la secuencia actual es la 4
	BEQ set_sec4

set_sec1 ; se resetea la posicion de r11 a la posicion en memoria de la secuencia sec_1
	LDR R11,= sec_1
	B comp_1 ; se manda a la comparacion1 el primer digito de la secuencia aleatoria contra el pirmero del usuario

set_sec2 ; se resetea la posicion de r11 a la posicion en memoria de la secuencia sec_2
	LDR R11,= sec_2
	B comp_1

set_sec3 ; se resetea la posicion de r11 a la posicion en memoria de la secuencia sec_3
	LDR R11,= sec_3
	B comp_1

set_sec4 ; se resetea la posicion de r11 a la posicion en memoria de la secuencia sec_4
	LDR R11,= sec_4
	B comp_1

comp_1; se compara el primer digito de la secuencia  con el primer digito de la secuencia del usuario
	LDR R4,[R11],#4
	LDR R5,=sec_usuario
	LDR R1,[R5],#4
	CMP R4,R1; en r4 se carga el digito de la secuencia y en r1 el digito de la secuencia de usuario
	BEQ comp_2
	BNE main

comp_2; se compara el segundo digito de la secuencia  con el segundo digito de la secuencia del usuario
	LDR R4,[R11],#4
	LDR R1,[R5],#4
	CMP R4,R1
	BEQ comp_3
	BNE main

comp_3; se compara el tercer digito de la secuencia  con el tercer digito de la secuencia del usuario
	LDR R4,[R11],#4
	LDR R1,[R5],#4
	CMP R4,R1; 
	BEQ secuencia ; Esta rutina sirve para cambiar de la sec_x actual a la siguiente secuencia para mostrarla y esperar a que el usuario ingrese los datos
	BNE main
;Si el digito en cualquier posicion no es igual al de la secuencia actual se regresa a la rutina principal para empezar de nuevo
secuencia_2 ; en las subrutinas secuencia_x se cargan en r5 la direccion de la secuencia de usuario en memoria, y en R11 la secuencia a mostrar dependiendo de la secuencia deseada
	LDR R3,=CONST_500MS
	LDR R5,=sec_usuario
	LDR R11,=sec_2
	LDR R8,=0
	LDR R9,=2
	B secuencia_1 ; Se manda a llamar a la rutina secuencia_1 para mostrar la nueva secuencia y se repite el ciclo antes descrito.

secuencia_3
	LDR R3,=CONST_500MS
	LDR R5,=sec_usuario
	LDR R11,=sec_3
	LDR R8,=0
	LDR R9,=3
	B secuencia_1

secuencia_4
	LDR R3,=CONST_500MS
	LDR R5,=sec_usuario
	LDR R11,=sec_4
	LDR R8,=0
	LDR R9,=4
	B secuencia_1

secuencia ; Se compara R9 en la cual se guarda la secuencia actual en un numero del 1 al 4, dependiendo de que secuencia es la actual se pasa a la siguiente cambiando el valor de r9 y llamando a las 
	CMP R9,#1 ; rutinas secuencia_x para colocar los valores adecuados de inicio de memoria de la secuencia siguiente
	BEQ secuencia_2
	CMP R9,#2
	BEQ secuencia_3
	CMP R9,#3
	BEQ secuencia_4
	CMP R9,#4
	BEQ main

main
	LDR R3,=CONST_500MS ; valor inicial de contador de retras
	LDR R5,=sec_usuario ; valor incial de la direccion en memoria de la secuencia de usuario
	LDR R11,=sec_1 ; valor inicial de la direccion en memoria de la primera secuecia
	LDR R8,=0 ; Reseteo de la variable r8
	LDR R9,=1 ; seteo de la constante C de la ecuacion de numeros aleatorios
	B secuencia_1 ; llamado a secuencia_1 para mostrar la primera secuecnia y entrar al ciclo del juego
	B main
    ALIGN
    END