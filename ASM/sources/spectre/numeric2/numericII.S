	org	$a500
;----------------------------
;-numeric 2		    -
;----------------------------
taille_logo=142*46
taille_plan=44*173
taille_ecran_noel=44*70
taille_plan_noel=4*32*11	;for mask
nb_bonhom	=11
haut_noel	=32
nb_plan_noel	=4
degrade=60		;nb couleurs ds degrader
nb_degr=14-1		;nb de repetition de degrader ds un rouleau
rolsize=degrade*nb_degr*2	;taille du rouleau en octets
centre_x	=168
centre_y	=83
nb_let_maxi	=14
vitesse_scroll	=16		;vit 1,2,4,8
masque_angle	=(1024-vitesse_scroll)
ecart_angle	=1024/nb_let_maxi
nbr_de_sprite=5
cdb = $188
nblettre	=43
haut_pos	=48	;a effacer
bhf1	=0
bhf2	=4*4*32
bhf3	=2*4*4*32
bhf4	=3*4*4*32
bhf5	=4*4*4*32
bhf6	=5*4*4*32
bhf7	=6*4*4*32
bhf8	=7*4*4*32
bhf9	=8*4*4*32
bhf10	=9*4*4*32
bhf11	=10*4*4*32
execbase =4
findtask = -294
addport = -354
remport = -360
openlib = -408
closelib= -414
opendev = -444
closedev= -450
doio	= -456
deb_piste_mod1=34*11*512
nb_pistes_mod1=40
deb_piste_mod2=74*11*512
nb_pistes_mod2=43
deb_piste_mod3=117*11*512
nb_pistes_mod3=42
;-------------------------------
wait_blt	macro
loop_wait_blt\@
	btst	#14,$2(a6)
	bne.s	loop_wait_blt\@
	endm
;-------------------------------
		movem.l	d0-d7/a0-a6,-(sp)
		bsr	saveall
		lea	$dff000,a6
		move.w	#$7fff,$96(a6)
		move.w	#$7fff,$9a(a6)
		bsr	init
		lea	p_lettre,a0
		move.l	#adr_N,(a0)+
		move.l	#adr_U,(a0)+
		move.l	#adr_M,(a0)+
		move.l	#adr_E,(a0)+
		move.l	#adr_R,(a0)+
		move.l	#adr_I,(a0)+
		move.l	#adr_C,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#adr_I,(a0)+
		move.l	#adr_I,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.w	#nb_let_maxi-1,d0
		lea	p_angle,a0
		moveq	#0,d1
copie		move.w	d1,(a0)+
		sub.w	#ecart_angle,d1
		dbf	d0,copie
		clr.w	$36(a6)		;on eff x,y
		bsr	mt_init
		bsr	startcopper
		bsr	vbl
		bsr	mt_end
		bsr	restoreall
		movem.l	(sp)+,d0-d7/a0-a6
		rts
;------------------------------------
saveall		move.l	4,a6
		jsr	-132(a6);forbid
		move.w	$dff01c,save_intena
		or.w	#$c000,save_intena
		move.w	$dff002,save_dmacon
		or.w	#$8100,save_dmacon
		rts
restoreall	btst	#14,$dff002
		bne.s	restoreall
		move.w	#$7fff,$dff09a
		move.w	save_intena,$dff09a
		move.w	#$7fff,$dff096
		move.w	save_dmacon,$dff096
		move.l	4,a6
		lea	name_glib,a1
		moveq	#0,d0
		jsr	-552(a6)	;ouvre lib
		move.l	d0,a0
		move.l	38(a0),$dff080
		clr.w	$dff088
		move.l	d0,a1
		jsr	-414(a6)	;ferme lib
		jsr	-138(a6)
		rts

startcopper	lea	copperlist,a0
		move.l	a0,$80(a6)
		tst.w	$88(a6)
		move.w	#$83e0,$96(a6)		;dma copper,blitter & bitplane
		rts

save_intena	dc.w 0
save_dmacon	dc.w 0
name_glib	dc.b "graphics.library",0
	even
;------------------------------------
init		lea	roller1,a0
		bsr	makeroller
		lea	roller2,a0
		bsr	makeroller
		lea	bmap,a0
		move.l	#logo1,d0
		moveq	#4-1,d1
plan_suit	move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		addq.l	#8,a0
		swap	d0
		add.l	#taille_logo,d0
		dbf	d1,plan_suit

		move.l	#ecran_scroll,d0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)

		lea	bmap2,a0
		move.l	#plan1,d0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		addq.l	#8,a0
		
		move.l	#plan2,d0
		moveq	#4-1,d1
plan_suit2	move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		addq.l	#8,a0
		swap	d0
		add.l	#taille_plan,d0
		dbf	d1,plan_suit2

sprite_init	lea	spr_pt,a0
		moveq	#nbr_de_sprite-1,d1
		move.l	#sprite,d0
install		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		add.l	#48,d0
		addq.l	#8,a0
		dbf	d1,install
init_scroll
		moveq	#0,d1
		lea	tablechars,a4
		move.l	(a4,d1.w),a4
		lea	boblettre,a0	;add coord
		moveq	#nblettre-1,d3
		lea	courbex,a2
		move.l	#courbe,d1
coord		move.l	a2,(a0)		;sauve pointeur
		addq.l	#8,a2		;dist entre chaque lettre
		move.l	d1,4(a0)
		move.l	a4,8(a0)	;img lettre" "au depart
		add.w	#12,a0
		addq.l	#2,d1		;decal hauteur y
		cmp.l	#fcourbe,d1
		blt	incy
		move.l	#courbe,d1
incy		dbf	d3,coord
;--------- init 2nd copper ------------
		lea	bmap4,a0
		move.l	#plan1,d0
		moveq	#4-1,d1
plan_suit4	move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		addq.l	#8,a0
		swap	d0
		add.l	#taille_ecran_noel,d0
		dbf	d1,plan_suit4
		lea	noel_image,a0	;1 plan
		lea	4*32(a0),a1	;2 plan
		lea	4*32*2(a0),a2	;3 plan
		lea	4*32*3(a0),a3	;4 plan
		lea	noel_masque,a4
		clr.l	d0
		move.w	#nb_bonhom-1,d2
autre_bonhom	move.w	#4*32-1,d0	;1bonhom
masq		move.b	(a0)+,(a4)
		move.b	(a1)+,d1
		or.b	d1,(a4)
		move.b	(a2)+,d1
		or.b	d1,(a4)
		move.b	(a3)+,d1
		or.b	d1,(a4)+
		dbf	d0,masq
		add.l	#4*32*3,a0
		add.l	#4*32*3,a1
		add.l	#4*32*3,a2
		add.l	#4*32*3,a3
		dbf	d2,autre_bonhom
		clr.l	d0
		move.l	d0,d1
		move.l	d0,d2
		rts
;------------------------------------
makeroller	moveq	#nb_degr-1,d0
make		moveq	#0,d1
		moveq	#14,d2
roll1		move.w	#$180,(a0)+
		move.w	d1,(a0)+
		add.w	#$101,d1
		dbra	d2,roll1
		move.w	#$180,(a0)+
		move.w	d1,(a0)+
		moveq	#14,d2
roll2		move.w	#$180,(a0)+
		sub.w	#$101,d1
		move.w	d1,(a0)+
		dbra	d2,roll2
		moveq	#14,d2
roll3		move.w	#$180,(a0)+
		add.w	#$100,d1
		move.w	d1,(a0)+
		dbra	d2,roll3
		moveq	#13,d2
roll4		move.w	#$180,(a0)+
		sub.w	#$100,d1
		move.w	d1,(a0)+
		dbra	d2,roll4
		dbra	d0,make
		rts
;--------------------------------------------
souris	moveq	#0,d0
	move.l	d0,d1
	lea	posx(pc),a0
	move.b	$b(a6),d0	;x pos souris
	move.b	oldposx,d1
	move.b	d0,oldposx
	sub.b	d1,d0	;dif par rapport a l'ancienne posx ds d1
	add.b	(a0),d0	;on ajoute la pos actuel en x
	cmp.w	#188,d0	;ici commence les tests pour les bords
	blt.s	infgauche
	move.w	#188,d0
infgauche
	cmp.w	#95,d0
	bgt.s	suphaut
	move.w	#95,d0
suphaut	move.b	d0,(a0)		;on sauve
	clr.l	d0		;on bouge
	move.w	d0,d1
	lea	posx(pc),a0
	move.b	(a0),d0	;on prend les x
	sub.b	#$35,d0	;ref bord gauche du cadre
	divs	#35,d0	;on prend une position tous les 35
	muls	#35,d0	;soit la largeur du curseur
	add.b	#$35,d0
	lea	sprite(pc),a1
	moveq	#nbr_de_sprite-1,d3
bgsp	move.b	d0,1(a1)
	addq.b	#8,d0
	add.l	#48,a1
	dbf	d3,bgsp
	btst	#6,$bfe001
	beq	bouton_gauche
	rts
oldposx	dc.b	0	;x
posx	dc.b	0
sprite	dc.w	$1337,$1d06
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111000000000000,%0011000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	0,0
	dc.w	$133f,$1d06	
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	0,0
	dc.w	$1347,$1d06	
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	0,0
	dc.w	$134f,$1d06	
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	0,0
	dc.w	$1357,$1d06	
	dc.w	%1111111111110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%0000000011110000,%0000000000000000
	dc.w	%1111111111110000,%0000000000000000
	dc.w	0,0
;--------------------------------------------
decibel		lea	mt_voice1+18(pc),a0
		lea	copdb2+6,a1
		lea	deci_table(pc),a2
		lea	pt_deci(pc),a3
		move.l	a3,a4
		moveq	#0,d1
		moveq	#56,d2
		move.l	#60,d3		;56*6 et oui 56+4
		subq.w	#3,(a0)
		ble	pas_son
		move.w	(a0),d1
		add.w	d1,d1
		move.w	(a2,d1),d1
		lsl.w	#2,d1
		move.l	(a3,d1),a3
		moveq	#16-1,d4	;hauteur equa
haut_son	move.w	(a3)+,d0	;ale
		move.w	d0,d1
		lsl.w	#8,d0
		or.w	d1,d0
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d3,a1
		dbf	d4,haut_son
		bra	decib2
pas_son		move.w	#0,(a0)
decib2		lea	mt_voice2+18(pc),a0
		lea	copdb2+22,a1
		move.l	a4,a3
		subq.w	#3,(a0)
		ble	pas_son2
		move.w	(a0),d1
		add.w	d1,d1
		move.w	(a2,d1),d1
		lsl.w	#2,d1
		move.l	(a3,d1),a3
		moveq	#16-1,d4	;hauteur equa
haut_son2	move.w	(a3)+,d0
		lsl	#8,d0
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d3,a1
		dbf	d4,haut_son2
		bra	decib3
pas_son2	move.w	#0,(a0)
decib3		lea	mt_voice3+18(pc),a0
		lea	copdb2+38,a1
		move.l	a4,a3
		subq.w	#3,(a0)
		ble	pas_son3
		move.w	(a0),d1
		add.w	d1,d1
		move.w	(a2,d1),d1
		lsl.w	#2,d1
		move.l	(a3,d1),a3
		moveq	#16-1,d4	;hauteur equa
haut_son3	move.w	(a3)+,d0
		lsl	#4,d0
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d3,a1
		dbf	d4,haut_son3
		bra	decib4
pas_son3	move.w	#0,(a0)
decib4		lea	mt_voice4+18(pc),a0
		lea	copdb2+50,a1
		move.l	a4,a3
		subq.w	#3,(a0)
		ble	pas_son4
		move.w	(a0),d1
		add.w	d1,d1
		move.w	(a2,d1),d1
		lsl.w	#2,d1
		move.l	(a3,d1),a3
		moveq	#16-1,d4	;hauteur equa
haut_son4	move.w	(a3)+,d0
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d2,a1
		move.w	d0,(a1)
		move.w	d0,4(a1)
		sub.l	d3,a1
		dbf	d4,haut_son4
		rts
pas_son4	move.w	#0,(a0)
		rts
deci_table	dc.w	0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4
		dc.w	5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,9,9,9,9
		dc.w	$a,$a,$a,$a,$b,$b,$b,$b,$c,$c,$c,$c
		dc.w	$d,$d,$d,$d,$e,$e,$e,$e,$f,$f,$f,$f,$f

decif		dc.w	7,7,8,8,9,9,10,10,11,11,13,13,14,14,15,15
decie		dc.w	7,8,8,9,9,10,10,11,11,13,13,14,14,15,15,0
decid		dc.w	8,8,9,9,10,10,11,11,13,13,14,14,15,15,0,0
decic		dc.w	8,9,9,10,10,11,11,13,13,14,14,15,15,0,0,0
decib		dc.w	9,9,10,10,11,11,13,13,14,14,15,15,0,0,0,0
decia		dc.w	9,10,10,11,11,13,13,14,14,15,15,0,0,0,0,0
deci9		dc.w	10,10,11,11,13,13,14,14,15,15,0,0,0,0,0,0
deci8		dc.w	10,11,11,13,13,14,14,15,15,0,0,0,0,0,0,0
deci7		dc.w	11,11,13,13,14,14,15,15,0,0,0,0,0,0,0,0
deci6		dc.w	11,13,13,14,14,15,15,0,0,0,0,0,0,0,0,0
deci5		dc.w	13,13,14,14,15,15,0,0,0,0,0,0,0,0,0,0
deci4		dc.w	13,14,14,15,15,0,0,0,0,0,0,0,0,0,0,0
deci3		dc.w	14,14,15,15,0,0,0,0,0,0,0,0,0,0,0,0
deci2		dc.w	14,15,15,0,0,0,0,0,0,0,0,0,0,0,0,0
deci1		dc.w	15,15,0,0,0,0,0,0,0,0,0,0,0,0,0
deci0		dcb.w	16,0

pt_deci		dc.l	deci0,deci1,deci2,deci3,deci4,deci5
		dc.l	deci6,deci7,deci8,deci9,decia,decib
		dc.l	decic,decid,decie,decif
;--------------------------------------------
vbl		cmp.b	#6,$6(a6)
		bne.s	vbl
		bsr.s	moverollers
		bsr	color_arc
		bsr	swap_ecran
		bsr	clearscreen
		bsr	avance_scroll
		bsr	mt_music
		bsr	decibel
		bsr	color_arc
		bsr	souris
		bsr	scroll
		bsr	bg_logo
		bsr	message
		btst	#10,$16(a6)
		bne.s	vbl
		rts
;------------------------------------
;cree le mvt des rouleaux
;------------------------------------
color_arc
	moveq	#0,d0
	move.w	ptrarc,d0
	cmp.w	#16-1,d0
	bne.s	suite_arc
	clr.w	ptrarc
	moveq	#0,d0
suite_arc
	move	d0,d2
	add.w	d0,d0
	lea	coularc3,a0
	add.l	d0,a0
	lea	arcciel+2,a1
	moveq	#8-1,d1
stoc_arc
	move.w	(a0)+,(a1)
	addq.l	#8,a1
	dbf	d1,stoc_arc
	addq.w	#1,d2
	move.w	d2,ptrarc
	rts
;------------------------------------
moverollers
	wait_blt
	lea	roller1+4+2,a0	;1er rouleau
	lea	-4(a0),a1
	move.w	(a1),d0
	move.l	#-1,$44(a6)
	move.l	#$9f00000,$40(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.l	#$00020002,$64(a6)	;a et d
	move.w	#((rolsize/2)-2)*64+1,$58(a6)
	move.w	d0,((rolsize/2)-2)*4(a1)
	wait_blt
	lea	roller2+(rolsize/2)*4-2,a0
	lea	-4(a0),a1
	move.w	(a0),d0
	move.l	#$9f00002,$40(a6)
	move.l	a1,$50(a6)
	move.l	a0,$54(a6)
	move.w	#((rolsize/2)-2)*64+1,$58(a6)
	move.w	d0,-((rolsize/2)-2)*4(a0)
	rts
;------------------------------------
bg_logo		lea	bmap,a0
		move.l	plog_sin,a1
		addq.l	#2,a1
		cmp.l	#log_sinf,a1
		bmi.s	bg_suite
		move.l	#log_sin,a1
bg_suite	move.l	a1,plog_sin
		move.l	#logo1,d0
		add.w	(a1),d0
		swap	d0	;pl1
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0	;pl2
		add.l	#taille_logo,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0	;pl3
		add.l	#taille_logo,d0
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		move.w	d0,6(a0)
		addq.l	#8,a0	;pl4
		add.l	#taille_logo,d0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		moveq	#0,d0
		rts
plog_sin	dc.l	log_sin
log_sin	dc.w	0,1*46,2*46,3*46,4*46,5*46,6*46,7*46,8*46,9*46,10*46
	dc.w	11*46,12*46,13*46,14*46,15*46,16*46,17*46,18*46,19*46
	dc.w	20*46,21*46,22*46,23*46,24*46,25*46,26*46,27*46,28*46
	dc.w	29*46,30*46,31*46,32*46,33*46,34*46,35*46,36*46,37*46
	dc.w	38*46,39*46,40*46,41*46,42*46,43*46,44*46,45*46,46*46
	dc.w	47*46,48*46,49*46,50*46,51*46,52*46,53*46,54*46,55*46
	dc.w	56*46,57*46,58*46,59*46,60*46,61*46,62*46,63*46,64*46
	dc.w	65*46,66*46,67*46,68*46,69*46,70*46,71*46,72*46,73*46
	dc.w	74*46,75*46,76*46,77*46,78*46,79*46,80*46,81*46
	dc.w	81*46,80*46,79*46,78*46,77*46,76*46,75*46,74*46
	dc.w	73*46,72*46,71*46,70*46,69*46,68*46,67*46,66*46
	dc.w	65*46,64*46,63*46,62*46,61*46,60*46,59*46,58*46
	dc.w	57*46,56*46,55*46,54*46,53*46,52*46,51*46,50*46
	dc.w	49*46,48*46,47*46,46*46,45*46,44*46,43*46,42*46
	dc.w	41*46,40*46,39*46,38*46,37*46,36*46,35*46,34*46
	dc.w	33*46,32*46,31*46,30*46,29*46,28*46,27*46,26*46
	dc.w	25*46,24*46,23*46,22*46,21*46,20*46,19*46,18*46
	dc.w	17*46,16*46,15*46,14*46,13*46,12*46,11*46,10*46
	dc.w	9*46,8*46,7*46,6*46,5*46,4*46,3*46,2*46,1*46,0
log_sinf
;---------------------------------
swap_ecran	move.l	pointeur1(pc),d0
		move.l	pointeur2,pointeur1
		move.l	d0,pointeur2
		lea	bmap2(pc),a0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		rts
pointeur1	dc.l	plan1
pointeur2	dc.l	plan1bis
;---------------------------------
clearscreen	wait_blt
		move.l	#-1,$44(a6)
		move.l	#$01000000,$40(a6)
		move.w	#0,$66(a6)
		move.l	pointeur1(pc),d0
		add.l	#((173-110)/2)*44,d0	;ici
		move.l	d0,$54(a6)
		move.w	#110*64+22,$58(a6)	;et la 
		rts
;---------------------------------
p_lettre	ds.l	nb_let_maxi
p_angle		ds.w	nb_let_maxi
resultat	ds.b	240
;---------------------------------
avance_scroll
		lea	cos(pc),a0
		lea	sinus(pc),a1
		lea	resultat(pc),a3
		lea	p_lettre(pc),a4
		lea	p_angle(pc),a5
		move.w	#centre_x,d5
		move.w	#centre_y,d6
		moveq	#nb_let_maxi-1,d7
boucle		move.w	(a5),d0
		add.w	#vitesse_scroll,d0		;bouge l'angle
		and.l	#masque_angle,d0	;<1020
		move.w	d0,(a5)
no_new_let	tst.l	(a4)
		bne.s	no_espace
		addq.l	#4,a4		;incremente pointeur
		addq.w	#2,a5		;et angle
		move.w	#0,(a3)+	;espace
		dbra	d7,boucle
		bra.s	aff_droites

no_espace	move.l	(a4)+,a2
		move.w	(a5)+,d0

		move.w	(a2)+,d1	;nb_points-1
		move.w	(a2)+,(a3)+	;nb de droites-1 sauver
calcul		move.l	(a2)+,d2	;d2=r d3=ang1
		move.w	d2,d3
		swap	d2
		lsr	#1,d2
		add.w	d0,d3
		and.w	#%1111111111,d3	;<1024
		add.w	d3,d3		;paire
		move.w	(a1,d3.w),d4	;sin ang=y		
		move.w	(a0,d3.w),d3	;cos ang=x	
		muls	d2,d3		;rcos(ang)
		muls	d2,d4		;rsin(ang)
		swap	d3		;d3=r*cos(ang)=y
		swap	d4		;d4=r*sin(ang)=x
		add.w	d5,d3		;+centre de rotation
		add.w	d6,d4
		swap	d3
		move.w	d4,d3
		move.l	d3,(a3)+	;on sauve aussi x,y
		dbra	d1,calcul
		dbra	d7,boucle

aff_droites	lea	resultat(pc),a0
		move.l	#$ffff8000,d7
		lea	$40(a6),a1
		lea	$48(a6),a2
		lea	$52(a6),a3
		lea	$64(a6),a4
		lea	$72(a6),a5
		wait_blt
		move.l	#$80008000,$44(a6)	;44 et 46
		moveq	#44,d4		;modulo c et d
		move.w	d4,$60(a6)	;mod c
		move.w	d4,$66(a6)	;mod d
		moveq	#nb_let_maxi-1,d4
new_dessin	move.w	(a0)+,d5	;le nb de droites-1
		beq.s	espace
dessine		movem.w	(a0)+,d0-d3
		bsr.s	drawline
		subq	#4,a0
		dbra	d5,dessine
		addq	#4,a0
espace		dbra	d4,new_dessin
		rts
;---------------------------------
drawline
		movem.l	d4/d5,-(sp)
		cmp.w	d2,d0		;x1-x2
		bcs.s	x1petit
		exg	d2,d0		;sinon change les 2 pts
		exg	d3,d1
x1petit	
		sub.w	d0,d2		;x2-x1 deltax ds d2
		sub.w	d1,d3		;y2-y1 deltay ds d3
		mulu	#44,d1		;y1*nb d'octets par ligne
		moveq	#15,d4		;masque
		and.w	d0,d4		;4 bits de x1
		sub.w	d4,d0		;x1-larg ligne
		lsr.w	#3,d0		;division par 8
		add.w	d0,d1		;x+y
		move.l	pointeur1(pc),d6;add du plan
		add.w	d1,d6		;x+y+add du plan
		ror.w	#4,d4		;vers start0-3
		or.w	#$bca,d4	;init usex et lfx
		swap	d4
		tst.w	d3		;flag n restaur\E9
		bmi.s	deltay_neg	;si deltay negatif
		cmp.w	d2,d3		;deltay-deltax
		blt.s	deltay_sup	;si deltay>deltax
		exg	d3,d2
		bset	#0,d4		;octant move.w #1,d4
		bra.s	trace_droite
deltay_sup
		move.w	#17,d4		;octant
		bra.s	trace_droite
deltay_neg
		neg.w	d3		;inversion de deltay
		cmp.w	d2,d3		;deltax-deltay
		blt.s	deltay2_pos	;si deltay>deltax
		exg	d3,d2
		move.w	#5,d4		;octant
		bra.s	trace_droite
deltay2_pos
		move.w	#25,d4		;octant
trace_droite
		move.w	d2,d5		;deltax ds d5
		addq.w	#1,d5		;d5+1
		lsl.w	#6,d5		;*64
		addq.w	#2,d5		;+larg 2
		add.w	d3,d3		;petit delta*2
		move.w	d3,d0		;petit delta*2 ds d0
		sub.w	d2,d0		;2*pdelta-gdelta
		bpl.s	pdelta_sup	;si 2*pdelta>gdelta
		bset	#6,d4		;octant
pdelta_sup	
		add.w	d3,d3		;petit delta*4
		add.w	d2,d2		;2*deltax
		add.w	d2,d2		;4*deltax
		wait_blt
		move.w	d3,$62(a6)	;2*delta ds mod b
		sub.w	d2,d3		;2*pdelta-2gdelta
		move.w	d3,(a4)		;64	mod a
		move.l	d7,(a5)		;$72	bltbdat et masque
		move.l	d4,(a1)		;$40	bltcon0
		move.l	d6,(a2)		;$48	bptcpth
		move.w	d0,(a3)+	;$52	bltaptl
		move.l	d6,(a3)+	;$54	bltdpth
		move.w	d5,(a3)		;$58	bltsize
		subq.l	#6,a3
		movem.l	(sp)+,d4/d5
		rts
;---------------------------------
;nb_points,r,angle:on *2 pour eviter de faire un lsl ds la routine
;de calcul
;			nb_points,nb_droites

adr_C		dc.w	6-1,5-1
		dc.w	192,72,200,82,190,90,150,90
		dc.w	140,78,153,66
adr_E		dc.w	7-1,6-1
		dc.w	202,72,200,90,170,90,170,80,170,90,140,90,143,66
adr_I		dc.w	6-1,5-1
		dc.w	140,90,143,66,140,78,200,82,200,90,202,72
adr_M		dc.w	5-1,4-1
		dc.w	200,90,140,90,150,78,143,66,202,72
adr_N		dc.w	4-1,3-1
		dc.w	200,90,140,90,202,72,143,66
adr_R		dc.w	8-1,7-1
		dc.w	200,90,140,90,140,78,153,66,170,80,170,90
		dc.w	170,80,202,72
adr_U		dc.w	4-1,3-1
		dc.w	140,90,200,90,202,72,143,66
;---------------------------------
;effacer ancienne lettre
scroll	wait_blt
	move.l	#-1,$44(a6)
	clr.w	$66(a6)		;md 
	move.l	#$01000000,$40(a6)
	move.l	#ecran_scroll+8*46,$54(a6)	;d sur bpl
	move.w	#haut_pos*64+23,$58(a6)
	moveq	#0,d0
;*** calcul prochaine pos ***
	moveq	#nblettre-1,d3
	lea	boblettre(pc),a0
	lea	ecran_scroll+8*46,a4	;add du plan scroll1
	move.l	a4,a5
	wait_blt
	move.l	#$ffff0000,$44(a6)
	clr.w	$42(a6)
	move.l	#$0024002a,$64(a6)	;m a&d
	move.w	#$002a,$62(a6)		;m b
math	addq.l	#2,(a0)		;pointeur x
	cmp.l	#fcourbex,(a0)
	blt.s	vas_y
	move.l	#courbex+2,(a0)
	lea	ptexte(pc),a3
search	moveq	#0,d1
	move.l	(a3),a2
	move.b	(a2)+,d1
	addq.l	#1,(a3)
	tst.b	d1		;on est a la fin?
	bne.s	paslafin
	move.l	#texte,(a3)	;reset pointeur texte
	bra.s	search		;nouveau char.
paslafin
	sub.w	#" ",d1
	lsl.w	#2,d1
	lea	tablechars(pc),a2	;recherche du font dans la table
	move.l	(a2,d1.w),a2
	move.l	a2,8(a0)
vas_y	addq.l	#2,4(a0)	;pointeury
	cmp.l	#fcourbe,4(a0)
	blt.s	vas_y2
	move.l	#courbe,4(a0)
vas_y2	move.l	(a0),a1
	move.w	(a1),d0		;x
	move.l	4(a0),a2
	move.w	(a2),d1		;y*46
	move.w	d0,d2		;interpretation des coordonnees
	lsr.w	#3,d0		;x/8
	and.w	#$fffe,d0
	add.w	d1,d0
	add.l	d0,a5
	and.w	#$f,d2		;calcul d\E9calage
	ror.w	#4,d2
	or.w	#$dfc,d2
;*** aff lettre ***
;a=lettre b=decor
	move.l	8(a0),$50(a6)		;a
	move.l	a5,$4c(a6)		;b
	move.l	a5,$54(a6)		;d
	move.w	d2,$40(a6)		;zone tampon en +
	move.w	#8*64+2,$58(a6)		;bltsize
	add.w	#12,a0
	move.l	a4,a5
	dbf	d3,math
	rts
;****donnees1*****
texte	DC.B "YES, IT'S TRUE !!! PROFECY AGAIN !! YES PROFECY !! DO YOU REMEMBER "
	DC.B "NUMERIC VOL I ? YES ? SO PUMP UP THE VOLUME !! IT'S STARTED AGAIN ! "
	DC.B "        SPECTRE FOR CODING, WOOPER FOR THE ZIKS, FURIO AND ALE OF FAME"
	DC.B " FOR GFX PRESENT YOU:       NUMERIC II !!! (AH YEAAHHH!)       "
	DC.B "BEWARE! ALL ZIKS ON THIS MUSIK DISK HAS BEEN TESTED IN THE BIGGEST NIGHT-CLUB"
	DC.B " OF OUR CITY (ANGERS)... HIS NAME IS 'LE QUARTZ' (HELLO TO THE DJ: JEAN LUC, AND TO CHRISTIAN. EH, CHRIS,"
	dc.b " WHY ARE YOU CALLED 'MOMO'?!)...  !!!          ARE YOU A FAN ? "  
	DC.B "SO VOTE FOR US IN THE EUROCHARTS!!! PLEASE ! DIGITAL CONCERT ARE PURE SHIT!"
	DC.B " SO FAN OF TECHNO-DANCE-HOUSE VOTE FOR NUMERIC I AND II ! SUPPORT OUR JOB ! "
	DC.B "AND REMEMBER THAT WE ARE PROFECY WITH 'F' AND NOT PROPHECY !"
	DC.B " WE ARE NOT LAME CRACKERS... WE DO IT FOR FUN... (AND FOR GUINNESS!) "
	DC.B "         NOW, MESSAGES ARE FOLLOWING "
	DC.B ":                    "
	DC.B " HI ! SPECTRE IS HERE WITH THE REVENGE OF NUMERIC CALLED"
	DC.B " NUMERIC II... NOW WE CAN HEARD THREE MUSICS COMPOSED BY WOOPER. "
	DC.B "THESE MUSICS TAKE A LOT OF PLACE IN MEMORY (ABOUT 330K EACH MUSIC) SO IS NOT "
	DC.B "VERY EASY TO PLACE THEM ON THE DISK... MORE OVER, I GOT "
	DC.B "PROBLEMS WITH THE LOADER OF MUSIC... NOW I SEND SOME PERSONNALS"
	DC.B " MESSAGES: ALE OF FAME WHEN YOU BEGIN TO ORGANISE A PARTY (FOR THE 31 DECEMBER), DON'T " 
	DC.B "STOP IT AND DON'T GO WITH D2R2 WITHOUT SAY US... OK? HI WOOPER "
	DC.B "YOU WANTED TO BEGIN THE ASSEMBLER SO GOOD LUCK !!!... AND IF YOU "
	DC.B "WANTED ADVICES ABOUT THIS CALLED ME... HI LOOPING THANKS TO CAME TO HOME "
	DC.B "AT THE NIGHT OF THE NEW YEAR... NOW A REMARK ABOUT THE IRIS CONFERENCE,"
	DC.B " IT WAS SO BAD AND THE ORGANISATION WAS NOT VERY GOOD.... NOW IT'S UP TO "
	DC.B "YOU MY FRIENDS,.................."
	dc.b "HERE IS WOOPER ! I JUST WANT TO SAY TWO THINGS IN THIS SCROLL-TEXT : FIRST I WOULD LIKE "
	dc.b "SOMEONE TO EXPLAIN ME WHY THERE IS SO MUCH GAYS IN TECHNO-PARTY (OR I SHOULD SAY : "
	dc.b "'RAVE')? AND HERE ARE FOLLOWING SOME MESSAGES TO SOME OF MY CONTACTS IN THE AMIGA "
	dc.b "SCENE :         HI SLEDGE/ADEPT... NICE PHONE-CALL BUT COMMUNICATION "
	DC.B "WAS REALLY BAD AND YOU SPEAK ENGLISH WITH A GERMAN ACCENT..."
	DC.B "    HELLO TRASHER AND POWERSWAP OF HARDLINE... SO... WHAT ABOUT OUR"
	DC.B " LAST PRODUCT ? EH TRASHER!... SORRY FOR THE LAME STUFF AS YOU SAID"
	DC.B " BUT YOU KNOW, I'M NOT A SWAPPER... I'M GFX AND SFX (AND SOON CODER !)... SO IT'S RIGHT"
	DC.B " THAT MY NEWS ARE 1, 2 OR 3 WEEKS OLD... BUT I HOPE WE'LL KEEP ON "
	DC.B "SWAPPING AND THAT YOU'LL SEND ME MORE AND MORE PACKS FROM YOU... "
	DC.B "     HELLO MERY/EOC 1999... COOL SI TU PEUX METTRE NUMERIC II SUR BOARD..."
	DC.B "     ALOAH, HELIOTH/VEGA !  J'ESPERE QUE TU METTRA MON ARTICLE SUR "
	DC.B "LA IRIS PARTY DANS FREEDOM CRACK...      HI CORONAL/EXIT... TA VANNE "
	DC.B "SUR LE SPERME DE STROUMFE (PUTAIN CA S'ECRIT COMMENT?) A FAIT MARRE "
	DC.B "PLUS D'UNE PERSONNE A ANGERS!      HELLO HOOKED/DRIFTERS...  LE SADDAM"
	DC.B " KILLER DE BLUESKY M'A SAUVE LA VIE!!!     " 
	DC.b " AND A LAST MESSAGE TO THE MUSICIAN OF BASS : YOU DON'T KNOW ME, AND I DON'T"
	dc.b " KNOW YOU, BUT I WOULD LIKE TO SAY THAT YOUR TECHNO-SONG ARE REALLY GREAT (ARGH, "
	dc.b "'SUBLIMAL VISION'!), SO KEEP ON AND LET'S RAVE A GOOD TIME! THAT'S ALL FOR ME GUYS !"
	dc.b " JUST SOME FEW GREETZ TO THIS SMASHING TECHNO-MAKER : T-99 (OF COURSE) - "
	dc.b "CUBIC 22 - MODULAR EXPANSION - CHANNEL X - ANGEL ICE - PLEASURE GAME - BIZARRE INC -"
	dc.b " B-SIDES - QUADROPHONIA - ANTICO - HUMAN RESOURCE - DANSE CITY -"
	dc.b " D M S - BIZARRE INC - UNLIMITED             ... BYYYEEEEE !!!         "
	DC.B "ONE MORE TIME IT'S GRETZKY ON THE COMMAND FOR A BIG BIG "
	DC.B "BIG SCROLL !!! I'M IN THE N.Y.C 92 AND IT'S 4.57 AM AND I "
	DC.B "MUST TYPE THIS SCROLL COZ THE OTHERS MEMBERS DON'T WANT "
   	DC.B "TO MAKE IT !!! I'M VERY SORRY AND DISAPPOINTED COZ I"
	DC.B "'VE LOST IN SEMI-FINALS OF THE KICK OFF CUP !!! I HATE "
	DC.B "MAXXIMUM/INTENSE COZ IT'S HIM WHO 'VE BEAT ME !!! YOU "
	DC.B "WILL PAY A SO ACTION !!! HAAAAAAAAAAAAAAAAA THE FOOD "
	DC.B "COMES !!!! THIS CONFERENCE IS FINALY COOL ALTHOUGH THE "
	DC.B "TOO NUMEROUS PEOPLE AND THE FEW OF AMIGA AND PLACE !!! " 
	DC.B "I WANT TO SAY TO ALL OUR FANS (EUH ... Y EN A-T-IL ?) "
 	DC.B "THAT SPECTRE AND SPEED POWER DON'T WANT TO FINISH "
	DC.B "NUMERIC TRACK II AND IT'S WHY WE DON'T PRESENT IT "
	DC.B "TO THE N.Y.C !!! THEY ARE TOO LAZY !!! SNIIIIIIIIIIFFF "
	DC.B "BUT THEY CAN'T AVOID MY VENGEANCE !!! HEHEHEHEHEHEHE "
	DC.B "NOOOOOOOO SCAL I WILL MAKE A LONG SCROLL COZ I MUST "
	DC.B "MAKE IT !!! IT'S THE ONLY THING I'VE MADE FOR THIS "
	DC.B "COOL TRACKDISK AND THIS THING MUST BE IMPORTANT !!! "
	DC.B "YEAH SCAL SLEEP NOW I CAN SAY WHAT I WANT ABOUT YOU "
	DC.B "LIKE YOU'RE A BIG LAMER AND A SO LAZY CODER !!! "
	DC.B "NO IT'S JUST A JOKE BUT YOU COULD BRING YOUR COMPUTER "
	DC.B "DON'T YOU THINK ??? A KEYBOARD WITHOUT A MONITOR IS "
	DC.B "USELESS !!! "
	DC.B "I COME BACK LATER COZ I MUST MAKE A BIG SCROLL "
	DC.B "(COMME CA, TU AURAS MOINS DE PLACE SPECTRE HEHEHEE !!!!)            "
	dc.b	0
	EVEN
ptexte	dc.l texte
tablechars
	DC.L $0000+imglettre,$0002+imglettre,$0004+imglettre,$0006+imglettre,$0008+imglettre,$000A+imglettre
	DC.L $000C+imglettre,$000E+imglettre,$0010+imglettre,$0012+imglettre,$0014+imglettre,$0016+imglettre
	DC.L $0018+imglettre,$001A+imglettre,$001C+imglettre,$001E+imglettre,$0020+imglettre,$0022+imglettre
	DC.L $0024+imglettre,$0026+imglettre,$0140+imglettre,$0142+imglettre,$0144+imglettre,$0146+imglettre
	DC.L $0148+imglettre,$014a+imglettre,$014c+imglettre,$014e+imglettre,$0150+imglettre,$0152+imglettre
	DC.L $0154+imglettre,$0156+imglettre,$0158+imglettre,$015a+imglettre,$015c+imglettre,$015e+imglettre
	DC.L $0160+imglettre,$0162+imglettre,$0164+imglettre,$0166+imglettre,$0280+imglettre,$0282+imglettre
	DC.L $0284+imglettre,$0286+imglettre,$0288+imglettre,$028a+imglettre,$028c+imglettre,$028e+imglettre
	DC.L $0290+imglettre,$0292+imglettre,$0294+imglettre,$0296+imglettre,$0298+imglettre,$029a+imglettre
	DC.L $029c+imglettre,$029e+imglettre,$02a0+imglettre,$02a2+imglettre,$02a4+imglettre,$02a6+imglettre,$2a8+imglettre
boblettre	ds.w	nblettre*6
courbex	dc.w	344,342,340,338,336,334,332,330,328,326,324,322
	dc.w	320,318,316,314,312,310,308,306,304,302,300,298
	dc.w	296,294,292,290,288,286,284,282,280,278,276,274
	dc.w	272,270,268,266,264,262,260,258,256,254,252,250
	dc.w	248,246,244,242,240,238,236,234,232,230,228,226
	dc.w	224,222,220,218,216,214,212,210,208,206,204,202
	dc.w	200,198,196,194,192,190,188,186,184,182,180,178
	dc.w	176,174,172,170,168,166,164,162,160,158,156,154
	dc.w	152,150,148,146,144,142,140,138,136,134,132,130
	dc.w	128,126,124,122,120,118,116,114,112,110,108,106
	dc.w	104,102,100,98,96,94,92,90,88,86,84,82,80,78,76
	dc.w	74,72,70,68,66,64,62,60,58,56,54,52,50,48,46,44
	dc.w	42,40,38,36,34,32,30,28,26,24,22,20,18,16,14,12
	dc.w	10,8,6,4,2,0
fcourbex
courbe
	dc.w	39*46,38*46,37*46,35*46,33*46,31*46,29*46
	dc.w	26*46,24*46,21*46,18*46,15*46,13*46,10*46,8*46,6*46,4*46
	dc.w	3*46,2*46,2*46,1*46,1*46,1*46,2*46,2*46,3*46
	dc.w	4*46,6*46,8*46,10*46,13*46,15*46,18*46,21*46,24*46,26*46
	dc.w	29*46,31*46,33*46,35*46,37*46,38*46,39*46
fcourbe
imglettre	incbin font81bp
	even
;---------------------------------
haut_minilet=5
mx_let=16
pos_let=28+44*6*3
message		tst.w	drapeau
		bne	nouvel_let
		addq.w	#1,monte
		cmp.w	#7,monte
		beq	met_let
		wait_blt
		lea	plan2+28+44,a0
		lea	plan2+28,a1
		move.l	#$fffffffe,$44(a6)
		move.l	#$9f00000,$40(a6)
		move.l	a0,$50(a6)
		move.l	a1,$54(a6)
		move.l	#$00240024,$64(a6)	;a et d
		move.w	#23*64+4,$58(a6)
		rts
met_let		clr.w	monte
		lea	plan2+pos_let,a0
		clr.l	(a0)

		clr.l	44(a0)
		clr.l	44*2(a0)
		clr.l	44*3(a0)
		clr.l	44*4(a0)
		add.l	#4,a0
		clr.w	(a0)
		clr.w	44(a0)
		clr.w	44*2(a0)
		clr.w	44*3(a0)
		clr.w	44*4(a0)
		move.w	#1,drapeau
		
nouvel_let	subq.w	#1,pause
		bne	ret_vbl
		move.w	#4,pause
		move.l	mess,a0		;aff une lettre
		lea	table,a1	;add des lettres
		lea	plan2+pos_let,a3;add de destination
		move.l	pt_tble_pl,a5	;add pos
new_let		clr.l	d0
		move.b	(a0)+,d0
		tst.b	d0
		bne.s	suit_mess
		move.l	#mess_t,a0
		move.l	a0,mess
		bra.s	new_let
suit_mess	sub.l	#" ",d0
		lsl.w	#2,d0
		move.l	(a1,d0),a2	;on a l'add de la lettre
		clr.l	d3
		move.l	d3,d2
		moveq	#haut_minilet-1,d4
		move.w	(a5)+,d2	;on prend x
		move.w	d2,d3
		lsr.w	#3,d2		;octet
		add.w	d2,a3		;plan + octet
		and.w	#$7,d3		;decal
aff_mess	move.b	(a2),d0		;le dessin
		lsr.b	d3,d0		;decal si necessaire
		or.b	d0,(a3)		;sur plan
		addq.l	#2,a2		;dess suivant
		add.l	#44,a3		;ligne suivante
		dbf	d4,aff_mess
		move.l	a0,mess		;sauve add lettre
		cmp.w	#-1,(a5)
		bne.s	other_test
		move.l	#tble_pl,a5
other_test	move.l	a5,pt_tble_pl
		subq.w	#1,max_let
		bne.s	ret_vbl
		clr.w	drapeau
		move.w	#mx_let,max_let
ret_vbl		rts

monte	dc.w	0
pause	dc.w	6
drapeau	dc.w	1
max_let	dc.w	mx_let
pt_tble_pl	dc.l	tble_pl
tble_pl	dc.w	0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60
	dc.w	-1
table	dc.l	lt_mes,lt_mes+10,lt_mes+10*2,lt_mes+10*3,lt_mes+10*4
	dc.l	lt_mes+10*5,lt_mes+10*6,lt_mes+10*7,lt_mes+10*8
	dc.l	lt_mes+10*9,lt_mes+10*10,lt_mes+10*11,lt_mes+10*12
	dc.l	lt_mes+10*13,lt_mes+10*14,lt_mes+10*15,lt_mes+10*16
	dc.l	lt_mes+10*17,lt_mes+10*18,lt_mes+10*19,lt_mes+10*20
	dc.l	lt_mes+10*21,lt_mes+10*22,lt_mes+10*23,lt_mes+10*24
	dc.l	lt_mes+10*25,lt_mes+10*26,lt_mes+10*27,lt_mes+10*28
	dc.l	lt_mes+10*29,lt_mes+10*30,lt_mes+10*31,lt_mes+10*32
	dc.l	lt_mes2,lt_mes2+10,lt_mes2+10*2,lt_mes2+10*3,lt_mes2+10*4
	dc.l	lt_mes2+10*5,lt_mes2+10*6,lt_mes2+10*7,lt_mes2+10*8
	dc.l	lt_mes2+10*9,lt_mes2+10*10,lt_mes2+10*11,lt_mes2+10*12
	dc.l	lt_mes2+10*13,lt_mes2+10*14,lt_mes2+10*15,lt_mes2+10*16
	dc.l	lt_mes2+10*17,lt_mes2+10*18,lt_mes2+10*19,lt_mes2+10*20
	dc.l	lt_mes2+10*21,lt_mes2+10*22,lt_mes2+10*23,lt_mes2+10*24
	dc.l	lt_mes2+10*25,lt_mes2+10*26
mess	dc.l	mess_t
mess_t	dc.b	"                "
	dc.b	"SPECTRE EST ICI "
	dc.b	"POUR VOUS DIRE  "
	dc.b	"QUE CE SCROLL A "
	dc.b	" ETE REALISE A  "
	dc.b	" LA DEMANDE DE  "
	dc.b	"ALE OF FAME,...."
	dc.b	"( CELUI QUI NE  "
	dc.b	"QUI NE SAIS PAS "
	dc.b	" QUOI DIRE DANS "
	dc.b	" LES SCROLLS ET "
	dc.b	" QUI D'AILLEURS "
	dc.b	"NE VA JAMAIS LES"
	dc.b	"LIRE....( MERCI "
	dc.b	"QUAND MEME POUR "
	dc.b	"TON AIDE POUR LE"
	dc.b	" CHARGEMENT SUR "
	dc.b	" PISTE.........)"
	dc.b	"  ET GRETZKY :  "
	dc.b	" J'AI DU MAL A  "
	dc.b	" PRONONCER TON  "
	dc.b	"NOM ET SURTOUT A"
	dc.b	"   L'ECRIRE.    "
	dc.b	" LE VOILA ENFIN "
	dc.b	"NUMERIC 2, ALORS"
	dc.b	" NE GUEULE PLUS "
	dc.b	" ET SPREAD LE A "
	dc.b	"   MAX...OK !!! "
	dc.b	" QUAND A TOI EL "
	dc.b	"GRAPHISTE :FURIO" 
	dc.b	"ENVOIE MOI S'IL "
	dc.b	"TE PLAIT ! ...  "
	dc.b	"LA BIDOUILLE QUE"
	dc.b	"JE T'AI DEMANDE "
	dc.b	"MERCI D'AVANCE.."
	dc.b	"ET SPEEDPOWER LE"
	dc.b	"CODEUR BOEUF ..."
	dc.b	"QUAND TU FAIS UN"
	dc.b	"PROGRAMME ESSAI "
	dc.b	"LE AVANT,CAR TON"
	dc.b	" MENU IL PLANTE "
	dc.b	"TROP SOUVENT...?"
	dc.b	"HI TO SNAKER ..."
	dc.b	"CODY(EXIT),MOCK "
	dc.b	"(TSB),BELZEBUTH "
	dc.b	"(ZENITH) ET AUX "
	dc.b	"AUTRES.........."
	dc.b	"     SALUT      "
	dc.b	"C'EST WOOPER QUI"
	dc.b	"PREND LA RELEVE."
	dc.b	" NOUS SOMMES LE "
	dc.b	"5/01/92 ET C'EST"
	dc.b	"CE SOIR A MINUIT"
	dc.b	"  QUE CESSERA   "
	dc.b	" D'EMETTRE RADIO"
	dc.b	" MAXXIMUM. ALORS"
	dc.b	"JUSTE UNE PETITE"
	dc.b	"    PENSEE...   "
	dc.b	"PUTAIN KESCE QUE"
	dc.b	"JE VAIS ECOUTER "
	DC.B	"   MAINTENANT   "
	DC.B	"   LORSQUE JE   "
	DC.B	"FERAIS DU DPAINT"
	DC.B	"  OU DU DEVPAC  "
	DC.B	"  (EH OUI, JE   "
	DC.B	"COMMENCE A CODER"
	DC.B	"C'EST GALERE !!)"
	DC.B	"MON PREMIER PROG"
	DC.B	" SERA UN SLIDE  "
	DC.B	"CAR C'EST PLUTOT"
	DC.B	" SIMPLE A FAIRE!"
	DC.B	"  MAIS JE VOUS  "
	DC.B	" RASSURE, JE NE "
	DC.B	"SUIS RENDU QU'AU"
	DC.B	"CHAPITRE SUR LA "
	DC.B	"COPPER-LIST !!! "
	DC.B	"MAIS CA AVANCE !"
	DC.B	" DU MOINS CA NE "
	DC.B	" RECULE PAS !!! "
	DC.B	" BIENTOT, NOUS  "
	DC.B	" SORTIRONS UNE  "
	DC.B	"DEMO TECHNO QUI "
	DC.B	"VA FLASHER A MAX"
	DC.B	"  VOILA RIEN A  "
	DC.B	"AJOUTER... JUSTE"
	DC.B	"UN PETIT HELLO A"
	DC.B	" TOUT MES POTES "
	DC.B	"  EN EUROPE...  "
	DC.B	"(A LITTLE HELLO "
	DC.B	"TO MY FRIENDS IN"
	DC.B	" EUROPE) <- IN  "
	DC.B	" ENGLISH IN THE "
	DC.B	"TEXT FOR THE NON"
	DC.B	"FRENCH PEOPLE !!"
	DC.B	"  SO HELLO TO:  "
	DC.B	"  SLEDGE/ADEPT  "
	DC.B	" ALL IN HARDLINE"
	DC.B	"  HELIOTH/VEGA  "
	DC.B	" SLAUGHTER/TECH "
	DC.B	" ALL IN INTENSE "
	DC.B	" AND SORRY FOR  "
	DC.B	"  THE OTHERS !  "
	dc.b	" ALLEZ C'EST A  "
	dc.b	"TON TOUR GRETZKY"
	dc.b	"................"
	dc.b	" HI GRETZKY EST "
	dc.b	" AUSSI ICI POUR "
	dc.b	" LE MEILLEUR ET "
	dc.b	" POUR LE PIRE ! "
	dc.b	" MAIS C'EST DANS"
	dc.b	" LE PIRE QUE JE "
	dc.b	" SUIS LE BEST ! "
	dc.b	" SURTOUT A 5H12 "
	dc.b	" DU MAT APRES 3 "
	DC.B    " NUITS BLANCHES "
 	DC.B    " ET UN TOURNOI  "
	DC.B 	" DE KICK OFF 2! "
	DC.B 	" BON, C'EST AU  "
	DC.B 	" MOINS LE 100EME"
	DC.B 	" SCROLL K J'TAPE"
	DC.B 	" ALORS MERDE !! "
	DC.B 	" Y EN A MARRE ! "
	DC.B 	" MAIS N'HESITEZ "
	DC.B 	" PAS A ME CON-  "
	DC.B    " TACTER MAIS :  "
	DC.B 	" UNIQUEMENT DU  "
	DC.B 	" LEGAL STUFF OK?"
	DC.B 	"  VESCO FRANCK  "
	DC.B 	" 50 RUE JACOTOT "
	DC.B 	"      73100     "
	DC.B 	"  AIX-LES-BAINS "
	DC.B 	"     SAVOIE     "
	DC.B 	" OK SO BYE BYE !"
	DC.B 	"JE VAIS DORMIR !"
	DC.B 	"RORORORORORRNNNN"
	DC.B 	"RORORORORONRRONN"
	DC.B 	" CRAFTON TU ME  "
	DC.B 	"FAIS CHIER MERDE"
	DC.B 	"TON GROUPE PUE !"
	DC.B	"----------------"
	dc.b	"..UGH !...C'EST " 
	DC.B	"  ALE OF FAME   "
	DC.B	" POUR MOI, LES  "
	DC.B	" SCROLLS ME FONT"
	DC.B	"   CHIER ALORS  "
	DC.B	"     BONJOUR    "
	DC.B	"      CHEZ      "
	DC.B	"     VOUS !!    "
	DC.B	"----------------"


	dc.b	0
	even
lt_mes	incbin	4*51
lt_mes2	incbin	4*52
	even
;
mt_init:move.l	mt_data2,a0	;lea
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
	move.l	mt_data2,a0	;lea
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
	move.l	mt_data2,a0	;lea
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
	move.l	mt_data2,a0		;en+
	add.l	#$3b6,a0		;aussi
	cmp.b	(a0),d1
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
mt_samplestarts:ds.l	$1f
mt_voice1:	ds.w	10
		dc.w	$1
		ds.w	3
mt_voice2:	ds.w	10
		dc.w	$2
		ds.w	3
mt_voice3:	ds.w	10
		dc.w	$4
		ds.w	3
mt_voice4:	ds.w	10
		dc.w	$8
		ds.w	3
;--------------------------------------------
;table de 1024 valeurs (sin0 et cos0)*32768
sinus	
	dc.w	$8001,$8002
	dc.w	$8004,$8007,$800B,$8011,$8018,$8020,$8029,$8033
	dc.w	$803F,$804C,$805A,$806A,$807A,$808C,$809F,$80B4
	dc.w	$80C9,$80E0,$80F8,$8111,$812C,$8147,$8164,$8182
	dc.w	$81A2,$81C2,$81E4,$8207,$822B,$8250,$8277,$829F
	dc.w	$82C8,$82F2,$831E,$834A,$8378,$83A7,$83D7,$8409
	dc.w	$843C,$846F,$84A4,$84DB,$8512,$854B,$8584,$85BF
	dc.w	$85FC,$8639,$8677,$86B7,$86F8,$873A,$877D,$87C1
	dc.w	$8807,$884D,$8895,$88DE,$8928,$8973,$89C0,$8A0D
	dc.w	$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6,$8C4B,$8CA2
	dc.w	$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0,$8F1F,$8F7E
	dc.w	$8FDE,$9040,$90A2,$9106,$916B,$91D0,$9237,$929F
	dc.w	$9308,$9372,$93DD,$9449,$94B6,$9525,$9594,$9604
	dc.w	$9675,$96E7,$975B,$97CF,$9844,$98BB,$9932,$99AA
	dc.w	$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90,$9D0F,$9D8F
	dc.w	$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3,$A12A,$A1B1
	dc.w	$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1,$A57F,$A60D
	dc.w	$A69D,$A72D,$A7BE,$A850,$A8E3,$A977,$AA0C,$AAA1
	dc.w	$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32,$AECD,$AF69
	dc.w	$B006,$B0A3,$B141,$B1E0,$B280,$B320,$B3C1,$B463
	dc.w	$B506,$B5A9,$B64D,$B6F2,$B797,$B83D,$B8E4,$B98C
	dc.w	$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87,$BE33,$BEE0
	dc.w	$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9,$C3AA,$C45C
	dc.w	$C50E,$C5C1,$C674,$C728,$C7DC,$C891,$C947,$C9FD
	dc.w	$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C,$CF05,$CFBF
	dc.w	$D07A,$D134,$D1F0,$D2AC,$D368,$D425,$D4E2,$D59F
	dc.w	$D65D,$D71B,$D7DA,$D899,$D959,$DA19,$DAD9,$DB99
	dc.w	$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024,$E0E7,$E1AA
	dc.w	$E26D,$E331,$E3F5,$E4BA,$E57E,$E643,$E708,$E7CD
	dc.w	$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72,$ED39,$EE00
	dc.w	$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD,$F375,$F43D
	dc.w	$F505,$F5CE,$F696,$F75F,$F827,$F8F0,$F9B9,$FA82
	dc.w	$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37


	dc.w	0,$C9,$192,$25B,$324,$3ED,$4B6,$57E,$647,$710,$7D9
	dc.w	$8A1,$96A,$A32,$AFB,$BC3,$C8B,$D53,$E1B,$EE3,$FAB
	dc.w	$1072,$1139,$1200,$12C7,$138E,$1455,$151B,$15E1
	dc.w	$16A7,$176D,$1833,$18F8,$19BD,$1A82,$1B46,$1C0B
	dc.w	$1CCF,$1D93,$1E56,$1F19,$1FDC,$209F,$2161,$2223
	dc.w	$22E4,$23A6,$2467,$2527,$25E7,$26A7,$2767,$2826
	dc.w	$28E5,$29A3,$2A61,$2B1E,$2BDB,$2C98,$2D54,$2E10
	dc.w	$2ECC,$2F86,$3041,$30FB,$31B4,$326D,$3326,$33DE
	dc.w	$3496,$354D,$3603,$36B9,$376F,$3824,$38D8,$398C
	dc.w	$3A3F,$3AF2,$3BA4,$3C56,$3D07,$3DB7,$3E67,$3F16
	dc.w	$3FC5,$4073,$4120,$41CD,$4279,$4325,$43D0,$447A
	dc.w	$4523,$45CC,$4674,$471C,$47C3,$4869,$490E,$49B3
	dc.w	$4A57,$4AFA,$4B9D,$4C3F,$4CE0,$4D80,$4E20,$4EBF
	dc.w	$4F5D,$4FFA,$5097,$5133,$51CE,$5268,$5301,$539A
	dc.w	$5432,$54C9,$555F,$55F4,$5689,$571D,$57B0,$5842
	dc.w	$58D3,$5963,$59F3,$5A81,$5B0F,$5B9C,$5C28,$5CB3
	dc.w	$5D3D,$5DC6,$5E4F,$5ED6,$5F5D,$5FE2,$6067,$60EB
	dc.w	$616E,$61F0,$6271,$62F1,$6370,$63EE,$646B,$64E7
	dc.w	$6562,$65DD,$6656,$66CE,$6745,$67BC,$6831,$68A5
	dc.w	$6919,$698B,$69FC,$6A6C,$6ADB,$6B4A,$6BB7,$6C23
	dc.w	$6C8E,$6CF8,$6D61,$6DC9,$6E30,$6E95,$6EFA,$6F5E
	dc.w	$6FC0,$7022,$7082,$70E1,$7140,$719D,$71F9,$7254
	dc.w	$72AE,$7306,$735E,$73B5,$740A,$745E,$74B1,$7503
	dc.w	$7554,$75A4,$75F3,$7640,$768D,$76D8,$7722,$776B
	dc.w	$77B3,$77F9,$783F,$7883,$78C6,$7908,$7949,$7989
	dc.w	$79C7,$7A04,$7A41,$7A7C,$7AB5,$7AEE,$7B25,$7B5C
	dc.w	$7B91,$7BC4,$7BF7,$7C29,$7C59,$7C88,$7CB6,$7CE2
	dc.w	$7D0E,$7D38,$7D61,$7D89,$7DB0,$7DD5,$7DF9,$7E1C
	dc.w	$7E3E,$7E5E,$7E7E,$7E9C,$7EB9,$7ED4,$7EEF,$7F08
	dc.w	$7F20,$7F37,$7F4C,$7F61,$7F74,$7F86,$7F96,$7FA6
	dc.w	$7FB4,$7FC1,$7FCD,$7FD7,$7FE0,$7FE8,$7FEF,$7FF5
	dc.w	$7FF9,$7FFC,$7FFE,$7FFF,$7FFE,$7FFC,$7FF9,$7FF5
	dc.w	$7FEF,$7FE8,$7FE0,$7FD7,$7FCD,$7FC1,$7FB4,$7FA6
	dc.w	$7F96,$7F86,$7F74,$7F61,$7F4C,$7F37,$7F20,$7F08
	dc.w	$7EEF,$7ED4,$7EB9,$7E9C,$7E7E,$7E5E,$7E3E,$7E1C
	dc.w	$7DF9,$7DD5,$7DB0,$7D89,$7D61,$7D38,$7D0E,$7CE2
	dc.w	$7CB6,$7C88,$7C59,$7C29,$7BF7,$7BC4,$7B91,$7B5C
	dc.w	$7B25,$7AEE,$7AB5,$7A7C,$7A41,$7A04,$79C7,$7989
	dc.w	$7949,$7908,$78C6,$7883,$783F,$77F9,$77B3,$776B
	dc.w	$7722,$76D8,$768D,$7640,$75F3,$75A4,$7554,$7503
	dc.w	$74B1,$745E,$740A,$73B5,$735E,$7306,$72AE,$7254
	dc.w	$71F9,$719D,$7140,$70E1,$7082,$7022,$6FC0,$6F5E
	dc.w	$6EFA,$6E95,$6E30,$6DC9,$6D61,$6CF8,$6C8E,$6C23
	dc.w	$6BB7,$6B4A,$6ADB,$6A6C,$69FC,$698B,$6919,$68A5
	dc.w	$6831,$67BC,$6745,$66CE,$6656,$65DD,$6562,$64E7
	dc.w	$646B,$63EE,$6370,$62F1,$6271,$61F0,$616E,$60EB
	dc.w	$6067,$5FE2,$5F5D,$5ED6,$5E4F,$5DC6,$5D3D,$5CB3
	dc.w	$5C28,$5B9C,$5B0F,$5A81,$59F3,$5963,$58D3,$5842
	dc.w	$57B0,$571D,$5689,$55F4,$555F,$54C9,$5432,$539A
	dc.w	$5301,$5268,$51CE,$5133,$5097,$4FFA,$4F5D,$4EBF
	dc.w	$4E20,$4D80,$4CE0,$4C3F,$4B9D,$4AFA,$4A57,$49B3
	dc.w	$490E,$4869,$47C3,$471C,$4674,$45CC,$4523,$447A
	dc.w	$43D0,$4325,$4279,$41CD,$4120,$4073,$3FC5,$3F16
	dc.w	$3E67,$3DB7,$3D07,$3C56,$3BA4,$3AF2,$3A3F,$398C
	dc.w	$38D8,$3824,$376F,$36B9,$3603,$354D,$3496,$33DE
	dc.w	$3326,$326D,$31B4,$30FB,$3041,$2F86,$2ECC,$2E10
	dc.w	$2D54,$2C98,$2BDB,$2B1E,$2A61,$29A3,$28E5,$2826
	dc.w	$2767,$26A7,$25E7,$2527,$2467,$23A6,$22E4,$2223
	dc.w	$2161,$209F,$1FDC,$1F19,$1E56,$1D93,$1CCF,$1C0B
	dc.w	$1B46,$1A82,$19BD,$18F8,$1833,$176D,$16A7,$15E1
	dc.w	$151B,$1455,$138E,$12C7,$1200,$1139,$1072,$FAB,$EE3
	dc.w	$E1B,$D53,$C8B,$BC3,$AFB,$A32,$96A,$8A1,$7D9,$710
	dc.w	$647,$57E,$4B6,$3ED,$324,$25B,$192,$C9,0,$FF37
	dc.w	$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82,$F9B9,$F8F0
	dc.w	$F827,$F75F,$F696,$F5CE,$F505,$F43D,$F375,$F2AD
	dc.w	$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00,$ED39,$EC72
	dc.w	$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD,$E708,$E643
	dc.w	$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA,$E0E7,$E024
	dc.w	$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99,$DAD9,$DA19
	dc.w	$D959,$D899,$D7DA,$D71B,$D65D,$D59F,$D4E2,$D425
	dc.w	$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF,$CF05,$CE4C
	dc.w	$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD,$C947,$C891
	dc.w	$C7DC,$C728,$C674,$C5C1,$C50E,$C45C,$C3AA,$C2F9
	dc.w	$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0,$BE33,$BD87
	dc.w	$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C,$B8E4,$B83D
	dc.w	$B797,$B6F2,$B64D,$B5A9,$B506,$B463,$B3C1,$B320
	dc.w	$B280,$B1E0,$B141,$B0A3,$B006,$AF69,$AECD,$AE32
	dc.w	$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1,$AA0C,$A977
	dc.w	$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D,$A57F,$A4F1
	dc.w	$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1,$A12A,$A0A3
	dc.w	$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F,$9D0F,$9C90
	dc.w	$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA,$9932,$98BB
	dc.w	$9844,$97CF,$975B,$96E7,$9675,$9604,$9594,$9525
	dc.w	$94B6,$9449,$93DD,$9372,$9308,$929F,$9237,$91D0
	dc.w	$916B,$9106,$90A2,$9040,$8FDE,$8F7E,$8F1F,$8EC0
	dc.w	$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2,$8C4B,$8BF6
	dc.w	$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D,$89C0,$8973
	dc.w	$8928,$88DE,$8895,$884D,$8807,$87C1,$877D,$873A
	dc.w	$86F8,$86B7,$8677,$8639,$85FC,$85BF,$8584,$854B
	dc.w	$8512,$84DB,$84A4,$846F,$843C,$8409,$83D7,$83A7
	dc.w	$8378,$834A,$831E,$82F2,$82C8,$829F,$8277,$8250
	dc.w	$822B,$8207,$81E4,$81C2,$81A2,$8182,$8164,$8147
	dc.w	$812C,$8111,$80F8,$80E0,$80C9,$80B4,$809F,$808C
	dc.w	$807A,$806A,$805A,$804C,$803F,$8033,$8029,$8020
	dc.w	$8018,$8011,$800B,$8007,$8004,$8002,$8001,$8002

	dc.w	$8004,$8007,$800B,$8011,$8018,$8020,$8029,$8033
	dc.w	$803F,$804C,$805A,$806A,$807A,$808C,$809F,$80B4
	dc.w	$80C9,$80E0,$80F8,$8111,$812C,$8147,$8164,$8182
	dc.w	$81A2,$81C2,$81E4,$8207,$822B,$8250,$8277,$829F
	dc.w	$82C8,$82F2,$831E,$834A,$8378,$83A7,$83D7,$8409
	dc.w	$843C,$846F,$84A4,$84DB,$8512,$854B,$8584,$85BF
	dc.w	$85FC,$8639,$8677,$86B7,$86F8,$873A,$877D,$87C1
	dc.w	$8807,$884D,$8895,$88DE,$8928,$8973,$89C0,$8A0D
	dc.w	$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6,$8C4B,$8CA2
	dc.w	$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0,$8F1F,$8F7E
	dc.w	$8FDE,$9040,$90A2,$9106,$916B,$91D0,$9237,$929F
	dc.w	$9308,$9372,$93DD,$9449,$94B6,$9525,$9594,$9604
	dc.w	$9675,$96E7,$975B,$97CF,$9844,$98BB,$9932,$99AA
	dc.w	$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90,$9D0F,$9D8F
	dc.w	$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3,$A12A,$A1B1
	dc.w	$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1,$A57F,$A60D
	dc.w	$A69D,$A72D,$A7BE,$A850,$A8E3,$A977,$AA0C,$AAA1
	dc.w	$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32,$AECD,$AF69
	dc.w	$B006,$B0A3,$B141,$B1E0,$B280,$B320,$B3C1,$B463
	dc.w	$B506,$B5A9,$B64D,$B6F2,$B797,$B83D,$B8E4,$B98C
	dc.w	$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87,$BE33,$BEE0
	dc.w	$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9,$C3AA,$C45C
	dc.w	$C50E,$C5C1,$C674,$C728,$C7DC,$C891,$C947,$C9FD
	dc.w	$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C,$CF05,$CFBF
	dc.w	$D07A,$D134,$D1F0,$D2AC,$D368,$D425,$D4E2,$D59F
	dc.w	$D65D,$D71B,$D7DA,$D899,$D959,$DA19,$DAD9,$DB99
	dc.w	$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024,$E0E7,$E1AA
	dc.w	$E26D,$E331,$E3F5,$E4BA,$E57E,$E643,$E708,$E7CD
	dc.w	$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72,$ED39,$EE00
	dc.w	$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD,$F375,$F43D
	dc.w	$F505,$F5CE,$F696,$F75F,$F827,$F8F0,$F9B9,$FA82
	dc.w	$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37
cos	
	dc.w	$FC13,$FCDC
	dc.w	$FDA5,$FE6E,$FF37,0,$C9,$192,$25B,$324,$3ED,$4B6
	dc.w	$57E,$647,$710,$7D9,$8A1,$96A,$A32,$AFB,$BC3,$C8B
	dc.w	$D53,$E1B,$EE3,$FAB,$1072,$1139,$1200,$12C7,$138E
	dc.w	$1455,$151B,$15E1,$16A7,$176D,$1833,$18F8,$19BD
	dc.w	$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56,$1F19,$1FDC
	dc.w	$209F,$2161,$2223,$22E4,$23A6,$2467,$2527,$25E7
	dc.w	$26A7,$2767,$2826,$28E5,$29A3,$2A61,$2B1E,$2BDB
	dc.w	$2C98,$2D54,$2E10,$2ECC,$2F86,$3041,$30FB,$31B4
	dc.w	$326D,$3326,$33DE,$3496,$354D,$3603,$36B9,$376F
	dc.w	$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4,$3C56,$3D07
	dc.w	$3DB7,$3E67,$3F16,$3FC5,$4073,$4120,$41CD,$4279
	dc.w	$4325,$43D0,$447A,$4523,$45CC,$4674,$471C,$47C3
	dc.w	$4869,$490E,$49B3,$4A57,$4AFA,$4B9D,$4C3F,$4CE0
	dc.w	$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097,$5133,$51CE
	dc.w	$5268,$5301,$539A,$5432,$54C9,$555F,$55F4,$5689
	dc.w	$571D,$57B0,$5842,$58D3,$5963,$59F3,$5A81,$5B0F
	dc.w	$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F,$5ED6,$5F5D
	dc.w	$5FE2,$6067,$60EB,$616E,$61F0,$6271,$62F1,$6370
	dc.w	$63EE,$646B,$64E7,$6562,$65DD,$6656,$66CE,$6745
	dc.w	$67BC,$6831,$68A5,$6919,$698B,$69FC,$6A6C,$6ADB
	dc.w	$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61,$6DC9,$6E30
	dc.w	$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082,$70E1,$7140
	dc.w	$719D,$71F9,$7254,$72AE,$7306,$735E,$73B5,$740A
	dc.w	$745E,$74B1,$7503,$7554,$75A4,$75F3,$7640,$768D
	dc.w	$76D8,$7722,$776B,$77B3,$77F9,$783F,$7883,$78C6
	dc.w	$7908,$7949,$7989,$79C7,$7A04,$7A41,$7A7C,$7AB5
	dc.w	$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7,$7C29,$7C59
	dc.w	$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61,$7D89,$7DB0
	dc.w	$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E,$7E9C,$7EB9
	dc.w	$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C,$7F61,$7F74
	dc.w	$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD,$7FD7,$7FE0
	dc.w	$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE


	dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0
	dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74
	dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9
	dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0
	dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59
	dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5
	dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6
	dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D
	dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A
	dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140
	dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30
	dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB
	dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745
	dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370
	dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D
	dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F
	dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689
	dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE
	dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0
	dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3
	dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279
	dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07
	dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F
	dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4
	dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB
	dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7
	dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC
	dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD
	dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E
	dc.w	$12C7,$1200,$1139,$1072,$FAB,$EE3,$E1B,$D53,$C8B
	dc.w	$BC3,$AFB,$A32,$96A,$8A1,$7D9,$710,$647,$57E,$4B6
	dc.w	$3ED,$324,$25B,$192,$C9,0,$FF37,$FE6E,$FDA5,$FCDC
	dc.w	$FC13,$FB4A,$FA82,$F9B9,$F8F0,$F827,$F75F,$F696
	dc.w	$F5CE,$F505,$F43D,$F375,$F2AD,$F1E5,$F11D,$F055
	dc.w	$EF8E,$EEC7,$EE00,$ED39,$EC72,$EBAB,$EAE5,$EA1F
	dc.w	$E959,$E893,$E7CD,$E708,$E643,$E57E,$E4BA,$E3F5
	dc.w	$E331,$E26D,$E1AA,$E0E7,$E024,$DF61,$DE9F,$DDDD
	dc.w	$DD1C,$DC5A,$DB99,$DAD9,$DA19,$D959,$D899,$D7DA
	dc.w	$D71B,$D65D,$D59F,$D4E2,$D425,$D368,$D2AC,$D1F0
	dc.w	$D134,$D07A,$CFBF,$CF05,$CE4C,$CD93,$CCDA,$CC22
	dc.w	$CB6A,$CAB3,$C9FD,$C947,$C891,$C7DC,$C728,$C674
	dc.w	$C5C1,$C50E,$C45C,$C3AA,$C2F9,$C249,$C199,$C0EA
	dc.w	$C03B,$BF8D,$BEE0,$BE33,$BD87,$BCDB,$BC30,$BB86
	dc.w	$BADD,$BA34,$B98C,$B8E4,$B83D,$B797,$B6F2,$B64D
	dc.w	$B5A9,$B506,$B463,$B3C1,$B320,$B280,$B1E0,$B141
	dc.w	$B0A3,$B006,$AF69,$AECD,$AE32,$AD98,$ACFF,$AC66
	dc.w	$ABCE,$AB37,$AAA1,$AA0C,$A977,$A8E3,$A850,$A7BE
	dc.w	$A72D,$A69D,$A60D,$A57F,$A4F1,$A464,$A3D8,$A34D
	dc.w	$A2C3,$A23A,$A1B1,$A12A,$A0A3,$A01E,$9F99,$9F15
	dc.w	$9E92,$9E10,$9D8F,$9D0F,$9C90,$9C12,$9B95,$9B19
	dc.w	$9A9E,$9A23,$99AA,$9932,$98BB,$9844,$97CF,$975B
	dc.w	$96E7,$9675,$9604,$9594,$9525,$94B6,$9449,$93DD
	dc.w	$9372,$9308,$929F,$9237,$91D0,$916B,$9106,$90A2
	dc.w	$9040,$8FDE,$8F7E,$8F1F,$8EC0,$8E63,$8E07,$8DAC
	dc.w	$8D52,$8CFA,$8CA2,$8C4B,$8BF6,$8BA2,$8B4F,$8AFD
	dc.w	$8AAC,$8A5C,$8A0D,$89C0,$8973,$8928,$88DE,$8895
	dc.w	$884D,$8807,$87C1,$877D,$873A,$86F8,$86B7,$8677
	dc.w	$8639,$85FC,$85BF,$8584,$854B,$8512,$84DB,$84A4
	dc.w	$846F,$843C,$8409,$83D7,$83A7,$8378,$834A,$831E
	dc.w	$82F2,$82C8,$829F,$8277,$8250,$822B,$8207,$81E4
	dc.w	$81C2,$81A2,$8182,$8164,$8147,$812C,$8111,$80F8
	dc.w	$80E0,$80C9,$80B4,$809F,$808C,$807A,$806A,$805A
	dc.w	$804C,$803F,$8033,$8029,$8020,$8018,$8011,$800B
	dc.w	$8007,$8004,$8002,$8001,$8002,$8004,$8007,$800B
	dc.w	$8011,$8018,$8020,$8029,$8033,$803F,$804C,$805A
	dc.w	$806A,$807A,$808C,$809F,$80B4,$80C9,$80E0,$80F8
	dc.w	$8111,$812C,$8147,$8164,$8182,$81A2,$81C2,$81E4
	dc.w	$8207,$822B,$8250,$8277,$829F,$82C8,$82F2,$831E
	dc.w	$834A,$8378,$83A7,$83D7,$8409,$843C,$846F,$84A4
	dc.w	$84DB,$8512,$854B,$8584,$85BF,$85FC,$8639,$8677
	dc.w	$86B7,$86F8,$873A,$877D,$87C1,$8807,$884D,$8895
	dc.w	$88DE,$8928,$8973,$89C0,$8A0D,$8A5C,$8AAC,$8AFD
	dc.w	$8B4F,$8BA2,$8BF6,$8C4B,$8CA2,$8CFA,$8D52,$8DAC
	dc.w	$8E07,$8E63,$8EC0,$8F1F,$8F7E,$8FDE,$9040,$90A2
	dc.w	$9106,$916B,$91D0,$9237,$929F,$9308,$9372,$93DD
	dc.w	$9449,$94B6,$9525,$9594,$9604,$9675,$96E7,$975B
	dc.w	$97CF,$9844,$98BB,$9932,$99AA,$9A23,$9A9E,$9B19
	dc.w	$9B95,$9C12,$9C90,$9D0F,$9D8F,$9E10,$9E92,$9F15
	dc.w	$9F99,$A01E,$A0A3,$A12A,$A1B1,$A23A,$A2C3,$A34D
	dc.w	$A3D8,$A464,$A4F1,$A57F,$A60D,$A69D,$A72D,$A7BE
	dc.w	$A850,$A8E3,$A977,$AA0C,$AAA1,$AB37,$ABCE,$AC66
	dc.w	$ACFF,$AD98,$AE32,$AECD,$AF69,$B006,$B0A3,$B141
	dc.w	$B1E0,$B280,$B320,$B3C1,$B463,$B506,$B5A9,$B64D
	dc.w	$B6F2,$B797,$B83D,$B8E4,$B98C,$BA34,$BADD,$BB86
	dc.w	$BC30,$BCDB,$BD87,$BE33,$BEE0,$BF8D,$C03B,$C0EA
	dc.w	$C199,$C249,$C2F9,$C3AA,$C45C,$C50E,$C5C1,$C674
	dc.w	$C728,$C7DC,$C891,$C947,$C9FD,$CAB3,$CB6A,$CC22
	dc.w	$CCDA,$CD93,$CE4C,$CF05,$CFBF,$D07A,$D134,$D1F0
	dc.w	$D2AC,$D368,$D425,$D4E2,$D59F,$D65D,$D71B,$D7DA
	dc.w	$D899,$D959,$DA19,$DAD9,$DB99,$DC5A,$DD1C,$DDDD
	dc.w	$DE9F,$DF61,$E024,$E0E7,$E1AA,$E26D,$E331,$E3F5
	dc.w	$E4BA,$E57E,$E643,$E708,$E7CD,$E893,$E959,$EA1F
	dc.w	$EAE5,$EBAB,$EC72,$ED39,$EE00,$EEC7,$EF8E,$F055
	dc.w	$F11D,$F1E5,$F2AD,$F375,$F43D,$F505,$F5CE,$F696
	dc.w	$F75F,$F827,$F8F0,$F9B9,$FA82,$FB4A,$FC13,$FCDC

	dc.w	$FDA5,$FE6E,$FF37,0,$C9,$192,$25B,$324,$3ED,$4B6
	dc.w	$57E,$647,$710,$7D9,$8A1,$96A,$A32,$AFB,$BC3,$C8B
	dc.w	$D53,$E1B,$EE3,$FAB,$1072,$1139,$1200,$12C7,$138E
	dc.w	$1455,$151B,$15E1,$16A7,$176D,$1833,$18F8,$19BD
	dc.w	$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56,$1F19,$1FDC
	dc.w	$209F,$2161,$2223,$22E4,$23A6,$2467,$2527,$25E7
	dc.w	$26A7,$2767,$2826,$28E5,$29A3,$2A61,$2B1E,$2BDB
	dc.w	$2C98,$2D54,$2E10,$2ECC,$2F86,$3041,$30FB,$31B4
	dc.w	$326D,$3326,$33DE,$3496,$354D,$3603,$36B9,$376F
	dc.w	$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4,$3C56,$3D07
	dc.w	$3DB7,$3E67,$3F16,$3FC5,$4073,$4120,$41CD,$4279
	dc.w	$4325,$43D0,$447A,$4523,$45CC,$4674,$471C,$47C3
	dc.w	$4869,$490E,$49B3,$4A57,$4AFA,$4B9D,$4C3F,$4CE0
	dc.w	$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097,$5133,$51CE
	dc.w	$5268,$5301,$539A,$5432,$54C9,$555F,$55F4,$5689
	dc.w	$571D,$57B0,$5842,$58D3,$5963,$59F3,$5A81,$5B0F
	dc.w	$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F,$5ED6,$5F5D
	dc.w	$5FE2,$6067,$60EB,$616E,$61F0,$6271,$62F1,$6370
	dc.w	$63EE,$646B,$64E7,$6562,$65DD,$6656,$66CE,$6745
	dc.w	$67BC,$6831,$68A5,$6919,$698B,$69FC,$6A6C,$6ADB
	dc.w	$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61,$6DC9,$6E30
	dc.w	$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082,$70E1,$7140
	dc.w	$719D,$71F9,$7254,$72AE,$7306,$735E,$73B5,$740A
	dc.w	$745E,$74B1,$7503,$7554,$75A4,$75F3,$7640,$768D
	dc.w	$76D8,$7722,$776B,$77B3,$77F9,$783F,$7883,$78C6
	dc.w	$7908,$7949,$7989,$79C7,$7A04,$7A41,$7A7C,$7AB5
	dc.w	$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7,$7C29,$7C59
	dc.w	$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61,$7D89,$7DB0
	dc.w	$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E,$7E9C,$7EB9
	dc.w	$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C,$7F61,$7F74
	dc.w	$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD,$7FD7,$7FE0
	dc.w	$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE
;------------------------------------
;donnees
coularc
	dc.w	$e00,$e02,$e04,$e06,$e08,$e0a,$e0c,$e0e	;43 couls
	dc.w	$c0e,$a0e,$80e,$60e,$40e,$20e,$00e
	dc.w	$02e,$04e,$08e,$0ae,$0ae,$0ce,$0ee
	dc.w	$0ec,$0ea,$0e8,$0e6,$0e4,$0e2,$0e0
	dc.w	$2e0,$4e0,$6e0,$8e0,$ae0,$ce0,$ee0
	dc.w	$ec0,$ea0,$e80,$e60,$e40,$e20,$e00

	dc.w	$e00,$e02,$e04,$e06,$e08,$e0a,$e0c,$e0e
	dc.w	$c0e,$a0e,$80e,$60e,$40e,$20e,$00e

coularc2
	dc.w	$fb5,$fb4,$fb3,$fa3,$f93,$f94,$f95
	dc.w	$e95,$d95,$da5,$db5,$db4,$db3,$eb3
	dc.w	$fb3,$fb4			;16 couls
	dc.w	$fb5,$fb4,$fb3,$fa3,$f93,$f94,$f95
	dc.w	$e95,$d95,$da5,$db5,$db4,$db3,$eb3

coularc3
	dc.w	$fb5,$fb3,$fb1,$f93,$f73,$f73,$f75
	dc.w	$d75,$b75,$b95,$bb5,$bb3,$bb1,$db1
	dc.w	$fb3,$fb5			;16 couls
	dc.w	$fb5,$fb3,$fb1,$f93,$f73,$f73,$f75
	dc.w	$d75,$b75,$b95,$bb5,$bb3,$bb1,$db1

ptrarc	dc.w	0
;------------------------------------
copperlist
	dc.w	$8e,$2471,$90,$2dd1
	dc.w	$92,$0030,$94,$00d8
	dc.w	$100,$5200,$102,0,$104,$24,$108,2,$10a,2	;plan logo
bmap	dc.w	$e0,0,$e2,0,$e4,0,$e6,0,$e8,0,$ea,0
	dc.w	$ec,0,$ee,0,$f0,0,$f2,0
spr_pt	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0
	dc.w	$180,$000,$182,$fff,$184,$dde,$186,$bbd
	dc.w	$188,$99c,$18a,$88b,$18c,$66a,$18e,$559
	dc.w	$190,$448,$192,$337,$194,$226,$196,$115
	dc.w	$198,$114,$19a,$003,$19c,$002,$19e,$001
	dc.w	$1a0,$fff,$1a2,$fff,$1a4,$fff,$1a6,$fff
	dc.w	$1a8,$fff,$1aa,$fff,$1ac,$fff,$1ae,$fff
	dc.w	$1b0,$fff,$1b2,$fff,$1b4,$fff,$1b6,$fff
	dc.w	$1b8,$fff,$1ba,$fff,$1bc,$fff,$1be,$fff
	dc.w	$610f,$fffe,$100,$0200
	dc.w	$102,0,$108,0,$10a,0;2eme plan
bmap2	dc.w	$e0,0,$e2,0,$e4,0,$e6,0,$e8,0,$ea,0
	dc.w	$ec,0,$ee,0,$f0,0,$f2,0
	dc.l	$1840fb5,$1880ff9,$18c0c82,$1900fe8,$1940a60
	dc.l	$1980730,$19c0400
	dc.l	$1800000,$1820000,$1860000,$18a0000,$18e0000
	dc.l	$1920000,$1960000,$19a0000,$19e0000
	dc.w	$6231,$fffe
roller1	ds.w	rolsize
	dc.w	$700f,$fffe,$100,$5200
	
arcciel
	dc.l	$01a00f00,$01a20000,$01a40d02,$01a60000
	dc.l	$01a80b04,$01aa0000,$01ac0906,$01ae0000
	dc.l	$01b00708,$01b20000,$01b4050a,$01b60000
	dc.l	$01b8030c,$01ba0000,$01bc010e,$01be0000
copdb
	dc.w	$7135,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$71c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7235,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$72c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7335,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$73c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7435,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$74c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7535,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$75c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$7b35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$7bc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7c35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$7cc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7d35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$7dc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7e35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$7ec5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$7f35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$7fc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$8535,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$85c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$8635,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$86c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$8735,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$87c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$8835,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$88c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$8935,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$89c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$8f35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$8fc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9035,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$90c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9135,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$91c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9235,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$92c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9335,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$93c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$9935,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$99c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9a35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$9ac5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9b35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$9bc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9c35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$9cc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$9d35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$9dc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$a335,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$a3c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$a435,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$a4c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$a535,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$a5c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$a635,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$a6c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$a735,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$a7c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$ad35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$adc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ae35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$aec5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$af35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$afc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$b035,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$b0c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$b135,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$b1c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$b735,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$b7c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$b835,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$b8c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$b935,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$b9c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ba35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$bac5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$bb35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$bbc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$c135,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$c1c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$c235,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$c2c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$c335,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$c3c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$c435,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$c4c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$c535,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$c5c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$cb35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$cbc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$cc35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$ccc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$cd35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$cdc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ce35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$cec5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$cf35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$cfc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$d535,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$d5c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$d635,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$d6c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$d735,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$d7c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$d835,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$d8c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$d935,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$d9c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$df35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$dfc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$e035,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$e0c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$e135,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$e1c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$e235,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$e2c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$e335,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$e3c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$e935,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$e9c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ea35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$eac5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$eb35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$ebc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ec35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$ecc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ed35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$edc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$f335,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$f3c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$f435,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$f4c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$f535,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$f5c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$f635,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$f6c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$f735,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$f7c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$fd35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$fdc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$fe35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$fec5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$ff35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$ffc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$0035,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$00c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$0135,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$01c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9

	dc.w	$0735,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$07c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$0835,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$08c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$0935,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$09c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
	dc.w	$0a35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$0ac5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0
copdb2
	dc.w	$0b35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$0bc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0,cdb,$ff9
;c'est celui la pour la fin
	dc.w	$0c35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$0cc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0

	dc.w	$0d35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$0dc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0

	dc.w	$0e35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$0ec5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0

	dc.w	$0f35,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$0fc5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0

	dc.w	$1035,$fffe,cdb,$0,cdb,$0,cdb,$ff9
	dc.w	cdb,$0,cdb,$0,cdb,$0,cdb,$ff9,$10c5,$fffe
	dc.w	cdb,$0,cdb,$0,cdb,$ff9,cdb,$0,cdb,$0

	dc.w	$110f,$fffe,$1a0,$fff,$1a2,$fff,$1a4,$fff,$1a6,$fff
	dc.w	$1a8,$fff,$1aa,$fff,$1ac,$fff,$1ae,$fff,$1b0,$fff
	dc.w	$1b2,$fff,$1b4,$fff,$1b6,$fff,$188,$ff9
	dc.w	$1d0f,$fffe,$100,$0200
	dc.w	$1e31,$fffe
roller2	ds.w	rolsize
	dc.w	$180,0
	dc.l	-2
;------------------------------------
bouton_gauche	lea	posx(pc),a0
		clr.w	d0
		move.b	(a0),d0
		sub.b	#$35,d0
		divs	#35,d0
		move.b	d0,add_sauver
		jsr	mt_end
		move.w	#$20,$96(a6)	;sprite off
		lea	plan1,a0
		lea	decor_noel,a1
		move.l	#(taille_ecran_noel*4)-1,d0
met_decor	move.b	(a1)+,(a0)+
		dbf	d0,met_decor
		lea	copperlist2,a0
		move.l	a0,$80(a6)
		tst.w	$88(a6)
		move.l	#noel_intro,mt_data2
		jsr	mt_init
		clr.b	$bfde00
		move.b	#$82,$bfd400
		move.b	#$37,$bfd500
		move.b	#$81,$bfdd00
		move.b	#$11,$bfde00
		move.l	$78,oldirq
		move.l	#new,$78
		move.w	#$e00c,$9a(a6)	;$78,soft,dskblk on
		lea	wait,a0		;rebond du logo
		lea	rebond,a1
continue	bsr	blank
		move.w	(a1),d0
		add.w	#$2c,d0
		move.b	d0,(a0)
		lea	bmap3,a2
		move.l	#logo1+taille_logo,d0
		clr.l	d1
		move.w	(a1)+,d1
		muls	#46,d1
		sub.l	d1,d0
		moveq	#4-1,d1
plan_suit3	move.w	d0,6(a2)
		swap	d0
		move.w	d0,2(a2)
		addq.l	#8,a2
		swap	d0
		add.l	#taille_logo,d0
		dbf	d1,plan_suit3
		cmp.l	#fin_rebond,a1
		bne.s	continue
		clr.l	d2

vbl2		bsr	blank
		btst	#0,ampoule
		beq.s	allumer
		bsr	bouge_noel
		bsr	charge_music
		bra.s	vbl2
allumer		
		move.w	#$700c,$9a(a6)	;$78,soft,dskblk off
		move.l	oldirq,$78	;remet interruption
		jsr	mt_end
		move.l	#data+2,mt_data2
		lea	plan1,a0
		move.l	#(taille_ecran_noel*4)-1,d0
eff_plan	clr.b	(a0)+
		dbf	d0,eff_plan
		lea	copperlist,a0
		move.l	a0,$80(a6)
		tst.w	$88(a6)
		move.w	#$8020,$96(a6)	;sprite on
		jsr	mt_init
		move.w	#$2c0f,wait
		bchg	#0,ampoule
		rts
blank		move.l	$4(a6),d2
		and.l	#$1ff00,d2
		cmp.l	#$0ff00,d2
		bne.s	blank
		rts
rebond	dc.w	0,$14,$2B,$41,$56,$6A,$7D,$8E,$7E
	dc.w	$6F,$62,$56,$4C,$44,$3D,$38,$34,$32,$32,$33,$35,$39
	dc.w	$3E,$44,$4A,$52,$5A,$62,$6B,$74,$7D,$86,$8E,$86,$7E
	dc.w	$77,$70,$6A,$65,$61,$5D,$5B,$59,$58,$58,$59,$5A,$5D
	dc.w	$60,$64,$68,$6D,$72,$77,$7D,$83,$89,$8E,$89,$84,$7F
	dc.w	$7A,$76,$72,$6F,$6C,$6A,$69,$68,$68,$68,$69,$6B,$6D
	dc.w	$6F,$72,$76,$7A,$7D,$82,$86,$8A,$8E,$8A,$86,$82,$7F
	dc.w	$7C,$79,$76,$74,$72,$71,$71,$70,$71,$71,$72,$74,$76
	dc.w	$78,$7B,$7E,$81,$84,$88,$8B,$8E,$8B,$88,$85,$82,$7F
	dc.w	$7D,$7B,$79,$78,$77,$76,$76,$76,$77,$77,$79,$7A,$7C
	dc.w	$7E,$81,$83,$86,$89,$8C,$8E,$8C,$89,$86,$84,$82,$80
	dc.w	$7E,$7C,$7B,$7A,$7A,$7A,$7A,$7A,$7B,$7C,$7D,$7F,$81
	dc.w	$83,$85,$87,$8A,$8C,$8E,$8C,$8A,$87,$85,$83,$82,$80
	dc.w	$7F,$7E,$7D,$7D,$7C,$7D,$7D,$7E,$7E,$80,$81,$83,$84
	dc.w	$86,$88,$8A,$8C,$8e
fin_rebond
new	movem.L	a0-a6/d0-d7,-(a7)
	bsr	mt_music
	move.b	$bfdd00,d0
	movem.L	(a7)+,a0-a6/d0-d7
	move.w	#$2000,$dff09c
	rte
oldirq	dc.l 0
noel_intro	incbin	mod.noel
	even
	dc.l	0
;------------------------------------
bouge_noel	eor.w	#1,break
		bne	remarche
pancarte_dec	move.w	adr_noel(pc),d0		;remet le decor
		ext.l	d0
		lea	decor_noel+35*44(pc),a0
		move.l	#plan1+35*44,a1
		add.l	d0,a0
		add.l	d0,a1
		moveq	#nb_plan_noel-1,d1
		move.l	#$00260026,$64(a6)	;ma&d
		move.l	#-1,$44(a6)
		clr.w	$42(a6) 
blit2		wait_blt
		move.w	#$9f0,$40(a6)	;decal a
		move.l	a0,$50(a6)	;a sur decor
		move.l	a1,$54(a6)	;d sur bpl
		move.w	#haut_noel*64+3,$58(a6)
		lea	taille_ecran_noel(a0),a0
		lea	taille_ecran_noel(a1),a1
		dbra	d1,blit2
;--- calcul prochaine position  noel ---
		move.l	pt_pos_noel(pc),a0
		move.w	(a0)+,d0	;x
		ext.l	d0
		move.w	d0,d2		;interpretation des coordonnees
		lsr.w	#3,d0		;x/8
		and.w	#$fffe,d0	;paire
		move.l	#plan1+35*44,a1	;add du plan
		add.l	d0,a1
		move.w	d0,adr_noel	;tu sauves ca pour l'effacer apres
		and.w	#$f,d2		;calcul decalage
		ror.w	#4,d2
;------ affichage noel -------
;a=sur masque;b=sur le bob;c=sur decor
		clr.l	d0
		move.w	(a0)+,d0	;adr image noel
		move.l	a0,pt_pos_noel	;on sauve le pt
		move.l	a0,a3
		lea	noel_image(pc),a0
		add.l	d0,a0
		lsr.l	#2,d0
		lea	noel_masque(pc),a2
		add.l	d0,a2
		wait_blt
		move.l	#$ffff0000,$44(a6)	;mask
		move.l	#$0026fffe,$60(a6)	;mc&b
		move.l	#$fffe0026,$64(a6)	;ma&d 
		move.w	d2,$42(a6)		;decalage de b
		or	#$0fca,d2
		move.w	d2,$40(a6)		;decalage de a
		moveq	#nb_plan_noel-1,d1
install_noel	wait_blt
		move.l	a0,$4c(a6)	 	;b sur bob
		move.l	a1,$48(a6)		;c sur decor
		move.l	a1,$54(a6)		;d sur bpl
		move.l	a2,$50(a6)		;a sur mask
		move.w	#haut_noel*64+3,$58(a6)
		add.l	#4*32,a0
		add.l	#taille_ecran_noel,a1
		dbra	d1,install_noel
		cmp.l	#fpos_noel,a3
		bne.s	marche
		bclr	#0,ampoule
		move.l	#pos_noel,pt_pos_noel
marche		cmp.w	#158,-4(a3)
		bne.s	remarche
		move.w	#1,drapeau2
remarche	rts
break		dc.w	0
ampoule		dc.w	$100
pt_pos_noel	dc.l	pos_noel	;x,adr image noel
pos_noel	
		dc.w	0,bhf1,2,bhf2,4,bhf3,6,bhf4,8,bhf5,10,bhf6
		dc.w	12,bhf7,14,bhf1,16,bhf2,18,bhf3,20,bhf4,22,bhf5
		dc.w	24,bhf6,26,bhf7,28,bhf1,30,bhf2,32,bhf3,34,bhf4
		dc.w	36,bhf5,38,bhf6,40,bhf7,42,bhf1,44,bhf2,46,bhf3
		dc.w	48,bhf4,50,bhf5,52,bhf6,54,bhf7,56,bhf1,58,bhf2
		dc.w	60,bhf3,62,bhf4,64,bhf5,66,bhf6,68,bhf7,70,bhf1
		dc.w	72,bhf2,74,bhf3,76,bhf4,78,bhf5,80,bhf6,82,bhf7
		dc.w	84,bhf1,86,bhf2,88,bhf3,90,bhf4,92,bhf5,94,bhf6
		dc.w	96,bhf7,98,bhf1,100,bhf2,102,bhf3,104,bhf4
		dc.w	106,bhf5,108,bhf6,110,bhf7,112,bhf1,114,bhf2
		dc.w	116,bhf3,118,bhf4,120,bhf5,122,bhf6,124,bhf7
		dc.w	126,bhf1,128,bhf2,130,bhf3,132,bhf4,134,bhf5
		dc.w	136,bhf6,138,bhf7,140,bhf1,142,bhf2,144,bhf3
		dc.w	146,bhf4,148,bhf5,150,bhf6,152,bhf7,154,bhf8
		dc.w	156,bhf9,158,bhf10,158,bhf11,160,bhf1,162,bhf2
		dc.w	164,bhf3,166,bhf4,168,bhf5,170,bhf6,172,bhf7
		dc.w	174,bhf1,176,bhf2,178,bhf3,180,bhf4,182,bhf5
		dc.w	184,bhf6,186,bhf7,188,bhf1,190,bhf2,192,bhf3
		dc.w	194,bhf4,196,bhf5,198,bhf6,200,bhf7,202,bhf1
		dc.w	204,bhf2,206,bhf3,208,bhf4,210,bhf5,212,bhf6
		dc.w	214,bhf7,216,bhf1,218,bhf2,220,bhf3,222,bhf4
		dc.w	224,bhf5,226,bhf6,228,bhf7,230,bhf1,232,bhf2
		dc.w	234,bhf3,236,bhf4,238,bhf5,240,bhf6,242,bhf7
		dc.w	244,bhf1,246,bhf2,248,bhf3,250,bhf4,252,bhf5
		dc.w	254,bhf6,256,bhf7,258,bhf1,260,bhf2,262,bhf3
		dc.w	264,bhf4,266,bhf5,268,bhf6,270,bhf7,272,bhf1
		dc.w	274,bhf2,276,bhf3,278,bhf4,280,bhf5,282,bhf6
		dc.w	284,bhf7,286,bhf1,288,bhf2,290,bhf3,292,bhf4
		dc.w	294,bhf5,296,bhf6,298,bhf7,300,bhf1,302,bhf2
		dc.w	304,bhf3,306,bhf4,308,bhf5,310,bhf6,312,bhf7
		dc.w	314,bhf1,316,bhf2,318,bhf3,320,bhf4
fpos_noel
adr_noel	dc.w	0	;pos noel sur plan
noel_image	incbin	bonhom
	even
noel_masque	ds.b	taille_plan_noel
	even
decor_noel	incbin	decor_noel
	even
;------------------------------------
drapeau2	dc.w	0
add_sauver	dc.w	0
charge_music	tst.w	drapeau2	;charger?
		beq	fin_charge
		cmp.b	#1,add_sauver	;choix music
		bne.s	test2
		move.l	#deb_piste_mod1,debut_piste
		move.l	#nb_pistes_mod1,nb_pistes
		bra	loading
test2		cmp.b	#2,add_sauver
		bne.s	test3
		move.l	#deb_piste_mod2,debut_piste
		move.l	#nb_pistes_mod2,nb_pistes
		bra	loading
test3		move.l	#deb_piste_mod3,debut_piste
		move.l	#nb_pistes_mod3,nb_pistes
loading		
		move.w	#$8010,$96(a6)	;disque on
		move.l	execbase,a6
		jsr	-138(a6)	;permit
		bsr	load_music
		jsr	-132(a6)	;forbid
		move.l	#$dff000,a6
		bsr	blank
		move.w	#$0010,$96(a6)	;disque off
		bsr	pancarte_dec	;affiche decrunch
		move.l	#data+2,mt_data_sav
		bsr	decrunch
		clr.w	drapeau2	;desactive drapeau
fin_charge	rts
load_music
	move.l	execbase,a6
	sub.l	a1,a1
	jsr	findtask(a6)		;chercher la tache
	move.l	d0,readreply+$10
	lea	readreply,a1
	jsr	addport(a6)
	lea	diskio,a1		;structure I/O
	move.l	#0,d0
	clr.l	d1
	lea	trddevice,a0
	jsr	opendev(a6)
	tst.l	d0
	bne	error
;on positionne la tete en piste 1 (22)
	move.l	debut_piste,d0
	move.l	#data,a2	;add du module cruncher
	move.l	nb_pistes,d4

piste	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	add.l	#11*512,d0
	add.l	#11*512,a2
	dbf	d4,piste

;	1 disquette = 512*11*80*2 octets	

	move.l	diskio+32,d6
	lea	diskio,a1
	move	#9,28(a1)
	move.l	#0,36(a1)
	jsr	doio(a6)
	lea	readreply,a1
	jsr	remport(a6)
	lea	diskio,a1
	jsr	closedev(a6)
	rts
lecturepiste
	lea	diskio,a1
	move.l	#readreply,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#11*512,36(a1)
	move.l	d0,44(a1)	;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts
error	move.l	#5,d2
	rts
debut_piste	dc.l	0
nb_pistes	dc.l	0
trddevice	dc.b	'trackdisk.device',0
		even
diskio		ds.l	20
readreply	ds.l	8
mt_data_sav	dc.l	0
;----- el decompactor -----
decrunch	lea	data,a4		;crunched file
		lea	12(a4),a5
		move.l	mt_data_sav,a0	;lea
		add.l	8(a4),a5	;bitlen
		move.l	a0,a3
		add.l	4(a4),a0	;lenght
		moveq	#127,d3
		moveq	#0,d4
		moveq	#3,d5
		moveq	#7,d6
		move.b	3(a4),d4	;scanbit

		move.l	-(a5),d7
deloop		lsr.l	#1,d7
		bne.s	not_empty0
		move.l	-(a5),d7
		roxr.l	#1,d7
not_empty0	bcc.s	copydata
		moveq	#0,d2
bytekpl		move	d5,d1
		bsr.s	getbits
		add	d0,d2
		cmp	d6,d0
		beq.s	bytekpl
		subq	#1,d2
byteloop	move	d6,d1
bytebits	lsr.l	#1,d7
		bne.s	not_empty2
		move.l	-(a5),d7
		roxr.l	#1,d7
not_empty2	roxr.b	#1,d0
		dbf	d1,bytebits
		move.b	d0,-(a0)
		dbf	d2,byteloop
		bra.s	test

copydata	moveq	#2-1,d1
		bsr.s	getfast
		moveq	#0,d1
		move.l	d0,d2
		move.b	0(a4,d0.w),d1
		cmp	d5,d0
		bne.s	copyfast
		lsr.l	#1,d7
		bne.s	not_empty3
		move.l	-(a5),d7
		roxr.l	#1,d7
not_empty3	bcs.s	copykpl

copykpl127	move	d6,d1
		bsr.s	getbits
		add	d0,d2
		cmp	d3,d0
		beq.s	copykpl127
		add	d6,d2
		add	d6,d2
		bra.s	copyskip

copykpl		move	d5,d1
		bsr.s	getbits
		add	d0,d2
		cmp	d6,d0
		beq.s	copykpl
copyskip	move	d4,d1
copyfast	addq	#1,d2
		bsr.s	getfast
copyloop	move.b	0(a0,d0.w),-(a0)
		dbf	d2,copyloop
test		cmp.l	a0,a3
		blo.s	deloop
		rts
getbits		subq	#1,d1
getfast		moveq	#0,d0
bitloop		lsr.l	#1,d7
		bne.s	not_empty1
		move.l	-(a5),d7
		move	d7,coldec
		roxr.l	#1,d7
not_empty1	addx.l	d0,d0
		dbf	d1,bitloop
		rts
;------------------------------------
copperlist2	dc.w	$8e,$2c71,$90,$01d1	;petit ecran
		dc.w	$92,$0030,$94,$00d8
		dc.w	$100,$4200,$102,0,$108,2,$10a,2
bmap3		dc.w	$e0,0,$e2,0,$e4,0,$e6,0,$e8,0,$ea,0,$ec,0,$ee,0
		dc.w	$180,$000,$182,$fff,$184,$dde,$186,$bbd
		dc.w	$188,$99c,$18a,$88b,$18c,$66a,$18e,$559
		dc.w	$190,$448,$192,$337,$194,$226,$196,$115
		dc.w	$198,$114,$19a,$003,$19c,$002,$19e,$001
wait		dc.w	$2c0f,$fffe,$100,$0200,$108,0,$10a,0
bmap4		dc.w	$e0,0,$e2,0,$e4,0,$e6,0,$e8,0,$ea,0,$ec,0,$ee,0
		dc.w	$bb01,$fffe,$100,$4200
		dc.w	$0180,$0000,$0182,$0c00,$0184,$0080,$0186,$0050
		dc.w	$0188,$008f,$018a,$0e97,$018c,$0975,$018e,$0753
		dc.w	$0190,$0800,$0192,$0999,$0194,$068c,$0196,$004f
		dc.w	$0198
coldec		dc.w	$0311,$019a,$0511,$019c,$079e,$019e,$0ddd
		dc.l	-2
;------------------------------------
mt_data2	dc.l	data
logo1		incbin	logo.profecy100
		even
plan2		incbin	diskdb
		even
plan1		ds.b	taille_plan
		even
plan1bis	ds.b	taille_plan
		even
ecran_scroll	ds.b	61*46
		even
;--- data cruncher ---
data	incbin mod.intro
fin
