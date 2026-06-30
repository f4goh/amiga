		;--------------------------------
		;-          Sinusscroll		-
		;--------------------------------

>EXTERN		'16Font',Font

org	$20000
load	$20000

Sin:		MACRO
		move.w	d0,d4
		add.w	(a0)+,d4
		move.w	(a7)+,(a1)
		move.w	d4,(a2)
		move.w	d1,(a3)
		move.w	d4,(a4)
		move.w	d2,(a5)
		ENDM

;------------------------------------------------------------------------

S:		movem.l	d0-d7/a0-a6,-(sp)
		lea.l	$dff000,a6
		bsr	Startup
		bsr	InitRutin
		bsr	StartCop
		bsr	MainLoop
		bsr	RestoreCop
		movem.l	(sp)+,d0-d7/a0-a6
		rts

Startup:	move.w	2(a6),d0
		bset	#15,d0
		move.w	d0,OldDma
		move.w	$1c(a6),d0
		bset	#15,d0
		move.w	d0,OldIrq
		move.l	$4,a6
		lea.l	Lib(pc),a1
		moveq	#0,d0
		jsr	-408(a6)
		move.l	d0,a0
		move.l	$26(a0),OldCop
		lea.l	$dff000,a6
		rts

StartCop:	move.l	#CopperList,$80(a6)
		tst.w	$88(a6)
		move.w	#$7fff,$96(a6)
		move.w	#$87c0,$96(a6)
		move.w	#$7fff,$9a(a6)
		move.w	#$c000,$9a(a6)
		rts

RestoreCop:	move.l	OldCop(pc),$80(a6)
		tst.w	$88(a6)
		move.w	OldDma(pc),$96(a6)
		move.w	OldIrq(pc),$9a(a6)
		rts

	;-----------------------------------------------------
		OldCop:		dc.l	0
		OldDma:		dc.w	0
		OldIrq:		dc.w	0
		Lib:		dc.b	'graphics.library',0
				even
	;-----------------------------------------------------

;------------------------------------------------------------------------

BlitWait:	btst	#14,2(a6)
		bne.S	BlitWait
		rts

ClearScreen:	bsr.S	BlitWait
		move.l	#-1,$44(a6)
		move.l	#$01000000,$40(a6)
		move.w	d2,$66(a6)
		move.l	d0,$54(a6)
		move.w	d1,$58(a6)
		rts

;------------------------------------------------------------------------

InitRutin:	move.l	Screen(pc),d0
		move.w	#116*64+24,d1
		moveq	#0,d2
		bsr	ClearScreen
		move.l	Screen+4(pc),d0
		bsr	ClearScreen
		move.l	#ScrollAdr,d0
		move.w	#16*64+24,d1
		bsr	ClearScreen

		move.l	#ScrollText,ScrollSave

		lea.l	SinAdr,a0
		lea.l	Sinus(pc),a1
		move.w	#300-1,d7
Loop1:		move.w	(a1)+,d0
		mulu	#48,d0
		move.w	d0,(a0)+
		dbra	d7,Loop1
		lea.l	SinAdr,a1
		move.w	#300*4,d7
Loop2:		move.w	(a1)+,(a0)+
		dbra	d7,Loop2
		rts

;------------------------------------------------------------------------

MainLoop:	cmp.b	#$80,$6(a6)
		bne.S	MainLoop

		btst	#10,$16(a6)
		beq.S	MainLoop

		move.w	$6(a6),Tid
		;move.w	#$7,$180(a6)
		bsr	SinScroll
		move.w	#0,$180(a6)
		move.w	$6(a6),Tid+2

		btst	#6,$bfe001
		bne.S	MainLoop
		rts

Tid:		dc.l	0

;------------------------------------------------------------------------

	Screen:		dc.l	$61000
			dc.l	$71000
	SinAdr:		=	$6a000
	ScrollAdr:	=	$7a000

	ScrollSave:	dc.l	0
	SinSave:	dc.l	0
	Oldie:		dc.w	0
	Reg:		dc.w	0


SinScroll:	bsr	Scrollen
		bsr	Buffra
		bsr	NewSin
		bsr	BlitSin
		rts

Buffra:		move.l	Screen(pc),d0
		move.l	Screen+4(pc),Screen
		move.l	d0,Screen+4
		addq.l	#2,d0
		lea.l	BMap(pc),a0
		sub.w	#48,d0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		add.w	#48,d0
		move.w	d0,14(a0)
		swap	d0
		move.w	d0,10(a0)
		rts

NewSin:		moveq	#0,d0
		move.w	Oldie(pc),d0
		addq.w	#3,d0
		cmp.w	#300,d0
		bls.S	NoD
		sub.w	#300,d0
NoD:		move.w	d0,Oldie
		add.w	d0,d0
		add.l	#SinAdr,d0
		move.l	d0,SinSave
		rts

BlitSin:	move.l	Screen+4(pc),d0
		move.l	SinSave(pc),a0
		move.w	#16*64+1,d2
		move.w	#34*64+1,d5
		move.l	#ScrollAdr,d1
		add.l	#44,d1
		add.l	#42,d0
		move.w	#9*48,d3
		bsr	BlitWait
		move.l	#-1,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	d0,$4c(a6)
		move.l	d0,$54(a6)
		move.l	d1,$50(a6)
		move.w	#48-2,$66(a6)
		move.w	#48-2,$62(a6)
		move.w	#48-2,$64(a6)

		lea.l	$44(a6),a1
		lea.l	$4e(a6),a2
		lea.l	$52(a6),a3
		lea.l	$56(a6),a4
		lea.l	$58(a6),a5
		lea.l	$40(a6),a6

		move.l	a7,SPSave
		lea.l	ST(pc),a7

		moveq	#21-1,d7

SLoop1:		moveq	#15-1,d6
		move.w	#$9f0,(a6)
		move.w	d0,d4
		add.w	(a0)+,d4
		sub.w	d3,d4
		move.w	(a7)+,(a1)
		move.w	d4,(a4)
		move.w	d1,d4
		sub.w	d3,d4
		move.w	d4,(a3)
		move.w	d5,(a5)
q:		btst	#14,$dff002
		bne.S	q
		move.w	#$dfc,(a6)
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		Sin
		subq.w	#2,d0
		subq.w	#2,d1
		dbra	d7,SLoop1

		lea.l	$dff000,a6
		move.l	SPSave(pc),a7
		rts

SPSave:		dc.l	0

	;-------------------------------------------

Scrollen:	cmp.w	#0,Reg
		bne.S	NoNew
		bsr	GetNew
		move.w	#16,Reg
NoNew:		bsr	ScrollIt
		subq.w	#2,Reg
		rts

GetNew:		move.l	ScrollSave(pc),a0
		moveq	#0,d0
		move.b	(a0),d0
		cmp.b	#-1,d0
		bne.S	NoRe
		move.l	#ScrollText,ScrollSave
		bra.S	GetNew
NoRe:		sub.b	#$20,d0
		add.w	d0,d0
		add.l	#Font,d0
		bsr	BlitWait
		move.l	#-1,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.w	#118-2,$64(a6)
		move.w	#48-2,$66(a6)
		move.l	d0,$50(a6)
		move.l	#ScrollAdr,d0
		add.w	#46,d0
		move.l	d0,$54(a6)
		move.w	#16*64+1,$58(a6)
		addq.l	#1,ScrollSave
		rts

ScrollIt:	bsr	BlitWait
		move.l	#-1,$44(a6)
		move.l	#ScrollAdr,d0
		add.w	#15*48+46,d0
		move.l	#$29f00002,$40(a6)
		clr.l	$64(a6)
		move.l	d0,$50(a6)
		move.l	d0,$54(a6)
		move.w	#16*64+24,$58(a6)
		rts

ScrollText:
DC.B	'AND FENOMENA IS BACK WITH A LAME SINUSSCROLL IN 135 LINES...   '
DC.B	'CODE BY MACE...   FONT BY COLOR...    SEE YA!          '
DC.B	-1
even

;------------------------------------------------------------------------

CopperList:	dc.l	$008e7266,$0090e7d6,$00920030,$009400d8
		dc.l	$01020089,$01040000,$01080004,$010a0004

		dc.l	$01800000,$01820666,$01840ccc,$01860999
BMap:		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$01002000

		dc.l	-2

;------------------------------------------------------------------------

Font:		=	$30000

Sinus:	dc.w	100,100,100,100,100,100,100,99
	dc.w	99,99,99,99,98,98,98,98
	dc.w	97,97,96,96,96,95,95,94
	dc.w	94,93,93,92,92,91,90,90
	dc.w	89,89,88,87,86,86,85,84
	dc.w	83,83,82,81,80,79,79,78
	dc.w	77,76,75,74,73,72,71,70
	dc.w	69,68,67,66,65,64,63,62
	dc.w	61,60,59,58,57,56,55,54
	dc.w	53,52,51,50,49,48,47,46
	dc.w	45,44,43,42,41,40,39,38
	dc.w	37,36,35,34,33,32,31,30
	dc.w	29,28,27,26,25,24,23,22
	dc.w	21,21,20,19,18,17,17,16
	dc.w	15,14,14,13,12,11,11,10
	dc.w	10,9,8,8,7,7,6,6
	dc.w	5,5,4,4,4,3,3,2
	dc.w	2,2,2,1,1,1,1,1
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,1,1,1
	dc.w	1,1,2,2,2,2,3,3
	dc.w	4,4,4,5,5,6,6,7
	dc.w	7,8,8,9,10,10,11,11
	dc.w	12,13,14,14,15,16,17,17
	dc.w	18,19,20,21,21,22,23,24
	dc.w	25,26,27,28,29,30,31,32
	dc.w	33,34,35,36,37,38,39,40
	dc.w	41,42,43,44,45,46,47,48
	dc.w	49,50,51,52,53,54,55,56
	dc.w	57,58,59,60,61,62,63,64
	dc.w	65,66,67,68,69,70,71,72
	dc.w	73,74,75,76,77,78,79,79
	dc.w	80,81,82,83,83,84,85,86
	dc.w	86,87,88,89,89,90,90,91
	dc.w	92,92,93,93,94,94,95,95
	dc.w	96,96,96,97,97,98,98,98
	dc.w	98,99,99,99,99,99,100,100
	dc.w	100,100,100,100

ST:
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000
dc.w 1,2,4,8,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,$4000,$8000


