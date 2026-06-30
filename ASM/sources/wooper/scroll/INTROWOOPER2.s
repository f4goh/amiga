	org	$c000
;-------------------------------------------------------------------
;INTRO POUR PREVIEW DE NUMERIC 3
;-------------------------------------------------------------------
execbase=4

nb_plan=1
hauteurimage=100		;en ligne
hauteurlogo=101
planlogo=5
nbrligne2=109		;Ligne qui defile: vers bas
ligne1=$4101	;Valeur du 1er WAIT...
nbrligne=22
debutecriture=(64+16)*2	;adresse dans image du debut de l'ecriture(64*nbr ligne)
pausemachine=0		;pause pour affichage des lettres
pscreen=1000		;pause entre chaque screen

	;section	code,code_c
start
	bsr	save_all	;Tres tres classique...
	move.l	#$dff000,a6
	bsr	install1	
	bsr	install2
	bsr	install3	;installation des plans du logo
	bsr	mt_init
	bsr	active_copper
	clr.w	counter
boucle
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$0ff00,d0
	bne	boucle

	add.w	#1,counter
	;move.w	#$fff,$180(a6)	;test tps machine
	bsr	affiche_lettre
	bsr	barres
	bsr	mt_music
	bsr	defil
	;clr.w	$180(a6)	;test tps machine 2, le retour
	cmp.w	#1200,counter
	beq	restore_all	

	btst	#6,$bfe001
	bne.s	boucle
restore_all
	bsr	mt_end

	move.w 	#$7fff,$dff096		;vide le dmacon
	move.w	save_dmacon,$dff096	;place la copie sauvée avant 
	rts


	move.l	4,a6
	lea	name_glib,a1		;ouvre la library
	moveq	#0,d0
	jsr	-552(a6)		;open-library
	move.l	d0,a0			;sauve handler
	move.l	38(a0),$dff080		;restore de la copper liste
	clr.w	$dff088			;clear copjmp1
	move.l	d0,a1			;adr de library
	jsr	-414(a6)		;closelibrary
	jsr	-138(a6)		;autorise le multitache
	clr.l	d0
	rts
counter
	dc.w	0

install1
	;installation de la 1ere liste copper
	lea	bmap,a0
	move.l	#image,d0
	moveq	#nb_plan-1,d1
plan_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*hauteurimage,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
	rts

install3
	;installation de la 1ere liste copper
	lea	bmap2,a0
	move.l	#logo,d0
	moveq	#planlogo-1,d1
plan_suivant2
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*hauteurlogo,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant2
	rts

active_copper
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
	clr.l	$144(a6)	;sprite souris off
	;dma active
	move.w	#$83c0,$96(a6)
	rts

affiche_lettre

copiebloc
	cmp.w	#$0,pause1
	bne	affiche_pas
	move.w	#pausemachine,pause1
	clr.w	d1
	clr.w	d0
	moveq.w	#$7,d0		;iteration (8-1)
	move.l	lsuiv,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
	cmp.b	#0,d1
	beq	debut_screen
	cmp.b	#$ff,d1
	beq	retourdebut
ret_deb	sub.b	#32,d1		;-32 car 32=ESPACE
	lea	font,a0		;adresse de font dans a0
	add.w	d1,a0		;Voila, a0 contient l'adresse de la lettre
	move.l	posecran,a2	;Dans a0=adresse de lettre
				;Dans a1=valeur ascii de la lettre
				;Dans a2=position sur ecran
bcopie	move.b	(a0),(a2)	;Affiche parti de la lettre
	add.w	#64,a0		;Nouvelle partie de la lettre
	add.w	#40,a2		;
	dbf	d0,bcopie
	addq.l	#$1,a1
	move.l	a1,lsuiv
	add.w	#$1,nolettre
	cmp.w	#$28,nolettre
	beq	saute_ligne	
ret_saut
	addq.l	#$1,posecran	;On svg la pos de la prochaine lettre
				;ne pas oublier d'ajouter 1 octet pour
				;la lettre suivante!...
	;COPIE CARRE
	lea	font+10,a0
	move.l	posecran,a2
	moveq.w	#$7,d0		;iteration (8-1)
	
bcopie2	move.b	(a0),(a2)	;Affiche parti de la lettre
	add.w	#64,a0		;Nouvelle partie de la lettre
	add.w	#40,a2		;
	dbf	d0,bcopie2

	rts
debut_screen
	subq.w	#$1,pauscreen
	cmp.w	#$0,pauscreen
	beq	suite_debut
	rts
suite_debut
	move.l	#image+debutecriture,posecran
	add.l	#$1,lsuiv		;on passe a lettre suivante
	move.w	#pscreen,pauscreen	;et on remet la pause a sa valeur
	rts
saute_ligne
	add.l	#281-1,posecran
	move.w	#$0,nolettre
	bra	ret_saut
affiche_pas
	subq.w	#$1,pause1
	rts

retourdebut
	move.l	#texte,lsuiv
	rts	
lsuiv
	dc.l	texte

lignecours
	dc.l	image
pauscreen
	dc.w	pscreen
nolettre
	dc.w	0
noligne
	dc.w	1
posecran
	dc.l	image+debutecriture
pause1
	dc.w	pausemachine

; *********************************************************************
; *********************************************************************

barres:
	lea	raster1,a0
	lea	raster2,a1
	move.l	ptrcoul2,a5
	cmp.w	#$ffff,(a5)
	beq	remet_debut
	move.w	#nbrligne-1,d3	;nombre d'iterations
	move.w	(a0),d0		;svg couleur 1
	move.w	(a5)+,(a0)	;on met la nouvelle couleur			
	move.w	(a5),(a1)
	move.l	a5,ptrcoul2
	addq.w	#4,a0
	addq.w	#4,a1
bouge_barre
	move.w	(a0),d1		;svg couleur 2
	move.w	d0,(a0)		;met 1er couleur svgder
	move.w	d0,(a1)
	addq.w	#4,a0
	addq.w	#4,a1
	move.w	(a0),d0		;svg couleur 1
	move.w	d1,(a0)
	move.w	d1,(a1)
	addq.w	#4,a1	
	addq.w	#4,a0
	dbf	d3,bouge_barre
	rts

remet_debut
	move.l	#couleurs,ptrcoul2
	rts

ptrcoul2
	dc.l	couleurs	

install2
	lea	cdefil,a0
	move.w	#ligne1,d0	;ca y en a etre la valeur du premier WAIT
	move.w	#nbrligne2-1,d1	;nbr de lignes-1 à mettre
allez_go
	move.l	#$01820000,(a0)+;registre couleur 180 à zero (noir)
	move.w	d0,(a0)+
	add.w	#$100,d0	;Incrementation position y de 1
	move.w	#$fffe,(a0)+
	dbf	d1,allez_go
	rts			;Ouf, fini de construire!...
defil
	lea	cdefil+2,a0
	move.l	ptrcoul3,a5
	cmp.w	#-1,(a5)
	beq	remet_debut2
ret_def	move.w	#nbrligne2-2,d3
	lsr.b	#1,d3
	subq.w	#1,d3		;nombre d'iterations (ya surement plus rapide)
				;faudra que je demande a spectre...
	move.w	(a0),d0		;svg couleur 1
	move.w	(a5)+,(a0)	;on met la nouvelle couleur			
	addq.w	#8,a0
bouge_barre2
	move.w	(a0),d1		;svg couleur 2
	move.w	d0,(a0)		;met 1er couleur svgder
	addq.w	#8,a0
	move.w	(a0),d0		;svg couleur 1
	move.w	d1,(a0)
	addq.w	#8,a0
	dbf	d3,bouge_barre2
	move.l	a5,ptrcoul3
	rts

remet_debut2
	lea	couleurs2,a5
	bra	ret_def
	rts

ptrcoul3
	dc.l	couleurs2
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

save_all
	move.l	4,a6			;no comment
	jsr	-132(a6)		;stopper le multitache
	move.w	$dff002,save_dmacon	;save registre dma
	or.w	#$8100,save_dmacon	;bit 15 et 14 à 1
	rts
					
save_dmacon
	dc.w 0
name_glib
	dc.b "graphics.library",0

	even
;-----------------------------------------------------------------------
couleurs:
		dc.w	$00f,$01f,$02f,$03f,$04f,$05f,$06f,$07f
		dc.w	$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
		dc.w	$0ff,$0fe,$0fd,$0fc,$0fb,$0fa,$0f9,$0f8
		dc.w	$0f7,$0f6,$0f5,$0f4,$0f3,$0f2,$0f1,$0f0
		dc.w	$0f0,$1f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0
		dc.w	$8f0,$9f0,$af0,$bf0,$cf0,$df0,$ef0,$ff0
		dc.w	$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80
		dc.w	$f70,$f60,$f50,$f40,$f30,$f20,$f10,$f00
		dc.w	$f00,$f01,$f02,$f03,$f04,$f05,$f06,$f07
		dc.w	$f08,$f09,$f0a,$f0b,$f0c,$f0d,$f0e,$f0f
		dc.w	$f0f,$e0f,$d0f,$c0f,$b0f,$a0f,$90f,$80f
		dc.w	$70f,$60f,$50f,$40f,$30f,$20f,$10f,$00f
		dc.w	-1
	even
couleurs2
		dc.w	$100,$200,$310,$420,$530,$640,$750,$860
		dc.w	$971,$a82,$b93,$ca4,$db5,$ec6,$fd7,$fe8
		dc.w	$ff9,$ffb,$ffd,$fff,$ffd,$ffb,$ff9
		dc.w	$fe8,$fd7,$ec6,$db5,$ca4,$b93,$a82,$971
		dc.w	$860,$750,$640,$530,$420,$310,$200,$100
		dc.w	$100,$200,$310,$420,$530,$640,$750,$860
		dc.w	$971,$a82,$b93,$ca4,$db5,$ec6,$fd7,$fe8
		dc.w	$ff9,$ffb,$ffd,$fff,$ffd,$ffb,$ff9
		dc.w	$fe8,$fd7,$ec6,$db5,$ca4,$b93,$a82,$971
		dc.w	$860,$750,$640,$530,$420,$310,$200,$100
		dc.w	$100,$200,$310,$420,$530,$640,$750,$860
		dc.w	$971,$a82,$b93,$ca4,$db5,$ec6,$fd7,$fe8
		dc.w	$ff9,$ffb,$ffd,$fff,$ffd,$ffb,$ff9
		dc.w	$fe8,$fd7,$ec6,$db5,$ca4,$b93,$a82,$971
		dc.w	$860,$750,$640,$530,$420,$310,$200,$100
		dc.w	-1
	even

copper		dc.w	$180,$0
		dc.w	$00e1,$fffe
		dc.w	$100,$0
		
		dc.w	$3035,$fffe,$180

raster1		dc.w	$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
	

		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.w	$4001,$fffe
		dc.w	$0100,$1200
		dc.w	$180,$0
cdefil
		ds.l	nbrligne2*2			
		dc.w	$be35,$fffe,$180
	
raster2		dc.w	$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$c001,$fffe
		dc.w	$0100,$0
bmap2		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
		dc.w	$c701,$fffe
		dc.w	$0100,$5200
coul_img:

		dc.w	$0180,$0000,$0182,$0dff,$0184,$0aff,$0186,$0fef
		dc.w	$0188,$0fbf,$018a,$0ffc,$018c,$0ff9,$018e,$0880
		dc.w	$0190,$0400,$0192,$0620,$0194,$0840,$0196,$0a60
		dc.w	$0198,$0c80,$019a,$0ea2,$019c,$0fc4,$019e,$0fe6
		dc.w	$01a0,$0403,$01a2,$0605,$01a4,$0807,$01a6,$0a09
		dc.w	$01a8,$0c2b,$01aa,$0e4d,$01ac,$0f6f,$01ae,$0f9f
		dc.w	$01b0,$0006,$01b2,$0028,$01b4,$004a,$01b6,$006c
		dc.w	$01b8,$028e,$01ba,$04af,$01bc,$06cf,$01be,$08ef

		dc.l	-2
;------------------------------------------------------------------------
	even
adresseplan
	dc.l	0
	even
texte
	; 20 LETTRES MAX SUR UNE LIGNE...

	dc.b	"                PROFECY                 "
	dc.b	"                                        "
	dc.b	"        PRESENT NUMERIC 3 PREVIEW       "
	dc.b	"            ON THE 12/06/92             "
	dc.b	"                                        "
	dc.b	"     CODE BY: ALE OF FAME AND WOOPER    "
	dc.b	"     MUSICS : WOOPER                    "   
	dc.b	"     GFX BY : FURIO AND WOOPER          "
	dc.b	"                                        "
	dc.b	"  FINAL VERSION WILL BE OUT VERY SOON   "
	dc.b	"                                        "
	dc.b	"    SHORT HELLO TO DJ MAXX/INTENSE      "
	dc.b	"               AND FX-COBRA/PROFECY     "
	dc.b	0	
	dc.b	-1	;indique la fin a ne pas enlever!!
	even
font
	incbin	dh1:numeric3/trackdisk/font8x8
	even
image	dcb.b	40*256,0
	even
logo
	incbin	dh1:numeric3/trackdisk/profecyrempli3.raw
	even
mt_data
	incbin	dh1:numeric3/mod.wooper/mod.intro
	even
end

