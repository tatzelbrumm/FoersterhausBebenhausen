; quadrature oscillator
	.cpl_on			; compiler mode [compiler default]
	.arms_on		; control mode [compiler default]
	.c54cm_off		; C55x native mode
;
; void qosc(
;   short *coeff,		// {power, re, im} coefficients
;   short *accu,		// {real, imaginary} Q15 accumulator
; 	unsigned short n_1,	// number of results produced -1
;	short **result);	// pointers to {real, imaginary} result storage
;
; Parameters:
; XAR0: pointer to coefficients
; XAR1: pointer to accumulator
; T0: number of iterations-1
; XAR2: pointer to result data pointers 
; 
; Registers:
; AC0
; AC1
; AC2
; AC3
; XAR0: pointer to coefficients
; XAR1: pointer to Re[accumulator]
; XAR2: pointer to Im[accumulator]
; XAR3: pointer to Re[result]
; XAR4: pointer to Im[result]
; XCDP: pointer to coefficients
;
	.def 	_qosc
	.text
_qosc
	psh 	mmap(ST3_55)
;	psh 	mmap(ST2_55)
	psh 	mmap(ST1_55)
	or  	#0340h, mmap(ST1_55)	; enable data sign extension, data saturation, fractional modes
	mov 	T0, BRC0
 ||	mov 	dbl(*AR2+), XAR3		; point to Re[result]
	mov 	dbl(*AR2), XAR4			; point to Im[result]
 ||	bset 	SMUL					; saturate multiplications
	amar 	*AR1(#1), XAR2			; point to Im[accumulator]
	mov 	*AR0+<<#16, AC2			; load target power
 ||	rptblocal	loop-1
	amar 	*AR0, XCDP
 ||	mov 	AC2, AC3			; target power
	mpy 	*AR1, *CDP+, AC0		; multiply by Re[coefficient]
 ::	mpy 	*AR2, *CDP+, AC1
	masr 	*AR2, *CDP+, AC0		; multiply by Im[coefficient]
 ::	macr 	*AR1, *CDP+, AC1
	sqs 	AC0, AC3			; - Re[result]^2
	sqsr 	AC1, AC3			; - Im[result]^2
	mov 	HI(AC3), T0
	macr 	AC0, T0, AC0			; scale Re[result]
	macr 	AC1, T0, AC1			; scale Im[result]
	mov 	HI(AC0), *AR3+			; save result
 ||	mov 	HI(AC1), *AR4+
	mov 	HI(AC0), *AR1			; save accumulator
 ||	mov 	HI(AC1), *AR2
loop
	pop 	mmap(ST1_55)
;	pop 	mmap(ST2_55)
	pop 	mmap(ST3_55)
	ret
