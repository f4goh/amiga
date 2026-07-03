
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

Main:		LEA.L	CoplistLong(PC),a0	; APTR long frame coplist
		LEA.L	CoplistShort(PC),a1	; APTR short frame coplist
		MOVE.L	a1,COP1LC(a5)		; Start with the short frame

; Setup the pointers in the long coplist

		LEA.L	Bitplane1,a2		; APTR Start of bitplane 1
		MOVE.L	a2,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		LEA.L	Bitplane2,a2		; APTR Start of bitplane 2
		MOVE.L	a2,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist
		MOVE.L	a1,d0
		MOVE.W	d0,22(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,18(a0)		; Place high word into coplist

; Setup the pointers in the short coplist

		LEA.L	Bitplane1+40,a2		; APTR Start of bitplane 1
		MOVE.L	a2,d0
		MOVE.W	d0,6(a1)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a1)		; Place high word into coplist
		LEA.L	Bitplane2+40,a2		; APTR Start of bitplane 2
		MOVE.L	a2,d0
		MOVE.W	d0,14(a1)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a1)		; Place high word into coplist
		MOVE.L	a0,d0
		MOVE.W	d0,22(a1)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,18(a1)		; Place high word into coplist

; Vertical lines on bitplane 1

		LEA.L	Bitplane1,a0		; APTR start of bitplane 1
		LEA.L	40*100(a0),a0		; APTR start of line 100
		LEA.L	Bitplane2,a1		; APTR start of bitplane 2
		LEA.L	40*101(a1),a1		; APTR start of line 101
		MOVE.W	#20-1,d0		; Fill 2 lines
		MOVEQ	#-1,d1			; D1 - All bit set
.FillLoop1	MOVE.L	d1,(a0)+
		MOVE.L	d1,(a1)+
		DBF	d0,.FillLoop1

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0F00,COLOR1(a5)	; Color 1: Red
		MOVE.W	#$000F,COLOR2(a5)	; Color 2: Blue
		MOVE.W	#$0FFF,COLOR3(a5)	; Color 3: White

		MOVE.W	#40,BPL1MOD(a5)		; Odd bitplane: skip next line 
		MOVE.W	#40,BPL2MOD(a5)		; Even bitplane: skip next line

		MOVE.W	#$2204,BPLCON0(a5)	; 2 bitplanes, colour on composite, interlaced
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#0,BPLCON2(a5)		; Functionality not required

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$38,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	#$8000,VPOSW(a5)	; Ensure long frame is active
		MOVE.W	#$8180,DMACON(a5)	; Enable Bitplane and Copper DMA

; Wait for the user to click the mouse	

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

;-----------------------------------------------------------
; Two coplists. One for each half-frame

CoplistLong:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2
		DC.W	COP1LCH,0	; Change coplist address for next vblank
		DC.W	COP1LCL,0	; 
		DC.W	$ffff,$fffe	; Wait indefinitely

CoplistShort:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2
		DC.W	COP1LCH,0	; Change coplist address for next vblank
		DC.W	COP1LCL,0	; 
		DC.W	$ffff,$fffe	; Wait indefinitely


;-----------------------------------------------------------

		SECTION	BitPlane,BSS_C

Bitplane1:	DS.B	(320*512/8)
Bitplane2:	DS.B	(320*512/8)

;-----------------------------------------------------------
