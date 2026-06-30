*********************************************************************
*                                                                   *
*                                                                   *
*     SOME ROUTINES FOR THE HANDLING OF BLITTER OBJECTS (BOBS)      *
*                                                                   *
*      Written By AntiAction of TETRAGON on 18th of July -88.       *
*                                                                   *
*                                                                   *
*********************************************************************

*************************************************
*		      MakeMask			*
*	D7=Depth, D0=WordWidth, D1=Height	*
*      A0-A5 Contains Source BM's, A6=Dest	*
*************************************************

MakeMask:
tst.b	d7
beq.s	MMaskRet			; If 0 Depth, return
bsr	MaskIt
subq.b	#1,d7
beq.s	MMaskRet
move.l	a1,a0
bsr	MaskIt
subq.b	#1,d7
beq.s	MMaskRet
move.l	a2,a0
bsr	MaskIt
subq.b	#1,d7
beq.s	MMaskRet
move.l	a3,a0
bsr	MaskIt
subq.b	#1,d7
beq.s	MMaskRet
move.l	a4,a0
bsr	MaskIt
subq.b	#1,d7
beq.s	MMaskRet
move.l	a5,a0
bsr	MaskIt
MMaskRet:
rts

*********************************
*   A0=Source, A6=Destination	*
*	      D = A+D		*
*********************************

MaskIt:
movem.l	d2-d3,-(a7)
bsr	WaitBlit
move.l	a0,$dff050			; BLTAPT
move.l	a6,$dff054			; BLTDPT
move.l	a6,$dff04c			; BLTBPT
clr.l	$dff064				; The Modulos = 0
clr.w	$dff062
move.l	#-1,$dff044			; Ze masks
move.l	#$0dfc0000,$dff040		; D = A+B
move.w	d1,d2				; Height
asl.w	#6,d2				; Mapped to bits 6-15
ori.w	d0,d2				; Width
move.w	d2,$dff058			; Trigger blit
movem.l	(a7)+,d2-d3
rts

******************************
* Wait for blitter to finish *
******************************

WaitBlit:
btst	#14,$dff002
bne.s	WaitBlit
rts

*********************************************************
*  Put A Bob plane into a bitmap, no background saving	*
*		  or masking with masks			*
*-------------------------------------------------------*
* 	D0=BOBWidth in words, D1=Height in pixels	*
* 	D2=BitMapWidth in bytes.			*
*	D3=Horiz.Position, D4=Vertical Position		*
*	A0=BobData Pointer				*
*	A1=BitMap  Pointer				*
*********************************************************

PutBobNoSave:
movem.l	d0-d7/a0-a6,-(a7)
bsr	WaitBlit
addq.w	#1,d0
swap	d4
move.w	#0,d4			; Used as long later
swap	d4
move.w	d3,d5
asr.w	#4,d5			; Divide by 16 to get word offset.
asl.w	#1,d5			; Multiply with 2 to get byte offset
mulu	d2,d4			; To get byte offset =vertwidth*ypos
add.w	d5,d4			; Total offset
and.w	#15,d3			; Shift value = low 4 bits
add.l	d4,a1			; Calc BitMap pointer

move.l	a0,$dff050		; BLTAPT
move.l	a1,$dff054		; BLTDPT
move.l	a1,$dff04c		; BLTBPT
move.l	#$ffff0000,$dff044	; First and LastWord masks
ror.w	#4,d3			; No.Of shifts
ori.w	#$0dfc,d3		; D=A+B
move.w	d3,$dff040		; BLTCON0
clr.w	$dff042			; BLTCON1
move.w	d2,d3			; BitMapWidth in bytes
asr.w	#1,d3			; Divide by two.
sub.w	d0,d3			; Calculate modulo
asl.w	#1,d3			; Must be even
move.w	d3,$dff062		; BLTBMOD
move.w	d3,$dff066		; BLTDMOD
move.w	#-2,$dff064		; BLTAMOD
lsl.w	#6,d1			; Height is mapped to bits 6-15
ori.w	d0,d1			; Width is mapped to bits 0-5
move.w	d1,$dff058		; BLTSIZE and trigger
movem.l	(a7)+,d0-d7/a0-a6
rts

*********************************************************
*      Erase a bob without restoring the background	*
*-------------------------------------------------------*
* 	D0=BOBWidth in words, D1=Height in pixels	*
* 	D2=BitMapWidth in bytes.			*
*	D3=Horiz.Position, D4=Vertical Position		*
*	A1=BitMap  Pointer				*
*********************************************************

EraseBobNoSave:
movem.l	d0-d7/a0-a6,-(a7)
bsr	WaitBlit
ext.l	d4
addq.w	#1,d0
asr.w	#4,d3			; Divide by 16 to get word offset.
asl.w	#1,d3			; Multiply with 2 to get byte offset
mulu	d2,d4			; To get byte offset =vertwidth*ypos
add.w	d3,d4			; Total offset
add.l	d4,a1			; Calc BitMap pointer

move.l	a1,$dff054		; BLTDPT
move.w	#$0100,$dff040		; D=0
clr.w	$dff042			; BLTCON1
move.w	d2,d3			; BitMapWidth in bytes
asr.w	#1,d3			; Divide by two.
sub.w	d0,d3			; Calculate modulo
asl.w	#1,d3			; Must be even
move.w	d3,$dff066		; BLTDMOD
lsl.w	#6,d1			; Height is mapped to bits 6-15
ori.w	d0,d1			; Width is mapped to bits 0-5
move.w	d1,$dff058		; BLTSIZE and trigger
movem.l	(a7)+,d0-d7/a0-a6
rts
