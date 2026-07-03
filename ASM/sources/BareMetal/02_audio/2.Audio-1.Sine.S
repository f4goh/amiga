
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

;		BCLR.B	#1,CIAAPRA		; Enable low-pass filter
;		BSET.B	#1,CIAAPRA		; Disable low-pass filter

		LEA	$DFF000,a5
		MOVE.L	#SineData,AUD0LC(a5)	; Set pointer to audio data location
		MOVE.W	#6,AUD0LEN(a5)		; Audio length in words, 6 words = 12 bytes
		MOVE.W	#64,AUD0VOL(a5)		; Maximum volume
		MOVE.W	#296,AUD0PER(a5)	; Period of 296 for 1kHz tone on a PAL system
		MOVE.W	#$8201,DMACON(a5)	; Start DMA for audio channel 0

WaitLoop:	BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	WaitLoop		; No click, keep testing
		MOVE.W	#1,DMACON(a5)		; Stop DMA for audio channel 0
		RTS

;-----------------------------------------------------------

SineData:	DC.B	0,64,111,127,111,64,0,-64,-111,-127,-111,-64

;-----------------------------------------------------------
