INCLUDE <P18F4321.inc>
D0 EQU 0x30 ;Set variables equal to a register
D1 EQU 0x31
ADCONRESULT EQU 0x34
ORG 0x000 ;Reset
	GOTO MAIN_PROG

; Main Program
ORG 0x100
MAIN_PROG MOVLW 0x10 ;Initialize STKPTR since interrupt and subroutines are used
	MOVWF STKPTR ;Value arbitrarily chosen
	CLRF TRISC ;Set PortC and PortD as output
	CLRF TRISD
	MOVLW 0x01 ;Select AN0 for input and enable ADC
	MOVWF ADCON0
	MOVLW 0x0D
	MOVWF ADCON1 ; Set VDD and VSS as reference input voltages and AN0 as analog
	MOVLW 0x29
	MOVWF ADCON2 ;Left justified 12TAD and Fosc/8
	BSF PIE1,ADIE ;Enable the ADC interrupt flag
	BCF PIR1, ADIF ;Clear the ADC interrupt flag
	BSF INTCON, PEIE ;Enable peripheral interrupts
	BSF INTCON, GIE ;Enable global interrupts
	BSF ADCON0,GO ;Start A/D conversion
WAIT BRA WAIT ;Wait for interrupt
	GOTO MAIN_PROG

;INTERRUPT SERVICE ROUTINE
ORG 0x0008 ;Interrupt Address Vector
	BCF PIR1, ADIF ;Clear ADIF
	MOVFF ADRESH,ADCONRESULT ;Move 8-bits of result into ADCONRESULT register
	CALL DIVIDE ; Call the divide subroutine
	CALL DISPLAY ;Call display subroutine
RETFIE

;Subroutine to divide
DIVIDE CLRF D0 ;Clears D0
	CLRF D1 ;Clears D1
	MOVLW D'51' ;Load 51 into WREG
EVEN CPFSEQ ADCONRESULT
	BRA QUOTIENT
	INCF D1, F
	SUBWF ADCONRESULT, F
QUOTIENT CPFSGT ADCONRESULT ;Checks if ADCONRESULT still greater than 51
	BRA DECIMAL
	INCF D1, F ; increment D1 for each time ADCONRESULT is greater than 51
	SUBWF ADCONRESULT, F; Subtract 51 from ADCONRESULT
	BRA EVEN
DECIMAL MOVLW 0x05
REMAINDER CPFSGT ADCONRESULT ; Checks if ADCONRESULT is greater than 5
	BRA DIVDONE
	INCF D0, F ; Increment D0 each
	SUBWF ADCONRESULT, F ; Subtract 5 from ADCONRESULT
	BRA REMAINDER
DIVDONE RETURN

;Subroutine to display result into 7-segment display
DISPLAY MOVFF D1, PORTC ; Output D1 on integer 7-seg
	MOVFF D0, PORTD ; Output D0 on fractional 7-seg
	RETURN
END