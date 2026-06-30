;-------------------------------------------------------------------
;-                 Un petit essai de DROITES: aiguilles            -
;-------------------------------------------------------------------

centre1x = 16
centre1y = 112
centre2x = 176
centre2y = 112
centre3x = 16
centre3y = 240
centre4x = 176
centre4y = 240

execbase = 4
nb_plan = 1
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$8000,save_intena 
;	move.w 	#$3fff,$9a(a6)
	bsr	mt_init

;installation de la 1ere liste copper
	lea	bmap(pc),a0
	move.l	#ecran,d0
	moveq	#nb_plan-1,d1
plan_suivant	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
	clr.l	$144(a6)
;dma active
	move.w	#$83c0,$96(a6)
	bsr	menu
	
restore_all
	bsr	mt_end
	move.l	execbase,a6
 	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
	move.w	save_intena,$dff09a
	lea	grname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
fin	clr.l	d0
	rts
save_dmacon:dc.w 0
save_intena:dc.w 0
grname:dc.b "graphics.library",0
	even

;------------------------------------------ Menu
menu		move.l	#$dff000,a6
vbl
;		move.l	$4(a6),d4
;		and.l	#$1ff00,d4
;		cmp.l	#$0ff00,d4
		cmp.b	#-1,$6(a6)
		bne	vbl
		bsr 	efface_aiguilles
		bsr	equa1
souris		
		btst	#6,$bfe001
		bne	vbl
		rts

;**********************************************************************
;TEST VUIMETRES
;**********************************************************************

vitessetourne=1

equa1
voix1		lea	mt_voice1+$12,a3
		cmp.w	#$0,(a3)
		bge	suite
		move.w	#$0,(a3)
suite		move.w	(a3),d2
		bsr	aiguille1		
voix2		subq.w	#vitessetourne,(a3)		;on decremente voix no 1...
		lea	mt_voice2+$12,a3
		cmp.w	#$0,(a3)
		bge	suite2
		move.w	#$0,(a3)
suite2		move.w	(a3),d2
		bsr	aiguille2
voix3		subq.w	#vitessetourne,(a3)		;on decremente voix no 2...
		lea	mt_voice3+$12,a3
		cmp.w	#$0,(a3)
		bge	suite3
		move.w	#$0,(a3)
suite3		move.w	(a3),d2
		bsr	aiguille3
voix4		subq.w	#vitessetourne,(a3)		;on decremente voix no 3...
		lea	mt_voice4+$12,a3
		cmp.w	#$0,(a3)
		bge	suite4
		move.w	#$0,(a3)
suite4		move.w	(a3),d2
		bsr	aiguille4
finvoix		subq.w	#vitessetourne,(a3)		;on decremente voix no 4...
		rts

;*************************************** aiguilles
aiguille1
		lea	ecran,a0
		lea	aigudata,a1
		lsl.w	#2,d2
		add.w	d2,a1
		moveq	#0,d2
		moveq	#0,d4
		move.l	#centre1x,d0
		move.l	#centre1y,d1
		move.l	d1,d3
		move.w	(a1)+,d2
		add.w	d0,d2
		move.w	(a1)+,d4
		sub.w	d4,d3
		bsr	drawline
		rts
aiguille2
		lea	ecran,a0
		lea	aigudata,a1
		lsl.w	#2,d2
		add.w	d2,a1
		moveq	#0,d2
		moveq	#0,d4
		move.l	#centre2x,d0
		move.l	#centre2y,d1
		move.l	d1,d3
		move.w	(a1)+,d2
		add.w	d0,d2
		move.w	(a1)+,d4
		sub.w	d4,d3
		bsr	drawline
		rts
aiguille3
		lea	ecran,a0
		lea	aigudata,a1
		lsl.w	#2,d2
		add.w	d2,a1
		moveq	#0,d2
		moveq	#0,d4
		move.l	#centre3x,d0
		move.l	#centre3y,d1
		move.l	d1,d3
		move.w	(a1)+,d2
		add.w	d0,d2
		move.w	(a1)+,d4
		sub.w	d4,d3
		bsr	drawline
		rts
aiguille4
		lea	ecran,a0
		lea	aigudata,a1
		lsl.w	#2,d2
		add.w	d2,a1
		moveq	#0,d2
		moveq	#0,d4
		move.l	#centre4x,d0
		move.l	#centre4y,d1
		move.l	d1,d3
		move.w	(a1)+,d2
		add.w	d0,d2
		move.w	(a1)+,d4
		sub.w	d4,d3
		bsr	drawline
		rts
;---------------------------------- effaceradar
efface_aiguilles
		btst	#14,$2(a6)
		bne.s	efface_aiguilles
		move.l	#ecran,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#256*64+20,$58(a6)	;a changer
		rts		
;---------------------------------- trace une ligne
drawline:	
		movem.l	d0-d7/a0-a6,-(a7)
		sub.w	d1,d3		;y2-y1 deltay dans d3
		bpl.s	lbl1		;si deltay positif
		neg.w	d3		;inversion deltay
		sub.w	d0,d2		;x2-x1 deltax dans d2	
		bpl.s	lbl8		;si deltax positif
		neg.w	d2		;inversion deltax
		cmp.w	d3,d2		;deltay-deltax
		bpl.s	lbl2		;si deltay > delta x
		moveq	#$d,d4		;octant 13
		bra.s	lbl6
lbl1		sub.w	d0,d2		;x2-x1 deltax dans d2
		bpl.s	lbl9		;si deltax positif
		neg.w	d2		;inversion deltax
		cmp.w	d3,d2		;deltay-deltax
		bpl.s	lbl3		;si deltay > deltax
		moveq	#9,d4		;octant 9
		bra.s	lbl6
lbl8		cmp.w	d3,d2		;deltay-deltax
		bpl.s	lbl5		;si deltay > deltax
		moveq	#5,d4		;octant 5
		bra.s	lbl6
lbl9		cmp.w	d3,d2		;deltay-deltax
		bpl.s	lbl4		;si deltay > deltax
		moveq	#1,d4		;octant 1
		bra.s	lbl6
lbl2		moveq	#$1d,d4		;octant 29
		bra.s	lbl7
lbl3		moveq	#$15,d4		;octant 21
		bra.s	lbl7
lbl4		moveq	#$11,d4		;octant 17
		bra.s	lbl7
lbl5		moveq	#$19,d4		;octant 25
		bra.s	lbl7
lbl6		exg	d2,d3		;delta < dans d2
lbl7		move.w	d2,d5		;on prepare bltsize
		addq.w	#1,d5		;longeur
		asl.w	#6,d5		;*64
		addq.w	#2,d5		;+largeur
		move.w	d0,d6		;x dans d6
		lsr.w	#3,d0		;pour avoir des octet
		mulu	#$28,d1		;y*40 octets par ligne
		add.w	d1,d0		;x+y
		adda.w	d0,a0		;on ajoute a l'add du plan
		add.w	d3,d3		;petit delta*2
		move.w	d3,d7
		cmp.w	d2,d7		;2*pdelta-gdelta
		bpl.s	lbl10		;si pdelta > gdelta
		bset	#6,d4
		sub.w	d2,d7		;2*pdelta-gdelta
		sub.w	d2,d7		;2*pdelta-2*gdelta
w_trace		btst	#14,$2(a6)
		bne.s	w_trace
		move.w	d7,$dff052	;bltaptl
		add.w	d7,d7		;*2
		move.w	d7,$dff064	;mod a
		bra.s	lbl11
lbl10		btst	#14,$2(a6)
		bne.s	lbl10
		move.w	d7,$dff052
		sub.w	d2,d7
		sub.w	d2,d7
		add.w	d7,d7
		move.w	d7,$dff064

lbl11		add.w	d3,d3		;2*pdelta*2
		move.w	d3,$dff062	;mod b
		ror.w	#4,d6		;vers start0-3
		andi.w	#$f000,d6
		ori.w	#$bfa,d6	;init usex et lfx
		move.w	#$28,$dff060	;mod c
		move.l	#$ffffffff,$dff044	;mask
		move.w	#$8000,$dff074	;bltadat
		move.w	d6,$dff040	;bltcon0
		move.w	d4,$dff042	;bltcon2
		move.l	a0,$dff048	;bltcpth
		move.l	a0,$dff054	;bltdpth
		move.w	d5,$dff058	;bltsize
		movem.l	(a7)+,d0-d7/a0-a6
		rts
;---------------------------------- soundtrack
new:
	movem.L	a0-a6/d0-d7,-(a7)
	bsr	mt_music
	movem.L	(a7)+,a0-a6/d0-d7
;	move.w	#$20,$9c(a6)		;a tester ok bernard
;	rte
lev3save:
	jmp	$0

mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	move.l	$6c,lev3save+2
	move.l	#new,$6c
	rts

mt_end:	move.l	lev3save+2,$6c
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	move.b	mt_data+$3b7,mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	cmp.b	#$1f,$3(a6)
	ble.s	mt_sets
	move.b	#$1f,$3(a6)
mt_sets:move.b	$3(a6),d0
	beq.s	mt_rts2
	move.b	d0,mt_speed
	clr.b	mt_counter
mt_rts2:rts

mt_sin:
 DC.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 DC.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 DC.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 DC.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 DC.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 DC.w $007f,$0078,$0071,$0000,$0000

mt_speed:	DC.b	6
mt_songpos:	DC.b	0
mt_pattpos:	DC.w	0
mt_counter:	DC.b	0

mt_break:	DC.b	0
mt_dmacon:	DC.w	0
mt_samplestarts:DS.L	$1f
mt_voice1:	DS.w	10
		DC.w	1
		DS.w	3
mt_voice2:	DS.w	10
		DC.w	2
		DS.w	3
mt_voice3:	DS.w	10
		DC.w	4
		DS.w	3
mt_voice4:	DS.w	10
		DC.w	8
		DS.w	3
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
;,$00e40000,$00e60000
;		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
;		dc.l	$00f00000,$00f20000
		dc.l	$01001200
		dc.w	$180,$000
		dc.w	$182
coul2		dc.w	$fff
		
		dc.l	-2
;------------------------------------------------------------------------
mt_data		incbin	tools/mod.reflex2
aigudata:	incbin	tools/aigu.b
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan
	even
end








