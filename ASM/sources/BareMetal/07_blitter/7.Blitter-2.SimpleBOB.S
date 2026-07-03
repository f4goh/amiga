
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

		LEA.L	Bitplanes,a1		; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		ADDA.W	#40*256,a1		; APTR Start of bitplane 2
		MOVE.L	a1,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0800,COLOR1(a5)	; Color 1: red
		MOVE.W	#$0008,COLOR2(a5)	; Color 2: blue
		MOVE.W	#$0080,COLOR3(a5)	; Color 3: green

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

		MOVE.W	#$81C0,DMACON(a5)	; Enable bitplane, Copper and Blitter DMA

; Wait for the user to click the mouse	

.WaitLoop	MOVE.L	VPOSR(a5),d0		; Get VPOSR and VHPOSR 
		LSR.L	#8,d0			; Shift vertical pos to lowest 9 bits
		AND.W	#$01FF,d0		; Remove unwanted bits
		CMP.W	#$0010,d0		; On line $10?
		BNE.B	.Skip			; No? Do nothing

		BSR.B	MoveBOB

.Wait		MOVE.L	VPOSR(a5),d0		; Get vertical an horizontal position
		LSR.L	#8,d0			; Shift vertical pos to lowest 9 bits
		AND.W	#$01FF,d0		; Remove unwanted bits
		CMP.W	#$0010,d0		; On line $10?
		BEQ.B	.Wait			; Wait until no longer on line $10

.Skip		BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------

MoveBOB:	MOVE.W	PrevPos(PC),d0
		MOVE.W	PrevPos+2(PC),d1
		BSR.W	ClearBOB

		LEA.L	Sine(PC),a0
		MOVEQ	#0,d0
		MOVE.B	SinePos(PC),d0
		ADDQ.B	#1,d0
		MOVE.B	d0,SinePos
		MOVE.B	(a0,d0.W),d0
		EXT.W	d0
		ADD.W	#128,d0
		MOVE.W	d0,PrevPos

		MOVEQ	#0,d1
		MOVE.B	SinePos+1(PC),d1
		ADDQ.B	#2,d1
		MOVE.B	d1,SinePos+1
		MOVE.B	(a0,d1.W),d1
		EXT.W	d1
		ASR	d1
		ADD.W	#64,d1
		MOVE.W	d1,PrevPos+2

		LEA.L	Object(PC),a0		; APTR object
		BSR.B	PlaceBOB

		RTS


;-----------------------------------------------------------
; INPUT:	D0 - X pos (hor) 
; 		D1 - Y pos (vert) 

ClearBOB:	LEA.L	Bitplanes,a1		; APTR playfield bitplane 1
		MULU	#40,d1			; Convert Y pos into offset
		ADD.L	d1,a1			; Add offset to destination
		AND.W	#$FFF0,d0		; Position without shift
		LSR.W	#3,d0			; Convert to byte offset
		ADDA.W	d0,a1			; Add ofset to playfield

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy		; No. Wait a bit

		MOVE.L	a1,BLTDPT(a5)		; Destination = playfield bitplane 1
		MOVE.W	#0,BLTADAT(a5)
		MOVE.W	#$FFFF,BLTAFWM(a5)	; No first word masking
		MOVE.W	#$FFFF,BLTALWM(a5)	; No last word masking
		MOVE.W	#$01F0,BLTCON0(a5)	; USED. Minterm $F0, D=A
		MOVE.W	#0,BLTCON1(a5)		; Data transfer, no fills
		MOVE.W	#30,BLTDMOD(a5)		; Skip 30 bytes of the destination
		MOVE.W	#0,BLTAMOD(a5)		; Skip 0 bytes of the source
		MOVE.W	#64<<6+5,BLTSIZE(a5)	; 64 lines high, 5 words wide

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy2	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy2		; No. Wait a bit

		ADDA.W	#40*256,a1		; APTR playfield bitplane 2
		MOVE.L	a1,BLTDPT(a5)		; Destination = playfield bitplane 2
		MOVE.W	#64<<6+5,BLTSIZE(a5)	; 64 lines high, 5 words wide

		RTS


;-----------------------------------------------------------
; INPUT:	A0 - APTR Blitter object
; 		D0 - X pos (hor) 
; 		D1 - Y pos (vert) 

PlaceBOB:	LEA.L	Bitplanes,a1		; APTR playfield bitplane 1
		MULU	#40,d1			; Convert Y pos into offset
		ADD.L	d1,a1			; Add offset to destination
		EXT.L	d0			; Clear top bits of D0
		ROR.L	#4,d0			; Roll shift bits to top word 
		ADD.W	d0,d0			; Bottom word: convert to byte offset 
		ADDA.W	d0,a1			; Add byte offset to destination
		SWAP	d0			; Move shift value to top word

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy		; No. Wait a bit

		MOVE.L	a0,BLTAPT(a5)		; Source A = Object bitplane 1
		MOVE.L	a1,BLTDPT(a5)		; Destination = playfield bitplane 1
		MOVE.W	#$FFFF,BLTAFWM(a5)	; No first word masking
		MOVE.W	#$FFFF,BLTALWM(a5)	; No last word masking
		OR.W	#$09F0,d0		; USEA and USED. Minterm $F0, D=A
		MOVE.W	d0,BLTCON0(a5)		; 	
		MOVE.W	#0,BLTCON1(a5)		; Data transfer, no fills
		MOVE.W	#30,BLTDMOD(a5)		; Skip 30 bytes of the destination
		MOVE.W	#0,BLTAMOD(a5)		; Skip 0 bytes of the source
		MOVE.W	#64<<6+5,BLTSIZE(a5)	; 64 lines high, 5 words wide

		BTST.B	#14-8,DMACONR(a5)	; Dummy read
.BltBusy2	BTST.B	#14-8,DMACONR(a5)	; Blitter ready?
		BNE.B	.BltBusy2		; No. Wait a bit

		ADDA.W	#40*256,a1		; APTR playfield bitplane 2
		MOVE.L	a1,BLTDPT(a5)		; Destination = playfield bitplane 2
		MOVE.W	#64<<6+5,BLTSIZE(a5)	; 64 lines high, 5 words wide

		RTS

;-----------------------------------------------------------

SinePos:	DC.B	64,0
PrevPos:	DC.W	0,0


;-----------------------------------------------------------
; Small coplist for refreshing the bitplane pointers

Coplist:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2

		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------

Sine:		INCLUDE	"BareMetal:Include/Sine256B.i"
Object:		INCBIN	"BareMetal:Assets/ChickenLips.RAW"


;-----------------------------------------------------------

		SECTION	BitPlane,BSS_C

Bitplanes:	DS.B	2*(320*256/8)

;-----------------------------------------------------------
