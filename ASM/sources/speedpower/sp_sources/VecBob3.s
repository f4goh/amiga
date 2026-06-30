;------------------------------------------------------------------------
;-									-
;-			     Vector-Stars				-
;-									-
;------------------------------------------------------------------------

org	$20000
load	$20000

>EXTERN		'Perspektiv',Per
>EXTERN		'VectorBob.RB',Bob

;------------------------------------------------------------------------

S:		movem.l	d0-d7/a0-a6,-(sp)
		lea.l	$dff000,a6
		bsr	Startup
		bsr	InitRutin
		bsr	BlitWait
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
		move.w	#280*2*64+24,d1
		moveq	#0,d2
		bsr	ClearScreen
		move.l	Screen+4(pc),d0
		bsr	ClearScreen

		lea.l	Cols+2(pc),a0
		lea.l	Bob,a1
		moveq	#8-1,d7
CLoop:		move.w	(a1)+,(a0)
		addq.l	#4,a0
		dbra	d7,CLoop
		move.l	a1,BobAdr

		lea.l	MulsList,a0
		moveq	#0,d0
		move.w	#300-1,d7
MulsLoop:	move.w	d0,(a0)+
		add.w	#44*3,d0
		dbra	d7,MulsLoop
		moveq	#0,d0
		move.w	#300,d7
AndLoop:	move.w	d0,d1
		move.w	d1,d2
		lsr.w	#3,d1
		and.w	#$f,d2
		ror.w	#4,d2
		move.w	d1,(a0)+
		move.w	d2,(a0)+
		addq.w	#1,d0
		dbf	d7,AndLoop

		move.l	#BobAdress,d0
		move.l	#MaskAdr,d1
		move.l	BobAdr(pc),d2
		move.l	d2,d3
		add.l	#15*2*3,d3
		bsr.L	BlitWait
		move.l	#-1,$44(a6)
		clr.l	$64(a6)
		move.l	#$09f00000,$40(a6)
		move.w	#150-1,d7
BobLoop1:	btst	#14,$2(a6)
		bne.S	BobLoop1
		move.l	d0,$54(a6)
		move.l	d2,$50(a6)
		move.w	#15*64*3+1,$58(a6)
		add.l	#15*2*3,d0
		dbf	d7,BobLoop1
		move.w	#150-1,d7
BobLoop2:	btst	#14,$2(a6)
		bne.S	BobLoop2
		move.l	d1,$54(a6)
		move.l	d3,$50(a6)
		move.w	#15*64*3+1,$58(a6)
		add.l	#15*2*3,d1
		dbf	d7,BobLoop2
		lea	MainList(pc),a1
		moveq	#0,d0
		move.w	#300-1,d7
CLLoop:		move.l	a1,(a1)+
		move.l	d0,(a1)+
		dbra	d7,CLLoop
		rts

MulsList:	=	$6d000
BobAdress:	=	$67000
MaskAdr:	=	$77000

;------------------------------------------------------------------------

MainLoop:	cmp.b	#-1,$6(a6)
		bne.S	MainLoop

		move.w	#$4,$180(a6)
		bsr	VectorBobs
		move.w	#$40,$180(a6)

		btst	#6,$bfe001
		bne.S	MainLoop
		rts

;------------------------------------------------------------------------

Vectorbobs:	bsr	Buffra
		bsr	Rensa
		bsr	VinkelAdd
		;move.w	#$060,$180(a6)
		bsr	Rakna
		;move.w	#$006,$180(a6)
		bsr	Sortera
		;move.w	#$600,$180(a6)
		bsr	Plotta
		;move.w	#$060,$180(a6)
		rts

Sortera:	lea	Posses+4(pc),a0
		lea	ExtraList(pc),a2
		lea	MainList+[300*8+4](pc),a1
		moveq	#0,d0
		move.w	#300,d4
		move.w	AntBobs(pc),d7
SortLoop:	move.w	(a0),d0
		lsl.w	#3,d0
		move.l	a1,a3
		sub.l	d0,a3
		tst.w	(a3)
		bne.S	UseExtra
		move.l	-4(a0),(a3)
		addq.l	#6,a0
		dbra	d7,SortLoop
		rts
UseExtra:	move.l	-4(a3),(a2)
		move.l	a2,-4(a3)
		move.l	-4(a0),4(a2)
		addq.l	#8,a2
		addq.l	#6,a0
		dbra	d7,SortLoop
		rts

Buffra:		move.l	Screen(pc),d0
		move.l	Screen+4(pc),Screen
		move.l	d0,Screen+4
		lea.l	BMap(pc),a0
		moveq	#3-1,d7
BMapLoop:	swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0
		add.l	#44,d0
		dbra	d7,BMapLoop
		rts

Rensa:		move.l	Screen(pc),d0
		moveq	#44-40,d2
		move.w	#200*64*3+20,d1
		bsr	ClearScreen
		rts

VinkelAdd:	lea.l	Vinklar(pc),a0
		lea.l	VAdds(pc),a1
		move.w	#720,d1
		moveq	#3-1,d7
VAddLoop:	move.w	(a0),d0
		add.w	(a1)+,d0
		cmp.w	d1,d0
		bls.S	Nothing
		sub.w	d1,d0
Nothing:	move.w	d0,(a0)+
		dbra	d7,VAddLoop
		rts

Rakna:		lea.l	Sinus+180(pc),a1
		lea.l	Sinus(pc),a2
		lea.l	Vinklar(pc),a3
		lea.l	Posses(pc),a4
		lea.l	Per,a5

		lea.l	CalcUp(pc),a6
		move.w	(a3),d0
		move.w	(a1,d0.W),(a6)+
		move.w	(a2,d0.W),(a6)+
		move.w	4(a3),d0
		move.w	(a1,d0.W),(a6)+
		move.w	(a2,d0.W),(a6)+
		move.w	2(a3),d0
		move.w	(a1,d0.W),(a6)+
		move.w	(a2,d0.W),(a6)+

		lea.l	CalcUp(pc),a1
		lea.l	MulsList,a6
		move.l	a7,SPSave
		lea.l	ObjX(pc),a0
		lea.l	ObjY(pc),a2
		lea.l	ObjZ(pc),a7
		move.w	AntBobs,d7

RakneLoop:	move.w	(a1)+,d1
		move.w	(a1)+,d2
		move.w	(a2),d3
		muls	d2,d3
		move.w	(a7),d4
		muls	d1,d4
		sub.l	d4,d3
		lsl.l	#2,d3
		swap	d3		;Y
		muls	(a2)+,d1
		muls	(a7)+,d2
		add.l	d1,d2
		lsl.l	#2,d2
		swap	d2		;Z

		move.w	(a1)+,d1
		move.w	(a1)+,d4
		move.w	(a0),d5
		muls	d4,d5
		move.w	d3,d6
		muls	d1,d6
		sub.l	d6,d5
		lsl.l	#2,d5
		swap	d5		;X
		muls	(a0)+,d1
		muls	d4,d3
		add.l	d1,d3
		lsl.l	#2,d3
		swap	d3		;Y

		move.w	(a1)+,d1
		move.w	(a1)+,d4
		move.w	d5,d0
		muls	d4,d0
		move.w	d2,d6
		muls	d1,d6
		sub.l	d6,d0
		lsl.l	#2,d0
		swap	d0		;X
		muls	d1,d5
		muls	d4,d2
		add.l	d5,d2
		lsl.l	#2,d2
		swap	d2		;Z

		add.w	(a1)+,d2
		add.w	d2,d2
		move.w	(a5,d2.W),d4
		lsr.w	#1,d2
		muls	d4,d0
		muls	d4,d3
		moveq	#5,d6
		lsl.l	d6,d0
		lsl.l	d6,d3
		swap	d0
		swap	d3
		add.w	(a1)+,d0
		add.w	(a1)+,d3
		add.w	d3,d3
		move.w	(a6,d3.W),d3
		lsl.w	#2,d0
		add.w	(a6,d0.W),d3
		move.w	d3,(a4)+
		move.w	2(a6,d0.W),(a4)+
		move.w	d2,(a4)+
		lea	-18(a1),a1
		dbra	d7,RakneLoop

		lea.l	$dff000,a6
		move.l	SPSave(pc),a7
		rts

SPSave:		dc.l	0

Plotta:		lea	MainList+4(pc),a0
		move.l	Screen(pc),d0
		move.w	#15*64*3+2,d4
		move.w	#$fca,d6

		bsr	BlitWait
		move.l	#$ffff0000,$44(a6)
		move.w	#2-4,$62(a6)
		move.w	#2-4,$64(a6)
		move.w	#44-4,$60(a6)
		move.w	#44-4,$66(a6)
		move.l	d0,$48(a6)
		move.l	d0,$54(a6)
		move.l	#BobAdress,$4c(a6)
		move.l	#MaskAdr,$50(a6)

		lea.l	$40(a6),a1
		lea.l	$42(a6),a3
		lea.l	$4a(a6),a2
		lea.l	$56(a6),a5
		lea	ExtraList(pc),a6
		move.l	a7,SPSave
		move.l	a0,a7

		move.w	#300-1,d7

PlotLoop:	tst.w	(a0)
		beq.S	NoBobby
		subq.l	#4,a0
		move.l	a0,a7
JumpIn:		move.w	4(a0),d3
		move.w	6(a0),d5
		move.w	d5,(a3)
		add.w	d6,d5
		move.w	d5,(a1)
		move.w	d3,(a2)
		movem.w	d3-d4,(a5)
		clr.l	4(a0)
		cmp.l	(a0),a7
		beq.S	NoBobby2
		move.l	(a0),a0
		bra.S	JumpIn
NoBobby2:	move.l	a7,a0
		move.l	a0,(a0)
		addq.l	#4,a0
NoBobby:	addq.l	#8,a0
		dbra	d7,PlotLoop
		lea.l	$dff000,a6
		move.l	SPSave(pc),a7
		rts

	;--------------------------------------------------

		Screen:		dc.l	$60000
				dc.l	$70000

		BMapSize:	=	280*44

		Posses:		blk.w	400*3,0
		MainList:	blk.l	300*2,0
		ExtraList:	blk.l	300*2,0
		CalcUp:		blk.w	3*2,0
				dc.w	150,326,100
		BobAdr:		dc.l	0

		Vinklar:	dc.w	0
				dc.w	0
				dc.w	0

		VAdds:		dc.w	4
				dc.w	6
				dc.w	8

	;--------------------------------------------------

ObjX:
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90
dc.w	-90,-70,-50,-30,-10,10,30,50,70,90

ObjY:
blk.w	10,-90
blk.w	10,-70
blk.w	10,-50
blk.w	10,-30
blk.w	10,-10
blk.w	10,10
blk.w	10,30
blk.w	10,50
blk.w	10,70
blk.w	10,90
blk.w	10,0

ObjZ:
blk.w	10,-33
blk.w	10,-20
blk.w	10,-10
blk.w	10,-5
blk.w	10,0
blk.w	10,-5
blk.w	10,-10
blk.w	10,-20
blk.w	10,-33
blk.w	10,-50
blk.w	10,-70

AntBobs:	dc.w	110-1

;------------------------------------------------------------------------

CopperList:	dc.l	$008e4866,$009010c6,$00920030,$009400d8
		dc.l	$01020000,$01040000,$01080058,$010a0058

Cols:		dc.l	$01800000,$01820000,$01840000,$01860000
		dc.l	$01880000,$018a0000,$018c0000,$018e0000
BMap:		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$01003000

		dc.l	-2

;------------------------------------------------------------------------

Per:		=	$30000
Bob:		=	$33000

Sinus:	dc.w	16384,16382,16374,16362,16344,16322,16294,16262
	dc.w	16225,16182,16135,16083,16026,15964,15897,15826
	dc.w	15749,15668,15582,15491,15396,15296,15191,15082
	dc.w	14967,14849,14726,14598,14466,14330,14189,14044
	dc.w	13894,13741,13583,13421,13255,13085,12911,12733
	dc.w	12551,12365,12176,11982,11786,11585,11381,11174
	dc.w	10963,10749,10531,10311,10087,9860,9630,9397
	dc.w	9162,8923,8682,8438,8192,7943,7692,7438
	dc.w	7182,6924,6664,6401,6137,5871,5603,5334
	dc.w	5063,4790,4516,4240,3963,3685,3406,3126
	dc.w	2845,2563,2280,1996,1712,1427,1142,857
	dc.w	571,285,0,-285,-571,-857,-1142,-1428
	dc.w	-1712,-1996,-2280,-2563,-2845,-3126,-3406,-3685
	dc.w	-3963,-4240,-4516,-4790,-5063,-5334,-5603,-5871
	dc.w	-6137,-6401,-6664,-6924,-7182,-7438,-7692,-7943
	dc.w	-8192,-8438,-8682,-8923,-9162,-9397,-9630,-9860
	dc.w	-10087,-10311,-10531,-10749,-10963,-11174,-11381,-11585
	dc.w	-11786,-11982,-12176,-12365,-12551,-12733,-12911,-13085
	dc.w	-13255,-13421,-13583,-13741,-13894,-14044,-14189,-14330
	dc.w	-14466,-14598,-14726,-14849,-14967,-15082,-15191,-15296
	dc.w	-15396,-15491,-15582,-15668,-15749,-15826,-15897,-15964
	dc.w	-16026,-16083,-16135,-16182,-16225,-16262,-16294,-16322
	dc.w	-16344,-16362,-16374,-16382,-16384,-16382,-16374,-16362
	dc.w	-16344,-16322,-16294,-16262,-16225,-16182,-16135,-16083
	dc.w	-16026,-15964,-15897,-15826,-15749,-15668,-15582,-15491
	dc.w	-15396,-15296,-15191,-15082,-14968,-14849,-14726,-14598
	dc.w	-14466,-14330,-14189,-14044,-13894,-13741,-13583,-13421
	dc.w	-13255,-13085,-12911,-12733,-12551,-12365,-12176,-11982
	dc.w	-11786,-11585,-11381,-11174,-10963,-10749,-10531,-10311
	dc.w	-10087,-9860,-9630,-9397,-9162,-8923,-8682,-8438
	dc.w	-8192,-7943,-7692,-7438,-7182,-6924,-6664,-6402
	dc.w	-6137,-5871,-5604,-5334,-5063,-4790,-4516,-4240
	dc.w	-3963,-3685,-3406,-3126,-2845,-2563,-2280,-1996
	dc.w	-1712,-1428,-1143,-857,-572,-286,0,285
	dc.w	571,857,1142,1427,1712,1996,2280,2562
	dc.w	2844,3126,3406,3685,3963,4240,4515,4790
	dc.w	5062,5334,5603,5871,6137,6401,6663,6924
	dc.w	7182,7438,7691,7943,8192,8438,8682,8923
	dc.w	9161,9397,9630,9860,10087,10310,10531,10748
	dc.w	10963,11173,11381,11585,11785,11982,12175,12365
	dc.w	12551,12732,12910,13085,13255,13421,13583,13740
	dc.w	13894,14044,14189,14330,14466,14598,14726,14849
	dc.w	14967,15081,15191,15296,15396,15491,15582,15668
	dc.w	15749,15826,15897,15964,16026,16083,16135,16182
	dc.w	16224,16262,16294,16322,16344,16361,16374,16382

	dc.w	16384,16382,16374,16362,16344,16322,16294,16262
	dc.w	16225,16182,16135,16083,16026,15964,15897,15826
	dc.w	15749,15668,15582,15491,15396,15296,15191,15082
	dc.w	14967,14849,14726,14598,14466,14330,14189,14044
	dc.w	13894,13741,13583,13421,13255,13085,12911,12733
	dc.w	12551,12365,12176,11982,11786,11585,11381,11174
	dc.w	10963,10749,10531,10311,10087,9860,9630,9397
	dc.w	9162,8923,8682,8438,8192,7943,7692,7438
	dc.w	7182,6924,6664,6401,6137,5871,5603,5334
	dc.w	5063,4790,4516,4240,3963,3685,3406,3126
	dc.w	2845,2563,2280,1996,1712,1427,1142,857
	dc.w	571,285,0,-285,-571,-857,-1142,-1428
	dc.w	-1712,-1996,-2280,-2563,-2845,-3126,-3406,-3685
	dc.w	-3963,-4240,-4516,-4790,-5063,-5334,-5603,-5871
	dc.w	-6137,-6401,-6664,-6924,-7182,-7438,-7692,-7943
	dc.w	-8192,-8438,-8682,-8923,-9162,-9397,-9630,-9860
	dc.w	-10087,-10311,-10531,-10749,-10963,-11174,-11381,-11585
	dc.w	-11786,-11982,-12176,-12365,-12551,-12733,-12911,-13085
	dc.w	-13255,-13421,-13583,-13741,-13894,-14044,-14189,-14330
	dc.w	-14466,-14598,-14726,-14849,-14967,-15082,-15191,-15296
	dc.w	-15396,-15491,-15582,-15668,-15749,-15826,-15897,-15964
	dc.w	-16026,-16083,-16135,-16182,-16225,-16262,-16294,-16322
	dc.w	-16344,-16362,-16374,-16382,-16384,-16382,-16374,-16362
	dc.w	-16344,-16322,-16294,-16262,-16225,-16182,-16135,-16083
	dc.w	-16026,-15964,-15897,-15826,-15749,-15668,-15582,-15491
	dc.w	-15396,-15296,-15191,-15082,-14968,-14849,-14726,-14598
	dc.w	-14466,-14330,-14189,-14044,-13894,-13741,-13583,-13421
	dc.w	-13255,-13085,-12911,-12733,-12551,-12365,-12176,-11982
	dc.w	-11786,-11585,-11381,-11174,-10963,-10749,-10531,-10311
	dc.w	-10087,-9860,-9630,-9397,-9162,-8923,-8682,-8438
	dc.w	-8192,-7943,-7692,-7438,-7182,-6924,-6664,-6402
	dc.w	-6137,-5871,-5604,-5334,-5063,-4790,-4516,-4240
	dc.w	-3963,-3685,-3406,-3126,-2845,-2563,-2280,-1996
	dc.w	-1712,-1428,-1143,-857,-572,-286,0,285
	dc.w	571,857,1142,1427,1712,1996,2280,2562
	dc.w	2844,3126,3406,3685,3963,4240,4515,4790
	dc.w	5062,5334,5603,5871,6137,6401,6663,6924
	dc.w	7182,7438,7691,7943,8192,8438,8682,8923
	dc.w	9161,9397,9630,9860,10087,10310,10531,10748
	dc.w	10963,11173,11381,11585,11785,11982,12175,12365
	dc.w	12551,12732,12910,13085,13255,13421,13583,13740
	dc.w	13894,14044,14189,14330,14466,14598,14726,14849
	dc.w	14967,15081,15191,15296,15396,15491,15582,15668
	dc.w	15749,15826,15897,15964,16026,16083,16135,16182
	dc.w	16224,16262,16294,16322,16344,16361,16374,16382



