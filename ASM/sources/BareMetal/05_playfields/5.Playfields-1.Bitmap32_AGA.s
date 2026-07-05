
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

		LEA.L	Bitplane,a1
		MOVE.L	a1,d0
		AND.L	#$FFFFFFF8,d0
		ADDQ.L	#8,d0
		MOVE.L	d0,a4
		MOVE.W	d0,6(a0)		; Place low word into coplist
		SWAP	d0
		MOVE.W	d0,2(a0)		; Place high word into coplist

		; Vertical lines

		MOVE.L	a4,a0
		MOVE.W	#256-1,d0
		MOVEQ	#3,d1			; Right most bit set
		MOVE.W	d1,d2
		ROR.W	#2,d2			; Left most bit set
.FillLoop1	MOVE.W	d2,(a0)
		MOVE.W	d1,38(a0)
		LEA.L	40(a0),a0
		DBF	d0,.FillLoop1

		; Horizontal lines

		MOVE.L	a4,a0
		LEA.L	255*40(a0),a1
		MOVEQ	#-1,d1
		MOVE.W	#10-1,d0
.FillLoop2	MOVE.L	d1,(a0)+
		MOVE.L	d1,(a1)+
		DBF.W	d0,.FillLoop2

		MOVE.W	#$8180,DMACON(a5)	; Enable Bitplane and Copper DMA

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS


;-----------------------------------------------------------

Coplist:	DC.W	BPL1PTH,0	; High word APTR bitplane 1
		DC.W	BPL1PTL,0	; Low word APTR bitplane 1
		DC.W	BPL2PTH,0	; High word APTR bitplane 2
		DC.W	BPL2PTL,0	; Low word APTR bitplane 2

		DC.W	FMODE,$1	; AGA: Use 32 bits DMA transfers

		DC.W	BPLCON0,$1200	; 1 bitplane, enable colour on composite
		DC.W	BPLCON1,$0000	; No delay/shift on the bitplanes
		DC.W	BPLCON2,$0000	;
		DC.W	BPL1MOD,$0000	; Modulo of 0 on odd bitplanes
		DC.W	BPL2MOD,$0000	; Modulo of 0 on even bitplanes
		DC.W	DIWSTRT,$2C81
		DC.W	DIWSTOP,$2CC1
		DC.W	DDFSTRT,$0038
		DC.W	DDFSTOP,$00C8

		DC.W	COLOR0,$0000	; Background colour: black
		DC.W	COLOR1,$0008	; Foreground colour: dark blue

	; From line $70 to $7E increase delay / shift for odd bitplanes

		DC.W	$7007,$fffe,BPLCON1,$0001
		DC.W	$7107,$fffe,BPLCON1,$0002	
		DC.W	$7207,$fffe,BPLCON1,$0003	
		DC.W	$7307,$fffe,BPLCON1,$0004	
		DC.W	$7407,$fffe,BPLCON1,$0005	
		DC.W	$7507,$fffe,BPLCON1,$0006	
		DC.W	$7607,$fffe,BPLCON1,$0007	
		DC.W	$7707,$fffe,BPLCON1,$0008	
		DC.W	$7807,$fffe,BPLCON1,$0009	
		DC.W	$7907,$fffe,BPLCON1,$000A	
		DC.W	$7A07,$fffe,BPLCON1,$000B	
		DC.W	$7B07,$fffe,BPLCON1,$000C	
		DC.W	$7C07,$fffe,BPLCON1,$000D	
		DC.W	$7D07,$fffe,BPLCON1,$000E	
		DC.W	$7E07,$fffe,BPLCON1,$000F	

	; From line $80 to $8E decrease delay / shift for odd bitplanes

		DC.W	$8007,$fffe,BPLCON1,$000E	
		DC.W	$8107,$fffe,BPLCON1,$000D	
		DC.W	$8207,$fffe,BPLCON1,$000C	
		DC.W	$8307,$fffe,BPLCON1,$000B	
		DC.W	$8407,$fffe,BPLCON1,$000A	
		DC.W	$8507,$fffe,BPLCON1,$0009	
		DC.W	$8607,$fffe,BPLCON1,$0008	
		DC.W	$8707,$fffe,BPLCON1,$0007	
		DC.W	$8807,$fffe,BPLCON1,$0006	
		DC.W	$8907,$fffe,BPLCON1,$0005	
		DC.W	$8A07,$fffe,BPLCON1,$0004	
		DC.W	$8B07,$fffe,BPLCON1,$0003	
		DC.W	$8C07,$fffe,BPLCON1,$0002	
		DC.W	$8D07,$fffe,BPLCON1,$0001	
		DC.W	$8E07,$fffe,BPLCON1,$0000	
		
		DC.W	$ffff,$fffe	; Wait indefinitely

;-----------------------------------------------------------

		SECTION	BitPlane,BSS_C

Bitplane:	DS.B	(320*256/8)+8

;-----------------------------------------------------------
