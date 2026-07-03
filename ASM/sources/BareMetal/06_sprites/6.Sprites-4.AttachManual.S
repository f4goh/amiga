;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000

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

		LEA.L	CopBPL(PC),a0		; APTR bitplane pointers in coplist
		LEA.L	Bitplane1,a1		; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist

		MOVEQ	#-1,d1
		MOVE.W	#2560-1,d0
.Fill		MOVE.L	d1,(a1)+
		DBF	d0,.Fill

; Setup the sprite pointers in the coplist

		LEA.L	CopSprite(PC),a0	; APTR Sprite pointers in coplist
		LEA.L	SpriteList(PC),a1	; APTR List of sprite pointers
		MOVEQ	#8-1,d7			; Process 8 sprite pointers
.NextSprite	MOVE.L	(a1)+,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		ADDQ.L	#8,a0			; Move to next pointer in coplist
		DBF	d7,.NextSprite

; Setup the colours

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0555,COLOR1(a5)	; Playfield: dark grey

		MOVE.W	#$0008,COLOR17(a5)	; Sprite 1: 0 0  Sprite 0: 0 1
		MOVE.W	#$000A,COLOR18(a5)	; Sprite 1: 0 0  Sprite 0: 1 0
		MOVE.W	#$000F,COLOR19(a5)	; Sprite 1: 0 0  Sprite 0: 1 1 
		MOVE.W	#$0080,COLOR20(a5)	; Sprite 1: 0 1  Sprite 0: 0 0 
		MOVE.W	#$00A0,COLOR21(a5)	; Sprite 1: 0 1  Sprite 0: 0 1 
		MOVE.W	#$00F0,COLOR22(a5)	; Sprite 1: 0 1  Sprite 0: 1 0 
		MOVE.W	#$0800,COLOR23(a5)	; Sprite 1: 0 1  Sprite 0: 1 1 
		MOVE.W	#$0A00,COLOR24(a5)	; Sprite 1: 1 0  Sprite 0: 0 0 
		MOVE.W	#$0F00,COLOR25(a5)	; Sprite 1: 1 0  Sprite 0: 0 1 
		MOVE.W	#$0880,COLOR26(a5)	; Sprite 1: 1 0  Sprite 0: 1 0 
		MOVE.W	#$0AA0,COLOR27(a5)	; Sprite 1: 1 0  Sprite 0: 1 1 
		MOVE.W	#$0FF0,COLOR28(a5)	; Sprite 1: 1 1  Sprite 0: 0 0 
		MOVE.W	#$0808,COLOR29(a5)	; Sprite 1: 1 1  Sprite 0: 0 1 
		MOVE.W	#$0A0A,COLOR30(a5)	; Sprite 1: 1 1  Sprite 0: 1 0 
		MOVE.W	#$0F0F,COLOR31(a5)	; Sprite 1: 1 1  Sprite 0: 1 1 

; Prepare the playfield

		MOVE.W	#0,BPL1MOD(a5)		; Odd bitplane same size as playfield
		MOVE.W	#0,BPL2MOD(a5)		; Even bitplane same size as playfield

		MOVE.W	#$1200,BPLCON0(a5)	; 1 bitplane, enable colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#$0024,BPLCON2(a5)	; Odd and even bitplanes lowest priority

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$38,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

; Setup interrupt and start everything

		MOVE.L	S_VBR(PC),a0
		MOVE.L	#IRQHandler,IRQ3(a0)	; Set the new vector
		MOVE.W	#$8020,INTENA(a5)	; Enable interrupt for the vertical blank
		MOVE.W	#$81A0,DMACON(a5)	; Enable bitplane, sprite and Copper DMA

; Wait for the user to click the mouse	

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------
; Position sprite with low resolution steps
;
; INPUT:	A0 - APTR Sprite struct
; 		D0 - X pos (hor)  $80 to $1C0 with default display window
; 		D1 - Y pos (vert) $2C to $12C with default display window
; 		D2 - Height

SetSprite:	AND.B	#$80,3(a0)	; Clear all except ATTACH bit
		MOVE.B	d1,(a0)		; SV7 - SV0
		BTST	#8,d1
		BEQ.B	.NoSV8
		OR.B	#$04,3(a0)	; Set SV8
.NoSV8		ADD.W	d2,d1		; Add height to get end position
		MOVE.B	d1,2(a0)	; EV7 - EV0
		BTST	#8,d1
		BEQ.B	.NoEV8
		OR.B	#$02,3(a0)	; Set EV8
.NoEV8		BTST	#0,d0		; Check SH0
		BEQ.B	.NoSH0
		OR.B	#$01,3(a0)	; Set SH0
.NoSH0		ASR.W	#1,d0		; Shift out SH0
		MOVE.B	d0,1(a0)	; Set SH8 - SH1
		RTS


;-----------------------------------------------------------
; Handler for the vertical-blank interrupt

IRQHandler:	MOVE.W	#$0020,$DFF000+INTREQ	; Clear the interrupt flag

		BTST	#7,CIAAPRA		; Check for joystick fire button
		BEQ.B	.NoMove			; Pressed? Do not move

		MOVEM.L	d0-d5/a0-a1,-(a7)

; Prepare the sprite struct position

		MOVEQ	#0,d0
		MOVE.B	SinePos(PC),d0
		ADDQ.B	#1,d0
		MOVE.B	d0,SinePos		; Sprite sine position
		LEA.L	Sine(PC),a1
		MOVE.B	(a1,d0.W),d0		; D0 - X position 
		EXT.W	d0
		ADD.W	#288,d0			; Place center of movement

		LEA.L	Sprite(PC),a0		; APTR struct of sprite 1
		MOVEQ	#$70,d1			; Sprite Y position
		MOVEQ	#16,d2			; Sprite height
		BSR.B	SetSprite

		MOVEM.L	(a7)+,d0-d5/a0-a1
.NoMove		RTE


;-----------------------------------------------------------

SinePos:	DC.W	0


;-----------------------------------------------------------
; Small coplist for refreshing the sprite pointers

Coplist:	DC.W	$1807,$fffe	; Wait for start of line $18

CopBPL:		DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1

CopSprite:	DC.W	SPR0PTH,0	; High word APTR sprite 0
		DC.W	SPR0PTL,0	; Low word APTR sprite 0
		DC.W	SPR1PTH,0	; High word APTR sprite 1
		DC.W	SPR1PTL,0	; Low word APTR sprite 1
		DC.W	SPR2PTH,0	; High word APTR sprite 2
		DC.W	SPR2PTL,0	; Low word APTR sprite 2
		DC.W	SPR3PTH,0	; High word APTR sprite 3
		DC.W	SPR3PTL,0	; Low word APTR sprite 3
		DC.W	SPR4PTH,0	; High word APTR sprite 4
		DC.W	SPR4PTL,0	; Low word APTR sprite 4
		DC.W	SPR5PTH,0	; High word APTR sprite 5
		DC.W	SPR5PTL,0	; Low word APTR sprite 5
		DC.W	SPR6PTH,0	; High word APTR sprite 6
		DC.W	SPR6PTL,0	; Low word APTR sprite 6
		DC.W	SPR7PTH,0	; High word APTR sprite 7
		DC.W	SPR7PTL,0	; Low word APTR sprite 7

		DC.W	$6007,$fffe	; WAIT line $60
		DC.W	SPR0POS,$0058	; Set sprite horizontal position
		DC.W	SPR0DATB,$03C0
		DC.W	SPR0DATA,$03C0
		DC.W	$6107,$fffe	; WAIT line $61
		DC.W	SPR0DATB,$0FF0
		DC.W	SPR0DATA,$03C0
		DC.W	$6207,$fffe	; WAIT line $61
		DC.W	SPR0DATB,$3FFC
		DC.W	SPR0DATA,$0FF0
		DC.W	$6307,$fffe	; WAIT line $61
		DC.W	SPR0DATB,$FFFF
		DC.W	SPR0DATA,$0FF0

		DC.W	$8D07,$fffe	; WAIT line $61
		DC.W	SPR0DATB,$3FFC
		DC.W	SPR0DATA,$0FF0
		DC.W	$8E07,$fffe	; WAIT line $61
		DC.W	SPR0DATB,$0FF0
		DC.W	SPR0DATA,$03C0
		DC.W	$8F07,$fffe	; WAIT line $60
		DC.W	SPR0DATB,$03C0
		DC.W	SPR0DATA,$03C0

		DC.W	$9007,$fffe	; WAIT line $90
		DC.W	SPR0CTL,$0000	; End drawing of the sprite

		DC.W	$ffff,$fffe	; Wait indefinitely


;-----------------------------------------------------------
; Sprite related tables

SpriteList:	DC.L	NoSprite,Sprite,NoSprite,NoSprite,NoSprite,NoSprite,NoSprite,NoSprite


;-----------------------------------------------------------
; Sprite structure

Sprite:		DC.W	$0,$80
		DC.W	%1111111111111111,%0000000000000000
		DC.W	%1100000000000011,%0111111111111110
		DC.W	%1010000000000101,%0111111111111110
		DC.W	%1001000000001001,%0111111111111110
		DC.W	%1000100000010001,%0111111111111110
		DC.W	%1000010000100001,%0111111111111110
		DC.W	%1000001001000001,%0111111111111110
		DC.W	%1000000110000001,%0111111111111110
		DC.W	%1000000110000001,%0111111111111110
		DC.W	%1000001001000001,%0111111111111110
		DC.W	%1000010000100001,%0111111111111110
		DC.W	%1000100000010001,%0111111111111110
		DC.W	%1001000000001001,%0111111111111110
		DC.W	%1010000000000101,%0111111111111110
		DC.W	%1100000000000011,%0111111111111110
		DC.W	%1111111111111111,%0000000000000000
NoSprite:	DC.W	0,0


;-----------------------------------------------------------

Sine:		INCLUDE	"BareMetal:Include/Sine256B.i"


;-----------------------------------------------------------

		SECTION	BitPlane,BSS_C

Bitplane1:	DS.B	(320*256/8)

;-----------------------------------------------------------
