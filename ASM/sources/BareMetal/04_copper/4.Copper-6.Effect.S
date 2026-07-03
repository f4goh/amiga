
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

		SECTION	Code,CODE

		INCLUDE	"BareMetal:Include/SafeStart.i"

Main:		BSR.B	CreateList

		MOVE.L	S_VBR(PC),a0		; Pointer to vector base
		MOVE.L	#IRQHandler,IRQ3(a0)	; Set the new vector

		LEA.L	Coplist,a0		; A0 = APTR coplist
		MOVE.L	a0,COP1LC(a5)		; Set start address for Copper

		MOVE.W	#$8010,INTENA(a5)	; Enable interrupt for the Copper
		MOVE.W	#$8080,DMACON(a5)	; Enable Copper DMA

.WaitLoop:	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing

		RTS


;-----------------------------------------------------------

CreateList:	LEA.L	Coplist,a0		; APTR Space for coplist

		MOVEQ	#50,d0			; D0 - Line number, start at 50
		MOVEQ	#41,d1			; D1 - Hor pos + copper MOVE bit

		MOVEQ	#48-1,d6		; Create 48 lines
.NextLine	MOVE.B	d0,(a0)+		; WAIT line number part
		EOR.B	#2,d1			; Toggle hor pos between 40 and 42
		MOVE.B	d1,(a0)+		; WAIT horzontal position part
		MOVE.W	#$fffe,(a0)+		; WAIT bitmask part
		ADDQ	#1,d0			; Next colour on next line 

		MOVEQ	#51-1,d7		; Place 51 MOVE instructions
.NextColour	MOVE.W	#COLOR0,(a0)+		; MOVE to COLOR0
		MOVE.W	#$0000,(a0)+		; Set to black for now
		DBF	d7,.NextColour 
		DBF	d6,.NextLine 

		MOVE.W	#INTREQ,(a0)+		; MOVE to INTREQ
		MOVE.W	#$8010,(a0)+		; Trigger Copper interrupt	

 		MOVE.W	#$ffff,(a0)+		; WAIT end of coplist 1st word
		MOVE.W	#$fffe,(a0)+		; WAIT end of coplist 2nd word
		RTS

;-----------------------------------------------------------

IRQHandler:	MOVE.W	#$0010,$DFF000+INTREQ	; Acknowledge the interrupt

		BTST	#7,CIAAPRA		; Check for joystick fire button
		BEQ.B	.NoMove			; Pressed? Do not move

		MOVEM.L	d0-d2/a0-a1/a5,-(a7)

		LEA.L	$dff000,a5
		BSR.B	MoveColours
		BSR.B	AddColours

		MOVEM.L	(a7)+,d0-d2/a0-a1/a5
.NoMove		RTE
		

;-----------------------------------------------------------

MoveColours:	LEA.L	Coplist,a0		; APTR generated coplist
		LEA.L	4(a0),a1		;

		ADDQ.L	#4,a0			; Skip WAIT at start of line
		ADDQ.L	#4,a1			; Start at 2nd MOVE

		MOVEQ	#48-1,d1		; Move 48 lines of colour
.NextLine	MOVEQ	#50-1,d0		; Process 50 MOVE instructions
.NextColour	ADDQ.L	#2,a0			; Skip COLOR0
		ADDQ.L	#2,a1			; Skip COLOR0
		MOVE.W	(a1)+,(a0)+		; Copy colour value
		DBF	d0,.NextColour
		ADDQ.L	#8,a0			; Skip last MOVE and WAIT at start of line
		ADDQ.L	#8,a1			; 
		DBF	d1,.NextLine 
		RTS


;-----------------------------------------------------------

AddColours:	MOVE.W	TopColour(PC),d0	; Get the colour mask last at the top
		CMP.W	#$0001,d0		; Is it the blue mask?
		BEQ.B	.BlueOnTop		; Draw so that blue is on top
		CMP.W	#$0010,d0		; Is it the green mask?
		BEQ.B	.GreenOnTop		; Draw so that green is on top
		CMP.W	#$0100,d0		; Is it the red mask?
		BEQ.B	.RedOnTop		; Draw so that red is on top

		BSR.B	.AddGreenBar		; Must be purple on top
		BSR.B	.AddRedBar
		BSR.B	.AddBlueBar
		BRA.B	.AddPurpleBar
		
.BlueOnTop	BSR.B	.AddGreenBar
		BSR.B	.AddPurpleBar
		BSR.B	.AddRedBar
		BRA.B	.AddBlueBar

.GreenOnTop	BSR.B	.AddBlueBar
		BSR.B	.AddRedBar
		BSR.B	.AddPurpleBar
		BRA.B	.AddGreenBar

.RedOnTop	BSR.B	.AddBlueBar
		BSR.B	.AddPurpleBar
		BSR.B	.AddGreenBar
		BRA.B	.AddRedBar


.AddBlueBar	LEA.L	SinePos(PC),a0		; APTR position for sine table
		MOVEQ	#$0001,d0		; Set colour mask for bar
		BRA.B	DrawBar			; Draw bar in coplist

.AddRedBar	LEA.L	SinePos+1(PC),a0
		MOVE.W	#$0100,d0
		BRA.W	DrawBar

.AddGreenBar	LEA.L	SinePos+2(PC),a0
		MOVE.W	#$0010,d0
		BRA.W	DrawBar

.AddPurpleBar	LEA.L	SinePos+3(PC),a0
		MOVE.W	#$0101,d0
		BRA.W	DrawBar


;-----------------------------------------------------------
; INPUT:	A0   - APTR position byte for sine table
;		D0.W - Colour mask
; 
; TRASHED:	D0-D2, A0-A1

DrawBar:	MOVEQ	#0,d1			; Clear upper bits
		ADDQ.B	#2,(a0)			; Increaste position
		MOVE.B	(a0),d1			; Get position 
		LEA.L	Sine(PC),a1		; APTR sine table
		MOVE.B	(a1,d1.W),d1		; D0 - X position 
		EXT.W	d1			; Sine value from -127 to 128
		ASR.W	#3,d1			; Sine value from -15 to 15
		ADD.W	#16,d1			; Sine value from 1 to 31
		BNE.B	.NotTop			; If zero then this bar is on top
		MOVE.W	d0,TopColour		; On top! Remember this

.NotTop		LEA.L	Coplist+202,a0		; APTR MOVE value to change
		MULU	#208,d1			; Calculate offset to line
		ADD.L	d1,a0			; APTR MOVE on correct line

		MOVE.W	d0,d1			; Start with the mas as-is
		ADD.W	d0,d0			; Make further steps double

		MOVEQ	#7-1,d2			; Draw 7 lines
.FadeIn		MOVE.W	d1,(a0)			; Write colour mask to coplist
		ADD.W	d0,d1			; Increase colour level
		ADDA.W	#208,a0			; Skip 104 words (to next line)
		DBF	d2,.FadeIn		; Do all lines

		MOVEQ	#7-1,d2			; Draw 7 more lines
.FadeOut	MOVE.W	d1,(a0)			; Write colour mask to coplist
		SUB.W	d0,d1			; Decrease colour level
		ADDA.W	#208,a0			; Skip 104 words (to next line)
		DBF	d2,.FadeOut		; Do all lines
		RTS


TopColour:	DC.W	0
SinePos:	DC.B	0,64,128,192


;-----------------------------------------------------------

Sine:		INCLUDE	"BareMetal:Include/Sine256B.i"


;-----------------------------------------------------------
		
		SECTION	Data,BSS_C

; Size required:	One line:	1 x WAIT + 51 x MOVE = 104 words
;			All lines:	48 x 104 = 4992 words
;			Interupt:	2 words = 4994 words
;			Coplist end:	2 words = 4996 words
; total: 1124 words

Coplist:	DS.W	4996


