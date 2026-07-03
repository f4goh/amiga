
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

Main:		LEA.L	Coplist(PC),a0		; A0 = APTR coplist
		MOVE.L	a0,COP1LC(a5)		; Set start address for Copper

		MOVE.W	#$8080,DMACON(a5)	; Enable Copper DMA

.WaitLoop:	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

;-----------------------------------------------------------

Coplist:	DC.W	COLOR0,$0000	; Start with a black background

		DC.W	$5007,$fffe	; Wait for line $50
		DC.W	COLOR0,$0009	; Set background colour to dark blue
		DC.W	$5107,$fffe	; Wait for line $51
		DC.W	COLOR0,$000F	; Set background colour to light blue
		DC.W	$5207,$fffe	; Wait for line $52
		DC.W	COLOR0,$0009	; Set background colour to dark blue
		DC.W	$5307,$fffe	; Wait for line $53
		DC.W	COLOR0,$0000	; Set background colour to black

		DC.W	$FFDF,$fffe	; Wait for the end of line 255

		DC.W	$0007,$fffe	; Wait for line $00 (256)
		DC.W	COLOR0,$0009	; Set background colour to dark blue
		DC.W	$0107,$fffe	; Wait for line $01 (257)
		DC.W	COLOR0,$000F	; Set background colour to light blue
		DC.W	$0207,$fffe	; Wait for line $02 (258)
		DC.W	COLOR0,$0009	; Set background colour to dark blue
		DC.W	$0307,$fffe	; Wait for line $03 (259)
		DC.W	COLOR0,$0000	; Set background colour to black

		DC.W	$ffff,$fffe	; Make Copper wait until next vertical blank

;-----------------------------------------------------------
