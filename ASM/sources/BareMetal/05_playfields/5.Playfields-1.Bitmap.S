
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

; Setup the bitplane pointers in the coplist

		LEA.L	Bitplane1,a1		; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		LEA.L	Bitplane2,a1		; APTR Start of bitplane 2
		MOVE.L	a1,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

; Vertical lines on bitplane 1

		LEA.L	Bitplane1,a0		; APTR start of bitplane 2
		MOVE.W	#256-1,d0		; Do all 256 PAL lines
		MOVEQ	#1,d1			; D1 - Only right most bit set
		MOVE.W	d1,d2
		ROR.W	#1,d2			; D2 - Only left most bit set
.FillLoop1	MOVE.W	d2,(a0)			; Start of line: set left most bit
		MOVE.W	d1,38(a0)		; End of lile: set right most bit
		LEA.L	40(a0),a0		; Skip to next line
		DBF	d0,.FillLoop1

; Horizontal lines on bitplane 1

		LEA.L	Bitplane1,a0		; APTR start of 1st line bitplane 1
		LEA.L	255*40(a0),a1		; APTR start of last line
		MOVEQ	#-1,d1			; All 32 bits set
		MOVE.W	#10-1,d0		; Do 10 LONGs (40 bytes, 320 pizxels)
.FillLoop2	MOVE.L	d1,(a0)+		; Do 1st line
		MOVE.L	d1,(a1)+		; Do last line
		DBF	d0,.FillLoop2

; Fill first 100 lines of bitplane 2

		LEA.L	Bitplane2,a0		; APTR start of bitplane 2
		MOVE.W	#100*10-1,d0		; Do 100 lines of 10 LONGs each
.FillLoop3	MOVE.L	d1,(a0)+		; D1 still has all bits set.
		DBF	d0,.FillLoop3

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0008,COLOR1(a5)	; Color 1: Blue
		MOVE.W	#$0800,COLOR2(a5)	; Color 2: Red
		MOVE.W	#$0080,COLOR3(a5)	; Color 3: Green

		MOVE.W	#0,BPL1MOD(a5)		; Odd bitplane same size as playfield
		MOVE.W	#0,BPL2MOD(a5)		; Even bitplane same size as playfield

		MOVE.W	#$2200,BPLCON0(a5)	; 2 bitplanes, enable colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#0,BPLCON2(a5)		; Functionality not required

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$38,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	#$8180,DMACON(a5)	; Enable Bitplane and Copper DMA

; Wait for the user to click the mouse	

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

;-----------------------------------------------------------
; Small coplist for refreshing the bitplane pointers

Coplist:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2
	
		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------

		SECTION	BitPlane,BSS_C

Bitplane1:	DS.B	(320*256/8)
Bitplane2:	DS.B	(320*256/8)

;-----------------------------------------------------------
