
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

Main:		LEA.L	CopBPL(PC),a0		; APTR to bitplane ptrs in coplist
		LEA.L	Bitplanes(PC),a1	; APTR Start of bitplane 1
		MOVE.L	a1,d0
		ADD.L	ScrollOffset(PC),d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		SWAP	d0
		ADD.L	#40*1024,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

		LEA.L	Coplist(PC),a0		; APTR Top of coplist
		MOVE.L	a0,COP1LC(a5)		; Set start address for coplist
		MOVE.L	S_VBR(PC),a0
		MOVE.L	#IRQHandler,IRQ3(a0)	; Set the new vector

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0008,COLOR1(a5)	; Color 1: Blue
		MOVE.W	#$0800,COLOR2(a5)	; Color 2: Red
		MOVE.W	#$0080,COLOR3(a5)	; Color 3: Green

		MOVE.W	#120-2,BPL1MOD(a5)	; Odd bitplane 120 bytes larger than playfield
		MOVE.W	#120-2,BPL2MOD(a5)	; Even bitplane 120 bytes larger than playfield

		MOVE.W	#$2200,BPLCON0(a5)	; 2 bitplanes, enable colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#0,BPLCON2(a5)		; Functionality not required

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$30,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	#$8020,INTENA(a5)	; Enable interrupt for the vertical blank
		MOVE.W	#$8180,DMACON(a5)	; Enable Bitplane and Copper DMA

; Wait for the user to click the mouse

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

;-----------------------------------------------------------

IRQHandler:	MOVE.W	#$0020,$DFF000+INTREQ	; Clear the interrupt flag

		MOVEM.L	d0-d2/a0-a1,-(a7)

		MOVE.W	$DFF000+JOY1DAT,d2	; Joystick port 2 state
		AND.W	#$0202,d2		; Keep only bits for left + right
		BEQ.B	.NoScroll		; None set? No scrolling

		MOVE.W	ScrollDelay(PC),d0	; Delay for scrolling
		MOVE.L	ScrollOffset(PC),d1	; Offset for the bitplane

		BTST	#1,d2			; Moving right?
		BNE.B	.ScrollRight

		SUBQ.W	#1,d0			; Move delay by one pixel
		BGE.B	.CalcDone
		ADDQ.L	#2,d1
		CMP.W	#120,d1
		BNE.B	.CalcDone
		MOVEQ.L	#0,d1
		BRA.B	.CalcDone

.ScrollRight	ADDQ.W	#1,d0			; Move delay by one pixel
		AND.W	#$0F,d0
		BNE.B	.CalcDone
		SUBQ.L	#2,d1
		BGE.B	.CalcDone
		MOVEQ.L	#118,d1

.CalcDone	AND.W	#$000F,d0		; Keep only bottom nibble
		MOVE.W	d0,ScrollDelay		; Store the delay value
		MOVE.W	d0,d2			; Copy the delay value
		ASL.W	#4,d2			; Move to next nibble
		OR.W	d2,d0			; Place both in same word
		MOVE.W	d0,$DFF000+BPLCON1	; Set delay for add and even bitplanes

		MOVE.L	d1,ScrollOffset		; Store new offset

		LEA.L	Bitplanes(PC),a1	; APTR Start of bitplane
		MOVE.L	a1,d0
		LEA.L	CopBPL(PC),a0		; APTR to bitplane ptrs in coplist
		ADD.L	d1,d0			; Add offset to APTR
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		SWAP	d0
		ADD.L	#40*1024,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

.NoScroll	MOVEM.L	(a7)+,d0-d2/a0-a1
		RTE

;-----------------------------------------------------------

ScrollDelay:	DC.W	0	; Storage for the delay value
ScrollOffset:	DC.L	38	; Storage for the scroll position in pixels

;-----------------------------------------------------------

Coplist:	DC.W	$2207,$fffe	; Wait for start of line $22 

CopBPL:		DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2

		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------

Bitplanes:	INCBIN	"BareMetal:Assets/HorizontalScroll.RAW"

;-----------------------------------------------------------
