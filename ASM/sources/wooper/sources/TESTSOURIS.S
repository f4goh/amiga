;------------------------------------------------------------------------
;-									-
;-			    Memorysearcher				-
;-									-
;------------------------------------------------------------------------

org	$7fbc0
load	$7fbc0

>EXTERN		'Siffror',Siffror

S:		move.l	$6c.W,OldInt
		move.l	#PRG,$6c.W
		rts

PRG:		movem.l	d0-d7/a0-a6,-(sp)
		btst	#6,$bfe001
		bne.S	LoLoLo
		btst	#10,$dff016
		bne.S	LoLoLo
Sd:		btst	#6,$bfe001
		beq.S	Sd
		bsr.S	StartUp
		bsr	Init
		bsr	BlitWait
		bsr	StartCopper
		bsr	MainLoop
		bsr	RestoreCopper
LoLoLo:		movem.l	(sp)+,d0-d7/a0-a6
		move.l	OldInt,-(a7)
		rts

StartUp:	move.l	$4.W,a6
		lea	GfxName(pc),a1
		lea	OldCop(pc),a2
		moveq	#0,d0
		jsr	-408(a6)
		move.l	d0,a1
		move.l	$26(a1),(a2)+
		jsr	-414(a6)
		lea	$dff000,a6
		move.w	$2(a6),d0
		bset	#15,d0
		move.w	d0,(a2)+
		rts

StartCopper:	move.l	#CopperList,$80(a6)
		tst.w	$88(a6)
		move.w	#$7fff,$96(a6)
		move.w	#$83c0,$96(a6)
		move.l	$4,a6
		jsr	-132(a6)
		lea	$dff000,a6
		rts

RestoreCopper:	move.l	OldCop(pc),$80(a6)
		move.w	OldDma(pc),$96(a6)
		move.l	$4,a6
		jsr	-138(a6)
		rts

Init:		bsr.S	BlitWait
		move.l	#$01000000,$40(a6)
		clr.w	$66(a6)
		move.l	BMapAdr(pc),$54(a6)
		move.w	#8*64+20,$58(a6)

		lea	BMap1(pc),a0
		move.l	BMapAdr(pc),d0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)

		move.w	$dff00a,OldY
		rts

BlitWait:	btst	#14,$2(a6)
		bne.S	BlitWait
		rts

OldInt:		dc.l	0

;------------------------------------------------------------------------

MainLoop:	cmp.b	#-1,$6(a6)
		bne.S	MainLoop
SQ:		cmp.b	#$28,$6(a6)
		bne.S	SQ

		bsr.S	CheckKeys
		bsr	Mouse
		bsr	MoveScreen
		bsr	NyAddress

		cmp.w	#1,Exit
		beq.S	EEE
		btst	#6,$bfe001
		bne.S	MainLoop
EEE:		rts

Exit:		dc.w	0

;------------------------------------------------------------------------

CheckKeys:	btst	#10,$16(a6)
		bne.S	NoRight
		bsr	ChangeIt
NoRight:	move.b	$bfec01,d0
		cmp.b	#$37,d0
		beq.S	RaiseMod
		cmp.b	#$33,d0
		beq.S	LowerMod
		cmp.b	#$75,d0
		beq.S	RestoreInt
		rts

RestoreInt:	move.l	OldInt(pc),$6c.W
		move.w	#1,Exit
		rts

RaiseMod:	addq.w	#2,X+6
		addq.w	#2,Mulun
		add.w	#16,XV
		rts

LowerMod:	subq.w	#2,X+6
		subq.w	#2,Mulun
		sub.w	#16,XV
		rts

ChangeIt:	move.w	HiLoReg(pc),d0
		lea	X(pc),a4
		lea	Mulun(pc),a5
		bchg	#0,d0
		move.w	d0,HiLoReg
		cmp.w	#0,d0
		beq.S	MakeLo
MakeHi:		move.w	#80,(a5)
		move.w	#$9200,10(a4)
		move.w	#$fff4,6(a4)
		move.w	#640,2(a5)
		add.w	#320,-6(a5)
		move.w	#2,4(a5)
Return:		bsr	MoveScreen
Waitt:		btst	#10,$16(a6)
		beq.S	Waitt
		move.w	$dff00a,OldY
		rts

MakeLo:		move.w	#40,(a5)
		move.w	#$1200,10(a4)
		move.w	#$fffa,6(a4)
		move.w	#320,2(a5)
		move.w	#3,4(a5)
		bra.S	Return

HiLoReg:	dc.w	0
Wait:		dc.w	0

Mouse:		moveq	#0,d0
		moveq	#0,d1
		lea	NewX(pc),a3
		clr.l	(a3)
		lea	$dff00a,a0
		move.b	1(a0),d0
		move.b	(a0),d1
		sub.b	5(a3),d0
		sub.b	4(a3),d1
		ext.w	d0
		ext.w	d1
		cmp.w	#$8000,d0
		blo.S	NoD
		not.w	d0
		move.w	XV(pc),d3
		subq.w	#1,d3
		sub.w	d0,d3
		move.w	d3,d0
NoD:		move.w	d0,(a3)
		move.w	d1,2(a3)
		move.w	(a0),4(a3)
		rts

MoveScreen:	lea	NewX(pc),a5
		move.l	BMapAdr2(pc),d0
		moveq	#0,d3
		moveq	#0,d2
		move.w	(a5),d1
		move.w	2(a5),d2
		move.w	14(a5),d3
		add.w	d1,d3
		move.w	22(a5),d4
		cmp.w	d4,d3
		bls.S	NoNewY
		sub.w	d4,d3
NoNewY:		move.w	d3,14(a5)
		move.w	d4,d5
		sub.w	d3,d5
		move.w	d5,d3
		eor.w	#$ffff,d2
		addq.w	#1,d2
		move.w	d3,d4
		move.w	24(a5),d5
		lsr.w	d5,d3
		bclr	#0,d3
		and.w	#$f,d4
		eor.w	#$f,d4
		move.w	d4,X+14
		muls	20(a5),d2
		add.l	d2,d0
		add.l	d3,d0

		move.l	#$80000,d2
		cmp.l	#0,d0
		bge.S	NoD2
		add.l	d2,d0
NoD2:		cmp.l	d2,d0
		blo.S	NoD3
		sub.l	d2,d0

NoD3:		sub.l	d3,d0
		move.l	d0,10(a5)
		add.l	d3,d0
		move.l	d0,16(a5)
		lea	BMap2(pc),a0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		rts

NyAddress:	move.l	RealAddy(pc),d0
		move.l	BMapAdr(pc),d2
		add.l	#20,d2
		moveq	#40,d4
		moveq	#16,d5
		lea	Siffror,a1
		moveq	#8-1,d7
AddLoop:	rol.l	#4,d0
		move.l	d0,d1
		and.w	#$f,d1
		move.l	a1,a0
		add.w	d1,a0
		move.l	d2,a2
		moveq	#7-1,d6
MoveLoop:	move.b	(a0),(a2)
		add.w	d4,a2
		add.w	d5,a0
		dbra	d6,MoveLoop
		addq.l	#1,d2
		dbra	d7,AddLoop
		rts

NewX:		dc.w	0
NewY:		dc.w	0
OldY:		dc.b	0
OldX:		dc.b	0

BMapAdr:	dc.l	$7fa00
BMapAdr2:	dc.l	0
Xet:		dc.w	319
RealAddy:	dc.l	0
Mulun:		dc.w	40
XV:		dc.w	320
Ola:		dc.w	3

;------------------------------------------------------------------------

CopperList:	dc.l	$008e2881,$009034c1,$00920028,$009400d8
		dc.l	$01040040,$01020000,$0108fffa

		dc.l	$01001200
		dc.l	$01800000,$01820fff

BMap1:		dc.l	$00e00000,$00e20000
		dc.l	$2507fffe,$01800f00
		dc.l	$2607fffe,$01800006
		dc.l	$2f01fffe,$01000000
		dc.l	$3107fffe,$01800f00

		dc.l	$3207fffe,$01800000
X:		dc.l	$01000000,$0108fffa,$01001200,$01020000

BMap2:		dc.l	$00e00000,$00e20000

		dc.l	-2

;------------------------------------------------------------------------

BlindSpr:	dc.l	0
OldCop:		dc.l	0
OldDma:		dc.w	0
GfxName:	dc.b	'graphics.library',0
		even

Siffror:	blk.b	112,0

ss:
