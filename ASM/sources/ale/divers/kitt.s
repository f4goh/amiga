;-------------------------------------------------------------------
;-                 Le Chevalier Solitaire  : K 2000       	   -
;-------------------------------------------------------------------


execbase = 4
nb_plan = 1
nb_sprite = 1
hauteur = 25
pos1 = $2b+$2c
pos2 = $2b+$2c+$2c
pos3 = $2b+$2c+$2c+$2c
pos4 = $2b+$2c+$2c+$2c+$2c
nb_carres = 11
pause_k2000=0		;en vbl

	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena

;installation de la liste copper
install_copper
		lea	copper,a0
		move.l	#$01800000,(a0)+
		move.l	#pos1,d0
		move.l	#hauteur,d1
		add.w	d0,d1
		bsr	inst_kitt1
		move.l	#pos2,d0
		move.l	#hauteur,d1
		add.w	d0,d1
		bsr	inst_kitt1
		move.l	#pos3,d0
		move.l	#hauteur,d1
		add.w	d0,d1
		bsr	inst_kitt1
		move.l	#pos4,d0
		move.l	#hauteur-2,d1
		add.b	d0,d1
		bsr	inst_kitt1
		move.l	#-2,(a0)
		bra	suite

inst_kitt1	
		addq	#1,d0
		move.l	#12-1,d3
		move.l	#$39,d2
raster_kitt1	move.b	d0,(a0)+
		move.b	d2,(a0)+
		move.w	#$fffe,(a0)+		
;		move.l	#$01800000,(a0)+
		move.w	#$0180,(a0)+
		move.w	d2,(a0)+
		add.b	#$10,d2
		dbf	d3,raster_kitt1
		cmp.b	d1,d0
		bne	inst_kitt1
		move.l	#$01800000,(a0)+
		rts

suite		bsr	plans_logo

;copper initialise
	move.w	#$7fff,$96(a6)
;	move.w	#$7fff,$9a(a6)
;	bsr	mt_init
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
;dma active
	move.w	#$83e0,$96(a6)	;c
	bsr	menu
	
restore_all
;	bsr	mt_end
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
;-------------------------------- pour les 4 plans logo
plans_logo
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
	rts
;-------------------------------- pour les sprites
plans_sprites
	lea	bmapsprite(pc),a0
	move.l	#sprite,d0
	moveq	#nb_sprite-1,d1
sprite_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40,d0		;4m*8l+8
	addq.l	#8,a0
	dbf	d1,sprite_suivant
	rts
;------------------------------------------------------------------------
menu
vbl
		cmp.b	#-1,$dff006
		bne	vbl
;		btst	#10,$dff016
;		bne	vbl
		bsr	kitt
souris		btst	#6,$bfe001
		bne	vbl
		rts
;---------------------------------- k dos mil
kitt
		cmp.w	#0,pause_k2000bis
		beq	fait_k2000
		sub.w	#1,pause_k2000bis
		rts
fait_k2000
		move.w	#pause_k2000,pause_k2000bis
		move.l	ptr_table1,a2
		cmp.w	#-1,(a2)
		bne	no_reset1
		move.l	#table_couleurs,a2
		move.l	a2,ptr_table1
no_reset1	lea	copper,a0
		add.w	#10,a0
		bsr	scanner
		move.l	a1,ptr_table1
		move.l	ptr_table2,a2
		cmp.w	#-1,(a2)
		bne	no_reset2
		move.l	#table_couleurs,a2
		move.l	a2,ptr_table2
no_reset2	add.l	#4,a0
		bsr	scanner
		move.l	a1,ptr_table2
		move.l	ptr_table3,a2
		cmp.w	#-1,(a2)
		bne	no_reset3
		move.l	#table_couleurs,a2
		move.l	a2,ptr_table3
no_reset3	add.l	#4,a0
		bsr	scanner
		move.l	a1,ptr_table3
		move.l	ptr_table4,a2
		cmp.w	#-1,(a2)
		bne	no_reset4
		move.l	#table_couleurs,a2
		move.l	a2,ptr_table4
no_reset4	add.l	#4,a0
		bsr	scanner
		move.l	a1,ptr_table4
		rts

scanner		move.l	#hauteur-1,d1
fill_vert	move.l	#nb_carres-1,d0
		move.l	a2,a1
fill_ligne	move.w	(a1)+,(a0)
		add.w	#8,a0
		dbf	d0,fill_ligne
		add.w	#8,a0
		dbf	d1,fill_vert
		rts
;---------------------------------- pour pas changer	;21 lignes
table_couleurs
	dc.w	$f00,$e00,$d00,$c00,$b00,$a00,$900,$800,$700,$600,$500
	dc.w	$e00,$f00,$c00,$b00,$a00,$900,$800,$700,$600,$500,$400
	dc.w	$d00,$e00,$f00,$a00,$900,$800,$700,$600,$500,$400,$300
	dc.w	$c00,$d00,$e00,$f00,$800,$700,$600,$500,$400,$300,$200
	dc.w	$b00,$c00,$d00,$e00,$f00,$600,$500,$400,$300,$200,$100
	dc.w	$a00,$b00,$c00,$d00,$e00,$f00,$400,$300,$200,$100,$000
	dc.w	$900,$a00,$b00,$c00,$d00,$e00,$f00,$200,$100,$000,$000
	dc.w	$800,$900,$a00,$b00,$c00,$d00,$e00,$f00,$000,$000,$000
	dc.w	$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00,$000,$000
	dc.w	$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00,$000
	dc.w	$500,$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
	dc.w	$400,$500,$600,$700,$800,$900,$a00,$b00,$c00,$f00,$e00
	dc.w	$300,$400,$500,$600,$700,$800,$900,$a00,$f00,$e00,$d00
	dc.w	$200,$300,$400,$500,$600,$700,$800,$f00,$e00,$d00,$c00
	dc.w	$100,$200,$300,$400,$500,$600,$f00,$e00,$d00,$c00,$b00
	dc.w	$000,$100,$200,$300,$400,$f00,$e00,$d00,$c00,$b00,$a00
	dc.w	$000,$000,$100,$200,$f00,$e00,$d00,$c00,$b00,$a00,$900
	dc.w	$000,$000,$000,$f00,$e00,$d00,$c00,$b00,$a00,$900,$800
	dc.w	$000,$000,$f00,$e00,$d00,$c00,$b00,$a00,$900,$800,$700
	dc.w	$000,$f00,$e00,$d00,$c00,$b00,$a00,$900,$800,$700,$600
	dc.w	-1
ptr_table1	dc.l	table_couleurs
ptr_table2	dc.l	table_couleurs+(11*2*4)
ptr_table3	dc.l	table_couleurs+(11*2*8)
ptr_table4	dc.l	table_couleurs+(11*2*12)
pause_k2000bis
	dc.w	pause_k2000
;---------------------------------- pourquoi pas
		move.l	a1,$54(a6)		;dest
		move.l	a0,$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000020,$64(a6)
		move.w	#256*64+4,$58(a6)

efface_lettre	btst	#14,$2(a6)
		bne.s	efface_lettre
		move.l	#spchar,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#16*64+2,$58(a6)
		rts		
;нннннннннннннннннннннннннннннннннннннн
;REPLAY
;нннннннннннннннннннннннннннннннннннннн
new:
	movem.L	a0-a5/d0-d7,-(a7)
;	bsr	mt_music
fin_new2
	movem.L	(a7)+,a0-a5/d0-d7
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
;******************************************************
sprite
	dc.w	$1d40,$2f02	;1d+273=12f
	dc.w	0,0,0,0
spchar	dcb.w	(255+16)*2	;lignes + lettre
spsce	dc.w	0,0
spdest	dc.w	0,0
	dc.w	0,0
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01040024,$01080000,$010a0000	;spr & modulos
bmapsprite	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$1a2,$fff	;001	
		dc.w	$1a4,$aaa	;010
		dc.w	$1a6,$888	;011
		dc.w	$1a8,$777	;100


bmap		dc.l	$00e00000,$00e20000
;		dc.l	$00e40000,$00e60000
;		dc.l	$00e80000,$00ea0000
;		dc.l	$00ec0000,$00ee0000


		dc.l	$01001200		;bitplane active
copper		dcb.w	10000
;------------------------------------------------------------------------
mt_data:	;incbin	mod.musique
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan
end



