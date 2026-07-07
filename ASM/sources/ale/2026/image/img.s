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
	        dc.w    $0180,$0000
        dc.w    $0182,$0FFF
        dc.w    $0184,$0ACD
        dc.w    $0186,$0121
        dc.w    $0188,$0120
        dc.w    $018A,$0789
        dc.w    $018C,$08AA
        dc.w    $018E,$0478
        dc.w    $0190,$0444
        dc.w    $0192,$0469
        dc.w    $0194,$0456
        dc.w    $0196,$069B
        dc.w    $0198,$0146
        dc.w    $019A,$0684
        dc.w    $019C,$047A
        dc.w    $019E,$0365

        dc.w    $01A0,$0774
        dc.w    $01A2,$0351
        dc.w    $01A4,$0135
        dc.w    $01A6,$0445
        dc.w    $01A8,$0662
        dc.w    $01AA,$09A5
        dc.w    $01AC,$0772
        dc.w    $01AE,$08A6

        dc.w    $01B0,$0167
        dc.w    $01B2,$0322
        dc.w    $01B4,$0A99
        dc.w    $01B6,$0042
        dc.w    $01B8,$0874
        dc.w    $01BA,$0474
        dc.w    $01BC,$0797
        dc.w    $01BE,$0434

		dc.l	-2
;------------------------------------------------------------------------
	even
image
	;ds.b	40*hauteurimage*nb_plan
    incbin "montagne.raw"
	even
end




	
