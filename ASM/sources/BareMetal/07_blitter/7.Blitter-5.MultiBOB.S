
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

		LEA.L	Playfield(PC),a1	; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		ADDA.W	#40,a1			; Bitplane 2 starts one line later
		MOVE.L	a1,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0800,COLOR1(a5)	; Color 1: red
		MOVE.W	#$0008,COLOR2(a5)	; Color 2: blue
		MOVE.W	#$0050,COLOR3(a5)	; Color 3: green

		MOVE.W	#40,BPL1MOD(a5)		; All bitplanes need to skip one line
		MOVE.W	#40,BPL2MOD(a5)		; at the end of each line

		MOVE.W	#$2200,BPLCON0(a5)	; 2 bitplanes, enable colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#0,BPLCON2(a5)		; Functionality not required

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$38,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	#$81C0,DMACON(a5)	; Enable bitplane, Copper and Blitter DMA

; Prepare Blitter registers that won't change

		MOVE.W	#$FFFF,BLTAFWM(a5)	; No first word masking
		MOVE.W	#$FFFF,BLTALWM(a5)	; No last word masking

; Wait for the user to click the mouse	

.WaitLoop	MOVE.L	VPOSR(a5),d0		; Get VPOSR and VHPOSR 
		LSR.L	#8,d0			; Shift vertical pos to lowest 9 bits
		AND.W	#$01FF,d0		; Remove unwanted bits
		CMP.W	#$0100,d0		; On line $100?
		BNE.B	.Skip			; No? Do nothing

		BSR.B	MoveBOB

.Wait		MOVE.L	VPOSR(a5),d0		; Get vertical an horizontal position
		LSR.L	#8,d0			; Shift vertical pos to lowest 9 bits
		AND.W	#$01FF,d0		; Remove unwanted bits
		CMP.W	#$0100,d0		; On line $100?
		BEQ.B	.Wait			; Wait until no longer on line $100

.Skip		BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------

MoveBOB:	LEA.L	Positions(PC),a4	; Positions array
		MOVEQ	#4-1,d7			; Do 3 BOBs
.ClearNext	MOVE.W	(a4)+,d0		; X position
		MOVE.W	(a4)+,d1		; Y position
		BSR.W	ClearBOB		; Restore BOB 1 background
		DBF	d7,.ClearNext		; Do this for all BOBs

; Calculate new X and Y positions

		LEA.L	Sine(PC),a0		; APTR Sine table
		LEA.L	SinePos(PC),a1		; APTR array with sine positions
		LEA.L	Positions(PC),a4	; APTR array with x/y positions
		MOVEQ	#4-1,d7			; Do 4 BOBs
.CalcPos	MOVEQ	#0,d0			; Clear all bits of D0
		MOVE.B	(a1),d0			; Get position in sine table
		ADDQ.B	#1,d0			; Move on to next position
		MOVE.B	d0,(a1)+		; Store new sine table position
		MOVE.B	(a0,d0.W),d0		; Get new sine value
		EXT.W	d0			; Extend BYTE sine to WORD
		ADD.W	#128,d0			; Make sine move between 0 and 256
		MOVE.W	d0,(a4)+		; Store as new X position
		MOVEQ	#0,d0			; Clear d0 again
		MOVE.B	(a1),d0			; Get position in sine table
		ADDQ.B	#2,d0			; Move on 2 positions
		MOVE.B	d0,(a1)+		; Store new sine table position
		MOVE.B	(a0,d0.W),d0		; Get new sine value
		EXT.W	d0			; Extend BYTE sine to WORD
		ASR	d0			; Make sine move between -64 and 64
		ADD.W	#64,d0			; Make sine move between 0 and 128
		MOVE.W	d0,(a4)+		; Store as new Y position
		DBF	d7,.CalcPos		; Do this for all BOBs

; Place the BOBs

		LEA.L	Positions(PC),a4	; Positions array
		MOVEQ	#4-1,d7			; Do 4 BOBs
.PlaceNext	MOVE.W	(a4)+,d0		; X position
		MOVE.W	(a4)+,d1		; Y position
		LEA.L	Object(PC),a0		; APTR BOB
		LEA.L	ObjectMask(PC),a1	; APTR mask
		BSR.B	PlaceBOB		; Draw BOB 
		DBF	d7,.PlaceNext		; Do this for all BOBs

		RTS


;-----------------------------------------------------------
; INPUT:	A0   - APTR Blitter object
;		A1   - APTR Mask for object
; 		D0.W - X pos (hor) 
; 		D1.W - Y pos (vert) 

PlaceBOB:	LEA.L	Playfield(PC),a2	; APTR interleaved playfield
		MULU	#80,d1			; Convert Y pos into offset
		ADD.L	d1,a2			; Add offset to destination
		EXT.L	d0			; Clear top bits of D0
		ROR.L	#4,d0			; Roll shift bits to top word 
		ADD.W	d0,d0			; Bottom word: convert to byte offset 
		ADDA.W	d0,a2			; Add byte offset to destination
		SWAP	d0			; Move shift value to top word

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy		; No. Wait a bit

		MOVE.L	a1,BLTAPT(a5)		; Source A = Mask
		MOVE.L	a0,BLTBPT(a5)		; Source B = Object
		MOVE.L	a2,BLTCPT(a5)		; Source C = Background
		MOVE.L	a2,BLTDPT(a5)		; Destination = Background
		MOVE.W	d0,BLTCON1(a5)		; Use shift for source B
		OR.W	#$0FCA,d0		; USEA, B, C and D. Minterm $CA, D=AB+/AC
		MOVE.W	d0,BLTCON0(a5)		; 	
		MOVE.W	#0,BLTAMOD(a5)		; Skip 0 bytes of the mask
		MOVE.W	#0,BLTBMOD(a5)		; Skip 0 bytes of the object
		MOVE.W	#30,BLTCMOD(a5)		; Skip 30 bytes of the destination
		MOVE.W	#30,BLTDMOD(a5)		; Skip 30 bytes of the destination
		MOVE.W	#128<<6+5,BLTSIZE(a5)	; 64 lines high, 5 words wide

		RTS


;-----------------------------------------------------------
; INPUT:	A0   - APTR Storage space
; 		D0.W - X pos (hor) 
; 		D1.W - Y pos (vert) 

ClearBOB:	LEA.L	Background(PC),a0	; APTR undamaged background
		LEA.L	Playfield(PC),a1	; APTR interleaved playfield
		MULU	#80,d1			; Convert Y pos into offset
		AND.W	#$FFF0,d0		; Position without shift
		LSR.W	#3,d0			; Convert to byte offset
		ADD.L	d1,d0			; Add both offsets together
		ADDA.W	d0,a0			; Add ofset to background
		ADDA.W	d0,a1			; Add ofset to playfield

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy		; No. Wait a bit

		MOVE.L	a0,BLTAPT(a5)		; Source A = background
		MOVE.L	a1,BLTDPT(a5)		; Destination = playfield
		MOVE.W	#$09F0,BLTCON0(a5)	; USEA, USED. Minterm $F0, D=A
		MOVE.W	#0,BLTCON1(a5)		; Data transfer, no fills
		MOVE.W	#30,BLTDMOD(a5)		; Skip 30 bytes of the playfield
		MOVE.W	#30,BLTAMOD(a5)		; Skip 30 bytes of the storage
		MOVE.W	#128<<6+5,BLTSIZE(a5)	; 128 lines high, 5 words wide

		RTS

;-----------------------------------------------------------

SinePos:	DC.B	64,0,96,32,128,64,160,96
Positions:	DC.W	0,0,0,0,0,0,0,0


;-----------------------------------------------------------
; Small coplist for refreshing the bitplane pointers

Coplist:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2

		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------

Sine:		INCLUDE	"BareMetal:Include/Sine256B.i"

Object:		INCBIN	"BareMetal:Assets/ChickenLips.RAWB"
ObjectMask:	INCBIN	"BareMetal:Assets/ChickenLipsMask.RAWB"
Background:	INCBIN	"BareMetal:Assets/Background.RAWB"
Playfield:	INCBIN	"BareMetal:Assets/Background.RAWB"

;-----------------------------------------------------------
