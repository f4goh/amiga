
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

;-----------------------------------------------------------

		SECTION	Code,CODE_C		

		INCLUDE	"BareMetal:Include/SafeStart.i"


Main:		MOVE.L	S_VBR(PC),a0
		MOVE.L	#IRQHandler,IRQ3(a0)	; Set the new vector

		LEA.L	Coplist(PC),a0		; A0 = APTR coplist
		MOVE.L	a0,COP1LC(a5)		; Set start address for Copper

		MOVE.W	#$8010,INTENA(a5)	; Enable interrupt for the Copper
		MOVE.W	#$8080,DMACON(a5)	; Enable Copper DMA

.WaitLoop:	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------

IRQHandler:	MOVE.W	#$0010,$DFF000+INTREQ	; Acknowledge the interrupt
		MOVE.W	#$0fff,$DFF000+COLOR0	; Set background to white
		RTE


;-----------------------------------------------------------

Coplist:	DC.W	COLOR0,$0000	; Start with a black background

		DC.W	$5207,$fffe	; Wait for start of line $52 
		DC.W	COLOR0,$000f	; Set background colour to light blue
		DC.W	$0051,$80fe	; Wait for horizontal position $50
		DC.W	COLOR0,$0000	; Set background colour to black
		DC.W	INTREQ,$8010	; Trigger Copper interrupt	

		DC.W	$5307,$fffe	; Wait for start of line $53
		DC.W	COLOR0,$0000	; Set background colour to black

		DC.W	$7307,$fffe	; Wait for start of line $73
		DC.W	COLOR0,$000f	; Set background colour to light blue
		DC.W	$0051,$80fe	; Wait for horizontal position $50
		DC.W	COLOR0,$0000	; Set background colour to black
		DC.W	INTREQ,$8010	; Trigger Copper interrupt	
		DC.W	COLOR1,$0000	; Set foreground colour to black
		DC.W	COLOR1,$0000	; Set foreground colour to black
		DC.W	COLOR1,$0000	; Set foreground colour to black
		DC.W	COLOR1,$0000	; Set foreground colour to black
		DC.W	COLOR1,$0000	; Set foreground colour to black
		DC.W	COLOR1,$0000	; Set foreground colour to black
		DC.W	COLOR1,$0000	; Set foreground colour to black

		DC.W	$7407,$fffe	; Wait for start of line $74
		DC.W	COLOR0,$0000	; Set background colour to black

		DC.W	$ffff,$fffe	; Make Copper wait until next vertical blank

;-----------------------------------------------------------
