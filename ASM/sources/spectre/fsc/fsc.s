;-------------------------------------------------------------------
;-             		pour FSC	 	 	    	   -
;-------------------------------------------------------------------

; voila fsc j'ai fini ton animation comme promis
; il ya eu 2 bugs non prevus :
; - mulu au lieu de muls pour calculer le coef de reduction
; - double buffer pour permettre le remplissage

;-------------------------------
vbl1		macro
loop_vbl1\@
	move.l	$4(a6),d6
	and.l	#$1ff00,d6
	cmp.l	#$11000,d6
	bne.s	loop_vbl1\@
	endm
;-------------------------------
wait_blt	macro
loop_blt\@
	btst	#14,$2(a6)
	bne.s	loop_blt\@
	endm
;-------------------------------

execbase = 4
debut_fsc = 10

	section	code,code_c
start:
save_all:
	move.l	#$dff000,a6
	move.w	$2(a6),save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$1c(a6),save_intena
	or.w	#$c000,save_intena

;-------------------------------- pour les  plans inuite 2 buffer !!
	;lea	bmapfsc(pc),a0
	;move.l	#fsc1,d0
	;move.w	d0,6(a0)
	;swap	d0
	;move.w	d0,2(a0)

;copper initialise
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
	clr.l	$144(a6)
;dma active
	move.w	#$83c0,$96(a6)
	bsr	menu_fsc

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
;------------------------------------------------ MENU fsc
menu_fsc
vbl_fsc		vbl1
		move.w	#$f,$180(a6)	;temps machine
		bsr	dessine_fsc
		clr.w	$180(a6)

souris		btst	#6,$bfe001
		bne	vbl_fsc
		;bne	souris
		rts
;------------------------------------ efface ,trace ,rempli l'fsc
dessine_fsc
		move.l	pointeur1(pc),d0
		move.l	pointeur2,pointeur1
		move.l	d0,pointeur2
		lea	bmapfsc(pc),a0
		move.w	d0,6(a0)
		swap	d0
		move.w	d0,2(a0)
				
		move.l	pointeur1,a0	;ecran a changer

		wait_blt		;efface ecran
		move.l	a0,$54(a6)
		move.l	#-1,$44(a6)
		move.l	#$01000000,$40(a6)
		clr.w	$66(a6)
		move.w	#256*64+20,$58(a6)

		
		wait_blt		;init routine de trace
		move.w	#40,$60(a6)
		move.l	#$ffff8000,$72(a6)
		move.l	#-1,$44(a6)

		cmp.l	#160,count_anims
		bne	dessine_contour
		move.l	#debut_fsc,count_anims
				
dessine_contour
		add.l	#2,count_anims
		move.l	count_anims,d7

		move.l	#160,d4
		lea	data_points_fsc,a1
		move.w	(a1)+,d5
trace_fsc
		moveq	#0,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3
		movem.w	(a1)+,d0-d3

		muls	d7,d0		;coef de reduction
		divs	d4,d0
		muls	d7,d1
		divs	d4,d1		
		muls	d7,d2
		divs	d4,d2		
		muls	d7,d3
		divs	d4,d3		


		add.w	#160,d0		;changement de repere x
		add.w	#160,d2

		move.w	d1,d6		;changement de repere y
		move.w	#128,d1
		sub.w	d6,d1		
		move.w	d3,d6
		move.w	#128,d3
		sub.w	d6,d3		
		bsr	drawline
		dbf	d5,trace_fsc

rempli_fsc	wait_blt
		add.l	#(248*40)-2,a0
		move.l	a0,$54(a6)	;dest
		move.l	a0,$50(a6)	;srce
		move.l	#-1,$44(a6)
		move.l	#$09f0000a,$40(a6)
		clr.l	$64(a6)
		move.w	#248*64+20,$58(a6)
		rts
count_anims	dc.l	debut_fsc
pointeur1	dc.l	fsc1
pointeur2	dc.l	fsc2
;---------------------------------- trace une ligne
drawline:	
	movem.l	d0-d7/a0,-(a7)
	move.l	#40,d5		;largeur ecran
	cmp.w	d1,d3
	bgt.s	line1
	exg	d0,d2
	exg	d1,d3
	beq.s	out
line1:	move.w	d1,d4
	muls	d5,d4
	move.w	d0,d5
	add.l	a0,d4
	asr.w	#3,d5
	add.w	d5,d4
	moveq	#0,d5
	sub.w	d1,d3
	sub.w	d0,d2
	bpl.s	line2
	moveq	#1,d5
	neg.w	d2
line2:	move.w	d3,d1
	add.w	d1,d1
	cmp.w	d2,d1
	dbhi	d3,line3
line3:	move.w	d3,d1
	sub.w	d2,d1
	bpl.s	line4
	exg	d2,d3
line4:	addx.w	d5,d5
	add.w	d2,d2
	move.w	d2,d1
	sub.w	d3,d2
	addx.w	d5,d5
	and.w	#15,d0
	ror.w	#4,d0
	or.w	#$a4a,d0
waitblt:btst	#6,2(a6)
	bne.s	waitblt
	move.w	d2,$52(a6)
	sub.w	d3,d2
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d0,$40(a6)
	move.b	oct(PC,d5.w),$43(a6)
	move.l	d4,$48(a6)
	move.l	d4,$54(a6)
	movem.w	d1/d2,$62(a6)
	move.w	d3,$58(a6)
	movem.l	(a7)+,d0-d7/a0
out:	rts
oct:	dc.l	$3431353,$b4b1757   
;------------------------------------------------------------------------
data_points_fsc
	dc.w	15-1			;15 doites (-1 pour le dbf)
	dc.w	-155,120,-155,-120
	dc.w	-55,120,-55,90
	dc.w	-125,90,-125,15
	dc.w	-85,15,-85,-15
	dc.w	-125,-15,-125,-120
	dc.w	-50,120,-50,-15
	dc.w	50,120,50,90
	dc.w	-20,90,-20,15
	dc.w	50,15,50,-120
	dc.w	20,-15,20,-90
	dc.w	-50,-90,-50,-120
	dc.w	155,120,155,90
	dc.w	55,120,55,-120
	dc.w	85,90,85,-90
	dc.w	155,-90,155,-120
	
;------------------------------------------------------------------------
copperlist
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
		;dc.w	$0180,0
		dc.w	$0182,$bbb
bmapfsc		dc.l	$00e00000,$00e20000
		dc.l	$01001200
		dc.l	-2
;------------------------------------------------------------------------
fsc1		dcb.b	40*256
fsc2		dcb.b	40*256
end




