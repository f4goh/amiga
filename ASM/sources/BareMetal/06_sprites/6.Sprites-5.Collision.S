
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
		LEA.L	Bitplanes,a1		; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		LEA.L	40*256(a1),a1		; Start of bitplane 2
		MOVE.L	a1,d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

; Setup the sprite pointers in the coplist

		LEA.L	CopSprite(PC),a0	; APTR Sprite pointers in coplist
		LEA.L	NoSprite(PC),a1		; APTR "end of data"
		MOVEQ	#8-1,d7			; Process 8 sprite pointers
.NextSprite	MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		ADDQ.L	#8,a0			; Move to next pointer in coplist
		DBF	d7,.NextSprite

; Setup the colours

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$000F,COLOR1(a5)	; Playfield 1: Blue
		MOVE.W	#$0F00,COLOR9(a5)	; Playfield 2: Red

		MOVE.W	#$0FFF,COLOR17(a5)	; Sprite 0+1 colour 1: White
		MOVE.W	#$0F00,COLOR18(a5)	; Sprite 0+1 colour 2: Red
		MOVE.W	#$000F,COLOR19(a5)	; Sprite 0+1 colour 3: Blue

; Prepare the playfield

		MOVE.W	#0,BPL1MOD(a5)		; Odd bitplane same size as playfield
		MOVE.W	#0,BPL2MOD(a5)		; Even bitplane same size as playfield
		MOVE.W	#$2600,BPLCON0(a5)	; 2 bitplanes, dual playfield, colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane
		MOVE.W	#$0000,BPLCON2(a5)	; Both plafields high priority

		MOVE.W	#$00C3,CLXCON(a5)	; Enable collisions for bitplane 1 and 2
		
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
; Move sprite with low resolution steps
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

		MOVEM.L	d0-d3/a0,-(a7)

		MOVE.W	$DFF000+CLXDAT,d0	; Get collision status
		BTST	#1,d0			; Collision with playfield 1?
		BEQ.W	.NoOdd			; No. Skip direction change
		NEG.W	SpriteDirX		; Change X direction
.NoOdd		BTST	#5,d0			; Collision with playfield 2?
		BEQ.B	.NoEven			; No. Skip direction change
		NEG.W	SpriteDirY		; Change Y direction

.NoEven		MOVE.W	SpritePosX(PC),d0	; X position
		ADD.W	SpriteDirX(PC),d0	; Move one step
		MOVE.W	d0,SpritePosX		; Store new postion
		MOVE.W	SpritePosY(PC),d1	; Y position
		ADD.W	SpriteDirY(PC),d1	; Move one step
		MOVE.W	d1,SpritePosY		; Store new position

		LEA.L	SpriteAnim(PC),a0	; APTR table with sprite anim
		MOVE.W	SpriteAnimPos(PC),d2	; Get position in sprite anim
		ADDQ.W	#2,d2			; Move to next position
		MOVE.W	d2,d3
		AND.W	#$FFFC,d3		; Ensure it is divisible by 4
		MOVE.L	(a0,d3.w),d3		; Get next struct pointer
		BNE.B	.GotSprite		; Not zero, got a sprite struct
		MOVEQ	#0,d2			; Start anim at beginning
		MOVE.L	(a0),d3			; Get first sprite in table
.GotSprite	MOVE.W	d2,SpriteAnimPos	; Store new position
		MOVEQ	#16,d2			; Set sprite height
		MOVE.L	d3,a0			; APTR to sprite struct
		BSR.W	SetSprite		; Update position in struct

		LEA.L	CopSprite(PC),a0	; APTR Sprite pointers in coplist
		MOVE.W	d3,6(a0)		; Place low word into coplist
		SWAP	d3
		MOVE.W	d3,2(a0)		; Place high word into coplist

		MOVEM.L	(a7)+,d0-d3/a0
.NoMove		RTE

;-----------------------------------------------------------

SpritePosX:	DC.W	$00C0
SpritePosY:	DC.W	$00D0
SpriteDirX:	DC.W	-1
SpriteDirY:	DC.W	-1
SpriteAnimPos:	DC.W	0
SpriteAnim:	DC.L	SpriteF,SpriteE,SpriteD,SpriteC,SpriteB,SpriteA,0


;-----------------------------------------------------------
; Small coplist for refreshing the sprite pointers

Coplist:	DC.W	$1807,$fffe	; Wait for start of line $18 

CopBPL:		DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2

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
; Sprite structures

SpriteA:	DC.W	0,0
		DC.W	$00c0,$0300
		DC.W	$00f0,$0f00
		DC.W	$00f8,$1f00
		DC.W	$00fc,$3f00
		DC.W	$40fe,$7f06
		DC.W	$70fe,$7f0e
		DC.W	$fcff,$ff3f
		DC.W	$feff,$ff7f
		DC.W	$ff7f,$feff
		DC.W	$ff3f,$fcff
		DC.W	$7f0e,$70fe
		DC.W	$7f02,$60fe
		DC.W	$3f00,$00fc
		DC.W	$1f00,$00f8
		DC.W	$0f00,$00f0
		DC.W	$0300,$00c0
		DC.W	$0000,$0000

SpriteB:	DC.W	0,0
		DC.W	$03c0,$0000
		DC.W	$0ff0,$0000
		DC.W	$07f8,$1808
		DC.W	$07fc,$381c
		DC.W	$03fe,$7c3e
		DC.W	$03fe,$7c3e
		DC.W	$01ff,$fe7f
		DC.W	$00ff,$ffff
		DC.W	$ff00,$ffff
		DC.W	$ff80,$fe7f
		DC.W	$7fc0,$7c3e
		DC.W	$7fc0,$783e
		DC.W	$3fe0,$381c
		DC.W	$1fe0,$1018
		DC.W	$0ff0,$0000
		DC.W	$03c0,$0000
		DC.W	$0000,$0000

SpriteC:	DC.W	0,0
		DC.W	$03c0,$00c0
		DC.W	$0ff0,$00f0
		DC.W	$1ff8,$00f8
		DC.W	$3ffc,$00fc
		DC.W	$3ff8,$40fe
		DC.W	$0ff0,$70fe
		DC.W	$03c0,$fcff
		DC.W	$0180,$feff
		DC.W	$0180,$ff7f
		DC.W	$03c0,$ff3f
		DC.W	$0ff0,$7f0e
		DC.W	$1ffc,$7f02
		DC.W	$3ffc,$3f00
		DC.W	$1ff8,$1f00
		DC.W	$0ff0,$0f00
		DC.W	$03c0,$0300
		DC.W	$0000,$0000

SpriteD:	DC.W	0,0
		DC.W	$03c0,$03c0
		DC.W	$0ff0,$0ff0
		DC.W	$1fe0,$0ff8
		DC.W	$3fe0,$07fc
		DC.W	$7fc0,$03fe
		DC.W	$7fc0,$03fe
		DC.W	$ff80,$01ff
		DC.W	$ff00,$00ff
		DC.W	$00ff,$ff00
		DC.W	$01ff,$ff80
		DC.W	$03fe,$7fc0
		DC.W	$03fe,$7fc0
		DC.W	$07fc,$3fe0
		DC.W	$07f8,$1ff0
		DC.W	$0ff0,$0ff0
		DC.W	$03c0,$03c0
		DC.W	$0000,$0000

SpriteE:	DC.W	0,0
		DC.W	$0300,$03c0
		DC.W	$0f00,$0ff0
		DC.W	$1f00,$1ff8
		DC.W	$3f00,$3ffc
		DC.W	$7f06,$3ff8
		DC.W	$7f0e,$0ff0
		DC.W	$ff3f,$03c0
		DC.W	$ff7f,$0180
		DC.W	$feff,$0180
		DC.W	$fcff,$03c0
		DC.W	$70fe,$0ff0
		DC.W	$60fe,$1ffc
		DC.W	$00fc,$3ffc
		DC.W	$00f8,$1ff8
		DC.W	$00f0,$0ff0
		DC.W	$00c0,$03c0
		DC.W	$0000,$0000

SpriteF:	DC.W	0,0
		DC.W	$0000,$03c0
		DC.W	$0000,$0ff0
		DC.W	$1018,$1fe0
		DC.W	$381c,$3fe0
		DC.W	$7c3e,$7fc0
		DC.W	$7c3e,$7fc0
		DC.W	$fe7f,$ff80
		DC.W	$ffff,$ff00
		DC.W	$ffff,$00ff
		DC.W	$fe7f,$01ff
		DC.W	$7c3e,$03fe
		DC.W	$7c3e,$03fe
		DC.W	$381c,$07fc
		DC.W	$1808,$07f8
		DC.W	$0000,$0ff0
		DC.W	$0000,$03c0
		DC.W	$0000,$0000

NoSprite:	DC.W	0,0

;-----------------------------------------------------------

Sine:		INCLUDE	"BareMetal:Include/Sine256B.i"

;-----------------------------------------------------------

		SECTION	BitPlane,DATA_C

Bitplanes:	INCBIN	"BareMetal:Assets/COllision.RAW"

;-----------------------------------------------------------
