
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

Main:		BSR.B	CreateList

		LEA.L	Coplist,a0		; A0 = APTR coplist
		MOVE.L	a0,COP1LC(a5)		; Set start address for Copper

		MOVE.W	#$0001,BPLCON0(a5)	; Set ENBPLCN3 to enable BPLCON3 
		MOVE.W	#$8080,DMACON(a5)	; Enable Copper DMA

.WaitLoop:	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------

CreateList:	LEA.L	Coplist,a0
		
		MOVEQ	#0,d0			; D0 - Line number counter
		MOVE.B	d0,(a0)+		; WAIT line number part
		MOVE.B	#07,(a0)+		; WAIT horzontal position part
		MOVE.W	#$fffe,(a0)+		; WAIT bitmask part
		ADDQ	#1,d0			; Next colour on next line 

		MOVEQ	#$f,d1			; D1 - High nibble colour
.HighLoop	MOVE.W	#BPLCON3,(a0)+		; MOVE register part
		MOVE.W	#$0000,(a0)+		; MOVE data part (clear LOCT)
		MOVE.W	#COLOR0,(a0)+		; MOVE register part
		MOVE.W	d1,(a0)+		; MOVE data part (colour high nibble)
		MOVE.W	#BPLCON3,(a0)+		; MOVE register part
		MOVE.W	#$0200,(a0)+		; MOVE data part (set LOCT)

		MOVEQ	#$f,d2			; D2 - Low nibble colour
.LowLoop	MOVE.W	#COLOR0,(a0)+		; MOVE register part
		MOVE.W	d2,(a0)+		; MOVE data part (colour low nibble)
		MOVE.B	d0,(a0)+		; WAIT line number part
		MOVE.B	#07,(a0)+		; WAIT horzontal position part
		MOVE.W	#$fffe,(a0)+		; WAIT bitmask part
		ADDQ	#1,d0			; Next colour on next line 
		SUBQ	#1,d2			; Decrease low nibble.
		BGE.B	.LowLoop		; Loop while zero or positive
		
		SUBQ	#1,d1			; Decrease high nibble.
		BGE.B	.HighLoop		; Loop while zero or positive
		
		MOVE.W	#$ffff,(a0)+		; WAIT end of coplist 1st word
		MOVE.W	#$fffe,(a0)+		; WAIT end of coplist 2nd word
		RTS
		
;-----------------------------------------------------------
		
		SECTION	Data,BSS_C

; Size required:	Low nibbles:	4 words x 256 = 1024 words
;			High nibbles:	6 words x 16 = 96 words
;			Coplist start:	2 words
;			Coplsit end:	2 words
; total: 1124 words

Coplist:	DS.W	1124

;-----------------------------------------------------------

