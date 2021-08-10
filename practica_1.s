; Autor: Omar Dami�n
;---------------------------------------------
;---------------------------------------------
;Practica 1 laboratorio E5
;Serie del seno
;		  M
;		------        n
;       \		   (-1)      (2n+1) 
;sin(x)= 		----------- X
;		/         (2n+1)!
;		------
;		  n=0
;Registros importantes 
;	s4=n	     s7=2n+1		
;	s8=(2n+1)!   s11=(-1)^n
;	s12=x^(2n+1) s16=sin(x)
;   s2 = M numero de iteraciones
		AREA codigo,CODE, READONLY, ALIGN=2
		THUMB
		EXPORT Start
Start	
	VMOV.F32 s1,#3 ; En s1 se encuentra el valor de x
	VMOV.F32 s2,#20 ; En s2 se va a encontra el valor de las iteraciones que se realizaran
	VMOV.F32 s3,#1 ; Constante de 1
	VMOV.F32 s4,#1 ; Varia con forme iteraciones
	VMOV.F32 s5,#-1	; constante
	VMOV.F32 s6,#2	; constante
	VMOV.F32 s9,#1 ; inicio de factorial 1
	VMOV.F32 s10,#1 ;variable que aumenta para el factorial
	VMOV.F32 s11,s5	;(-1)^n
	VMOV.F32 s13,s4 ;variable para calcular (-1)^n
	VMOV.F32 s14,s13;variable para calcular x^(2n+1)
	VMOV.F32 s12,s1 ; x^(2n+1)
	VSUB.F32 s4,s3; coloca el valor de 0 en n,s4
	VMOV.F32 s16,s4; coloca el valor de 0 en s16=sen(x)
	
denominador_exponente
	VMUL.F32 s7,s6,s4 ; 2n
	VADD.F32 s7,s3	  ; 2n+1 en s7 se guardo el 2n+1
	B factorial

factorial	;(2n+1)!
	VCMP.F32 s7,s3;     ;Compara par saber si (2n+1)=1
	VMRS APSR_nzcv, FPSCR
	BEQ factorial_1     ;Es el factorial de 1
	BNE factorial_n_1   ;Hay que calcular el factorial den 2n+1

factorial_1
	VMOV.F32 s8,#1 ; factorial de 1!=1 cuando n =0
	B exponente_0 ;->Saltar a exponenet_0

factorial_n_1
	VMUL.F32 s9,s10	; (1*k) donde k=1,2,3,4,5....n-1
	VADD.F32 s10,s3 ;  k+1
	VCMP.F32 s10,s7 ; Compara si k = 2n+1
	VMRS APSR_nzcv, FPSCR
	BEQ factorial_mul_final ; si k == 2n+1 va a factorial_mul_final y hace n*s9 
	BNE factorial_n_1 ; si k!=2n+1 entonces vuelve a multiplicar

factorial_mul_final
	VMUL.F32 s8,s9,s7 ; El factorial de 2n+1 se almacena en s8
	B exponente ;->Saltar a exponente para ver si n=1 o n>2
	
exponente_0 ; Cuando n = 0
	VMUL.F32 s11,s5,s5
	B exponentex_0 ;Saltar a exponentex para calcular x^(2n+1) cuando n=0 x^1 

exponente; cuando n=1 o n>2
	VCMP.F32 s4,s3
	VMRS APSR_nzcv, FPSCR
	BEQ exponente_1 ; slata a exponente_1 cuando n=1 (-1)^1=1
	BNE exponente_n ; salta a exponente_n cuando n>1 (-1)^n
	
exponente_1 ;cuando n=1
	VMOV.F32 s11,s5
	B exponentex_1 ;Saltar a exponentex_1 para calcular x^(1) cuando n=0
	 
exponente_n ;cuando n>1 
	VMUL.F32 s11,s5 ;-1*-1
	VADD.F32 s13,s3 ; s13 + 1
	VCMP.F32 s13,s4  ; compara si la iteracion es = n
	VMRS APSR_nzcv, FPSCR
	BNE exponente_n ; si s13!=n realiza el proceso nuevamente 
	BEQ exponentex_n ; si s13=n salta a exponentex_n cuando termina de calcular (-1)^n
	
exponentex_0
	VMOV.F32 s12,s1 ; cuando n=0-> (2n+1)=1 y x^1 = x
	B n_mas

exponentex_1 ;cuando n=1 -> (2n+1)=3
	VMUL.F32 S12,S1 ; x*x
	VADD.F32 s14,s3 ; s14+1
	VCMP.F32 s14,s7 ; s14 = 2n+1
	VMRS APSR_nzcv, FPSCR 
	BNE	exponentex_1 ; si s14!=2n+1, vuelve a hacer el proceso
	BEQ n_mas ; si s14=2n+1, cuando termina de calcular el x^(2n+1) realiza la sumatoria y vulve a iterar para encontrar el sin(x)

exponentex_n ; cuando n>1 -> (2n+1) se calcula 
	VMUL.F32 S12,S1 ; x*x
	VADD.F32 s14,s3 ; s14+1
	VCMP.F32 s14,s7 ; s14 = 2n+1
	VMRS APSR_nzcv, FPSCR 
	BNE	exponentex_n ; si s14!=2n+1
	BEQ n_mas ; si s14=2n+1	

n_mas
	VDIV.F32 s15,s11,s8; operacion de (-1)^n/(2n+1)!
	VMUL.F32 s15,s12; operacion de [(-1)^n/(2n+1)!]*x^(2n+1)
	VADD.F32 s16,s15; sumatoria desde n=0 hasta n=20
	VADD.F32 s4,s3 ;Aumenta el valor de n
	VMOV.F32 s10,s3;Resetea el valor de s10 a 1
	VMOV.F32 s9,s3;Resetea el valor de s10 a 1
	VMOV.F32 s11,s5;Resetea el valor de s11 a -1
	VMOV.F32 s12,s1;Resetea el valor de s12 a x
	VMOV.F32 s14,s3;Resetea el valor de s14 a 1
	VMOV.F32 s13,s3;Resetea el valor de s13 a 1
	VCMP.F32 s4,s2 ;Compara el valor del registro s4 con el s2->numero de iteraciones
	VMRS APSR_nzcv, FPSCR
	BEQ fin
	BNE denominador_exponente
	NOP
	NOP
	
fin
	ALIGN
	END