execbase = 4
nb_plan = 5
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
	move.l	val_pointeur,d0
	bsr	bit_maps
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
menu		cmp.b	#-1,$6(a6)
		bne.S	menu
		bsr	show_mem
souris		btst	#6,$bfe001
		bne	menu
		rts

bit_maps			;dans d0 adresse du plan
		lea	bmap(pc),a0
		moveq	#nb_plan-1,d1
plan_suivant	move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
		swap	d0
		add.l	#40*256,d0
		addq.l	#8,a0
		dbf	d1,plan_suivant
		rts

show_mem
		moveq	#0,d0
		move.b	$bfec01,d0
		not.b	d0
		ror.b	#1,d0
		cmp.b	#$59,d0
		beq	inc_pointeur
		cmp.b	#$58,d0
		beq	dec_pointeur
		rts
inc_pointeur	add.l	#32,val_pointeur
		move.l	val_pointeur,d0
		bsr	bit_maps
		rts
dec_pointeur	sub.l	#32,val_pointeur
		move.l	val_pointeur,d0
		bsr	bit_maps
		rts
	
val_pointeur	dc.l	$10000

;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
		dc.l	$01006a00

		dc.l	-2
;------------------------------------------------------------------------
end


