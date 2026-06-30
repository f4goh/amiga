;**********************************************************************
; Wooper again qui cette fois commence a coder un scroll vertical genre
; "THE END" dans un film 3 etoiles dans télépoche...
; Aujourd'hui c'est le 7/03/1992. Y fait pas beau mais je m'en fous car
; moi je code... Depuis que j'ai appris le BLITTER c'est plus cool et
; surtout je fais des routines bien plus rapides... Bon allez assez de
; bits inutiles, let's code!
; *********************************************************************
;
;	David CALLY
;	23, rue de l'aubepine
;	49124 st barthelemy
;	FRANCE
;	Tel: 41 93 96 41
;
;**********************************************************************

;**********************************************************************
; P A R A M E T R E S
;**********************************************************************

nb_plan=1
debutecriture=248*40
hauteurimage=320
pause=14
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
	bsr	scroll
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

affiche_lettre
	subq.w	#$1,tempo2
	cmp.w	#$0,tempo2
	bne	copiepas
	move.w	#8,tempo2
	move.l	#image+debutecriture,posecran
	move.w	#39,d2		;40-1 lettres a afficher sur la ligne
copiebloc
	clr.w	d1
	clr.w	d0
	moveq.w	#$7,d0		;iteration (8-1)
	move.l	lsuiv,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
	cmp.b	#-1,d1
	beq	retourdebut
ret_deb	sub.b	#32,d1		;-32 car 32=ESPACE
	lea	font,a0		;adresse de font dans a0
	add.w	d1,a0		;Voila, a0 contient l'adresse de la lettre
	move.l	posecran,a2	;Dans a0=adresse de lettre
				;Dans a1=valeur ascii de la lettre
				;Dans a2=position sur ecran
bcopie	move.b	(a0),(a2)	;Affiche parti de la lettre
	add.w	#64,a0		;Nouvelle partie de la lettre
	add.w	#40,a2		;
	dbf	d0,bcopie
	addq.l	#$1,a1
	move.l	a1,lsuiv
	add.w	#$1,nolettre
ret_saut
	addq.l	#$1,posecran	;On svg la pos de la prochaine lettre
				;ne pas oublier d'ajouter 1 octet pour
				;la lettre suivante!...
	dbf	d2,copiebloc
	move.l	#image+debutecriture,posecran
copiepas
	rts
retourdebut
	lea	texte,a1
	move.b	(a1),d1
	bra	ret_deb
lsuiv
	dc.l	texte
nolettre
	dc.w	0
posecran
	dc.l	image+debutecriture

scroll
		subq.w	#$1,tempo1
		cmp.w	#$0,tempo1
		bne	pas_scroll
		move.w	#pause,tempo1
		bsr	affiche_lettre
ret_mettre
		lea	image,a0
		lea	image+40,a1
w_blit		btst	#14,$2(a6)
		bne.s	w_blit
		move.l	a0,$54(a6) 			;dest ecran
		move.l	a1,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#255*64+20,$58(a6)
pas_scroll
		rts
tempo1				;tempo pour scroll
	dc.w	pause
tempo2				;tempo pour affichage de la ligne de texte
	dc.w	8
;********************************************************

copper:
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.w	$0100,$1200
		dc.w	$0180,$0000,$0182,$0fff

		dc.l	-2
;------------------------------------------------------------------------
	even
texte
	dc.b	" PROFECY HAS BEEN PROUD TO PRESENT YOU  "
	dc.b	"    THE FANTASTIC  LET'S RAVE DEMO !    "
	dc.b	-1	
	even
font
	incbin	tools/font8x8

image
	ds.b	40*hauteurimage*nb_plan
	even
end




	
