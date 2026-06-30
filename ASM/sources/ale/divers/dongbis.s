;-------------------------------------------------------------------
;-                 Un petit essai de Copper : DONG-DONG  	   -
;-------------------------------------------------------------------

execbase = 4
nb_plan = 4
l1=$ff0
l2=$ff0
l3=$fff
l4=$0ff
l5=$0ff
vit_rebond=10
deb_dong=$0
nb_mot=4
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon

	bsr	mt_init
	clr.b	$bfde00
	move.b	#$82,$bfd400
	move.b	#$37,$bfd500
	move.b	#$81,$bfdd00
	move.b	#$11,$bfde00
	move.l	$78,oldirq
	move.l	#new,$78	

;installation de la 1ere liste copper
	bsr	install_copper_jeu
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
;dma active
	move.w	#$83c0,$96(a6)
	bsr	menu
	
restore_all
	move.l	execbase,a6
 	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
	lea	grname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
fin	clr.l	d0
	move.l	oldirq,$78
	bsr	mt_end
	rts
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even

;------------------------------------------------------------------------
new:
	movem.L	a0-a6/d0-d7,-(a7)
	bsr	mt_music
	move.b	$bfdd00,d0
	movem.L	(a7)+,a0-a6/d0-d7
	move.w	#$2000,$dff09c
	rte
oldirq:dc.l 0

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
	rts

mt_end:	clr.w	$dff0a8
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
	clr.b	mt_songpos
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
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0
;------------------------------------------------------------------------
;installation des coppers listes
install_copper_jeu
		lea	copper_dong,a0
		move.l	#$01800000,(a0)+
		move.l	#deb_dong,d0
inst_cop_dong	move.b	d0,(a0)+
		move.b	#$31,(a0)+
		move.w	#$fffe,(a0)+
		move.l	#46-1,d1
cop_moves	move.l	#$01800000,(a0)+
		dbf	d1,cop_moves						
		addq.l	#1,d0
		cmp.b	#deb_dong+$28,d0
		bne	inst_cop_dong
		move.l	#$01800000,(a0)+
		move.l	#-2,(a0)

init_coul	lea	copper_dong,a0
		lea	couls_dong,a1
		move.l	#46-1,d1
		move.l	#(8*5)-1,d2
		add.l	#6,a0		
met_coul	add.l	#4,a0
		move.l	#46-1,d1
col_moves	move.w	(a1),(a0)
		add.l	#4,a0
		dbf	d1,col_moves
		addq.l	#2,a1
		dbf	d2,met_coul
		rts
;------------------------------------------------------------------------
couls_dong:
		dc.w	$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f
		dc.w	$f,$10f,$20f,$30f,$40f,$50f,$60f,$70f,$80f
		dc.w	$90f,$a0f,$b0f,$c0f,$d0f,$e0f,$f0f
		dc.w	$e0e,$c0c,$a0a,$808,$606,$404,$202,$0
;------------------------------------------------------------------------
menu		clr.w	up_down
		clr.w	count_mot
		bsr	d2_anim	
vbl		cmp.b	#-1,$dff006
		bne	vbl
		bsr	rebond
;		bsr	flash_smile
;		bsr	equalizer
				
souris		
		btst	#6,$bfe001
		bne	vbl
		rts
;---------------------------------- d2-anim
d2_anim
		move.l	#nb_plan-1,d0
		move.l	#40*256,d1
		move.l	#40*72,d2
		lea	d2raw,a0
		lea	ecran,a1
					
d2_wait		btst	#14,$2(a6)
		bne.s	d2_wait
		move.l	a1,$54(a6)
		move.l	a0,$50(a6)
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#72*64+20,$58(a6)
		add.l	d2,a0
		add.l	d1,a1
		dbf	d0,d2_wait
		rts
;---------------------------------- flash_smile
flash_smile
		move.l	#$dff000,a6
		move.w	strob_smile,d0
		cmp.w	#28,d0
		beq	light_smile

clear_smile	btst	#14,$2(a6)
		bne.s	clear_smile

		move.l	#ecran+(40*(256+0))+12,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0018,$66(a6)
		move.w	#128*64+8,$58(a6)
		rts		
light_smile	btst	#14,$2(a6)
		bne.s	light_smile
		move.l	#ecran+(40*(256+0))+12,$54(a6)
		move.l	#smiles,$50(a6)
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000018,$64(a6)
		move.w	#128*64+8,$58(a6)
		move.w	#$ff0,l_smil1
		move.w	#$ff0,l_smil2
		rts
;---------------------------------- equaliseur par traits 32 oct(max)
;-------- il faut effacer les equas au blitter
nb_valeurs=4
equa_space=40*10
equa_space_start=40*150

equalizer
		lea	table_valeurs,a1
		lea	mt_voice2+18(pc),a0
		subq.w	#4,(a0)
		ble	pas_son1
		move.w	(a0),(a1)+
		bra	level1
pas_son1	move.w	#0,(a0)
level1		lea	mt_voice2+18(pc),a0
		subq.w	#4,(a0)
		ble	pas_son2
		move.w	(a0),(a1)+
		bra	level2
pas_son2	move.w	#0,(a0)
level2		lea	mt_voice3+18(pc),a0
		subq.w	#4,(a0)
		ble	pas_son3
		move.w	(a0),(a1)+
		bra	level3
pas_son3	move.w	#0,(a0)
level3		lea	mt_voice4+18(pc),a0
		subq.w	#4,(a0)
		ble	pas_son4
		move.w	(a0),(a1)+
		bra	level4
pas_son4	move.w	#0,(a0)
level4
		bsr	clear
		lea	ecran,a0
		lea	table_valeurs,a1
		move.l	#nb_valeurs-1,d0
		move.l	#equa_space,d1
		add.l	#equa_space_start,a0
		move.l	a0,a2
equa_lignes	move.w	(a1)+,d2
;		lsr.b	#1,d2
equa_trait	move.b	#$ff,(a0)+
		dbf	d2,equa_trait
		add.l	d1,a2
		move.l	a2,a0
		dbf	d0,equa_lignes
		rts

clear_equa	btst	#14,$2(a6)
		bne.s	clear_equa
		move.l	#ecran+(40*150),$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#0,$66(a6)
		move.w	#40*64+20,$58(a6)
		rts
clear
		lea	ecran,a0
		move.l	#nb_valeurs-1,d0
		move.l	#equa_space,d1
		add.l	#equa_space_start,a0
		move.l	a0,a2
equa_lignese	move.w	#32,d2
equa_traite	move.b	#$00,(a0)+
		dbf	d2,equa_traite
		add.l	d1,a2
		move.l	a2,a0
		dbf	d0,equa_lignese
		rts

table_valeurs:
		dc.w	0,0,0
strob_smile:	dc.w	0
	
;---------------------------------- scroll la barre
; test de flag si autorise rebond ou pas ( a faire bientot)
rebond:		cmp.w	#0,up_down
		beq	dong_plus
		bsr	dong_moins
fin_rebond	rts
		
dong_plus	lea	copper_dong,a0
		addq.l	#4,a0
		move.l	#$28-1,d0
		cmp.b	#250-$28,(a0)
		beq	fin_descend
descend		add.b	#vit_rebond,(a0)
		add.l	#188,a0
		dbf	d0,descend
		bra	fin_rebond
fin_descend	move.w	#1,up_down
		bra	fin_rebond

dong_moins	lea	copper_dong,a0
		addq.l	#4,a0
		move.l	#$28-1,d0
		cmp.b	#0,(a0)
		beq	fin_monte
monte		sub.b	#vit_rebond,(a0)
		add.l	#188,a0
		dbf	d0,monte
		rts
fin_monte	move.w	#0,up_down
		bsr	init_coul
		lea	mot,a3
		move.w	count_mot,d0
		cmp.b	#nb_mot,d0
		beq	fin_des_mots
		lsl.w	#2,d0
		move.l	(a3,d0),a2
		bsr	met_mot2
		add.w	#1,count_mot
		rts
fin_des_mots	move.w	#0,count_mot
		rts
	
up_down		dc.w	0
count_mot	dc.w	0

;------------------------------ ecrit un mot dans la copper
met_mot
		lea	mot,a3
		move.l	12(a3),a2
met_mot2	lea	copper_dong,a0
		move.w	(a2)+,d6
		add.w	(a2)+,a0
paste_lettre	move.l	(a2)+,a1
		bsr	met_lettre
		sub.l	#7504,a0	;7504 je sais pas pourquoi
		dbf	d6,paste_lettre
		rts
met_lettre			;d0 d1 d2 d3 d4 d5
		clr.l	d0
		move.l	#5-1,d1
suite_ligne	move.l	#8-1,d2
		move.w	(a1)+,d3
		move.w	(a1)+,d4
		move.w	(a1)+,d5
		lsl.w	d0,d3
		lsl.w	d0,d4
		lsl.w	d0,d5
met_ligne	or.w	d3,(a0)
		addq.l	#4,a0
		or.w	d4,(a0)
		addq.l	#4,a0
		or.w	d5,(a0)
		add.l	#45*4,a0
		dbf	d2,met_ligne
		add.w	#1,d0
		dbf	d1,suite_ligne	
		rts

;------------------------------
mot		dc.l	profecy,wooper,spectre,ale
fin_mot
profecy:	dc.w	7-1,18+28
		dc.l	dp,dr,do,df,de,dc,dy
wooper:		dc.w	6-1,18+36
		dc.l	dw,do,do,dp,de,dr
ale:		dc.w	3-1,18+36+28
		dc.l	da,dl,de
spectre:	dc.w	7-1,18+28
		dc.l	ds,dp,de,dc,dt,dr,de

;------------------------------

d:		dc.w	$0,$0,$0	;espace
		dc.w	$0,$0,$0
		dc.w	$0,$0,$0
		dc.w	$0,$0,$0
		dc.w	$0,$0,$0
da:		dc.w	$0,l1,$0
		dc.w	l2,$0,l2
		dc.w	l3,l3,l3
		dc.w	l4,$0,l4
		dc.w	l5,$0,l5
db:		dc.w	l1,l1,$0
		dc.w	l2,$0,l2
		dc.w	l3,l3,$0
		dc.w	l4,$0,l4
		dc.w	l5,l5,$0
dc:		dc.w	l1,l1,l1
		dc.w	l2,$0,$0
		dc.w	l3,$0,$0
		dc.w	l4,$0,$0
		dc.w	l5,l5,l5
dd:		dc.w	l1,l1,$0
		dc.w	l2,$0,l2
		dc.w	l3,$0,l3
		dc.w	l4,$0,l4
		dc.w	l5,l5,$0
de:		dc.w	l1,l1,l1
		dc.w	l2,$0,$0
		dc.w	l3,l3,$0
		dc.w	l4,$0,$0
		dc.w	l5,l5,l5
df:		dc.w	l1,l1,l1
		dc.w	l2,$0,$0
		dc.w	l3,l3,$0
		dc.w	l4,$0,$0
		dc.w	l5,$0,$0
dg:		dc.w	l1,l1,l1
		dc.w	l2,$0,$0
		dc.w	l3,$0,l3
		dc.w	l4,$0,l4
		dc.w	l5,l5,l5
dh:		dc.w	l1,$0,l1
		dc.w	l2,$0,l2
		dc.w	l3,l3,l3
		dc.w	l4,$0,l4
		dc.w	l5,$0,l5

dl:		dc.w	l1,$0,$0
		dc.w	l2,$0,$0
		dc.w	l3,$0,$0
		dc.w	l4,$0,$0
		dc.w	l5,l5,l5

dm:		dc.w	l1,$0,l1
		dc.w	l2,l2,l2
		dc.w	l3,$0,l3
		dc.w	l4,$0,l4
		dc.w	l5,$0,l5

do:		dc.w	l1,l1,l1
		dc.w	l2,$0,l2
		dc.w	l3,$0,l3
		dc.w	l4,$0,l4
		dc.w	l5,l5,l5

dp:		dc.w	l1,l1,l1
		dc.w	l2,$0,l2
		dc.w	l3,l3,l3
		dc.w	l4,$0,$0
		dc.w	l5,$0,$0

dr:		dc.w	l1,l1,$0
		dc.w	l2,$0,l2
		dc.w	l3,l3,$0
		dc.w	l4,$0,l4
		dc.w	l5,$0,l5

ds:		dc.w	l1,l1,l1
		dc.w	l2,$0,$0
		dc.w	l3,l3,l3
		dc.w	$0,$0,l4
		dc.w	l5,l5,l5

dt:		dc.w	l1,l1,l1
		dc.w	$0,l2,$0
		dc.w	$0,l3,$0
		dc.w	$0,l4,$0
		dc.w	$0,l5,$0

dw:		dc.w	l1,$0,l1
		dc.w	l2,$0,l2
		dc.w	l3,$0,l3
		dc.w	l4,l4,l4
		dc.w	l5,$0,l5

dy:		dc.w	l1,$0,l1
		dc.w	l2,$0,l2
		dc.w	l3,l3,l3
		dc.w	$0,l4,$0
		dc.w	$0,l5,$0

;------------------------------------------------------------------------
couleurs
		dc.w	$000,$001,$002,$003,$004,$005,$006,$007
		dc.w	$008,$009,$00a,$00b,$00c,$00d,$00e,$00f
		dc.w	$00f,$01f,$02f,$03f,$04f,$05f,$06f,$07f
		dc.w	$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
		dc.w	$0ff,$1ef,$2df,$3cf,$4bf,$5af,$69f,$78f
		dc.w	$87f,$96f,$a5f,$b4f,$c3f,$d2f,$e1f,$f0f
		dc.w	$f0f,$f0e,$f0d,$f0c,$f0b,$f0a,$f09,$f08
		dc.w	$f07,$f06,$f05,$f04,$f03,$f02,$f01,$f00

;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
;		dc.l	$00f00000,$00f20000
		dc.l	$01004200
		dc.w	$0180,$0000,$0182,$0111,$0184,$0222,$0186,$0333
		dc.w	$0188,$0444,$018a,$0555,$018c,$0666,$018e,$0777
		dc.w	$0190,$0888,$0192,$0999,$0194,$0aaa,$0196,$0bbb
		dc.w	$0198,$0ccc,$019a,$0ddd,$019c,$0eee,$019e,$0fff
		;dc.w	$182,$0f0
		;dc.w	$184
l_smil1		;dc.w	$ff0
		;dc.w	$186
l_smil2		;dc.w	$ff0
copper_dong
	dcb.w	188*8*6


;		dc.l	-2	;dans install copper
;------------------------------------------------------------------------
mt_data:	incbin	mod.bud
smiles:		incbin	smiles.raw
d2raw:		incbin	d2.raw
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan
	even
end

