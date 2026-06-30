execbase = 4
nb_plan = 1
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
;	bsr	mt_init
;	clr.b	$bfde00
;	move.b	#$82,$bfd400
;	move.b	#$37,$bfd500
;	move.b	#$81,$bfdd00
;	move.b	#$11,$bfde00
;	move.l	$78,oldirq
;	move.l	#new,$78	
;installation de la 1ere liste copper
	lea	bmap(pc),a0
	move.l	#image,d0
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
	move.w	#$83d0,$96(a6)
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
;	move.l	oldirq,$78
;	bsr	mt_end
	rts
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even
;------------------------------------------------------------------------
menu		cmp.b	#$40,$6(a6)
		bne.S	menu
		bsr	chaos
souris		btst	#6,$bfe001
		bne	souris
		rts
chaos
		bsr	depart
		clr.l	d0		;hauteur y
ligne		clr.l	d1		;largeur x
		bchg	#0,quel_calcul
colonne
		bsr	point_a
		bsr	point_b
		cmp.b	#0,quel_calcul
		bra	calcul1
;		bsr	calcul2
suite_calcul	bsr	point_c
		bsr	point_d
		add.w	#1,d1
		cmp.w	#319,d1
		bne	colonne
		addq	#1,d0
		cmp.w	#255,d0
		bne	ligne
		rts

depart		lea	image,a0
		move.l	#$00000000,(a0)+	;320/32
		move.l	#$00000000,(a0)+
		move.l	#$0f000000,(a0)+
		move.l	#$00000000,(a0)+
		move.l	#$00000000,(a0)+
		move.l	#$80000000,(a0)+	;160
		move.l	#$000f0000,(a0)+
		move.l	#$00000000,(a0)+
		move.l	#$00000000,(a0)+
		move.l	#$00000000,(a0)
		rts

point_a		lea	image,a0	;d1 x
		lea	table,a1	;d0 y
		clr.l	d5
		clr.l	d6
		move.w	d1,d5		;save x
		move.w	d0,d6		;save y
		mulu	#40,d6
		divs	#8,d5
		add.w	d5,d6
		add.w	d6,a0
		move.b	(a0),d3
		swap	d5
		move.b	(a1,d5),d4
		and.b	d4,d3
		cmp.b	#0,d3
		bne	set_pt_a
		move.w	#0,val_pt_a
		rts
set_pt_a	move.w	#1,val_pt_a
		rts

point_b		lea	image,a0	;d1 x
		lea	table,a1	;d0 y
		clr.l	d5
		clr.l	d6
		move.w	d1,d5		;save x
		move.w	d0,d6		;save y
		add.w	#1,d5
		mulu	#40,d6
		divs	#8,d5
		add.w	d5,d6
		add.w	d6,a0
		move.b	(a0),d3
		swap	d5
		move.b	(a1,d5),d4
		and.b	d4,d3
		cmp.b	#0,d3
		bne	set_pt_b
		move.w	#0,val_pt_b
		rts
set_pt_b	move.w	#1,val_pt_b
		rts

calcul1
		move.w	val_pt_a,d2
		move.w	val_pt_b,d3
		move.w	d2,d4
		move.w	d3,d5
		add.w	d4,d5
		cmp.w	#2,d5
		beq	exclusif
		or.w	d2,d3		;xor
		move.w	d3,val_res
		bra	suite_calcul
exclusif	clr.w	val_res
		bra	suite_calcul


calcul2
		move.w	val_pt_a,d2
		move.w	val_pt_b,d3
		or.w	d2,d3		;and
		bchg	#0,d3
		move.w	d3,val_res
		rts

point_c
		cmp.w	#0,val_res
		beq	pas_point_c
		lea	image,a0	;d1 x
		lea	table,a1	;d0 y
		clr.l	d5
		clr.l	d6
		move.w	d1,d5		;save x
		move.w	d0,d6		;save y
		;add.w	#1,d5
		add.w	#1,d6
		mulu	#40,d6
		divs	#8,d5
		add.w	d5,d6
		add.w	d6,a0
		swap	d5
		move.b	(a1,d5),d6
		or.b	d6,(a0)
pas_point_c	rts

point_d
		cmp.w	#0,val_res
		beq	pas_point_d
		lea	image,a0	;d1 x
		lea	table,a1	;d0 y
		clr.l	d5
		clr.l	d6
		move.w	d1,d5		;save x
		move.w	d0,d6		;save y
		add.w	#1,d5
		add.w	#1,d6
		mulu	#40,d6
		divs	#8,d5
		add.w	d5,d6
		add.w	d6,a0
		swap	d5
		move.b	(a1,d5),d6
		or.b	d6,(a0)
pas_point_d	rts


val_pt_a	dc.w	0
val_pt_b	dc.w	0
val_res		dc.w	0

quel_calcul	dc.b	1,0

table	dc.b	$80,$40,$20,$10,$8,$4,$2,$1
	even
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
;	,$00e40000,$00e60000
;		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
;		dc.l	$00f00000,$00f20000,$00f40000,$00f60000
		dc.l	$01001a00
coul_img:

		dc.w	$0180,$0000,$0182,$0fff
		
		dc.l	-2
;------------------------------------------------------------------------
image	dcb.b	40*256
end

