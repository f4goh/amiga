
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

		LEA.L	Bitplane,a1		; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0FFF,COLOR1(a5)	; Color 1: white

		MOVE.W	#0,BPL1MOD(a5)		; Odd bitplane same size as playfield
		MOVE.W	#0,BPL2MOD(a5)		; Even bitplane same size as playfield

		MOVE.W	#$1200,BPLCON0(a5)	; 1 bitplane, enable colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#0,BPLCON2(a5)		; Functionality not required

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$38,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	#$81C0,DMACON(a5)	; Enable bitplane, Copper and Blitter DMA

; Draw lines while waiting for the user to click the mouse	

.WaitLoop	MOVE.L	VPOSR(a5),d0		; Get VPOSR and VHPOSR 
		LSR.L	#8,d0			; Shift vertical pos to lowest 9 bits
		AND.W	#$01FF,d0		; Remove unwanted bits
		CMP.W	#$0001,d0		; On line 1?
		BNE.B	.Skip			; No? Do nothing

		BSR.B	DrawLines

.Wait		MOVE.L	VPOSR(a5),d0		; Get vertical an horizontal position
		LSR.L	#8,d0			; Shift vertical pos to lowest 9 bits
		AND.W	#$01FF,d0		; Remove unwanted bits
		CMP.W	#$0001,d0		; On line 1?
		BEQ.B	.Wait			; Wait until no longer on line 1

.Skip		BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing

		RTS


;-----------------------------------------------------------

DrawLines:	LEA.L	SinePos(PC),a0		; APTR sine table positions
		LEA.L	Sine(PC),a1		; APTR sine table
		MOVEQ	#4-1,d7			; Doing 4 coordinates

.NextSinePos	MOVEQ	#0,d0			; Ensure top bits are clear
		MOVE.B	(a0),d0			; Get previous position
		ADDQ.B	#1,d0			; Move to next position
		MOVE.B	d0,(a0)+		; Store new position
		MOVE.B	(a1,d0.W),d0		; Get sine value at position
		EXT.W	d0			; Value between -127 and 127
		ADD.W	#128,d0			; Value between 1 and 255
		MOVE.W	d0,-(a7)		; Store on the stack
		DBF	d7,.NextSinePos		; Do them all

		MOVE.W	(a7)+,d3		; Y position 2
		MOVE.W	(a7)+,d2		; X position 2
		MOVE.W	(a7)+,d1		; Y position 1
		MOVE.W	(a7)+,d0		; X position 1
		BSR.B	DrawLine		; Draw the line
		RTS

;-----------------------------------------------------------

SinePos:	DC.B	64,0,128,64


;-----------------------------------------------------------
; INPUT:	D0.W - X position 1
; 		D1.W - Y position 1 
; 		D2.W - X position 2
; 		D3.W - Y position 2 
;
; TRASH:	A0, D0-D4

DrawLine:	SUB.W	d0,d2			; D2 = Dx = X1 - X2
		BMI.B	.Oct2345		; Nagative? Octant could be 2,3,4,5
		SUB.W	d1,d3			; D3 = Dy = Y1 - Y2 
		BMI.B	.Oct01			; Negative? Octant is 0 or 1
		CMP.W	d3,d2			; Compare Dy with Dx
		BMI.B	.Oct6			; Dy > Dx? Octant 6!
		MOVEQ	#$0011,d4		; Select LINE + octant 7!
		BRA.B	.DoneOctant

.Oct6		EXG	d2,d3			; Ensure D2=Dmax and D3=Dmin
		MOVEQ	#$0001,d4		; Select LINE + octant 6
		BRA.B	.DoneOctant

.Oct2345	NEG.W	d2			; Make Dx positive 
		SUB.W	d1,d3			; D3 = Dy = Y1 - Y2
		BMI.B	.Oct23			; Negative? Octant is 2 or 3
		CMP.W	d3,d2			; Compare Dy with Dx
		BMI.B	.Oct5			; Dy > Dx? Octant 5!
		MOVEQ	#$0015,d4		; Select LINE + octant 4
		BRA.B	.DoneOctant

.Oct5		EXG	d2,d3			; Ensure D2=Dmax and D3=Dmin
		MOVEQ	#$0009,d4		; Select LINE + octant 5
		BRA.B	.DoneOctant

.Oct23		NEG.W	d3			; Make Dy positive
		CMP.W	d3,d2			; Compare Dy with Dx
		BMI.B	.Oct2			; Dy > Dx? Octant 2!
		MOVEQ	#$001D,d4		; Select LINE + octant 3
		BRA.B	.DoneOctant

.Oct2		EXG	d2,d3			; Ensure D2=Dmax and D3=Dmin
		MOVEQ	#$000D,d4		; Select LINE + octant 2
		BRA.B	.DoneOctant

.Oct01		NEG.W	d3			; Make Dy positive
		CMP.W	d3,d2			; Compare Dy with Dx
		BMI.B	.Oct1			; Dy > Dx? Octant 1!
		MOVEQ	#$0019,d4		; Select LINE + octant 0
		BRA.B	.DoneOctant

.Oct1		EXG	d2,d3			; Ensure D2=Dmax and D3=Dmin
		MOVEQ	#$0005,d4		; Select LINE + octant 1

.DoneOctant	ADD.W	d2,d2			; D2 = 2 * Dmax	
		ASL.W	#2,d3			; D3 = 4 * Dmin

		LEA.L	Bitplane,a0		; APTR bitplane to draw on
		MULU	#40,d1			; Convert Y1 pos into offset
		ADD.L	d1,a0			; Add ofset to bitplane pointer
		EXT.L	d0			; Clear top bits of D0
		ROR.L	#4,d0			; Roll shift bits to top word 
		ADD.W	d0,d0			; Bottom word: convert to byte offset 
		ADDA.W	d0,a0			; Add byte offset to bitplane pointer
		SWAP	d0			; Move shift value to bottom word
		OR.W	#$0B5A,d0		; USEA, C and D. Minterm $5A, D=A/C+/AC

		MOVE.W	d2,d1			; D1 = 2 * Dmax
		LSL.W	#5,d1			; Shift Dmax to Hx pos for BLTSIZE
		ADD.W	#$0042,d1		; Add 1 to Hx and set Wx to 2

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy		; No. Wait a bit

		MOVE.W	#$FFFF,BLTAFWM(a5)	; No first word masking
		MOVE.W	#$FFFF,BLTALWM(a5)	; No last word masking
		MOVE.W	#40,BLTCMOD(a5)		; Bitplane is 40 bytes wide
		MOVE.W	#40,BLTDMOD(a5)		; Bitplane is 40 bytes wide
		MOVE.L	a0,BLTCPT(a5)		; Source C = bitplane to draw on
		MOVE.L	a0,BLTDPT(a5)		; Destination = bitplane to draw on
		MOVE.W	d0,BLTCON0(a5)		; Source A shift and logic function
		MOVE.W	d3,BLTBMOD(a5)		; Set 4 * Dmin
		MOVE.W	#$8000,BLTADAT(a5)	; A data = 0x8000 (write to BLTCON0 first!)

		SUB.W	d2,d3			; D3 = (2 * Dmax)-(4 * Dmin)
		EXT.L	d3			; Make full long sized
		MOVE.L	d3,BLTAPT(a5)		; Store in A pointer
		BPL.B	.NotNeg			; Skip if positive
		OR.W	#$0040,d4		; Set SIGN bit if negative
.NotNeg		MOVE.W	d4,BLTCON1(a5)		; Octant selection, SIGN and LINE
		SUB.W	d2,d3			; D2 = (2*Dmax), D3 = (2*Dmax)-(4*Dmin)
		MOVE.W	d3,BLTAMOD(a5)		; D3 = 4 * (DMax - Dmin)
		MOVE.W	d1,BLTSIZE(a5)		; Set length and start the Blitter
		RTS


;-----------------------------------------------------------
; Small coplist for refreshing the bitplane pointer

Coplist:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		
		DC.W	$ffff,$fffe	; Wait indefinitely


;-----------------------------------------------------------
; Only data required is the sine table

Sine:		INCLUDE	"BareMetal:Include/Sine256B.i"


;-----------------------------------------------------------
; BSS section for the bitplane(s)

		SECTION	BitPlane,BSS_C

Bitplane:	DS.B	(320*256/8)

;-----------------------------------------------------------
