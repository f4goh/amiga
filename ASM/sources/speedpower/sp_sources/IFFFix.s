
	        ;--- IFF-Picture Decruncher & Fixer ---

org	$20000
load	$20000
>EXTERN		'df0:BB',$40000

S:		movem.l	d0-d7/a0-a6,-(a7)
		bsr	Decrunch
		bsr	SaveAll
		bsr	StartCopper
		bsr	WaitLoop
		bsr	RestoreCopper
		movem.l	(a7)+,d0-d7/a0-a6
		rts

SaveAll:	lea	OldCop(pc),a2
		moveq	#$f,d2
		moveq	#0,d0
		move.l	4.W,a6
		lea	GfxName(pc),a1
		jsr	-408(a6)
		move.l	d0,a0
		move.l	$26(a0),(a2)+
		lea	$dff000,a6
		move.w	$2(a6),d0
		move.w	$1c(a6),d1
		bset	d2,d0
		bset	d2,d1
		movem.w	d0-d1,(a2)
		rts

StartCopper:	lea	CopperList(pc),a0
		move.l	a0,$80(a6)
		tst.w	$88(a6)
		move.w	#$7fff,d0
		move.w	d0,$96(a6)
		move.w	d0,$9a(a6)
		move.w	#$87c0,$96(a6)
		move.w	#$c000,$9a(a6)
		rts

RestoreCopper:	lea	OldCop(pc),a0
		move.l	(a0)+,$80(a6)
		tst.w	$88(a6)
		move.w	(a0)+,$96(a6)
		move.w	(a0)+,$9a(a6)
		rts

WaitLoop:	cmp.b	#-1,$6(a6)
		bne.S	WaitLoop
		btst	#6,$bfe001
		bne.S	WaitLoop
		rts

OldCop:		dc.l	0,0
GfxName:	dc.b	'graphics.library',0
		even

;----------------------------------------------------------------------

			;--- The Decrunch ---

Decrunch:	bsr	Base
		bsr	GetColors
		bsr	Graphics
		rts

GetColors:	move.l	#'CMAP',d0
		move.l	IFFPointer(pc),a0
		bsr	FindString
		lea	Colors+2(pc),a1
		move.w	Cols(pc),d7
		subq.w	#1,d7
ColorLoop:	moveq	#0,d0
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		lsl.w	#4,d0
		lsr.b	#4,d2
		or.b	d1,d0
		or.b	d2,d0
		move.w	d0,(a1)
		addq.l	#4,a1
		dbf	d7,ColorLoop
		rts

; --- When decrunching: ------------------------------------------------
; - 1:st byte:	< 128 then the number stands for the number of following
;		bytes that should be copied into the plane.
;		= 128 clear the next byte of the plane
;		> 128 then NEG the byte. The number you have now is the
;		number of times the next byte in the IFF-file should be
;		copied into the plane.
;------------------------------------------------------------------------

Graphics:	move.l	#'BODY',d0
		move.l	IFFPointer(pc),a0
		bsr	FindString
		lea	LinePointers(pc),a1
		move.l	ShowAdr(pc),d0
		move.l	#256*40,d1
		moveq	#4,d7
ALoop:		move.l	d0,(a1)+
		add.l	d1,d0
		dbf	d7,ALoop

		moveq	#0,d3
		move.b	BPlan(pc),d3
		subq.b	#1,d3
		move.w	#128,d4
		lea	LinePointers(pc),a3
		move.w	#256-1,d7

LLoop1:		move.l	a3,a1
		move.w	d3,d6
LLoop2:		move.l	(a1),a2
		moveq	#40-1,d5
LLoop3:		moveq	#0,d0
		move.b	(a0)+,d0
		bpl.S	Move1
		cmp.b	d4,d0
		bne.S	Move2

Move3:		clr.b	(a2)+
EndIt2:		tst.b	d5
		bpl.S	LLoop3
		move.l	a2,(a1)+
		dbf	d6,LLoop2
		dbf	d7,LLoop1
		rts

Move2:		neg.b	d0
		sub.b	d0,d5
		move.b	(a0)+,d1
FL1:		move.b	d1,(a2)+
		dbf	d0,FL1
		subq.b	#1,d5
		bra.S	EndIt2

Move1:		sub.b	d0,d5
		subq.b	#1,d5
FL2:		move.b	(a0)+,(a2)+
		dbf	d0,FL2
		bra.S	EndIt2

;------------------------------------------------------------

FindString:	cmp.l	(a0),d0
		beq.S	StringFound
		addq.l	#2,a0
		bra.S	FindString
StringFound:	addq.l	#8,a0
		rts

Base:		lea	IFFPointer(pc),a0
		move.l	IFFBild(pc),(a0)
		move.l	(a0),a1
		moveq	#0,d0
		move.b	28(a1),d0		;Antal Bitplan
		lea	AntBpl+2(pc),a2
		lsl.b	#4,d0
		move.b	d0,(a2)
		lsr.b	#4,d0
		move.b	d0,16(a0)
		subq.w	#1,d0
		add.w	d0,d0
		move.w	NoCols(pc,d0.W),d0
		move.w	d0,14(a0)
		lea	BMap(pc),a3
		move.l	ShowAdr(pc),d0
		moveq	#0,d1
		move.w	#256*40,d1
		moveq	#0,d7
		move.b	16(a0),d7
		subq.w	#1,d7
BMapLoop:	swap	d0
		move.w	d0,2(a3)
		swap	d0
		move.w	d0,6(a3)
		addq.l	#8,a3
		add.l	d1,d0
		dbf	d7,BMapLoop
		rts

IFFBild:	dc.l	$40000
ShowAdr:	dc.l	$50000
IFFPointer:	dc.l	0
NoCols:		dc.w	2,4,8,16,32
Cols:		dc.w	0
BPlan:		dc.b	0
		even

LinePointers:	blk.l	5,0

;----------------------------------------------------------------------

CopperList:	dc.l	$008e2881,$009028dd,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000

BMap:		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000

Colors:		dc.l	$01800000,$01820000,$01840000,$01860000
		dc.l	$01880000,$018a0000,$018c0000,$018e0000
		dc.l	$01900000,$01920000,$01940000,$01960000
		dc.l	$01980000,$019a0000,$019c0000,$019e0000
		dc.l	$01a00000,$01a20000,$01a40000,$01a60000
		dc.l	$01a80000,$01aa0000,$01ac0000,$01ae0000
		dc.l	$01b00000,$01b20000,$01b40000,$01b60000
		dc.l	$01b80000,$01ba0000,$01bc0000,$01be0000

AntBpl:		dc.l	$01000000

		dc.l	-2
ss:

