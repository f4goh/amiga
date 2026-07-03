
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


; Exec library offsets
OldOpenLibrary	EQU	-408
CloseLibrary	EQU	-414

; Dos library offsets
Open		EQU	-30
Close		EQU	-36
Write  		EQU	-48


		INCLUDE	"BareMetal:Include/BareMetal.i"

;-----------------------------------------------------------

		SECTION	Code,CODE_C		


		BSR.W	GetTrack		; Read encoded track

		LEA.L	Encoded,a0		; APTR Source
		ADDQ.L	#2,a0			; Skip syncword
		LEA.L	Decoded,a2		; APTR Destination
		BSR.W	DecTrack		; Decode whole track

		BRA.B	SaveBuffers		; Save buffers to file
		RTS


;-----------------------------------------------------------
; Use dos.libary to write both buffers to disk

SaveBuffers:	MOVE.L	4.w,a6			; A6 = ExecBase.
		LEA.L	DosName(PC),a1
		JSR	OldOpenLibrary(a6)
		TST.L	d0
		BEQ.W	.NoDos
		MOVE.L	d0,a6			; A6 = dos base

		MOVE.L	#EncFile,d1		; APTR file name
		MOVE.L	#1006,d2		; Open for writing
		JSR	Open(a6)
		MOVE.L	d0,d7			; D7 = File handle
		BEQ.B	.NoEncFile		; No file, nothing to do
		MOVE.L	d0,d1
		MOVE.L	#Encoded,d2		; APTR Buffer
		MOVE.L	#12960,d3		; ULONG length
		JSR	Write(a6)
		MOVE.L	d7,d1			; D1 = File handle
		JSR	Close(a6)

.NoEncFile	MOVE.L	#DecFile,d1		; APTR file name
		MOVE.L	#1006,d2		; Open for writing
		JSR	Open(a6)
		MOVE.L	d0,d7			; D7 = File handle
		BEQ.B	.NoDecFile		; No file, nothing to do
		MOVE.L	d0,d1
		MOVE.L	#Decoded,d2		; APTR Buffer
		MOVE.L	#5940,d3		; ULONG length
		JSR	Write(a6)
		MOVE.L	d7,d1			; D1 = File handle
		JSR	Close(a6)	

.NoDecFile	MOVE.L	a6,a1			; A1 = Dosbase
		MOVE.L	4.w,a6			; A6 = ExecBase.
		JSR	CloseLibrary(a6)
.NoDos		RTS

;-----------------------------------------------------------

DosName:	DC.B	"dos.library",0
EncFile:	DC.B	"ram:encoded.data",0
DecFile:	DC.B	"ram:decoded.data",0
		EVEN


;-----------------------------------------------------------
; Decode track
;
; INPUT:	A0 - APTR Track to decode
;		A2 - APTR Destination buffer
;
; TRASH:	A1,A3,D0-D3

DecTrack:	MOVEQ	#11,d3			; D3 = Num sectors to decode
.NextSector	MOVE.L	a2,a3			; A3 = APTR decoded sector
		BSR.B	DecSector		; Decode the sector
		SUBQ.L	#1,d3			; Decoded one more sector
		BEQ.B	.Done			; Zero? All done!
		ADDA.W	#8,a0			; Skip sector identification
		MOVE.B	3(a3),d0		; Get SectorsTillEnd
		CMP.B	#1,d0			; This was the last one?
		BNE.B	.NextSector		; No. Do the next one
		
		CMP.B	#11,d3			; Done all 11 sectors?
		BEQ.B	.Done			; Finished, otherwise search gap

.FindSync	CMP.W	#$4489,(a0)+		; Find the syncword at end of gap
		BNE.B	.FindSync
		BRA.B	.NextSector		; Found it, keep decoding

.Done		RTS


;-----------------------------------------------------------
; Decode sector
;
; INPUT:	A0 - APTR Sector to decode
;		A2 - APTR Destination buffer
;
; TRASH:	A1,D0-D2
;
; OUTPUT:	A0 - APTR End of sector data
;		A2 - APTR Next location in destination buffer 

DecSector:	BSR.B	DecLong			; Decode sector identification

		LEA.L	16(a0),a1		; APTR to even bit block of 16 bytes
		MOVEQ	#4-1,d0			; Process 4 longs
		BSR.B	DecBlock		; Decode the admin bytes

		MOVE.L	a1,a0			; Continue at the end of the even block
		BSR.B	DecLong			; Header checksum
		BSR.B	DecLong			; Data block checksum

		LEA.L	512(a0),a1		; APTR to even bit block of 512 bytes
		MOVEQ	#128-1,d0		; Process 128 longs
		BSR.B	DecBlock		; Decode the user data
		MOVE.L	a1,a0			; Continue at the end of the even block

		RTS


;-----------------------------------------------------------
; Decode a block of longs 
;
; INPUT:	A0   - APTR Source odd longs
;		A1   - APTR Source even longs
;		A2   - APTR Destination
;		D0.W - Number of longs to decode -1
;
; TRASH:	D0-d2
;
; OUTPUT:	A0 - APTR Next odd source
;		A1 - APTR Next even source
;		A2 - APTR Next destination

DecBlock:	MOVE.L	(a0)+,d1		; D1 = Odd bits
		MOVE.L	(a1)+,d2		; D2 = Even bits
		AND.L	#$55555555,d1		; Clear all clock bits
		AND.L	#$55555555,d2		; Clear all clock bits
		LSL.L	d1			; Shift odd bits to odd positions
		OR.L	d2,d1			; Combine odd and even bits
		MOVE.L	d1,(a2)+		; Store result
		DBF	d0,DecBlock		; Do all longs in the block
		RTS


;-----------------------------------------------------------
; Decode two longs into one long
;
; INPUT:	A0 - APTR Source
;		A2 - APTR Destination
;
; TRASH:	D0,D1
;
; OUTPUT:	A0 - APTR Next source
;		A2 - APTR Next destination

DecLong:	MOVE.L	(a0)+,d0		; D0 = Odd bits
		MOVE.L	(a0)+,d1		; D1 = Even bits
		AND.L	#$55555555,d0		; Clear all clock bits
		AND.L	#$55555555,d1		; Clear all clock bits
		LSL.L	d0			; Shift odd bits to odd positions
		OR.L	d1,d0			; Combine odd and even bits
		MOVE.L	d0,(a2)+		; Store result
		RTS


;-----------------------------------------------------------
; Read one track of raw data from the disk
; 
; First use SafeStart to stop the OS
; SafeStart will then BSR to the "Main" label
; At the end of Main the code will RTS back into SafeStart
; SafeStart will start the OS again and RTS back to the caller

GetTrack:	INCLUDE	"BareMetal:Include/SafeStart.i"


Main:		BSR.B	StartDf0		; Start drive 0

;		MOVEQ	#40,d0			; Select track 
;		BSR.W	MoveHeads		; Move the heads there

		BSR.W	ReadTrack		; Read track 0 from disk

		BSR.B	StopDisk		; Stop the drive motor
		RTS


;-----------------------------------------------------------

StartDf0:	MOVE.B	#$77,CIAB+PRB		; Motor ON, disk 0, bottom, down
.Again		BTST.B	#4,CIAA+PRA		; Goes low when on position 0
		BEQ.B	.OnZero			; Reached position?
		BSR.W	DiskStep		; Move head one step (down)
		ADDQ.B	#1,OrgPos		; Count the number of steps
		BRA.B	.Again			; Keep stepping until on 0
.OnZero:	CLR.B	CurPos			; Currently on position 0

.NotReady	BTST.B	#5,CIAA+PRA		; Goes low when drive is ready
		BNE.B	.NotReady		; Wait until it becomes ready
		RTS


;-----------------------------------------------------------

StopDisk:	MOVE.B	OrgPos(PC),d0		; Original head position
		BSR.B	MoveHeads		; Move heads back to that position
		BSET.B	#7,CIAB+PRB		; Motor OFF
		MOVE.B	#$FF,CIAB+PRB		; Deselect all drives
		RTS


OrgPos:		DC.B	0	; Position heads were on when starting
CurPos:		DC.B	0	; Position the heads are currently on


;-----------------------------------------------------------

ReadTrack:	MOVE.W	#$8010,DMACON(a5)	; Enable disk DMA

		MOVE.W	#$4489,DSKSYNC(a5)	; Look for the MFM syncword 
		MOVE.W	#$0200,ADKCON(a5)	; Do not sync on MSB
		MOVE.W	#$8500,ADKCON(a5)	; Set WORDSYNC amd FAST
		MOVE.L	#Encoded,DSKPT(a5)	; APTR to memory block
		MOVE.W	#$9950,DSKLEN(a5)	; Start DMA and read 6480 words
		MOVE.W	#$9950,DSKLEN(a5)	; Write again to start

.WaitInt	BTST.B	#1,INTREQR+1(a5)	; Disk block complete bit set?
		BEQ.B	.WaitInt		; Wait until it is

		MOVE.W	#$0002,INTREQ(a5)	; Clear disk block complete bit
		MOVE.W	#$0010,DMACON(a5)	; Disable disk DMA
		MOVE.W	#$0000,DSKLEN(a5)	; Clear DMA bit and length
		RTS


;-----------------------------------------------------------
; Move the heads to a particular position
;
; INPUT:	D0.B - position number (0-79)
;
; TRASH:	A0,D0-D2

MoveHeads:	MOVE.B	CurPos(PC),d2		; Get previous current position
		MOVE.B	d0,CurPos		; Store new current position
		SUB.B	d0,d2			; Calculate number of steps
		BEQ.B	.Done			; Already there.
		BPL.B	.MoveDown		; Positive? Needs to move down

		NEG.B	d2			; Make positive number of steps
		BCLR.B	#1,CIAB+PRB		; Stepping up
		BRA.B	.Move

.MoveDown	BSET.B	#1,CIAB+PRB		; Stepping down

.Move		SUBQ.B	#1,d2			; Correct number of loops
		EXT.W	d2			; Extend to word size
.Again		BSR.B	DiskStep		; Generate one stepping pulse
		DBF	d2,.Again		; Until all pulses done
.Done		RTS


;-----------------------------------------------------------
; Create one 3ms stepper pulse for the selected drive
;
; TRASH:	A0,D0,D1

DiskStep:	BCLR.B	#0,CIAB+PRB		; Start low pulse to step
		BSR.B	Delay_3ms		; Keep pulse low for > 3ms
		BSET.B	#0,CIAB+PRB		; Set to high to end the pulse
		RTS


;-----------------------------------------------------------
; Create a 3ms delay using the TOD timer of CIAB.
; CIAB's TOD timer runs at 15.750 kHz (PAL) or 15.734 kHz(NTSC)
;
; TRASH:	A0,D0,D1

Delay_3ms:	LEA.L	CIAB,A0			; Reading TOD from CIAB
		BSR.B	GetTOD			; Get current value
		MOVE.L	d0,d1	
		ADD.L	#48,d1			; Calculate end value
		AND.L	#$00FFFFFF,d1		; Remove possible overflow
.ToSoon		BSR.B	GetTOD			; Get the current value
		CMP.L	d1,d0			; Has the value been reached
		BNE.B	.ToSoon			; No. Keep reading
		RTS


;-----------------------------------------------------------
; Get TOD value from a CIA
;
; INPUT:	A0 - CIA base address
;
; TRASH:	D0
;
; OUTPUT:	D0 - TOD value


GetTOD:		MOVEQ	#0,d0			; Ensure top bits will be cleared
		MOVE.B	TODHI(a0),d0		; Reading TODHI latches values
		SWAP	d0			; Move to bottom byte of top word
		MOVE.B	TODMID(a0),d0		; Read TOD middle byte
		ASL.W	#8,d0			; Move to top byte bottom word
		MOVE.B	TODLO(a0),d0		; Reading TODLO removes latch
		RTS


;-----------------------------------------------------------

		SECTION	DiskData,BSS_C

Encoded:	DS.B	12960	;Space for 12 encoded sectors
Decoded:	DS.B	5940	;Space for 11 decoded sectors (540 bytes each)

;-----------------------------------------------------------

