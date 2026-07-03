;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

; Copyright 2021 ing. E. Th. van den Oosterkamp
;
; Example software for the book "BareMetal Amiga Programming" (ISBN 9798561103261)
;
; Permission is hereby granted, free of charge, to any person obtaining a copy 
; of this software and associated files (the "Software"), to deal in the Software 
; without restriction, including without limitation the rights to use, copy,
; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
; and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in 
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
; PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



;
; Interfacing the keyboard
;
; This example uses the function keys to change the background colour.
;
; Press F1 to increase the amount of red.
; Press F2 to increase the amount of green.
; Press F3 to increase the amount of blue.
;
; When a colour reaches 15 it will start at 0 again.
;
; Press the left mouse button to exit
;


		INCLUDE	"BareMetal:Include/BareMetal.i"

;-----------------------------------------------------------

		SECTION	Code,CODE

		INCLUDE	"BareMetal:Include/SafeStart.i"

; Backup the two IRQ vectors since these are not done by SafeStart.i

Main:		MOVE.L	S_VBR(PC),a0		; APTR to vector CPU table
		MOVE.L	IRQ2(a0),-(a7)		; Backup vector 2
		MOVE.L	IRQ6(a0),-(a7)		; Backup vextor 6

; Set the new vectors and enable the interrupts
		
		MOVE.L	#CIAA_Handler,IRQ2(a0)	; Set the new CIAA IRQ vector
		MOVE.L	#CIAB_Handler,IRQ6(a0)	; Set the new CIAB IRQ vector

		MOVE.W	#$A008,INTENA(a5)	; Enable interrupt for CIAA+CIAB

; Read the keycode set by the interrupt and act on it
	
.WaitLoop:	MOVE.B	KeyCode(PC),d0		; Get the next key code
		BEQ.B	.NoKey			; No key code to process?

		CMPI.B	#$50,d0			; F1 key?
		BNE.B	.NotF1			
		ADDQ.B	#1,Red			; Increase red
		ANDI.B	#$F,Red			; Change the red bits only

.NotF1		CMPI.B	#$51,d0			; F2 key?
		BNE.B	.NotF2
		ADDQ.B	#1,Green		; Increase green
		ANDI.B	#$F,Green		; Change the green bits only

.NotF2		CMPI.B	#$52,d0			; F3 key?
		BNE.B	.NotF3
		ADDQ.B	#1,Blue			; Increase blue
		ANDI.B	#$F,Blue		; Change the blue bits only

.NotF3		MOVE.B	Red(PC),d1		; Get the red bits
		LSL.W	#4,d1			; Make space for green bits
		OR.B	Green(PC),d1		; Insert the green bits
		LSL.W	#4,d1			; Make space for blue bits
		OR.B	Blue(PC),d1		; Insert the blue bits
		MOVE.W	d1,$DFF000+COLOR0	; Use color to set background

		CLR.B	KeyCode			; Processed this code

; Keep looping until the left mouse button is clicked

.NoKey		BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing

; Disable the interrupts before restoring the original vectors

		MOVE.W	#$2008,INTENA(a5)	; Disable interrupt for CIAAi+CIAB

		MOVE.L	(a7)+,IRQ6(a0)		; Restore original vector 6
		MOVE.L	(a7)+,IRQ2(a0)		; Restore original vector 2

		RTS

;-----------------------------------------------------------

KeyCode:	DC.B	0
Red:		DC.B	8
Green:		DC.B	8
Blue:		DC.B	8


;-----------------------------------------------------------
;
; This handler is called each time CIAA receives a byte from the keyboard.
; The keyboard needs a 200uS handshake signal. The signal is started by
; this interrupt handler which sets up an alarm on CIAB so that the
; CIAB_handler is called at the end of the handshake period.
;
; Using a value of 4 TOD counts means that the ALARM interrupt fill fire
; at somewhere between 190uS and 254uS for PAL systems.

CIAA_Handler:	MOVEM.L	d0-d1,-(a7)

		MOVE.B	CIAAICR,d0		; Read source of CIAA IRQ
		BEQ.W	.NoIRQ			; Not from CIAA!
		BTST	#3,d0			; Check the SP bit 
		BEQ.W	.NotKB			; Not set? Was not keyboard IRQ

		MOVE.B	CIAASDR,d0		; Read new value
		ROR.B	d0			; Set the bits in right order
		NOT.B	d0			; Account for active-low!
		MOVE.B	d0,KeyCode			; Store new key code

		BSET.B	#6,CIAACRA		; Change serial to output
		CLR.B	CIAASDR			; Set the SP (KDAT) pin low.

		MOVEQ	#0,d1			; Ensure top bits will be cleared
		MOVE.B	CIABTODHI,d1		; Reading TODHI latches values
		SWAP	d1			; Move to bottom byte of top word
		MOVE.B	CIABTODMID,d1		; Read TOD middle byte
		ASL.W	#8,d1			; Move to top byte bottom word
		MOVE.B	CIABTODLO,d1		; Reading TODLO removes latch

		BSET.B	#7,CIABCRB		; Writing to TOD will set alarm

		ADDQ.L	#4,d1			; Calculate the number of TOD counts required

		MOVE.B	d1,d0			; Make copy of the TODLO value
		ASR.W	#8,d1			; Move TODMID to low byte
		MOVE.B	d1,CIABTODMID		; Write to TOD
		SWAP	d1			; Move TODHI to low byte
		MOVE.B	d1,CIABTODHI		; Write to TOD
		MOVE.B	d0,CIABTODLO		; Write TODLO to TOD
		MOVE.B	#$84,CIABICR		; Enable TOD alarm interrupt 

.NotKB		MOVE.W	#$0008,$DFF000+INTREQ	; Acknowledge CIAA IRQ

.NoIRQ		MOVEM.L	(a7)+,d0-d1
		RTE


;-----------------------------------------------------------
;
; This handler is called each time the TOD of CIAB reaches the ALARM value.
; When this happens the keyboard handshake on CIAA has finished and the
; keyboard can send the next value.

CIAB_Handler:	MOVEM.L	d0,-(a7)

		MOVE.B	CIABICR,d0		; Read source of CIAB IRQ
		BEQ.W	.NoIRQ			; Not from CIAB!
		BTST	#2,d0			; Check the TOD bit 
		BEQ.B	.NoIRQ			; Not set? Was not TOD counter IRQ

		BCLR.B	#6,CIAACRA		; Change serial back to input.
		MOVE.B	#$04,CIABICR		; Disable TOD alarm interrupt

.NoIRQ		MOVE.W	#$2000,$DFF000+INTREQ	; Acknowledge CIAB IRQ

		MOVEM.L	(a7)+,d0
		RTE

; -----------------------------------------------------------


