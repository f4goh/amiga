;----------------------------------------------------------------------------
;-									    -
;----------------------------------------------------------------------------

		opt c+,o+,ow-
		section	code,code_c

S		movem.l	d0-d7/a0-a6,-(sp)
		bsr	saveall
		bsr	init
		bsr	startcopper
		bsr	vbl
		bsr	restoreall
		movem.l	(sp)+,d0-d7/a0-a6
		rts

saveall:	lea	oldcop(pc),a2
		move.l	$4,a6
		lea	lib(pc),a1
		moveq	#0,d0
		jsr	-408(a6)
		move.l	d0,a0
		move.l	$26(a0),(a2)+
		lea	$dff000,a6
		move.w	$1c(a6),d0
		bset	#15,d0
		move.w	d0,(a2)+
		move.w	2(a6),d0
		bset	#15,d0
		move.w	d0,(a2)+
		rts

restoreall	lea	oldcop(pc),a0
		move.l	(a0)+,$80(a6)
		move.w	(a0)+,$9a(a6)
		move.w	(a0)+,$96(a6)
		rts

init
		move.w	#$1200,$100(a6)
		clr.w	$102(a6)
		clr.w	$104(a6)
		clr.w	$108(a6)
		clr.w	$10a(a6)
		move.w	#$2981,$8e(a6)
		move.w	#$f1c1,$90(a6)
		move.w	#$0038,$92(a6)
		move.w	#$00d0,$94(a6)
		bsr	build_coplist
		rts

startcopper	
		lea	copperlist,a0
		move.l	a0,$80(a6)
		tst.w	$88(a6)
		move.w	#$7fff,$96(a6)
		move.w	#$83c0,$96(a6)		;dma copper,blitter & bitplane
		move.w	#$7fff,$9a(a6)
		move.w	#$c010,$9a(a6)
		rts

oldcop:		dc.l	0
olddma:		dc.w	0
lib:		dc.b	'graphics.library',0
		even

;------------------------------------
build_coplist
		lea	copperlist,a0
		move.w	#$e0,(a0)+
		move.l	#ecran,d1
		swap	d1
		move.w	d1,(a0)+
		move.w	#$e2,(a0)+
		swap	d1
		move.w	d1,(a0)+
		lea	image,a1
		moveq	#$29,d0
loop_chaque_ligne
		move.w	#$142,(a0)+	;spr0ctl
		move.w	d0,d1
		lsl.w	#8,d1
		and.w	#$ff00,d1
		move.w	d1,(a0)
		addq.w	#1,(a0)+
		move.w	d0,d1
		ror.l	#8,d1
		and.l	#$ff000000,d1
		or.l	#$0039fffe,d1
		move.l	d1,(a0)+
		move.w	d0,d1
		lsl.w	#8,d1
		and.w	#$ff00,d1
		or.w	#$0040,d1
		moveq	#20-1,d2
loop_each_word
		move.w	#$140,(a0)+	;spr0pos
		move.w	d1,(a0)+
		move.w	#$144,(a0)+	;spr0data
		move.w	(a1)+,(a0)+
		addq.w	#8,d1
		dbf	d2,loop_each_word
		addq.w	#1,d0
		cmp.w	#$f1,d0
		blt.s	loop_chaque_ligne
		move.l	#$fffffffe,(a0)+
		rts
;--------------------------------------------
vbl	cmp.b	#6,$6(a6)
	bne.s	vbl
	
wait_blt
	btst	#14,$2(a6)
	bne.s	wait_blt
	clr.w	$74(a6)		;bltadat
	clr.w	$64(a6)		;bltamod
	move.l	#-1,$44(a6)
	move.l	#$01f00000,$40(a6)
	clr.w	$66(a6)		;bltdmod
	move.l	#ecran,$54(a6)	;dest
	move.w	#200*64+20,$58(a6)	;320*200
	move.b	$bfec01,d0
	not	d0
	ror.b	#1,d0
	cmp.b	#$45,d0
	beq.s	init_end
	
	btst	#6,$bfe001
	bne.s	vbl
init_end
	rts
;------------------------------------
;donnees
;------------------------------------
image	dcb.l	(320*200)/4,-1
ecran	ds.l	(320*200)/4
copperlist
	ds.l	34000/4

