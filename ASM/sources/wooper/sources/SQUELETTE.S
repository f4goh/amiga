;**********************************************************************
; SQUELETTE POUR TOUT LES PROGRAMMES...
; Réalisation: WOOPER/PROFECY
;
; Alias David CALLY
;	23, rue de l'aubepine
;	49124 st barthelemy
;	FRANCE
;	Tel: 41 93 96 41
;
;**********************************************************************

;**********************************************************************
; P A R A M E T R E S
;**********************************************************************

nb_plan=5
hauteurimage=256

	section	principale,code_c
debut
	bsr	save_all	;C'est classique...
	move.l	#$dff000,a6	;Ouais...
	move.w	#$7fff,$96(a6)	;A mettre je crois pour les interruptions...
	move.w	#$7fff,$9a(a6)	;Ca aussi...
	clr.l	$144(a6)	;sprite souris off
	bsr	install1	;installation pour un ecran 5 plans
	bsr	active_copper	;Bon...
boucle
	cmp.b	#-1,$6(a6)
	bne.s	boucle
	move.w	#$fff,$180(a6)	;test tps machine
	clr.w	$180(a6)	;test tps machine 2, le retour
	btst	#6,$bfe001
	bne.s	boucle

	bsr	restore_all	;Ca aussi c'est classique...
	clr.l	d0		;Code retour
	rts			;The end

save_all:
	move.b	#%10000111,$bfd100	;on arrete les drives
	move.l	4,a6			;no comment
	jsr	-132(a6)		;stopper le multitache
	move.w	$dff002,save_dmacon	;save registre dma
	or.w	#$8100,save_dmacon	;bit 15 et 14 à 1
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena
	rts

restore_all:
	move.w	#$7fff,$dff096		;vide le dmacon
	move.w	save_dmacon,$dff096	;place la copie sauvée avant 
	move.w	#$7fff,$dff09a		;vide intena
	move.w	save_intena,$dff09a
	move.l	4,a6
	lea	name_glib,a1		;ouvre la library
	moveq	#0,d0
	jsr	-552(a6)		;open-library
	move.l	d0,a0			;sauve handler
	move.l	38(a0),$dff080		;restore de la copper liste
	clr.w	$dff088			;clear copjmp1
	move.l	d0,a1			;adr de library
	jsr	-414(a6)		;closelibrary
	jsr	-138(a6)		;autorise le multitache
	rts
install1
	;installation de la 1ere liste copper
	lea	bmap,a0
	move.l	#image,d0
	moveq	#nb_plan-1,d1
plan_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*hauteurimage,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
	rts

active_copper
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
	;dma active
	move.w	#%1000001111000000,$96(a6)
	rts

save_intena:
	dc.w 	0
save_dmacon:
	dc.w	0
name_glib:
	dc.b "graphics.library",0	
	even				

;********************************************************

	section		data,data_c	;Est-ce vraiment necessaire?

copper:
		dc.w	$100,$0

		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
		dc.w	$2e01,$fffe
		dc.w	$0100,$5200
		dc.w	$0180,$0000,$0182,$0fff,$0184,$0777,$0186,$0fff
		dc.w	$0188,$0aaa,$018a,$0fff,$018c,$0fff,$018e,$0fff
		dc.w	$0190,$0fff,$0192,$0fff,$0194,$0fff,$0196,$0fff	
		dc.w	$0198,$0fff,$019a,$0fff,$019c,$0fff,$019e,$0fff
		dc.w	$01a0,$0fff,$01a2,$0555,$01a4,$0000,$01a6,$0000
		dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
		dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
		dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

		dc.l	-2
;------------------------------------------------------------------------
	even
image
	ds.b	40*hauteurimage*nb_plan
	even
end




	
