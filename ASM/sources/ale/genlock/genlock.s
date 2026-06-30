;-------------------------------------------------------------------
;-                 	Genlock pour l'inspecteur derrick          -
;-------------------------------------------------------------------

gen1=$1200
gen0=0

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

;installation de la 1ere liste copper
	move.w	#gen0,plan
	clr.w	coul
	clr.w	coul0
		
;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
	clr.l	$144(a6)
;dma active
	move.w	#$83c0,$96(a6)
	bsr	menu
	
restore_all
	move.l	execbase,a6
 	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
 	move.w	#$7fff,$dff09a
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

;------------------------------------------ Menu
menu
		move.l	#pointe_ecran,a1
vbl		move.l	$4(a6),d4
		and.l	#$1ff00,d4
		cmp.l	#$0ff00,d4
		bne	vbl
		bsr	test_touche
		tst.w	pas_touche
		beq	souris
wait		btst	#10,$dff016
		bne	wait
souris		
		btst	#6,$bfe001
		bne	vbl
		rts

pointe_ecran	dc.l	ecran1
		dc.l	ecran2
		dc.l	ecran3
		dc.l	ecran4
		dc.l	ecran5
		dc.l	ecran6
		dc.l	ecran7
		dc.l	ecran8
test_touche
	move.w	#0,d0
	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	beq	next_plan
	cmp.b	#$58,d0
	beq	plan_noir
	cmp.b	#$57,d0
	beq	plan_bleu
	clr.w	pas_touche
	rts
pas_touche
	dc.w	0

next_plan
	move.w	#1,pas_touche
	lea	bmap(pc),a0
	move.l	(a1)+,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	move.w	#gen1,plan
	move.w	#$fff,coul
	clr.w	coul0
	rts
plan_noir
	move.w	#1,pas_touche
	move.w	#gen0,plan
	clr.w	coul
	clr.w	coul0
	rts
plan_bleu
	move.w	#1,pas_touche
	move.w	#gen0,plan
	move.w	#$f,coul0
	rts
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.w	$0100
plan		dc.w	$0
		dc.w	$180
coul0		dc.w	$000
		dc.w	$182
coul		dc.w	$0
		dc.l	-2
;------------------------------------------------------------------------
ecran1:		incbin	1pre.raw
ecran2:		incbin	2cin.raw
ecran3:		incbin	3ext.raw
ecran4:		incbin	1pub.raw
ecran5:		incbin	5cama.raw
ecran6:		incbin	5fred.raw
ecran7:		incbin	4pate.raw
ecran8:		incbin	3fan.raw
;------------------------------------------------------------------------
end


