;-------------------------------------------------------------------
;-                 	AFFICHE SAMPLE 			      	   -
;-------------------------------------------------------------------


execbase = 4
nb_plan = 1

	section	code,code_c
start:
save_all:
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena

;installation de la liste copper
	lea	bmap(pc),a0
	move.l	#ecran,d0
	moveq	#nb_plan-1,d1
plan_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
;copper initialise
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	bsr	mt_init
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
;dma active
	move.w	#$83c0,$96(a6)
	move.w	#$c020,$9a(a6)
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
;------------------------------------------------------------------------
menu
vbl
		cmp.b	#-1,$dff006
		bne	vbl
		bsr	display_samples

souris		btst	#6,$bfe001
		bne	vbl
		rts
;------------------------------------------------------------------------
display_samples
		lea	mt_voice1,a0
		move.l	4(a0),a1
		cmp.l	sample_sauve1,a1
		beq	meme_sample1
		move.l	a1,sample_sauve1
		clr.w	ptr_sample1
meme_sample1	bsr	affiche_sample1
		rts
sample_sauve1	dc.l	0
ptr_sample1	dc.w	0
;------------------------------------------------------------------------
affiche_sample1
		moveq	#0,d1		;x
go_sample1	move.b	(a1)+,d0	;y
		bsr	point
		addq	#1,d1
		cmp.b	#50,d1
		bne	go_sample1
		rts

point
		lea	ecran,a0
		lea	table,a2
		move.l	d1,d5		;save x
		move.l	d0,d6		;save y
		mulu	#40,d6
		lsl.l	#2,d5		;ajust offset
		move.l	(a2,d5),d5	;pour la table
		add.w	d5,d6
		add.w	d6,a0
		swap	d5
		bset	d5,(a0)
		rts
;-----------------------------------------------
table	
	dc.w	7,0,6,0,5,0,4,0,3,0,2,0,1,0,0,0
	dc.w	7,1,6,1,5,1,4,1,3,1,2,1,1,1,0,1
	dc.w	7,2,6,2,5,2,4,2,3,2,2,2,1,2,0,2
	dc.w	7,3,6,3,5,3,4,3,3,3,2,3,1,3,0,3
	dc.w	7,4,6,4,5,4,4,4,3,4,2,4,1,4,0,4
	dc.w	7,5,6,5,5,5,4,5,3,5,2,5,1,5,0,5
	dc.w	7,6,6,6,5,6,4,6,3,6,2,6,1,6,0,6
	dc.w	7,7,6,7,5,7,4,7,3,7,2,7,1,7,0,7
	dc.w	7,8,6,8,5,8,4,8,3,8,2,8,1,8,0,8
	dc.w	7,9,6,9,5,9,4,9,3,9,2,9,1,9,0,9
	dc.w	7,10,6,10,5,10,4,10,3,10,2,10,1,10,0,10
	dc.w	7,11,6,11,5,11,4,11,3,11,2,11,1,11,0,11
	dc.w	7,12,6,12,5,12,4,12,3,12,2,12,1,12,0,12
	dc.w	7,13,6,13,5,13,4,13,3,13,2,13,1,13,0,13
	dc.w	7,14,6,14,5,14,4,14,3,14,2,14,1,14,0,14
	dc.w	7,15,6,15,5,15,4,15,3,15,2,15,1,15,0,15
	dc.w	7,16,6,16,5,16,4,16,3,16,2,16,1,16,0,16
	dc.w	7,17,6,17,5,17,4,17,3,17,2,17,1,17,0,17
	dc.w	7,18,6,18,5,18,4,18,3,18,2,18,1,18,0,18
	dc.w	7,19,6,19,5,19,4,19,3,19,2,19,1,19,0,19
	dc.w	7,20,6,20,5,20,4,20,3,20,2,20,1,20,0,20
	dc.w	7,21,6,21,5,21,4,21,3,21,2,21,1,21,0,21
	dc.w	7,22,6,22,5,22,4,22,3,22,2,22,1,22,0,22
	dc.w	7,23,6,23,5,23,4,23,3,23,2,23,1,23,0,23
	dc.w	7,24,6,24,5,24,4,24,3,24,2,24,1,24,0,24
	dc.w	7,25,6,25,5,25,4,25,3,25,2,25,1,25,0,25
	dc.w	7,26,6,26,5,26,4,26,3,26,2,26,1,26,0,26
	dc.w	7,27,6,27,5,27,4,27,3,27,2,27,1,27,0,27
	dc.w	7,28,6,28,5,28,4,28,3,28,2,28,1,28,0,28
	dc.w	7,29,6,29,5,29,4,29,3,29,2,29,1,29,0,29
	dc.w	7,30,6,30,5,30,4,30,3,30,2,30,1,30,0,30
	dc.w	7,31,6,31,5,31,4,31,3,31,2,31,1,31,0,31
	dc.w	7,32,6,32,5,32,4,32,3,32,2,32,1,32,0,32
	dc.w	7,33,6,33,5,33,4,33,3,33,2,33,1,33,0,33
	dc.w	7,34,6,34,5,34,4,34,3,34,2,34,1,34,0,34
	dc.w	7,35,6,35,5,35,4,35,3,35,2,35,1,35,0,35
	dc.w	7,36,6,36,5,36,4,36,3,36,2,36,1,36,0,36
	dc.w	7,37,6,37,5,37,4,37,3,37,2,37,1,37,0,37
	dc.w	7,38,6,38,5,38,4,38,3,38,2,38,1,38,0,38
	dc.w	7,39,6,39,5,39,4,39,3,39,2,39,1,39,0,39
;---------------------------------- efface ecran
clear_surface	btst	#14,$2(a6)
		bne.s	clear_surface
		move.l	#ecran+(40*20),$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#220*64+20,$58(a6)
		rts		
;нннннннннннннннннннннннннннннннннннннн
;REPLAY
;нннннннннннннннннннннннннннннннннннннн
new:
	movem.L	a0-a5/d0-d7,-(a7)
	bsr	mt_music
	movem.L	(a7)+,a0-a5/d0-d7
	move.w	#$20,$dff09c
	rte
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
		dc.l	$01040000,$01080000,$010a0000,$01020000


bmap		dc.l	$00e00000,$00e20000

;		dc.w	$0180,$0000
		dc.w	$0182,$0fff
		dc.l	$01001200
		dc.l	-2
;------------------------------------------------------------------------
mt_data:	incbin	mod.loading
	even
;------------------------------------------------------------------------
ecran	dcb.b	40*256
end





