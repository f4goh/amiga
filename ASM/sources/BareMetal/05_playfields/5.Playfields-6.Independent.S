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


; ChangeLog:
;
; V1.1 - On line 118 amd 125 change SUB.W into ADD.W. Due to two's
;        complement this changes the direction of the movement and makes
;        the outcome of the mouse position caclulation correct. Even though
;        it makes no real difference to the way this example looks.



		INCLUDE	"BareMetal:Include/BareMetal.i"

;-----------------------------------------------------------

		SECTION	Code,CODE_C		

		INCLUDE	"BareMetal:Include/SafeStart.i"

Main:		LEA.L	CopBPL(PC),a0		; APTR to bitplane ptrs in coplist
		LEA.L	Bitplanes(PC),a1	; APTR Start of bitplane 1
		MOVE.L	a1,d0
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist
		SWAP	d0
		MOVE.W	d0,14(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,10(a0)		; Place high word into coplist

		LEA.L	Coplist(PC),a0		; APTR Start of coplist
		MOVE.L	a0,COP1LC(a5)		; Set start address for coplist
		MOVE.L	S_VBR(PC),a0
		MOVE.L	#IRQHandler,IRQ3(a0)	; Set the new vector

; Prepare the playfield

		MOVE.W	#$0000,COLOR0(a5)	; Background: black
		MOVE.W	#$0F00,COLOR1(a5)	; Color 1: Blue
		MOVE.W	#$000F,COLOR2(a5)	; Color 2: Red
		MOVE.W	#$00F0,COLOR3(a5)	; Color 3: Green

		MOVE.W	#40-2,BPL1MOD(a5)	; Odd bitplane 40 bytes larger than playfield
		MOVE.W	#40-2,BPL2MOD(a5)	; Even bitplane 40 bytes larger than playfield

		MOVE.W	#$2200,BPLCON0(a5)	; 2 bitplanes, enable colour on composite
		MOVE.W	#0,BPLCON1(a5)		; No delay/shift on odd or even bitplane yet
		MOVE.W	#0,BPLCON2(a5)		; Functionality not required

		MOVE.W	#0,FMODE(a5)		; AGA: Use 16 bit DMA transfers
		MOVE.W	#$2C81,DIWSTRT(a5)	; Left/top corner of display window
		MOVE.W	#$2CC1,DIWSTOP(a5)	; Right/bottom corner of display window
		MOVE.W	#$30,DDFSTRT(a5)	; Location of first DMA fetch each line
		MOVE.W	#$D0,DDFSTOP(a5)	; Location of last DMA fetch each line

		MOVE.W	JOY0DAT(a5),d0
		MOVE.B	d0,PrevH
		LSR.W	#8,d0
		MOVE.B  d0,PrevV

		MOVE.W	#$8020,INTENA(a5)	; Enable interrupt for the vertical blank
		MOVE.W	#$8180,DMACON(a5)	; Enable Bitplane and Copper DMA

; Wait for the user to click the mouse and clean up

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

;-----------------------------------------------------------

Calculate:	MOVE.W	d0,d2			; Copy of X position
		AND.W	#$000F,d2		; Use bottom 4 bits for delay
		SUB.W	d2,d0			; Remove the bottom bits
		ASR.W	#3,d0			; Divide by 8 for byte position
		MULU.W	#80,d1			; Convert Y pos to byte position
		ADD.W	d1,d0			; Add both byte positions
		NOT	d2			; Convert bottom bits to delay value
		AND.W	#$000F,d2		; Keep only the bottom bits
		MOVE.W	d2,d1			; D1 - Delay value
		RTS

;-----------------------------------------------------------

IRQHandler:	MOVE.W	#$0020,$DFF000+INTREQ	; Clear the interrupt flag
		MOVEM.L	d0-d4/a0-a1,-(a7)

		MOVE.W	ScrollX(PC),d3		; D3 - X pos
		MOVE.W	ScrollY(PC),d4		; D4 - Y pos

; Calculate new X and Y position

		MOVE.W	$DFF000+JOY0DAT,d0	; Relative mouse position
		MOVE.W	d0,d1			; Bottom byte: H, top byte: V
		SUB.B	PrevH,d0		; Calculate relative H change 
		EXT.W	d0			; Extend from byte to word size
		ADD.W	d0,d3			; Calculate new X position
		MOVE.B	d1,PrevH		; Store result for next time
		LSR.W	#8,d1			; Bottom byte: V
		MOVE.B	PrevV,d0		; Get the previous V counter
		MOVE.B	d1,PrevV		; Store the new vlue for next time
		SUB.W	d0,d1			; Calculate the V change
		EXT.W	d1			; Extend from byte to word size
		ADD.W	d1,d4			; Calculate new Y position

; Ensure X/Y position stays on the screen

		MOVE.W	d3,d0			; D0 - New X position
		BPL.B	.XStillPos		; Still positive?
		MOVEQ	#0,d0			; No. Keep on zero
.XStillPos	CMPI.W	#320,d0			; Compare X pos with 320
		BLS.B	.XInRange		; X position less than 320?
		MOVE.W	#319,d0			; No. Keep on 319.
.XInRange	MOVE.W	d0,ScrollX		; Store new X position

		MOVE.W	d4,d1			; D1 - New Y position
		BPL.B	.YStillPos		; Still positive?
		MOVEQ	#0,d1			; No. Keep on zero
.YStillPos	CMPI.W	#256,d1			; Compare with 256
		BLS.B	.YInRange		; Y position less than 256?
		MOVE.W	#255,d1			; No. Keep omn 255
.YInRange	MOVE.W	d1,ScrollY		; Store new Y position

; Calculate location of bitplane

		BSR.W	Calculate		; Calculate delay and offset
		EXT.L	d0			; Extend offset to 32 bits
		MOVE.L	d0,d3			; D3 - bitplane byte offset
		MOVE.W	d1,d4			; D4 - bitplane delay

; Calculate location of mirrored bitplane

		MOVE.W	#319,d0			; Right edge of screen
		SUB.W	ScrollX(PC),d0		; Subtract actual X position
		MOVE.W	#255,d1			; Bottom of screen
		SUB.W	ScrollY(PC),d1		; Subtract actual Y position
		BSR.W	Calculate		; Claculate delay and offset
		EXT.L	d0			; Extend offset to 32 bits

; Combine both delay values

		ASL.W	#4,d4			; Shift delay for even bitplanes
		OR.W	d4,d1			; Add delay of odd bitplanes
		MOVE.W	d1,$DFF000+BPLCON1	; Set delay for all bitplanes

; Setup the bitplane pointers for the coplist

		LEA.L	CopBPL(PC),a0		; APTR to bitplane ptrs in coplist
		LEA.L	Bitplanes(PC),a1	; APTR Start of bitplane
		MOVE.L	a1,d1
		ADD.L	d0,d1
		MOVE.W	d1,6(a0)		; Place low word into coplist
		SWAP	d1
		MOVE.W	d1,2(a0)		; Place high word into coplist

		LEA.L	Bitplanes(PC),a1	; APTR Start of bitplane 
		MOVE.L	a1,d1
		ADD.L	d3,d1
		MOVE.W	d1,14(a0)		; Place low word into coplist
		SWAP	d1
		MOVE.W	d1,10(a0)		; Place high word into coplist

		MOVEM.L	(a7)+,d0-d4/a0-a1
		RTE

;-----------------------------------------------------------

PrevH:		DC.B	0
PrevV:		DC.B	0
ScrollX:	DC.W	160
ScrollY:	DC.W	128

;-----------------------------------------------------------

Coplist:	DC.W	$2207,$fffe	; Wait for start of line $22 

CopBPL:		DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2

		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------

Bitplanes:	INCBIN	"BareMetal:Assets/Circles.RAW"

;-----------------------------------------------------------
