;-------------------------------------------------------------------
;-                 Un petit essai de SYCRONISATION : Rève tracker -
;-------------------------------------------------------------------
nb_plan=1
hauteurimage=256


pausecoul1=25		;Nbr VBL pause entre chaque cycle couleur
vitessetourne=6		;Vitesse a laquelle reagisse les carres au volume
			;ATTENTION: soit 2,4,6,8...

;registres de l'UART (port serie) 
serdat = $dff030	;send
serper = $dff032	;init
serdatr= $dff018	;reçois
adkcon = $dff09e
adkconr= $dff010

;1200 bauds ---> 2982
;3600 bauds ---> 943
;4800 bauds ---> 745

vitesse= 745


execbase = 4
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$8000,save_intena 
	move.w 	#$3fff,$9a(a6)
	bsr	mt_init
	clr.l	$144(a6)	;sprite souris off
	bsr	install1	;installation pour un ecran 5 plans
	bsr	active_copper	;Bon...

;dma active
	clr.l	d0
	move.w	#vitesse,serper
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

active_copper
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
	;dma active
	move.w	#%1000001111000000,$96(a6)
	rts
;------------------------------------------ Menu
menu		btst	#10,$dff016
		bne	menu
		move.w	#$111,d0
		bsr	send_char
attend		bsr	recois_char
		cmp.b	#$11,d0
		bne	attend		;connecter		
		bra	esclave
	
maitre		cmp.b	#-1,$6(a6)
		bne	maitre
		move.w	#$122,d0
		bsr	send_char	;top
		bra	go2
vbl1		cmp.b	#-1,$6(a6)
		bne	vbl1
go2		bsr	mt_music
		bsr	equa1
waitm1		btst	#6,$bfe001
		bne	vbl1
		rts


esclave		bsr	recois_char
		cmp.b	#$22,d0
		bne	esclave
		move.l	$4(a6),d1
		and.l	#$1ff00,d1
		bra	go1

vbl2		move.l	$4(a6),d4
		and.l	#$1ff00,d4
		cmp.l	d1,d4		
		bne	vbl2
go1		bsr	mt_music
		bsr	equa1
waitm2		btst	#6,$bfe001
		bne	vbl2
		rts

recois_char:
		btst	#14,serdatr
		beq	recois_char
		clr.l	d0
		move.w	serdatr,d0
		rts

send_char	move.w	d0,serdat
wait_send	btst	#12,serdatr
		beq	wait_send	;vide	
		rts

;********************************************************
; EFFET NO 1
;********************************************************
equa1
		move.l	ptrcoul,a2		;Pointeur couleurs dans a2		
		subq.w	#$1,delaicoul
		cmp.w	#$0,delaicoul
		bne	yaundelai
		move.w	(a2)+,coulchange	;Cycle couleur
		move.w	#pausecoul1,delaicoul	
yaundelai
voix1		;VOIX NO 1
		lea	mt_voice1+$12,a3
		cmp.w	#$0,(a3)
		bge	suite
		move.w	#$0,(a3)

suite
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d1		;y
paste_y		move.l	#0,d0		;x
paste_x		lea	image,a0
		add.l	d1,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#4,d0
		cmp.w	#4*10,d0
		bne	paste_x
		add.w	#(40*32),d1
		cmp.w	#40*32*2,d1
		bne	paste_y


voix2		;VOIX NO 2
		subq.w	#vitessetourne,(a3)		;on decremente voix no 1...

		lea	mt_voice2+$12,a3
		cmp.w	#$0,(a3)
		bge	suite2
		move.w	#$0,(a3)

suite2
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d1		;y
paste_y2	move.l	#0,d0		;x
paste_x2	lea	image+40*64,a0
		add.l	d1,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#4,d0
		cmp.w	#4*10,d0
		bne	paste_x2
		add.w	#(40*32),d1
		cmp.w	#40*32*2,d1
		bne	paste_y2
voix3		;VOIX NO 3
		subq.w	#vitessetourne,(a3)		;on decremente voix no 2...

		lea	mt_voice3+$12,a3
		cmp.w	#$0,(a3)
		bge	suite3
		move.w	#$0,(a3)

suite3
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d1		;y
paste_y3	move.l	#0,d0		;x
paste_x3	lea	image+40*128,a0
		add.l	d1,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#4,d0
		cmp.w	#4*10,d0
		bne	paste_x3
		add.w	#(40*32),d1
		cmp.w	#40*32*2,d1
		bne	paste_y3
voix4		;VOIX NO 4
		subq.w	#vitessetourne,(a3)		;on decremente voix no 3...

		lea	mt_voice4+$12,a3
		cmp.w	#$0,(a3)
		bge	suite4
		move.w	#$0,(a3)

suite4
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d1		;y
paste_y4	move.l	#0,d0		;x
paste_x4	lea	image+40*192,a0
		add.l	d1,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#4,d0
		cmp.w	#4*10,d0
		bne	paste_x4
		add.w	#(40*32),d1
		cmp.w	#40*32*2,d1
		bne	paste_y4
finvoix
		subq.w	#vitessetourne,(a3)		;on decremente voix no 4...
		cmp.w	#-1,(a2)
		beq	debut_coul
		move.l	a2,ptrcoul
		rts
debut_coul
		move.l	#couleurs,ptrcoul
		rts
copieblit
w_blit		btst	#14,$2(a6)
		bne.s	w_blit
		move.l	source,$54(a6) 			;dest ecran
		move.l	destination,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.l	#$00000024,$64(a6)
		move.w	#32*64+2,$58(a6)
		rts
source
		dc.l	0
destination
		dc.l	0
table_equivalence
		;Table d'equivalence entre le volume et l'image a afficher
		;1er long mot=image pour volume=0
		;2eme long mot=image pour volume=1 etc...
		;Ici volume de 0 à 6
		dc.l	carre,carre+128,carre+128,carre+128,carre+128
		dc.l	carre+128,carre+128
		;Ici volume de 7 à 12
		dc.l	carre+256,carre+256,carre+256,carre+256
		dc.l	carre+256,carre+256
		;Ici volume de 13 à 18
		dc.l	carre+384,carre+384,carre+384,carre+384
		dc.l	carre+384,carre+384
		;Ici volume de 19 à 24
		dc.l	carre+512,carre+512,carre+512,carre+512
		dc.l	carre+512,carre+512
		;Ici volume de 25 à 30
		dc.l	carre+640,carre+640,carre+640,carre+640
		dc.l	carre+640,carre+640
		;Ici volume de 31 à 36
		dc.l	carre+768,carre+768,carre+768,carre+768
		dc.l	carre+768,carre+768
		;Ici volume de 37 à 42
		dc.l	carre+896,carre+896,carre+896,carre+896
		dc.l	carre+896,carre+896
		;Ici volume de 43 à 48
		dc.l	carre+1024,carre+1024,carre+1024,carre+1024
		dc.l	carre+1024,carre+1024
		;Ici volume de 49 à 54
		dc.l	carre+1152,carre+1152,carre+1152,carre+1152
		dc.l	carre+1152,carre+1152
		;Ici volume de 55 à 64
		dc.l	carre+1280,carre+1280,carre+1280,carre+1280
		dc.l	carre+1280,carre+1280,carre+1280,carre+1280
		dc.l	carre+1280,carre+1280

ptrcoul
		dc.l	couleurs
delaicoul
		dc.w	pausecoul1




;---------------------------------- soundtrack
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
;------------------------------------------------------------------------
couleurs
		dc.w	$f0f,$ff0,$f00,$00f,$0f0,$0ff,$fff
		dc.w	-1
copper:
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.w	$2e01,$fffe
		dc.w	$0100,$1200
		dc.w	$0180,$0000,$0182
coulchange	dc.w	$0fff

		dc.l	-2
;------------------------------------------------------------------------
	even
carre
	dcb.b	4*32,0
	incbin	carretourne.raw
mt_data
	incbin	mod.technoremix2
image
	ds.b	40*hauteurimage*nb_plan
	even
end




	

