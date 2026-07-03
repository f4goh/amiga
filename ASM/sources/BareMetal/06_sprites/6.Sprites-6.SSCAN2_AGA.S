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

; Prepare the playfield

		MOVE.W	#$8004,FMODE(a5)	; AGA: SSCAN2 and 32 bit transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$38,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	#0,BPL1MOD(a5)		; Odd bitplane same size as playfield
		MOVE.W	#0,BPL2MOD(a5)		; Even bitplane same size as playfield

		MOVE.W	#$1201,BPLCON0(a5)	; 1 bitplane, composite colour, enable BPLCON3
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#$0024,BPLCON2(a5)	; Odd and even bitplanes lowest priority

; Setup the colours (now that BPL3CON has been enabled)

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0555,COLOR1(a5)	; Playfield: dark grey

		MOVE.W	#$000A,COLOR17(a5)	; Sprite 0 colour 1: blue
		MOVE.W	#$0008,COLOR18(a5)	; Sprite 0 colour 2: dark blue
		MOVE.W	#$000F,COLOR19(a5)	; Sprite 0 colour 3: light blue

; Setup interrupt and start everything

		MOVE.L	S_VBR(PC),a0
		MOVE.L	#IRQHandler,IRQ3(a0)	; Set the new vector
		MOVE.W	#$8020,INTENA(a5)	; Enable interrupt for the vertical blank
		MOVE.W	#$81A0,DMACON(a5)	; Enable bitplane, sprite and Copper DMA

; Wait for the user to click the mouse	

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------------
; Move 32 bits wide sprite
;
; INPUT:	A0 - APTR Sprite struct
; 		D0 - X pos (hor)  $200 to $700 with default display window
; 		D1 - Y pos (vert) $2C to $12C with default display window
; 		D2 - Height
;
; OUTPUT:	A0 - APTR Sprite struct
;		D0 - Trashed
;		D1 - Trashed
; 		D2 - Height

SetSprite32:	AND.B	#$80,5(a0)	; Clear all except ATTACH bit
		MOVE.B	d1,(a0)		; SV7 - SV0
		BTST	#8,d1
		BEQ.B	.NoSV8
		OR.B	#$04,5(a0)	; Set SV8
.NoSV8		BTST	#9,d1
		BEQ.B	.NoSV9
		OR.B	#$40,5(a0)	; Set SV9
.NoSV9		ADD.W	d2,d1		; Add height to get end position
		MOVE.B	d1,4(a0)	; EV7 - EV0
		BTST	#8,d1
		BEQ.B	.NoEV8
		OR.B	#$02,5(a0)	; Set EV8
.NoEV8		BTST	#9,d1
		BEQ.B	.NoEV9
		OR.B	#$20,5(a0)	; Set EV9
.NoEV9		BTST	#0,d0		; Check SH0
		BEQ.B	.NoSH0
		OR.B	#$08,5(a0)	; Set SH0
.NoSH0		BTST	#1,d0		; Check SH1
		BEQ.B	.NoSH1
		OR.B	#$10,5(a0)	; Set SH1
.NoSH1		BTST	#2,d0		; Check SH2
		BEQ.B	.NoSH2
		OR.B	#$01,5(a0)	; Set SH2
.NoSH2		ASR.W	#3,d0		; Shift out SH2-SH0
		MOVE.B	d0,1(a0)	; Set SH10 - SH3
		RTS


;-----------------------------------------------------------
; Handler for the vertical-blank interrupt

IRQHandler:	MOVE.W	#$0020,$DFF000+INTREQ	; Clear the interrupt flag

		MOVEM.L	d0-d2/a0,-(a7)

; Prepare the sprite struct position

		ADDQ.B	#1,SpritePos	; Advance sine position 
		MOVEQ	#0,d0		; Ensure upper byte is clear
		MOVE.B	SpritePos(PC),d0; Sprite sine position
		ASL.W	d0		; Sine uses 2 bytes per value
		LEA.L	Sine(PC),a0	; APTR sine table
		MOVE.W	(a0,d0.W),d0	; Get sine value
		ASR.W	#7,d0		; Limit range
		ADD.W	#576,d0		; Sprite X position
		MOVEQ	#80,d1		; Sprite Y position
		MOVEQ	#16,d2		; Sprite normal height

		BTST	#7,CIAAPRA	; Check for joystick fire button
		BNE.B	.NoSH10		; Not pressed?

		MOVEQ	#32,d2		; Sprite height doubles
		BSET	#10,d0		; Set SH10: enable scan doubling
.NoSH10		LEA.L	Sprite0(PC),a0	; APTR sprite struct
		BSR	SetSprite32	; Update sprite struct

		MOVEM.L	(a7)+,d0-d2/a0
		RTE


;-----------------------------------------------------------
; Small coplist for refreshing the sprite pointers

Coplist:	DC.W	$1807,$fffe	; Wait for start of line $22 
		DC.W	BPLCON3,$0080	; AGA: All sprites are high-res

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

		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------
; Sprite related tables

SpritePos:	DC.B	0
		EVEN
SpriteList:	DC.L	Sprite0,NoSprite,NoSprite,NoSprite,NoSprite,NoSprite,NoSprite,NoSprite


;-----------------------------------------------------------
; Sprite structures (32 bits wide)

		CNOP	0,4
Sprite0:	DC.L	$10100000,$20000000
		DC.L	%11111111111111111111111111111111,%00000000000000000000000000000000
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000000001,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000011101,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000100011,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000100011,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000100011,%01111111111111111111111111111110
		DC.L	%10000000000000000000000000011101,%01111111111111111111111111111110
		DC.L	%11111111111111111111111111111111,%00000000000000000000000000000000
NoSprite:	DC.L	0,0

;-----------------------------------------------------------

Sine:		INCLUDE	"BareMetal:Include/Sine256W.i"

;-----------------------------------------------------------

		SECTION	BitPlane,BSS_C

Bitplane1:	DS.B	(320*256/8)

;-----------------------------------------------------------
