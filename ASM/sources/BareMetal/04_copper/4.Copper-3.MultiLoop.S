
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

Main:		LEA.L	Coplist(PC),a0		; 
		MOVE.L	a0,COP1LC(a5)		; Set start address for coplist

		LEA.L	Coploop1(PC),a0
		MOVE.L	a0,d0
		MOVE.W	d0,-2(a0)		; Bottom word into coplist
		SWAP	d0
		MOVE.W	d0,-6(a0)		; Top word into coplist

		LEA.L	Coploop2(PC),a0
		MOVE.L	a0,d0
		MOVE.W	d0,-2(a0)
		SWAP	d0
		MOVE.W	d0,-6(a0)

		MOVE.W	#$8080,DMACON(a5)	; Enable Copper DMA

.WaitLoop:	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

;-----------------------------------------------------------

Coplist:	DC.W	COLOR0,$0000	; Background colour: black
		DC.W	$4007,$fffe	; Wait for line $40
		DC.W	COLOR0,$0008	; Background colour: dark blue
		DC.W	$4107,$fffe	; Wait for line $41
		DC.W	COLOR0,$0000	; Background colour: black

		DC.W	COP2LCH,0	; Place the Coploop1 address into COP2LC
		DC.W	COP2LCL,0	;
Coploop1:	DC.W	$0051,$80fe	; Wait for horizontal position $51
		DC.W	COLOR0,$0050	; Set background colour to dark green
		DC.W	$0091,$80fe	; Wait for horizontal position $91
		DC.W	COLOR0,$0000	; Set background colour to black
		DC.W	$00E1,$80fe	; Wait for the end of the line
		DC.W	$8007,$ff01	; Skip next instruction if after line $79
		DC.W	COPJMP2,$0	; Trigger jump to location in COP2LC

		DC.W	COP2LCH,0	; Place the Coploop2 address into COP2LC
		DC.W	COP2LCL,0	; 
Coploop2:	DC.W	$8071,$80fe	; Wait for horizontal position $51
		DC.W	COLOR0,$0500	; Set background colour to dark red
		DC.W	$80B1,$80fe	; Wait for horizontal position $91
		DC.W	COLOR0,$0000	; Set background colour to black
		DC.W	$80E1,$80fe	; Wait for the end of the line
		DC.W	$E007,$ff01	; Skip next instruction if after line $E0
		DC.W	COPJMP2,$0	; Trigger jump to location in COP2LC

		DC.W	COLOR0,$0008	; Background colour: dark blue
		DC.W	$E107,$fffe	; Wait for line $01
		DC.W	COLOR0,$0000	; Background colour: black

		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------
