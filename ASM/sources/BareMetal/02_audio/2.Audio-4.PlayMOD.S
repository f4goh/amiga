
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


ExecSupervisor	EQU	-30
exec_AttnFlags	EQU	296
CIAAPRA		EQU	$BFE001

;-----------------------------------------------------------

		SECTION Data,DATA_C

ModFile:	INCBIN "BareMetal:Assets/mod.file"

;-----------------------------------------------------------

		SECTION	Code,CODE

		MOVE.L	4.w,a6			; A6 = Exec base
		MOVEQ	#0,d0
		BTST.B	#0,exec_AttnFlags(a6)	; Check if > 68000 processor
		BEQ.B	.NoVBR			; On 68000 no VBR (always zero)
		LEA.L	GetVBR(PC),a5		; Function to call as supervisor
		JSR	ExecSupervisor(a6)	; Call supervisor function in A5
		MOVE.L	d0,a0			; A0 = VBR

.NoVBR		LEA	$DFF000,a6		; Custom base
		MOVE.L	d0,a0			; VBR offset
		MOVEQ	#1,d0			; 0 = NTSC, otherwise PAL
		BSR	_mt_install_cia		; Initialise CIA interrupt

		LEA.L	ModFile,a0		; A0 - Pointer to mod file
		MOVEQ	#0,d0			; D0 - Start location (pattern 0)
		MOVE	d0,a1			; A1 - APTR to samples (NULL)
		BSR	_mt_init		; Initialise the player

		MOVE.B	#1,_mt_Enable		; Start playback

.WaitLoop	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing

		BSR	_mt_end			; Stop playing
		BSR	_mt_remove_cia		; Remove CIA interrupt
		RTS


;-----------------------------------------------------------

GetVBR:		DC.L	$4E7A0801		; MOVEC VBR,d0
		RTE				; Return from supervisor mode


;-----------------------------------------------------------

		INCDIR "BareMetal:ptplayer/"
		INCLUDE "ptplayer.asm"

;-----------------------------------------------------------
