;-------------------------------------------------------------------
;-                 LA GESTION DE LA SOURIS PAR LE SPRITE       	   -
;-------------------------------------------------------------------


execbase = 4
nb_plan = 1
nb_sprite = 1
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena

	bsr	plans_ecran

;copper initialise
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
;dma active
	move.w	#$83e0,$96(a6)	;c
	bsr	menu
	
restore_all
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
;-------------------------------- pour les  plans ecran
plans_ecran
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
		move.w	#$f,$180(a6)
		bsr	test_souris
		bsr	deplace_mouse
		clr.w	$180(a6)
souris		btst	#6,$bfe001
		bne	vbl
		rts
;------------------------------------------------------------------------
test_souris
la		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d4

		lea	$dff00a,a0
		move.b	1(a0),d0
		move.b	(a0),d1
		
		move.b	oldx,d2
		move.b	oldy,d3
		move.b	d2,d4
		lsl.w	#8,d4

		move.b	d0,oldx
		move.b	d1,oldy
		sub.b	d2,d0
		sub.b	d3,d1

		add.b	newx,d0
		add.b	newy,d1

		move.b	d0,d4
		cmp.w	#$f000,d4
		blo	suite1
		bset.b	#0,posx
suite1
		cmp.w	#$00bb,d4
		bgt	suite2
		bclr.b	#0,posx
suite2

		move.b	d0,newx
		move.b	d1,newy
		

		move.b	d0,posx+1	;sauvegarde pour le sprite
		move.b	d1,posy1+1
		add.b	#16,d1
		move.b	d1,posy2+1
		rts


newx:		dc.b	0
newy:		dc.b	0
oldx:		dc.b	0
oldy:		dc.b	0


deplace_mouse
		lea	posx(pc),a0
		move.w	(a0),d0
		move.w	d0,d1
		lsr.w	#1,d0
		and.w	#1,d1
		move.b	2(a0),d2
		lsl.b	#2,d2
		or.b	d2,d1
		move.b	4(a0),d2
		lsl.b	#1,d2
		or.b	d2,d1
		move.w	2(a0),d2
		lsl.w	#8,d2
		or.w	d2,d0
		move.w	4(a0),d2
		lsl.w	#8,d2
		or.w	d2,d1
		swap	d0
		move.w	d1,d0
		move.l	d0,sprite
		rts

posx	dc.w	$80+(160-8)	;x=0  $80
posy1	dc.w	$2c+(128-8)	;y=0  $2c
posy2	dc.w	$2c+16+(128-8)
;******************************************************
sprite
	dc.w	$2c40,$3c00	
	dc.w	$07c0,$0440,$1830,$1930,$2008,$2008,$4004,$4104
	dc.w	$4004,$4004,$8002,$8102,$8002,$0000,$8002,$5454
	dc.w	$8002,$0000,$8002,$8102,$4004,$4004,$4004,$4104
	dc.w	$2008,$2008,$1830,$1930,$07c0,$0440,$0000,$0000
	dc.w	0,0
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01040024,$01080000,$010a0000	;spr & modulos
bmapsprite	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$1a2,$fff	;001	
		dc.w	$1a4,$ccc	;010
		dc.w	$1a6,$777	;011


bmap		dc.l	$00e00000,$00e20000
;		dc.l	$00e40000,$00e60000
;		dc.l	$00e80000,$00ea0000
;		dc.l	$00ec0000,$00ee0000

;		dc.w	$0180,$0000
		dc.w	$0182,$0fff


		dc.l	$01001200		;bitplane active
		dc.l	-2
;------------------------------------------------------------------------
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan
end


