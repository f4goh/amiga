;-------------------------------------------------------------------
;-                 LE ZOOM BLITTER DE ALE OF FAME       	   -
;-------------------------------------------------------------------


execbase = 4
nb_plan = 4
nb_sprite = 1
pause_masque = 10
pause_image = 600*1

;	org 	$2c000
	section	code,code_c
start:
save_all:
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena

;installation de la liste copper
install_bmap
		lea	bmap,a0
		move.l	#$2b,d0
inst_cop_bmap1	addq	#1,d0
		move.b	d0,(a0)+
		move.b	#$01,(a0)+
		move.w	#$fffe,(a0)+
		move.l	#$01a00000,(a0)+
		move.l	#$00f20000,(a0)+
		move.l	#$0102000f,(a0)+
		move.b	d0,(a0)+
		move.b	#$b9,(a0)+
		move.w	#$fffe,(a0)+
		move.l	#$01020000,(a0)+
		cmp.b	#$ff,d0
		bne	inst_cop_bmap1
		move.l	#$ffe1fffe,(a0)+
		moveq	#0,d0
inst_cop_bmap2	
		move.l	#$01a00000,(a0)+
		move.l	#$00f20000,(a0)+
		move.l	#$0102000f,(a0)+
		move.b	d0,(a0)+
		move.b	#$b9,(a0)+
		move.w	#$fffe,(a0)+
		move.l	#$01020000,(a0)+
		addq	#1,d0
		move.b	d0,(a0)+
		move.b	#$01,(a0)+
		move.w	#$fffe,(a0)+
		cmp.b	#$2c,d0
		bne	inst_cop_bmap2
		move.l	#-2,(a0)
		bra	la

les_couleurs
		lea	couleurs,a0
		move.l	#8-1,d2
		moveq	#0,d1
gogo		move.w	d1,(a0)+
		add.w	#$1,d1
		move.w	#15-1,d0
gogo2		add.w	#$10,d1
		move.w	d1,(a0)+
		dbf	d0,gogo2
		move.w	#15-1,d0
gogo3		add.w	#$100,d1
		move.w	d1,(a0)+
		dbf	d0,gogo3
		dbf	d2,gogo

la		lea	bmap,a0
		lea	couleurs,a1
		add.w	#6,a0
		move.l	#243-1,d0
ccouls		move.w	(a1)+,(a0)
		add.w	#24,a0
		dbf	d0,ccouls
		bsr	plans_logo
pphamer		btst	#14,$2(a6)
		bne	pphamer
;copper initialise
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	bsr	mt_init
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
;dma active
	move.w	#$83e0,$96(a6)	;c
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
;----------------------------------------------install les plans lignes
plans_lignes
	lea	bmap(pc),a0	;copper
	move.l	#ecran,d1	;blow
	swap	d1
	move.w	d1,bmapblit	;bhigh
	swap 	d1
	move.l	#256-1,d0	;count
	add.w	#10,a0
met_ligne
	move.w	d1,(a0)		;bas
	add.l	#24,a0		;prochaine ligne
	add.l	#40,d1
	dbf	d0,met_ligne
	rts
;-------------------------------- pour les 4 plans logo
plans_logo
	lea	bmapbis(pc),a0
	move.l	#logo,d0
	moveq	#nb_plan-1,d1
plan_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
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
install_ecran	move.l	#4-1,d0
		lea	logo+(256/8),a1
		lea	ilogo,a0
install_logo	btst	#14,$2(a6)
		bne.s	install_logo
		move.l	a1,$54(a6)		;dest
		move.l	a0,$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000020,$64(a6)
		move.w	#256*64+4,$58(a6)
		add.l	#8*256,a0		
		add.l	#40*256,a1
		dbf	d0,install_logo
		rts
;------------------------------------------------------------------------
menu
vbl
		cmp.b	#-1,$dff006
		bne	vbl

		move.l	#image1,nb_image
		bsr	install_image
		move.l	#image2,nb_image
		bsr	install_image
		move.l	#image3,nb_image
		bsr	install_image
		move.l	#image4,nb_image
		bsr	install_image
		move.l	#image5,nb_image
		bsr	install_image


souris		btst	#6,$bfe001
		bne	vbl
		rts
;---------------------------------- installe les images
install_image
		bsr	plans_lignes
		lea	masque,a2
		move.l	#8-1,d3
copietout	move.l	#pause_masque-1,d4
vblm		cmp.b	#$20,$dff006		;$40
		bne	vblm
		dbf	d4,vblm
		move.l	nb_image,a0
		lea	ecran,a1
		move.l	#16-1,d0
copiev		move.l	#15-1,d1	;16
copieh		btst	#14,$2(a6)
		bne.s	copieh		
		move.l	a1,$54(a6) 			;dest ecran
		move.l	a2,$4c(a6)			;b masque
		move.l	a0,$50(a6)			;source blitraw A
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$0dc00000,$40(a6)
		move.l	#$001c0026,$64(a6)	;mod  A & D 1e
		move.w	#$0000,$62(a6)		;mod B
		move.w	#16*64+1,$58(a6)
		add.l	#2,a0
		add.l	#2,a1
		dbf	d1,copieh
		add.l	#15*30,a0		;32
		add.l	#(80/8),a1		;64
		add.l	#15*40,a1
		dbf	d0,copiev
		add.l	#16*2,a2
		dbf	d3,copietout
		move.l	#pause_image-1,d4
vbli		cmp.b	#$40,$dff006
		bne	vbli
		dbf	d4,vbli
		bsr	blitzom
		rts
nb_image	dc.l	0
;---------------------------------- scroll avec 1 sprite
scroll
	moveq	#0,d0
	cmp.w	#16,nouvelle_lettre
	bne	decale_scroll
	move.l	ptr_scroll,a0
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	beq	fin_scroll
	cmp.b	#" ",d0
	beq	espace_char
	sub.b	#"0",d0
	lea	lettre,a1
	lsl.w	#6,d0		;*64
	add.l	d0,a1
	bsr	copie_lettre
fin_lettre
	move.l	a0,ptr_scroll
	clr.w	nouvelle_lettre
	bsr	decale_scroll
	rts

fin_scroll
	bsr	decale_scroll
	move.l	#texte,ptr_scroll
	move.w	#16,nouvelle_lettre
	rts

espace_char
	bsr	efface_lettre
	bra	fin_lettre

ptr_scroll	dc.l	texte
nouvelle_lettre	dc.w	16

decale_scroll	btst	#14,$2(a6)
		bne.s	decale_scroll
		move.l	#spdest,$54(a6)		;dest
		move.l	#spsce,$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00002,$40(a6)	;descend
		move.l	#$00000000,$64(a6)
		move.w	#(257+16)*64+2,$58(a6)
		add.w	#1,nouvelle_lettre
		rts
copie_lettre	btst	#14,$2(a6)
		bne.s	copie_lettre
		move.l	#spchar,$54(a6)		;dest
		move.l	a1,$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)	;descend
		move.l	#$00000000,$64(a6)
		move.w	#16*64+2,$58(a6)
		rts
efface_lettre	btst	#14,$2(a6)
		bne.s	efface_lettre
		move.l	#spchar,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#16*64+2,$58(a6)
		rts		
;---------------------------------- le  TEXTE
texte
;	dc.b	"0123456789 @ ? > = < ; : "
	dc.b	" LOADING "
	dc.b	-1
	even	
;---------------------------------- le blitter zooming commence
blitzom
		lea	table,a1
		move.l	#16-1,d0
next_zoom1	lea	ecran,a0	;utilise reg an ou sp
		add.w	(a1)+,a0	;pas de la source +2
		move.l	#8-1,d1
vbz1		move.l	$4(a6),d6	;syncro out
		and.l	#$1ff00,d6
		cmp.l	#$13000,d6	;130
		bne	vbz1
		move.w	(a1)+,d2	;taille
		add.w	#256*64,d2	;ajustement blitter
		move.w	(a1)+,d3	;le modulo A D
		bsr	deplace_image
		move.w	(a1)+,d2	;taille
		add.w	#256*64,d2	;ajustement blitter
		move.w	(a1)+,d3	;le modulo A D
		bsr	deplace_image
		bsr	scroll_x3	;horiz
		move.w	(a1)+,vert
		bsr	scroll_y3	;vert
		dbf	d1,vbz1
		dbf	d0,next_zoom1
		rts

scroll_y3
		lea	bmap(pc),a2
		move.w	vert,d5
		subq.w	#1,d5
		add.w	#10,a2
		move.w	(a2),d6
scrb_ligne
		add.w	#24,a2
		move.w	(a2),d7
		move.w	d6,(a2)
		move.w	d7,d6
		dbf	d5,scrb_ligne

		lea	bmap(pc),a2
		move.w	vert,d5
		subq.w	#1,d5
		add.w	#(24*255)+10,a2
		move.w	(a2),d6
scrh_ligne
		sub.w	#24,a2
		move.w	(a2),d7
		move.w	d6,(a2)
		move.w	d7,d6
		dbf	d5,scrh_ligne
		rts		
vert	dc.w	0

scroll_x3	lea	bmap(pc),a2	;copper
		move.l	#256-1,d6	;count
		add.w	#10,a2
dep_ligne
		move.w	$4(a2),d5
		and.w	#$f,d5
		cmp.w	#$0,d5
		bne	suite
		add.w	#$02,(a2)
		move.w	#0,$4(a2)		
suite
		add.w	#5,a2
		move.b	(a2),d5
		sub.b	#1,d5
		and.b	#$f,d5
		move.b	d5,(a2)
		add.w	#(24-5),a2	;prochaine ligne
		dbf	d6,dep_ligne
		rts


; il reste d4,d5, a2-a5   mais d6,d2,d3,d7 can used after deplace
; d7 used for paused

deplace_image	btst	#14,$2(a6)
		bne.s	deplace_image
		move.l	a0,$54(a6)		;dest = source = a0
		move.l	a0,$50(a6)		;source varie ++
		move.l	#$fffffffe,$44(a6)	;tjs masque 7xxxe
		move.l	#$19f00000,$40(a6)	;toujours ror 1
		move.w	d3,$64(a6)		;mod A  d0
		move.w	d3,$66(a6)		;mod D	d0
		move.w	d2,$58(a6)		;taille d1
		rts
pause:
		move.l	#200,d7
vbp		cmp.b	#-1,$dff006
		bne	vbp
		dbf	d7,vbp
		rts
;---------------------------------- efface blit au cas ou
clear_zoom	btst	#14,$2(a6)
		bne.s	clear_zoom
		move.l	#ecran,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#256*64+20,$58(a6)
		rts		
;---------------------------------- table de mouvement
table   dc.w    0                ; 1er
        dc.w    16,40-(16*2)
        dc.w    8,40-(8*2),10
        dc.w    12,40-(12*2)
        dc.w    4,40-(4*2),20
        dc.w    14,40-(14*2)
        dc.w    6,40-(6*2),30
        dc.w    10,40-(10*2)
        dc.w    2,40-(2*2),40
        dc.w    15,40-(15*2)
        dc.w    7,40-(7*2),50
        dc.w    9,40-(9*2)
        dc.w    1,40-(1*2),60
        dc.w    13,40-(13*2)
        dc.w    5,40-(5*2),70
        dc.w    11,40-(11*2)
        dc.w    3,40-(3*2),80
        dc.w    2	         ;2 eme
        dc.w    15,40-(15*2)
        dc.w    8,40-(8*2),90
        dc.w    12,40-(12*2)
        dc.w    4,40-(4*2),100
        dc.w    14,40-(14*2)
        dc.w    6,40-(6*2),11
        dc.w    10,40-(10*2)
        dc.w    2,40-(2*2),22
        dc.w    15,40-(15*2)
        dc.w    7,40-(7*2),33
        dc.w    9,40-(9*2)
        dc.w    1,40-(1*2),44
        dc.w    13,40-(13*2)
        dc.w    5,40-(5*2),45
        dc.w    11,40-(11*2)
        dc.w    3,40-(3*2),56
        dc.w    4                ;3 eme
        dc.w    8,40-(8*2)
        dc.w    1,40-(1*2),67
        dc.w    11,40-(11*2)
        dc.w    4,40-(4*2),78
        dc.w    13,40-(13*2)
        dc.w    6,40-(6*2),89
        dc.w    10,40-(10*2)
        dc.w    3,40-(3*2),30
        dc.w    14,40-(14*2)
        dc.w    7,40-(7*2),41
        dc.w    9,40-(9*2)
        dc.w    2,40-(2*2),52
        dc.w    12,40-(12*2)
        dc.w    5,40-(5*2),63
        dc.w    8,40-(8*2)
        dc.w    1,40-(1*2),74
        dc.w    6                ;4 eme
        dc.w    8,40-(8*2)
        dc.w    1,40-(1*2),85
        dc.w    11,40-(11*2)
        dc.w    4,40-(4*2),96
        dc.w    13,40-(13*2)
        dc.w    6,40-(6*2),107
        dc.w    10,40-(10*2)
        dc.w    3,40-(3*2),28
        dc.w    11,40-(11*2)
        dc.w    7,40-(7*2),35
        dc.w    9,40-(9*2)
        dc.w    2,40-(2*2),50
        dc.w    12,40-(12*2)
        dc.w    5,40-(5*2),61
        dc.w    8,40-(8*2)
        dc.w    1,40-(1*2),72
        dc.w    8                ;5 eme
        dc.w    7,40-(7*2)
        dc.w    1,40-(1*2),83
        dc.w    10,40-(10*2)
        dc.w    4,40-(4*2),94
        dc.w    12,40-(12*2)
        dc.w    6,40-(6*2),105
        dc.w    8,40-(8*2)
        dc.w    2,40-(2*2),36
        dc.w    11,40-(11*2)
        dc.w    5,40-(5*2),57
        dc.w    9,40-(9*2)
        dc.w    3,40-(3*2),78
        dc.w    12,40-(12*2)
        dc.w    1,40-(1*2),89
        dc.w    8,40-(8*2)
        dc.w    5,40-(5*2),40
        dc.w    10               ;6 eme
        dc.w    7,40-(7*2)
        dc.w    1,40-(1*2),49
        dc.w    10,40-(10*2)
        dc.w    4,40-(4*2),41
        dc.w    7,40-(7*2)
        dc.w    6,40-(6*2),90
        dc.w    8,40-(8*2)
        dc.w    2,40-(2*2),80
        dc.w    11,40-(11*2)
        dc.w    5,40-(5*2),50
        dc.w    9,40-(9*2)
        dc.w    3,40-(3*2),48
        dc.w    10,40-(10*2)
        dc.w    1,40-(1*2),60
        dc.w    8,40-(8*2)
        dc.w    5,40-(5*2),65
        dc.w    12                ;7 eme
        dc.w    7,40-(7*2)
        dc.w    2,40-(2*2),70
        dc.w    10,40-(10*2)
        dc.w    5,40-(5*2),120
        dc.w    8,40-(8*2)
        dc.w    3,40-(3*2),60
        dc.w    6,40-(6*2)
        dc.w    1,40-(1*2),110
        dc.w    9,40-(9*2)
        dc.w    4,40-(4*2),80
        dc.w    6,40-(6*2)
        dc.w    5,40-(5*2),120
        dc.w    8,40-(8*2)
        dc.w    3,40-(3*2),90
        dc.w    10,40-(10*2)
        dc.w    1,40-(1*2),125
        dc.w    14                ;8 eme
        dc.w    7,40-(7*2)
        dc.w    2,40-(2*2),61
        dc.w    9,40-(9*2)
        dc.w    4,40-(4*2),95
        dc.w    8,40-(8*2)
        dc.w    3,40-(3*2),105
        dc.w    6,40-(6*2)
        dc.w    1,40-(1*2),120
        dc.w    9,40-(9*2)
        dc.w    4,40-(4*2),70
        dc.w    6,40-(6*2)
        dc.w    5,40-(5*2),62
        dc.w    8,40-(8*2)
        dc.w    3,40-(3*2),83
        dc.w    7,40-(7*2)
        dc.w    2,40-(2*2),64
        dc.w    16                ;9 eme
        dc.w    5,40-(5*2)
        dc.w    1,40-(1*2),75
        dc.w    7,40-(7*2)
        dc.w    3,40-(3*2),90
        dc.w    6,40-(6*2)
        dc.w    2,40-(2*2),100
        dc.w    8,40-(8*2)
        dc.w    4,40-(4*2),70
        dc.w    7,40-(7*2)
        dc.w    1,40-(1*2),116
        dc.w    5,40-(5*2)
        dc.w    4,40-(4*2),80
        dc.w    8,40-(8*2)
        dc.w    2,40-(2*2),71
        dc.w    6,40-(6*2)
        dc.w    3,40-(3*2),85
        dc.w    18                ;10 eme
        dc.w    5,40-(5*2)
        dc.w    1,40-(1*2),98
        dc.w    7,40-(7*2)
        dc.w    3,40-(3*2),81
        dc.w    6,40-(6*2)
        dc.w    2,40-(2*2),76
        dc.w    5,40-(5*2)
        dc.w    3,40-(3*2),90
        dc.w    7,40-(7*2)
        dc.w    1,40-(1*2),80
        dc.w    5,40-(5*2)
        dc.w    4,40-(4*2),89
        dc.w    7,40-(7*2)
        dc.w    2,40-(2*2),104
        dc.w    6,40-(6*2)
        dc.w    3,40-(3*2),115
        dc.w    20               ;11 eme
        dc.w    4,40-(4*2)
        dc.w    1,40-(1*2),86
        dc.w    6,40-(6*2)
        dc.w    3,40-(3*2),95
        dc.w    5,40-(5*2)
        dc.w    2,40-(2*2),85
        dc.w    4,40-(4*2)
        dc.w    1,40-(1*2),101
        dc.w    6,40-(6*2)
        dc.w    3,40-(3*2),122
        dc.w    5,40-(5*2)
        dc.w    2,40-(2*2),103
        dc.w    6,40-(6*2)
        dc.w    1,40-(1*2),115
        dc.w    4,40-(4*2)
        dc.w    2,40-(2*2),91
        dc.w    22               ;12 eme
        dc.w    4,40-(4*2)
        dc.w    1,40-(1*2),92
        dc.w    4,40-(4*2)
        dc.w    3,40-(3*2),97
        dc.w    5,40-(5*2)
        dc.w    2,40-(2*2),102
        dc.w    4,40-(4*2)
        dc.w    1,40-(1*2),104
        dc.w    2,40-(2*2)
        dc.w    1,40-(1*2),98
        dc.w    5,40-(5*2)
        dc.w    2,40-(2*2),96
        dc.w    3,40-(3*2)
        dc.w    1,40-(1*2),101
        dc.w    4,40-(4*2)
        dc.w    2,40-(2*2),125
        dc.w    24               ;13 eme
        dc.w    4,40-(4*2)
        dc.w    2,40-(2*2),107
        dc.w    3,40-(3*2)
        dc.w    1,40-(1*2),116
        dc.w    3,40-(3*2)
        dc.w    2,40-(2*2),121
        dc.w    4,40-(4*2)
        dc.w    1,40-(1*2),104
        dc.w    4,40-(4*2)
        dc.w    3,40-(3*2),125
        dc.w    2,40-(2*2)
        dc.w    1,40-(1*2),106
        dc.w    3,40-(3*2)
        dc.w    4,40-(4*2),126
        dc.w    1,40-(1*2)
        dc.w    2,40-(2*2),119
        dc.w    26               ;14 eme
        dc.w    3,40-(3*2)
        dc.w    2,40-(2*2),123
        dc.w    3,40-(3*2)
        dc.w    1,40-(1*2),110
        dc.w    2,40-(2*2)
        dc.w    1,40-(1*2),119
        dc.w    3,40-(3*2)
        dc.w    1,40-(1*2),111
        dc.w    2,40-(2*2)
        dc.w    3,40-(3*2),117
        dc.w    1,40-(1*2)
        dc.w    3,40-(3*2),114
        dc.w    1,40-(1*2)
        dc.w    2,40-(2*2),124
        dc.w    3,40-(3*2)
        dc.w    2,40-(2*2),123
        dc.w    28               ;15 eme
        dc.w    2,40-(2*2)
        dc.w    1,40-(1*2),118
        dc.w    1,40-(1*2)
        dc.w    2,40-(2*2),121
        dc.w    2,40-(2*2)
        dc.w    2,40-(2*2),119
        dc.w    1,40-(1*2)
        dc.w    2,40-(2*2),118
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),121
        dc.w    2,40-(2*2)
        dc.w    1,40-(1*2),122
        dc.w    2,40-(2*2)
        dc.w    2,40-(2*2),119
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),120
        dc.w    30               ;16 eme
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),121
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),122
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),123
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),124
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),125
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),126
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),127
        dc.w    1,40-(1*2)
        dc.w    1,40-(1*2),128
;------------------------------------------------------------------------
lettre:

	dc.w	$3ffc,$2004,$7ffe,$4002,$ffff,$8001,$ffff,$0000
	dc.w	$ffff,$0000,$ff8f,$0080,$ffcf,$0840,$f7ef,$0420
	dc.w	$f3ff,$0210,$f1ff,$0100,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$fe00,$8000,$7e00,$4000,$1e00,$1000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$3f0f,$2100,$7f8f,$4080,$ffcf,$8040,$ffcf,$0000
	dc.w	$ffcf,$0000,$f3cf,$0000,$f3cf,$0000,$f3cf,$0000
	dc.w	$f3cf,$0000,$f3cf,$0000,$f3ff,$0000,$fbff,$0000
	dc.w	$fbff,$0200,$f9ff,$8100,$78ff,$4080,$0000,$0000
	dc.w	$3ffc,$2184,$7ffe,$4002,$ffff,$8001,$ffff,$0000
	dc.w	$ffff,$0000,$fbff,$0020,$f3df,$0010,$f3cf,$0000
	dc.w	$f3cf,$0000,$f00f,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$f00f,$0000,$0000,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$01e0,$0000,$01e0,$0000,$01e0,$0000
	dc.w	$01e0,$0000,$01e0,$0000,$ffe0,$0000,$ffe0,$0000
	dc.w	$ffe0,$0020,$ffc0,$0040,$ff80,$0080,$0000,$0000
	dc.w	$f0fc,$0084,$f1fe,$0102,$f3ff,$0201,$f3ff,$0000
	dc.w	$f3ff,$0000,$f3cf,$0000,$f3cf,$0000,$f3cf,$0000
	dc.w	$f3cf,$0000,$f3cf,$0000,$ffdf,$0000,$ffdf,$0000
	dc.w	$ffdf,$0000,$ffdf,$0001,$ffde,$0042,$0000,$0000
	dc.w	$f0fc,$0084,$f1fe,$0102,$f3ff,$0201,$f3ff,$0000
	dc.w	$f3ff,$0000,$f3cf,$0000,$f3cf,$0000,$f3cf,$0000
	dc.w	$fbcf,$0800,$ffcf,$0400,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000
	dc.w	$f800,$0800,$fc00,$0400,$ff00,$0100,$ffc0,$0040
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$fbff,$0200
	dc.w	$f8ff,$0080,$f800,$0000,$f800,$0000,$f800,$0000
	dc.w	$f800,$0000,$f800,$0000,$f800,$0000,$0000,$0000


	dc.w	$3e7c,$2244,$7ffe,$4182,$ffff,$8001,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$fdbf,$0420,$f99f,$0810
	dc.w	$fdbf,$0420,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4182,$3e7c,$2244,$0000,$0000
	dc.w	$3fff,$2000,$7fff,$4000,$ffff,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$f0f0,$0000,$f0f0,$0000,$f0f0,$0000
	dc.w	$f9f0,$0900,$fff0,$0600,$fff0,$0000,$fff0,$0000
	dc.w	$fff0,$8010,$7fe0,$4020,$3fc0,$2040,$0000,$0000
	dc.w	$0000,$0000,$1e78,$0000,$1e78,$0000,$1e78,$0000
	dc.w	$1e78,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$01c8,$0000,$01f8,$0000,$01f8,$0000,$01e0,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000
	dc.w	$fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000
	dc.w	$fffc,$0000,$fffc,$0000,$fffc,$0000,$fffc,$0000
	dc.w	$fffc,$0000,$fffc,$0000,$fffc,$0000,$0000,$0000
	dc.w	$1ff0,$0000,$1ff0,$0000,$1ff0,$0000,$1ff0,$0000
	dc.w	$1ff0,$0000,$1ff0,$0000,$1ff0,$0000,$ffff,$0001
	dc.w	$fffe,$8002,$7ffc,$4004,$3ff8,$2008,$1ff0,$1010
	dc.w	$0fe0,$0820,$07c0,$0440,$0380,$0280,$0000,$0000
	dc.w	$0380,$0280,$07c0,$0440,$0fe0,$0820,$1ff0,$1010
	dc.w	$3ff8,$2008,$7ffc,$4004,$fffe,$8002,$ffff,$0001
	dc.w	$1ff0,$0000,$1ff0,$0000,$1ff0,$0000,$1ff0,$0000
	dc.w	$1ff0,$0000,$1ff0,$0000,$1ff0,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$7f80,$4080
	dc.w	$ffc0,$8040,$ffe0,$0020,$ffef,$0000,$ffef,$0000
	dc.w	$ffef,$0000,$ffef,$0400,$fbef,$0200,$f9ef,$0100
	dc.w	$f800,$0000,$f800,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$ffef,$0000,$ffef,$0000,$ffef,$0000
	dc.w	$ffef,$0000,$ffef,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000




	dc.w	$3fff,$2000,$7fff,$4000,$ffff,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$fcf0,$0400,$f8f0,$0800,$f0f0,$0000
	dc.w	$f8f0,$0800,$fcf0,$0400,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8000,$7fff,$4000,$3fff,$2000,$0000,$0000
	dc.w	$3f7c,$2144,$7ffe,$4082,$ffff,$8001,$ffff,$0000
	dc.w	$ffff,$0000,$fbdf,$0810,$f3cf,$1008,$e3c7,$0000
	dc.w	$e3c7,$0000,$e3c7,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$0000,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$f81f,$0810,$fc3f,$0420,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000
	dc.w	$3ffc,$2004,$7ffe,$4002,$ffff,$8001,$ffff,$0000
	dc.w	$ffff,$0000,$fc3f,$0420,$f81f,$0810,$f00f,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$0000,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$f3cf,$0000,$f3cf,$0000
	dc.w	$fbdf,$0810,$ffff,$0420,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000
	dc.w	$f000,$0000,$f000,$0000,$f000,$0000,$f000,$0000
	dc.w	$f000,$0000,$f000,$0000,$f3c0,$0000,$f3c0,$0000
	dc.w	$fbc0,$0800,$ffc0,$0400,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8000,$7fff,$4000,$3fff,$2000,$0000,$0000
	dc.w	$3cff,$2000,$7cff,$4000,$fcff,$8000,$fcfe,$0000
	dc.w	$fcff,$0400,$f8ff,$0800,$f0ef,$0000,$f00f,$0000
	dc.w	$f81f,$0810,$fc3f,$0420,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$03c0,$0000,$03c0,$0000,$03c0,$0000
	dc.w	$03c0,$0000,$03c0,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$0000,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$f00f,$0000,$f00f,$0000,$0000,$0000,$0000,$0000
	dc.w	$fffc,$0004,$fffe,$0002,$ffff,$0001,$ffff,$0000
	dc.w	$ffff,$0000,$003f,$0020,$001f,$0010,$000f,$0000
	dc.w	$001f,$0010,$003f,$0020,$00ff,$0000,$00ff,$0000
	dc.w	$00ff,$0001,$00fe,$0002,$00fc,$0004,$0000,$0000
	dc.w	$c003,$4002,$e007,$2004,$f00f,$1008,$f81f,$0810
	dc.w	$fc3f,$0420,$fe7f,$0240,$ffff,$8181,$7ffe,$4002
	dc.w	$3ffc,$2004,$1ff8,$1008,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$0000,$0000
	dc.w	$000f,$0000,$000f,$0000,$000f,$0000,$000f,$0000
	dc.w	$000f,$0000,$000f,$0000,$000f,$0000,$000f,$0000
	dc.w	$001f,$0010,$003f,$0020,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0001,$fffe,$0002,$fffc,$0004,$0000,$0000
	dc.w	$3fff,$2000,$7fff,$4000,$ffff,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$f800,$0000,$ff80,$0000,$ff80,$0000
	dc.w	$ff80,$0000,$f800,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8000,$7fff,$4000,$3fff,$2000,$0000,$0000
	dc.w	$3fff,$2000,$7fff,$4000,$ffff,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$fc00,$0400,$f800,$0800,$f000,$0000
	dc.w	$f800,$0800,$fc00,$0400,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8000,$7fff,$4000,$3fff,$2000,$0000,$0000
	dc.w	$3ffc,$2004,$7ffe,$4002,$ffff,$8001,$ffff,$0000
	dc.w	$ffff,$0000,$f81f,$0000,$f00f,$0000,$f00f,$0000
	dc.w	$f00f,$0000,$f81f,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000


	dc.w	$3fc0,$2040,$7fe0,$4020,$fff0,$8010,$fff0,$0000
	dc.w	$fff0,$0000,$fff0,$0600,$f9f0,$0900,$f0f0,$0000
	dc.w	$f0f0,$0000,$f0f0,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$0000,$0000
	dc.w	$3ffb,$2000,$7fff,$4000,$fffe,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$fc7f,$0400,$f87f,$0810,$f00f,$0000
	dc.w	$f81f,$0810,$fc3f,$0420,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$8001,$7ffe,$4002,$3ffc,$2004,$0000,$0000
	dc.w	$3f8f,$2088,$7fdf,$4000,$ffff,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$fffe,$0602,$f9fc,$0904,$f0f8,$0008
	dc.w	$f0f0,$0000,$f0f0,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0000,$ffff,$0000,$ffff,$0000,$0000,$0000
	dc.w	$78fc,$4084,$f9fe,$8102,$fbff,$0201,$fbff,$0000
	dc.w	$fbff,$0000,$f3cf,$0000,$f3cf,$0000,$f3cf,$0000
	dc.w	$f3cf,$0000,$f3cf,$0000,$ffdf,$0000,$ffdf,$0000
	dc.w	$ffdf,$8040,$7f9f,$4081,$3f1e,$2102,$0000,$0000
	dc.w	$3fff,$2000,$7fff,$4000,$ffff,$8000,$ffff,$0000
	dc.w	$ffff,$0000,$f800,$0000,$f800,$0000,$f800,$0000
	dc.w	$f800,$0000,$f800,$0000,$f800,$0000,$f800,$0000
	dc.w	$f800,$0000,$f800,$0000,$f800,$0000,$0000,$0000
	dc.w	$fffc,$0004,$fffe,$0002,$ffff,$0001,$ffff,$0000
	dc.w	$ffff,$0000,$003f,$0020,$001f,$0010,$000f,$0000
	dc.w	$001f,$0010,$003f,$0020,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0001,$fffe,$0002,$fffc,$0004,$0000,$0000
	dc.w	$f800,$0800,$ff00,$0100,$fff0,$0010,$fffe,$0002
	dc.w	$3fff,$2000,$07ff,$0400,$003f,$0000,$003f,$0000
	dc.w	$03ff,$0200,$0fff,$0800,$7ffe,$4002,$fff8,$0008
	dc.w	$ffc0,$0040,$fe00,$0200,$f800,$0800,$0000,$0000
	dc.w	$fffc,$0004,$fffe,$0002,$ffff,$0001,$ffff,$0000
	dc.w	$ffff,$0000,$001f,$0000,$01ff,$0000,$01ff,$0000
	dc.w	$01ff,$0000,$001f,$0000,$ffff,$0000,$ffff,$0000
	dc.w	$ffff,$0001,$fffe,$0002,$fffc,$0004,$0000,$0000
	dc.w	$f007,$1004,$f80f,$0808,$fc3f,$0420,$fe7f,$0240
	dc.w	$ffff,$8181,$3ffc,$2004,$1ff8,$1008,$0ff0,$0810
	dc.w	$1ff8,$1008,$3ffc,$2004,$ffff,$8181,$fe7f,$0240
	dc.w	$fc3f,$0420,$f80f,$0808,$f007,$1004,$0000,$0000
	dc.w	$fffc,$0004,$fffe,$0002,$ffff,$0001,$ffff,$0000
	dc.w	$ffff,$0000,$03df,$0000,$03cf,$0000,$03cf,$0000
	dc.w	$03cf,$0000,$03cf,$0000,$ffdf,$0000,$ffdf,$0000
	dc.w	$ffdf,$0040,$ff9f,$0081,$ff1e,$0102,$0000,$0000
	dc.w	$fc0f,$0400,$fe0f,$0200,$ff0f,$0100,$ff8f,$0080
	dc.w	$ffcf,$0040,$ffef,$0020,$ffff,$0010,$ffff,$0800
	dc.w	$f7ff,$0400,$f3ff,$0200,$f1ff,$0100,$f0ff,$0080
	dc.w	$f07f,$0040,$f03f,$0020,$f01f,$0010,$0000,$0000
;--------------------------------
;REPLAY
;--------------------------------
new:
	movem.L	a0-a5/d0-d7,-(a7)
	bsr	scroll
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
;******************************************************
couleurs:	
	dc.w	$100,$200,$200,$300,$300,$300,$401,$401
	dc.w	$401,$401,$502,$502,$502,$502,$502,$613
	dc.w	$613,$613,$613,$613,$613,$724,$724,$724
	dc.w	$724,$724,$724,$724,$835,$835,$835,$835
	dc.w	$835,$835,$835,$835,$946,$946,$946,$946
	dc.w	$946,$946,$946,$946,$946,$a57,$a57,$a57
	dc.w	$a57,$a57,$a57,$a57,$a57,$a57,$a57,$b68
	dc.w	$b68,$b68,$b68,$b68,$b68,$b68,$b68,$b68
	dc.w	$b68,$b68,$c79,$c79,$c79,$c79,$c79,$c79
	dc.w	$c79,$c79,$c79,$c79,$c79,$c79,$c79,$d8a
	dc.w	$d8a,$d8a,$d8a,$d8a,$d8a,$d8a,$d8a,$d8a
	dc.w	$d8a,$d8a,$d8a,$d8a,$e9b,$e9b,$e9b,$e9b
	dc.w	$e9b,$e9b,$e9b,$e9b,$e9b,$e9b,$e9b,$e9b
	dc.w	$e9b,$e9b,$fac,$fac,$fac,$fac,$fac,$fac
	dc.w	$fac,$fac,$fac,$fac,$fac,$fac,$fac,$fac
	dc.w	$fac,$ecc,$ecc,$ecc,$ecc,$ecc,$ecc,$ecc
	dc.w	$ecc,$ecc,$ecc,$ecc,$ecc,$ecc,$ecc,$ddb
	dc.w	$ddb,$ddb,$ddb,$ddb,$ddb,$ddb,$ddb,$ddb
	dc.w	$ddb,$ddb,$ddb,$ddb,$ddb,$ddb,$cda,$cda
	dc.w	$cda,$cda,$cda,$cda,$cda,$cda,$cda,$cda
	dc.w	$cda,$cda,$cda,$cda,$bd9,$bd9,$bd9,$bd9
	dc.w	$bd9,$bd9,$bd9,$bd9,$bd9,$bd9,$bd9,$bd9
	dc.w	$ac8,$ac8,$ac8,$ac8,$ac8,$ac8,$ac8,$ac8
	dc.w	$ac8,$ac8,$ac8,$9b7,$9b7,$9b7,$9b7,$9b7
	dc.w	$9b7,$9b7,$9b7,$9b7,$9b7,$8a6,$8a6,$8a6
	dc.w	$8a6,$8a6,$8a6,$8a6,$8a6,$8a6,$795,$795
	dc.w	$795,$795,$795,$795,$795,$795,$684,$684
	dc.w	$684,$684,$684,$684,$684,$573,$573,$573
	dc.w	$573,$573,$573,$462,$462,$462,$462,$462
	dc.w	$351,$351,$351,$351,$240,$240,$240,$130
	dc.w	$130,$020,$010
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


bmapbis		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000

		dc.w	$00f0
bmapblit	dc.w	$0000	

;		dc.w	$0180,$0000
		dc.w	$0182,$0c9c,$0184,$0ede,$0186,$0dbd
		dc.w	$0188,$0ff0,$018a,$0b7b,$018c,$0a6a,$018e,$0858
		dc.w	$0190,$0737,$0192,$0626,$0194,$0525,$0196,$0414
		dc.w	$0198,$0303,$019a,$0202,$019c,$0102,$019e,$000a

		dc.w	$01a0,$0fff



		dc.l	$01005200		;bitplane active
bmap		dcb.w	(12*257)		;w,$180,e2,102,w,102
		;moins 8 pour plus tard

;------------------------------------------------------------------------
masque:		incbin	masques.raw
image1:		incbin	ecran1.raw
image2:		incbin	ecran2.raw
image3:		incbin	ecran3.raw
image4:		incbin	ecran4.raw
image5:		incbin	ecran5.raw
ilogo:		incbin	logopro.raw
mt_data:	incbin	mod.loading
	even
;------------------------------------------------------------------------
ecran	dcb.b	40*256
logo	dcb.b	40*256*nb_plan
	even
end



