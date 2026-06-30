;-------------------------------------------------------------------
;-                 		Le Club 3000     	      	   -
;-------------------------------------------------------------------


execbase = 4
nb_plan = 1
pause_k2000=0		;en vbl

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
;	move.w	#$7fff,$9a(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
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
	rts
;------------------------------------------------------------------------
menu
vbl
		cmp.b	#-1,$dff006
		bne	vbl
;		btst	#10,$dff016
;		bne	vbl
		bsr	club
souris		btst	#6,$bfe001
		bne	vbl
		rts
;---------------------------------- club modulo
club
		rts
;---------------------------------- pourquoi pas
kitt
		cmp.w	#0,pause_k2000bis
;		beq	fait_k2000
		sub.w	#1,pause_k2000bis
		rts
pause_k2000bis
	dc.w	pause_k2000

		move.l	a1,$54(a6)		;dest
		move.l	a0,$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000020,$64(a6)
		move.w	#256*64+4,$58(a6)

efface_lettre	btst	#14,$2(a6)
		bne.s	efface_lettre
;		move.l	#spchar,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#16*64+2,$58(a6)
		rts		
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000


		dc.l	$01001200

		dc.l	$2fe1fffe
bmap		dc.l	$00e00000,$00e20000,$01080000,$010a0000

		dc.l	$4de1fffe,$0108ffb0,$010affb0
		dc.l	$6ae1fffe,$01080000,$010a0000
		dc.l	$87e1fffe,$0108ffb0,$010affb0
		dc.l	$a4e1fffe,$01080000,$010a0000
		dc.l	$c1e1fffe,$0108ffb0,$010affb0
		dc.l	$dee1fffe,$01080000,$010a0000
		dc.l	$fbe1fffe,$0108ffb0,$010affb0

		dc.l	-2
;------------------------------------------------------------------------
image_club:	;incbin	club.raw
;------------------------------------------------------------------------
	dcb.b	40*21*nb_plan
ecran
	incbin	club.raw
end



