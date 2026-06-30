;-------------------------------------------------------------------
;-   UNE ANIMATION DE TRACE DE SURFACES PAR POINTS  (400 PTS) 	   -
;-------------------------------------------------------------------

execbase = 4
nb_plan = 3
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$8100,save_intena

;installation de la 1ere liste copper
	lea	bmap(pc),a0
	move.l	#ecran,d0
	moveq	#nb_plan-1,d1
plan_suivant	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*2,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
;copper initialise
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
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
;------------------------------------------------------------------------
menu
		lea	table,a1
		lea	ecran+4,a0
		move.l	a0,a2
		lea	images,a3

vbl		cmp.b	#$e0,$6(a6)
		bne.S	vbl
;		move.w	#$f,$180(a6)
		bsr	clear_surface
		bsr	trace
		bsr	pause
;		clr.w	$180(a6)

souris		btst	#6,$bfe001
		bne	vbl
		rts
pause		
		move.l	#30,d7
vblp		cmp.b	#$e0,$6(a6)
		bne.S	vblp
		dbf	d7,vblp
		rts
trace
		moveq	#0,d0
		moveq	#0,d1
		cmp.l	#fin_images,a3
		bne	suite
		lea	images,a3
suite		move.l	#400-1,d3
affiche_trace	move.b	(a3)+,d1
		move.b	(a3)+,d0
		bsr	point2
		dbf	d3,affiche_trace	
		rts



point2
		move.l	a2,a0
		move.l	d1,d5		;save x
		move.l	d0,d6		;save y
		mulu	#40,d6
;		lsl.l	#5,d6		; * 32
		lsl.l	#2,d5		;ajust offset
		move.l	(a1,d5),d5	;pour la table
		add.w	d5,d6
		add.w	d6,a0
		swap	d5
		bset	d5,(a0)
		rts

;---------------------------------- efface ecran
clear_surface	btst	#14,$2(a6)
		bne.s	clear_surface
		move.l	#ecran+(40*20),$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#220*64+20,$58(a6)
wait_clear	btst	#14,$2(a6)
		bne.s	wait_clear
		rts		

table	
	dc.w	7,0,6,0,5,0,4,0,3,0,2,0,1,0,0,0
	dc.w	7,1,6,1,5,1,4,1,3,1,2,1,1,1,0,1
	dc.w	7,2,6,2,5,2,4,2,3,2,2,2,1,2,0,2
	dc.w	7,3,6,3,5,3,4,3,3,3,2,3,1,3,0,3
	dc.w	7,4,6,4,5,4,4,4,3,4,2,4,1,4,0,4
	dc.w	7,5,6,5,5,5,4,5,3,5,2,5,1,5,0,5
	dc.w	7,6,6,6,5,6,4,6,3,6,2,6,1,6,0,6
	dc.w	7,7,6,7,5,7,4,7,3,7,2,7,1,7,0,7
	dc.w	7,8,6,8,5,8,4,8,3,8,2,8,1,8,0,8
	dc.w	7,9,6,9,5,9,4,9,3,9,2,9,1,9,0,9
	dc.w	7,10,6,10,5,10,4,10,3,10,2,10,1,10,0,10
	dc.w	7,11,6,11,5,11,4,11,3,11,2,11,1,11,0,11
	dc.w	7,12,6,12,5,12,4,12,3,12,2,12,1,12,0,12
	dc.w	7,13,6,13,5,13,4,13,3,13,2,13,1,13,0,13
	dc.w	7,14,6,14,5,14,4,14,3,14,2,14,1,14,0,14
	dc.w	7,15,6,15,5,15,4,15,3,15,2,15,1,15,0,15
	dc.w	7,16,6,16,5,16,4,16,3,16,2,16,1,16,0,16
	dc.w	7,17,6,17,5,17,4,17,3,17,2,17,1,17,0,17
	dc.w	7,18,6,18,5,18,4,18,3,18,2,18,1,18,0,18
	dc.w	7,19,6,19,5,19,4,19,3,19,2,19,1,19,0,19
	dc.w	7,20,6,20,5,20,4,20,3,20,2,20,1,20,0,20
	dc.w	7,21,6,21,5,21,4,21,3,21,2,21,1,21,0,21
	dc.w	7,22,6,22,5,22,4,22,3,22,2,22,1,22,0,22
	dc.w	7,23,6,23,5,23,4,23,3,23,2,23,1,23,0,23
	dc.w	7,24,6,24,5,24,4,24,3,24,2,24,1,24,0,24
	dc.w	7,25,6,25,5,25,4,25,3,25,2,25,1,25,0,25
	dc.w	7,26,6,26,5,26,4,26,3,26,2,26,1,26,0,26
	dc.w	7,27,6,27,5,27,4,27,3,27,2,27,1,27,0,27
	dc.w	7,28,6,28,5,28,4,28,3,28,2,28,1,28,0,28
	dc.w	7,29,6,29,5,29,4,29,3,29,2,29,1,29,0,29
	dc.w	7,30,6,30,5,30,4,30,3,30,2,30,1,30,0,30
	dc.w	7,31,6,31,5,31,4,31,3,31,2,31,1,31,0,31
	dc.w	7,32,6,32,5,32,4,32,3,32,2,32,1,32,0,32
	dc.w	7,33,6,33,5,33,4,33,3,33,2,33,1,33,0,33
	dc.w	7,34,6,34,5,34,4,34,3,34,2,34,1,34,0,34
	dc.w	7,35,6,35,5,35,4,35,3,35,2,35,1,35,0,35
	dc.w	7,36,6,36,5,36,4,36,3,36,2,36,1,36,0,36
	dc.w	7,37,6,37,5,37,4,37,3,37,2,37,1,37,0,37
	dc.w	7,38,6,38,5,38,4,38,3,38,2,38,1,38,0,38
	dc.w	7,39,6,39,5,39,4,39,3,39,2,39,1,39,0,39

images	incbin	datasurfg
fin_images
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000
;		dc.l	$0108fff8,$010afff8
		dc.l	$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$01003a00
coul_img:
;		dc.w	$0180,$0000
		dc.w	$0182,$0555
		dc.w	$0184,$0999
		dc.w	$0186,$0fff
		dc.w	$0188,$0fff
		dc.w	$018a,$0fff
		dc.w	$018c,$0fff
		dc.w	$018e,$0fff
		
		dc.l	-2
;------------------------------------------------------------------------
ecran	dcb.b	40*256*3
end

