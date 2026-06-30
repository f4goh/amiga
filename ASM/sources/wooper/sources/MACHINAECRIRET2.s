;-------------------------------------------------------------------
;MACHINE A ECRIRE: by WOOPER/PROFECY
;-------------------------------------------------------------------

execbase=4
nb_plan=1
hauteurimage=100		;en ligne
debutaffiche=$2e01		;1er wait de l'ecran
debutecriture=(64+16)*2		;adresse dans image du debut de l'ecriture(64*nbr ligne)
pausemachine=0			;pause pour affichage des lettres
pscreen=100			;pause entre chaque screen

	section	code,code_c
start
	bsr	save_all	;Tres tres classique...
	move.l	#$dff000,a6
	clr.l	$144(a6)	;sprite souris off
	bsr	install1	
	bsr	active_copper

boucle
	cmp.b	#-1,$6(a6)
	bne.s	boucle
	move.w	#$fff,$180(a6)	;test tps machine
	bsr	affiche_lettre
	clr.w	$180(a6)	;test tps machine 2, le retour
	btst	#6,$bfe001
	bne.s	boucle
restore_all
	move.w 	#$7fff,$dff096		;vide le dmacon
	move.w	save_dmacon,$dff096	;place la copie sauvée avant 
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
fin	clr.l	d0
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
	move.w	#$83d0,$96(a6)
	rts

affiche_lettre

copiebloc
	cmp.w	#1,fin_affichage
	bne	suite_zob
	rts
suite_zob
	cmp.w	#$0,pause1
	bne	affiche_pas
	move.w	#pausemachine,pause1
	clr.w	d1
	clr.w	d0
	moveq.w	#$7,d0		;iteration (8-1)
	move.l	lsuiv,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
	cmp.b	#"z",d1
	beq	saute_ligne
	cmp.b	#$ff,d1
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
	cmp.w	#$28,nolettre
	beq	saute_ligne	
	addq.l	#$1,posecran	;On svg la pos de la prochaine lettre
				;ne pas oublier d'ajouter 1 octet pour
				;la lettre suivante!...
ret_saut

	rts
suite_debut
	rts
saute_ligne
	add.l	#1,noligne
	move.l	noligne,posecran
	move.l	posecran,d7
	muls.w	#40*8,d7
	lea	image+debutecriture,a0
	add.l	a0,d7
	move.l	d7,posecran
	add.l	#1,lsuiv
	move.w	#0,nolettre
	bra	ret_saut
affiche_pas
	subq.w	#$1,pause1
	rts

retourdebut
	move.l	#texte,lsuiv
	move.w	#1,fin_affichage

	rts	
fin_affichage
	dc.w	0
lsuiv
	dc.l	texte

lignecours
	dc.l	image
nolettre
	dc.w	0
noligne
	dc.l	1
posecran
	dc.l	image+debutecriture
pause1
	dc.w	pausemachine

save_all
	move.b	#%10000111,$bfd100	;on arrete les drives
	move.l	4,a6			;no comment
	jsr	-132(a6)		;stopper le multitache
	move.w	$dff002,save_dmacon	;save registre dma
	or.w	#$8100,save_dmacon	;bit 15 et 14 à 1
	rts
					
save_dmacon
	dc.w 0
name_glib
	dc.b "graphics.library",0

	even
;-----------------------------------------------------------------------
	section	data,data_c

copper
		dc.w	$180,$0
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.w	debutaffiche,$fffe
		dc.w	$0100,$1200
		dc.w	$180,$0
		dc.w	debutaffiche+hauteurimage*$100
		dc.w	$0100,$0	;desactive affichage
		dc.l	-2
;------------------------------------------------------------------------
	even
adresseplan
	dc.l	0
	even
texte
	; 20 LETTRES MAX SUR UNE LIGNE...

	dc.b	"THE MODULE IS NOW LOADING...z"
	dc.b	"SO PLEASE WAIT!!!z"
	dc.b	"THIS MODULE IS CALLED 'TECHNOMEGAREMIX'z"
	dc.b	"THERE IS SAMPLES FROM:z"
	dc.b	-1	;indique la fin a ne pas enlever!!
	even
image
	ds.b	40*256
	even
font
	incbin	tools/font8x8
	even
end


