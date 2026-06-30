;-------------------------------------------------------------------
;-                     		TETE RISQUE       	    	   -
;-------------------------------------------------------------------


execbase = 4
nb_plan = 1
nb_sprite = 2
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
	bsr	plans_logo

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
	add.l	#(4*16)+8,d0		;4l*16+8
	addq.l	#8,a0
	dbf	d1,sprite_suivant
	rts
;------------------------------------------------------------------------
menu
vbl
		cmp.b	#-1,$dff006
		bne	vbl
		bsr	deplace_sprite
souris		btst	#6,$bfe001
		bne	souris
		rts
;----------------------------------------------
deplace_sprite
		lea	position_x(pc),a0
		move.w	(a0),d0		;x
		move.w	d0,d1
		lsr.w	#1,d0
		and.w	#1,d1
		move.b	2(a0),d2	;y
		lsl.b	#2,d2
		or.b	d2,d1
		move.b	4(a0),d2	;y+hauteur
		lsl.b	#1,d2
		or.b	d2,d1
		move.w	2(a0),d2	;y
		lsl.w	#8,d2
		or.w	d2,d0
		move.w	4(a0),d2	;y+hauteur
		lsl.w	#8,d2
		or.w	d2,d1
		swap	d0
		move.w	d1,d0
		move.l	d0,sprite
		rts
position_x		dc.w	$80		;sprite
position_y1		dc.w	$2c
position_y2		dc.w	$2c+16
;------------------------------------------------------------------------
sprite
	dc.w	$0000,$0000	

	dc.w	%0000000111110000,%0000111100000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111100001111111,%1111100000011111
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111100000111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%1111111111111111
	dc.w	%1111111111111111,%1111111111111111
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%0000000000000000,%1111111111111111
	dc.w	%0000000000000000,%1111111111111111
	dc.w	%1111111111111111,%0000000000000000
	dc.w	0,0

	dc.w	$8080,$9000	
	dc.w	%0000111111000000,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%0000000000000000,%0000000000000000
	dc.w	%1111111111111111,%0000000000000000
	dc.w	0,0
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040024,$01080000,$010a0000	;spr & modulos
bmapsprite	dc.w	$120,0,$122,0,$124,0,$126,0
		dc.w	$128,0,$12a,0,$12c,0,$12e,0
		dc.w	$130,0,$132,0,$134,0,$136,0
		dc.w	$138,0,$13a,0,$13c,0,$13e,0
		dc.w	$1a2,$f00	;001	
		dc.w	$1a4,$0f0	;010
		dc.w	$1a6,$00f	;011
		dc.w	$1a8,$fff	;100


bmap		dc.l	$00e00000,$00e20000

		dc.l	$01001200		;bitplane active
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan

end

