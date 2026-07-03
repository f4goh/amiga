
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


		INCLUDE	"BareMetal:Include/BareMetal.i"

ExecSupervisor	EQU	-30
exec_AttnFlags	EQU	296	

;-----------------------------------------------------------

		SECTION	Code,CODE_C		

Main:		MOVE.L	4.w,a6			; A6 = Exec base
		SUB.L	a0,a0			; A0 = zero
		BTST.B	#0,exec_AttnFlags(a6)	; Check if > 68000 processor
		BEQ.B	.NoVBR			; On 68000 no VBR (always zero)
		LEA.L	GetVBR(PC),a5		; Function to call as supervisor
		JSR	ExecSupervisor(a6)	; Call supervisor function in A5
		MOVE.L	d0,a0			; A0 = VBR

.NoVBR		LEA	$DFF000,a5		; Custom base
		MOVE.W	INTENAR(a5),d7		; Store original value
		OR.W	#$8000,d7		; Set the SET bit
		MOVE.L	IRQ4(a0),OldVector	; Store original vector

		MOVE.L	#AudioHandler,IRQ4(a0)	; Set the new vector
		MOVE.W	#$8080,INTENA(a5)	; Enable interrupt for audio channel 0

		MOVE.L	#SndData,AUD0LC(a5)	; Set pointer to audio data location
		MOVE.W	#SndLen>>1,AUD0LEN(a5)	; Audio length in words
		MOVE.W	#64,AUD0VOL(a5)		; Maximum volume
		MOVE.W	#296,AUD0PER(a5)	; Period of 296 for 1kHz tone on a PAL system
		MOVE.W	#$8201,DMACON(a5)	; Start DMA for audio channel 0

.WaitLoop	MOVE.W	AH_Count(PC),d0		; Get interrupt count value
		CMPI.W	#2,d0			; Check if there were 2 interrupts
		BGE.B	.EndWait		; If 2 or more then end the wait loop
		BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing

.EndWait	MOVE.W	#$0001,DMACON(a5)	; Stop DMA for audio channel 0
		MOVE.W	#$0080,INTENA(a5)	; Disable interrupt for audio channel 0	
		MOVE.L	OldVector(PC),IRQ4(a0)	; Restore original vector
		MOVE.W	d7,INTENA(a5)		; Restore original value
		RTS


;-----------------------------------------------------------

GetVBR:		DC.L	$4E7A0801		; MOVEC VBR,d0
		RTE				; Return from supervisor mode


;-----------------------------------------------------------

AudioHandler:	MOVE.W	#$0080,$DFF000+INTREQ	; Acknowledge the interrupt
		MOVE.L	#Silence,$DFF000+AUD0LC	; Next audio location: silence
		MOVE.W	#2,$DFF000+AUD0LEN	; Data consists of 2 words (4 bytes)
		ADDQ.W	#1,AH_Count		; Increase counter
		RTE


;-----------------------------------------------------------

AH_Count:	DC.W	0	; Storage for interrupt counter
OldVector:	DC.L	0	; Storage for original interrupt vector
Silence:	DC.L	0


;-----------------------------------------------------------

SndData:	INCBIN "BareMetal:Assets/Audio-Sample.raw"
SndLen		EQU 	*-SndData
	

;-----------------------------------------------------------

