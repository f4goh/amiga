;*********************************************************************
; MENU commencé le 12/02/1992, fini le:24/02/92
; Réalisation: WOOPER/PROFECY
; (et apres seulement 1 mois 1/2 d'apprentissage de l'assembleur!)
; Alias David CALLY
;	23, rue de l'aubepine
;	49124 st barthelemy
;	FRANCE
;	Tel: 41 93 96 41
;
;
;Les noms des choix, le scroll-text et l'affichage des greetz sont à la
;fin du programme... (Faites Amiga droit+b pour allez a la fin.).
;
;Au niveau explication, j'ai pas grand chose à dire car c'est tres simple
;Vous n'avez qu'a changer le nom des demos (surtout ne pas oublier de
;modifier le parametre 'nb_choix' au debut du programme! Celui-ci contient
;le nombre de demos du pack.
;En ce qui concerne le scroll-text, n'oublie pas de laisser la ligne de
;blancs à la fin... sinon bug!
;
;Voici aussi les caracteristiques du logo:
;Taille: 320x101 16 couleurs (les couleurs sont a modifier dans la copper
;list... si vous savez pas comment faire contacter moi...)
;Je vous donne aussi l'adresse d'un mec: POLUX/KREATOR (un groupe minable
;mais ce gfx est assez good...) qui est d'accord pour faire quelques logos
;
;David GUILLIEN
;68 Ter rue Cdt Charcot
;69005 LYON
;Tel: 72 32 07 78
;
;Dites que c'est WOOPER qui vous a file son adresse...
;
;Je vous joinds aussi une disquette type contenant la routine cli
;le logo cli, et le loader (tres important!)
;
;Sur la disquette, le nom des fichiers pour les demos devront s'appeler 
; 00, 01, 02... jusqu'à 08 max
;
;Voila that's all! spreader a max les potots!
;
;(ATTENTION! Ce code est de la vrai merde! Alors ne vous amusez pas a 
;changer les parametres... De meme, le scroll plante mais j'ai magouiller
;de facon a ce que cela ne se voit pas! (vive les rasters!))
;
;WOOPER/PROFECY
;*********************************************************************

nb_choix=9			;ATTENTION, 9 choix max!
				;ne pas oublier de modifier!
nb_plan=5
nb_etoiles=50			;nombre d'etoiles (data=*5, Ok?)
nb_planlogo=4
hauteurlogo=101			;en ligne
debutaffiche=$4001		;1er wait de l'ecran
lignedebut=10
debutecriture=40*lignedebut	;adresse dans image du debut de l'ecriture
hauteurimage=140		;Hauteur de l'image des choix
nbrligne=22			;A ne pas modifier!
premierligne=$4a01		;Valeur 1er wait pour le choix
offset=$900			;Adresse second choix
pausemachine=0			;pause pour affichage des lettres
pscreen=50			;pause entre chaque screen
debutecriture2=40*1
largeur_equa=3			;en ligne
affiche_equa=91			;no de la ligne sur ecran


	section	principale,code_c
debut
	bsr	save_all	;C'est classique...
	move.l	#$dff000,a6	;Ouais...
	move.w	#$7fff,$96(a6)	;A mettre je crois pour les interruptions...
	move.w	#$7fff,$9a(a6)	;Ca aussi...
	clr.l	$144(a6)	;sprite souris off
	move.l	ptrcoul,a5	;Ah,AH! Ne plus toucher a a5
	bsr	install1	;installation des plans
	bsr	install2	;installation logo
	bsr	active_copper	;Bon...
	bsr	met_choix	;Affiche les choix sur ecran
	bsr	mt_init
boucle
	cmp.b	#-1,$6(a6)
	bne.s	boucle
	;move.w	#$fff,$180(a6)	;test tps machine

	bsr	barres
	bsr	etoiles
	bsr	affiche_lettre
	bsr	greetings
	bsr	equalizeur
	bsr	mt_music

	;clr.w	$180(a6)	;test tps machine 2, le retour
	btst	#6,$bfe001
	bne.s	boucle

	bsr	restore_all	;Ca aussi c'est classique...
	clr.l	d0		;Code retour
	move.b	nobarre+1,$100	;Svg choix
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

install2
	lea	bmap2,a0
	move.l	#logo,d0
	moveq	#nb_planlogo-1,d1
plan_suivant2
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*hauteurlogo,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant2
	rts

active_copper
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
	;dma active
	move.w	#%1000001111000000,$96(a6)
	rts

met_choix
	move.w	#39,d2		;40-1 lettres a afficher sur la ligne
	muls	#nb_choix,d2
copiebloc
	clr.w	d1
	clr.w	d0
	moveq	#$7,d0		;iteration (8-1)
	move.l	lsuiv,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
ret_deb	sub.b	#32,d1			;-32 car 32=ESPACE
	lea	font,a0			;adresse de font dans a0
	add.w	d1,a0			;Voila, a0 contient l'adresse de la lettre
	move.l	posecran,a2		;Dans a0=adresse de lettre
					;Dans a1=valeur ascii de la lettre
					;Dans a2=position sur ecran
bcopie	move.b	512(a0),hauteurimage*40(a2)		;Affiche parti de la lettre
	move.b	(a0),(a2)
	add.w	#64,a0			;Nouvelle partie de la lettre
	add.w	#40,a2		
	dbf	d0,bcopie
	addq.l	#$1,a1
	move.l	a1,lsuiv
	add.w	#$1,nolettre
	cmp.w	#40,nolettre
	beq	saute_ligne
ret_saut
	add.l	#1,posecran	;On svg la pos de la prochaine lettre
				;ne pas oublier d'ajouter 1 octet pour
				;la lettre suivante!...
	
	dbf	d2,copiebloc

	rts
saute_ligne
	add.l	#40*8,posecran
	move.w	#0,nolettre
	bra	ret_saut
lsuiv
	dc.l	texte
nolettre
	dc.w	0
posecran
	dc.l	image+debutecriture
save_intena:
	dc.w 	0
save_dmacon:
	dc.w	0
name_glib:
	dc.b "graphics.library",0	
	even				

;*************************************************************
equalizeur	
		bsr	efface_equa
		lea	mt_voice1+$12,a0
		cmp.w	#$0,(a0)
		beq	vol1_ok
		subq.w	#1,(a0)		;on decremente...

ret_voix1	bsr	affiche_equa1						

vol1_ok		

		lea	mt_voice2+$12,a0
		cmp.w	#$0,(a0)
		beq	vol2_ok
		subq.w	#1,(a0)		;on decremente...

ret_voix2	bsr	affiche_equa2

vol2_ok		

		lea	mt_voice3+$12,a0
		cmp.w	#$0,(a0)
		beq	vol3_ok
		subq.w	#1,(a0)		;on decremente...
	
ret_voix3	bsr	affiche_equa3
		
vol3_ok		

		lea	mt_voice4+$12,a0
		cmp.w	#$0,(a0)
		beq	vol4_ok
		subq.w	#1,(a0)		;on decremente...
		
ret_voix4	bsr	affiche_equa4

vol4_ok		
		rts	

efface_equa

		lea	image+(40*140*2)+(40*affiche_equa),a2
		move.w	#20*21,d0
efface		move.w	#$0,(a2)+
		dbf	d0,efface
		rts
		;btst	#14,$2(a6)
		;bne.s	efface_equa
		;move.l	#image+(40*256*3),$54(a6)
		;move.l	#$ffffffff,$44(a6)	;masque
		;move.l	#$01000000,$40(a6)	;bltcon0 et 1
		;move.w	#0,$66(a6)
		;move.w	#140*64+20,$58(a6)
		;rts

affiche_equa1
		lea	image+(40*hauteurimage*2)+(40*affiche_equa),a1
		move.l	a1,a2		;svg bidouille
		move.w	#largeur_equa-1,d1
ligne_suivante1
		move.w	(a0),d0
		lsr	#$1,d0
		
affiche1	move.b	#%11111111,(a1)+
		
		dbf	d0,affiche1
		add.w	#40,a2
		move.l	a2,a1
		dbf	d1,ligne_suivante1
		rts
affiche_equa2
		lea	image+(40*hauteurimage*2)+40*largeur_equa*2+(40*affiche_equa),a1
		move.l	a1,a2		;svg bidouille
		move.w	#largeur_equa-1,d1
ligne_suivante2
		move.w	(a0),d0
		lsr	#$1,d0
		
affiche2	move.b	#%11111111,(a1)+
		
		dbf	d0,affiche2
		add.w	#40,a2
		move.l	a2,a1
		dbf	d1,ligne_suivante2

		rts
affiche_equa3
		lea	image+(40*hauteurimage*2)+40*largeur_equa*4+(40*affiche_equa),a1
		move.l	a1,a2		;svg bidouille
		move.w	#largeur_equa-1,d1
ligne_suivante3
		move.w	(a0),d0
		lsr	#$1,d0
		
affiche3	move.b	#%11111111,(a1)+
		
		dbf	d0,affiche3
		add.w	#40,a2
		move.l	a2,a1
		dbf	d1,ligne_suivante3

		rts
affiche_equa4
		lea	image+(40*hauteurimage*2)+40*largeur_equa*6+(40*affiche_equa),a1
		move.l	a1,a2		;svg bidouille
		move.w	#largeur_equa-1,d1
ligne_suivante4
		move.w	(a0),d0
		lsr	#$1,d0
		
affiche4	move.b	#%11111111,(a1)+
		
		dbf	d0,affiche4
		add.w	#40,a2
		move.l	a2,a1
		dbf	d1,ligne_suivante4

		rts


;*************************************************************

greetings

copiebloc3
	cmp.w	#$0,pause1
	bne	affiche_pas3
	move.w	#pausemachine,pause1
	clr.w	d1
	clr.w	d0
	moveq	#$7,d0		;iteration (8-1)
	move.l	lsuiv3,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
	cmp.w	#$29,nolettre3
	beq	debut_screen3
	cmp.b	#$ff,d1
	beq	retourdebut3
ret_deb3
	sub.b	#32,d1		;-32 car 32=ESPACE
	lea	font,a0		;adresse de font dans a0
	add.w	d1,a0		;Voila, a0 contient l'adresse de la lettre
	move.l	posecran3,a2	;Dans a0=adresse de lettre
				;Dans a1=valeur ascii de la lettre
				;Dans a2=position sur ecran
bcopie3	move.b	(a0),(a2)	;Affiche parti de la lettre
	add.w	#64,a0		;Nouvelle partie de la lettre
	add.w	#40,a2		;
	dbf	d0,bcopie3
	addq.l	#$1,a1
	move.l	a1,lsuiv3
	addq.w	#$1,nolettre3
	addq.l	#$1,posecran3	;On svg la pos de la prochaine lettre
				;ne pas oublier d'ajouter 1 octet pour
				;la lettre suivante!...
	rts
debut_screen3
	subq.w	#$1,pauscreen3
	cmp.w	#$0,pauscreen3
	beq	suite_debut3
	rts
suite_debut3
	move.l	#image+debutecriture2,posecran3
	move.w	#pscreen,pauscreen3	;et on remet la pause a sa valeur
	move.w	#$1,nolettre3
	rts
affiche_pas3
	subq.w	#$1,pause1
	rts

retourdebut3
	move.l	#texte3,lsuiv3
	rts	
lsuiv3
	dc.l	texte3
pauscreen3
	dc.w	pscreen
nolettre3
	dc.w	1
posecran3
	dc.l	image+debutecriture2
pause1
	dc.w	pausemachine

;*************************************************************

etoiles
	move.w	#nb_etoiles-1,d0	;Combien d'iteration?
	lea	data_etoiles,a1
doit	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	lea	image,a0		;Debut ecran dans a0
	move.l	a1,a2			;On svg la position du x
	move.b	(a1)+,d1		;Coord X
	move.b	(a1)+,d2		;Coord y
	move.b	(a1)+,d3		;Pas d'incrementation
	move.b	(a1)+,d4		;No du plan
	move.b	(a1)+,d5		;No du bit
	muls.w	#40*hauteurimage,d4
	add.l	d4,a0
	sub.w	d3,d5			;On 'additionne' la valeur d'incrementation
	cmp.w	#-1,d5			;Compare si valeur negative...
	ble	calcul1			;Oui...
ret_calcul1

	;Test si on est au 21eme mot
	cmp.w	#$28,d1
	beq	calcul2			;Oui...

	;Ici on calcul l'adresse du mot a mettre	
	muls.w	#40,d2
	add.w	d2,a0			;On a la ligne
	add.w	d1,a0			;On a la position x

	sub.w	#$1,a0
	move.b	#$0,(a0)+
	move.b	#$0,(a0)

	bset	d5,(a0)
					;svg de la nvlle valeur de x
ret_calcul2

	move.b	d1,(a2)
	add.l	#$4,a2
	move.b	d5,(a2)			;Svg no du bit
	dbf	d0,doit
	rts

calcul1
	;Ici on positionne le bon bit dans le mot suivant
	sub.w	#-1,d5			
	add.w	#$7,d5			;On obtient le no du bit...
	add.w	#$1,d1			;On incremente la coord X
	bra	ret_calcul1

calcul2
	;Ici on remet la position X a 0
	;Ici on calcul l'adresse du mot a mettre	
	muls.w	#40,d2
	add.w	d2,a0			;On a la ligne
	add.w	d1,a0			;On a la position x
	sub.l	#$1,a0
	move.b	#$0,(a0)+
	move.w	#$0,d1
	bra	ret_calcul2

;**********************************************************************

barres:
	lea	ptraster,a0
	cmp.w	#$ffff,(a5)
	beq	remet_debut
	move.w	#nbrligne-1,d3	;nombre d'iterations
	move.w	(a0),d0		;svg couleur 1
	move.w	(a5)+,(a0)	;on met la nouvelle couleur			
	addq.w	#4,a0
bouge_barre
	move.w	(a0),d1		;svg couleur 2
	move.w	d0,(a0)		;met 1er couleur svgder
	move.w	d0,192(a0)
	move.w	d0,384(a0)
	move.w	d0,576(a0)
	move.w	d0,768(a0)
	move.w	d0,960(a0)
	move.w	d0,1152(a0)
	addq.w	#4,a0
	move.w	(a0),d0		;svg couleur 1
	move.w	d1,(a0)
	move.w	d1,192(a0)
	move.w	d1,384(a0)
	move.w	d1,576(a0)
	move.w	d1,768(a0)
	move.w	d1,960(a0)
	move.w	d1,1152(a0)
	addq.w	#4,a0
	dbf	d3,bouge_barre
	bsr	test_souris
	rts

remet_debut
	move.l	ptrcoul,a5
	rts

test_souris
	move.w	nobarre,d5
pas_depasse	
		move.b	svgpos,d4
		move.w	$a(a6),d6
		lsr	#8,d6
		cmp.b	d4,d6
		bge	pas_haut
		bsr	haut
pas_haut	cmp.b	d4,d6
		ble	pas_bas
		bsr	bas

pas_bas
		rts		

haut
	move.b	d6,svgpos
	cmp.w	#$0,d5
	bne	suite_haut
	rts

suite_haut
	
	subq.w	#$1,d5
	move.w	d5,nobarre
	move.w	#premierligne,d4
	move.w	nobarre,d3
	muls.w	#offset,d3
	add.w	d3,d4	
	move.w	d4,wait1
	add.w	#$100,d4
	move.w	d4,wait2
	add.w	#$100,d4
	move.w	d4,wait3
	add.w	#$100,d4
	move.w	d4,wait4
	add.w	#$100,d4
	move.w	d4,wait5
	add.w	#$100,d4
	move.w	d4,wait6
	add.w	#$100,d4
	move.w	d4,wait7
	rts	
bas
	move.b	d6,svgpos
	cmp.w	#nb_choix-1,d5
	bne	suite_bas
	rts

suite_bas
	addq.w	#$1,d5
	move.w	d5,nobarre
	move.w	#premierligne,d4
	move.w	nobarre,d3
	muls.w	#offset,d3
	add.w	d3,d4	
	move.w	d4,wait1
	add.w	#$100,d4
	move.w	d4,wait2
	add.w	#$100,d4
	move.w	d4,wait3
	add.w	#$100,d4
	move.w	d4,wait4
	add.w	#$100,d4
	move.w	d4,wait5
	add.w	#$100,d4
	move.w	d4,wait6
	add.w	#$100,d4
	move.w	d4,wait7
	rts	
nobarre
	dc.w	0
svgpos:
	dc.b	0
	even
ptrcoul
	dc.l	couleurs
	even

;-------------------------------------------------------------------
;SCROLL TEXT
;-------------------------------------------------------------------

affiche_lettre

copiebloc2
	subq.w	#$1,tempo
	cmp.w	#$0,tempo
	bne	affiche_pas2
	move.w	#4,tempo
	clr.w	d1
	clr.w	d0
	moveq	#$7,d0		;iteration (8-1)
	move.l	lsuiv2,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
	cmp.b	#$ff,d1
	beq	retourdebut2
ret_deb2
	sub.b	#32,d1		;-32 car 32=ESPACE
	lea	font,a0		;adresse de font dans a0
	add.w	d1,a0		;Voila, a0 contient l'adresse de la lettre
	move.l	posecran2,a2	;Dans a0=adresse de lettre
				;Dans a1=valeur ascii de la lettre
				;Dans a2=position sur ecran
bcopie2	move.b	(a0),(a2)	;Affiche parti de la lettre
	add.w	#64,a0		;Nouvelle partie de la lettre
	add.w	#40,a2		;
	dbf	d0,bcopie2
	bsr	scroll		;On scroll tout
	addq.l	#$1,a1
	move.l	a1,lsuiv2
	add.w	#$1,nolettre2
ret_saut2
	rts
affiche_pas2
	bsr	scroll
	rts

retourdebut2
	move.l	#texte2,lsuiv2
	rts	
lsuiv2
	dc.l	texte2

tempo
	dc.w	4
nolettre2
	dc.w	0
noligne
	dc.w	1
posecran2
	dc.l	image+40*121



scroll
	move.w	#20,d4			;Toute la ligne+1
	muls.w	#8,d4
	lea	image+40*121-40,a4
go1	
	move.l	(a4),d6
	move.l	d6,d7			;svg

	lsl.l	#2,d6
	move.l	d6,(a4)		;On remet apres decalage...
	lsr.l	#8,d7			;On met les 4 bits a droites
	lsr.l	#8,d7			
	lsr.l	#8,d7			
	lsr.l	#6,d7			
	subq.l	#4,a4
	or.l	d7,(a4)
	add.l	#8,a4
	dbf	d4,go1			
	rts


;************************************************************


mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	move.b	mt_data+$3b7,mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	cmp.b	#$1f,$3(a6)
	ble.s	mt_sets
	move.b	#$1f,$3(a6)
mt_sets:move.b	$3(a6),d0
	beq.s	mt_rts2
	move.b	d0,mt_speed
	clr.b	mt_counter
mt_rts2:rts

mt_sin:
 DC.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 DC.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 DC.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 DC.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 DC.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 DC.w $007f,$0078,$0071,$0000,$0000

mt_speed:	DC.b	6
mt_songpos:	DC.b	0
mt_pattpos:	DC.w	0
mt_counter:	DC.b	0

mt_break:	DC.b	0
mt_dmacon:	DC.w	0
mt_samplestarts:DS.L	$1f
mt_voice1:	DS.w	10
		DC.w	1
		DS.w	3
mt_voice2:	DS.w	10
		DC.w	2
		DS.w	3
mt_voice3:	DS.w	10
		DC.w	4
		DS.w	3
mt_voice4:	DS.w	10
		DC.w	8
		DS.w	3

	section		data,data_c

couleurs
	dc.w	$00f,$01f,$02f,$03f,$04f,$05f,$06f,$07f
	dc.w	$08f,$09f,$0af,$0bf,$0cf,$0df,$0ef,$0ff
	dc.w	$0ff,$0fe,$0fd,$0fc,$0fb,$0fa,$0f9,$0f8
	dc.w	$0f7,$0f6,$0f5,$0f4,$0f3,$0f2,$0f1,$0f0
	dc.w	$0f0,$1f0,$2f0,$3f0,$4f0,$5f0,$6f0,$7f0
	dc.w	$8f0,$9f0,$af0,$bf0,$cf0,$df0,$ef0,$ff0
	dc.w	$ff0,$fe0,$fd0,$fc0,$fb0,$fa0,$f90,$f80
	dc.w	$f70,$f60,$f50,$f40,$f30,$f20,$f10,$f00
	dc.w	$f00,$f01,$f02,$f03,$f04,$f05,$f06,$f07
	dc.w	$f08,$f09,$f0a,$f0b,$f0c,$f0d,$f0e,$f0f
	dc.w	$f0f,$e0f,$d0f,$c0f,$b0f,$a0f,$90f,$80f
	dc.w	$70f,$60f,$50f,$40f,$30f,$20f,$10f,$00f
	dc.w	-1
	even

data_etoiles

	;ATTENTION: Voici la structure des donnees pour les etoiles
	;Le premier octet, est la position x (de 0 à 39) en no d'octet
	;Le second octet, est la ligne y (de 0 à ff)
	;Le troisieme est le pas d'incrementation de l'etoile
	;Le 4eme, c'est le no du plan ou se trouve l'etoile
	;Enfin le 5eme c'est le no du bit du mot qui est allumé... 
	;Voila, bonne chance...
	incbin	etoiles.b
	even
copper:
		dc.w	$100,$0
		dc.w	$2e01,$fffe,$180,$102
		dc.w	$2f01,$fffe,$180,$305
		dc.w	$3001,$fffe,$180,$507
		dc.w	$3101,$fffe,$180,$709
		dc.w	$3201,$fffe,$180,$92b
		dc.w	$3301,$fffe,$180,$b4d
		dc.w	$3401,$fffe,$180,$d6f
		dc.w	$3501,$fffe,$180,$b4d
		dc.w	$3601,$fffe,$180,$92b
		dc.w	$3701,$fffe,$180,$709
		dc.w	$3801,$fffe,$180,$507
		dc.w	$3901,$fffe,$180,$305
		dc.w	$3a01,$fffe,$180,$102


		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
		dc.w	debutaffiche,$fffe
		dc.w	$0100,$5200
		dc.w	$0180,$0000,$0182,$0fff,$0184,$0777,$0186,$0fff
		dc.w	$0188,$0fff,$018a,$0fff,$018c,$0777,$018e,$0fff	;$188=couls equa,$18c,$18e	
		dc.w	$0190,$0888,$0192,$0fff,$0194,$0fff,$0196,$0fff	;$192=couleur etoiles passe lettre et $190=coul 2eme etoiles
		dc.w	$0198,$0fff,$019a,$0fff,$019c,$0fff,$019e,$0fff	;Nothing
		dc.w	$01a0,$0fff,$01a2,$0fff,$01a4,$0fff,$01a6,$0fff	;1a0=couleur 1er etoiles
		dc.w	$01a8,$0fff,$01aa,$0fff,$01ac,$0fff,$01ae,$0fff ;ok
		dc.w	$01b0,$0fff,$01b2,$0fff,$01b4,$0fff,$01b6,$0fff ;ok
		dc.w	$01b8,$0fff,$01ba,$0fff,$01bc,$0fff,$01be,$0fff ;ok

		dc.w	$4101,$fffe,$182,$269
		dc.w	$4201,$fffe,$182,$48c
		dc.w	$4301,$fffe,$182,$6af
		dc.w	$4401,$fffe,$182,$8cf
		dc.w	$4501,$fffe,$182,$6af
		dc.w	$4601,$fffe,$182,$48c
		dc.w	$4701,$fffe,$182,$269
		dc.w	$4801,$fffe,$182,$fff
				

wait1		dc.w	premierligne,$fffe,$182
ptraster
		dc.w	$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
	
wait2		dc.w	premierligne+$100,$fffe

		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000

wait3		dc.w	premierligne+$200,$fffe
	
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000

wait4		dc.w	premierligne+$300,$fffe
	
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
	
wait5		dc.w	premierligne+$400,$fffe
	
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000

wait6		dc.w	premierligne+$500,$fffe
	
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000

wait7		dc.w	premierligne+$600,$fffe
	
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000,$182,$000
		dc.w	$182,$000,$182,$000,$182,$000,$182,$000,$182,$000

		dc.w	premierligne+$700,$fffe,$182,$fff
;Raster pour equalizer
		dc.w	$9b35,$fffe,$188,$820
		dc.w	$9c35,$fffe,$188,$f82
		dc.w	$9d35,$fffe,$188,$820
		dc.w	$9e35,$fffe,$188,$000

		dc.w	$a135,$fffe,$188,$280
		dc.w	$a235,$fffe,$188,$8f2
		dc.w	$a335,$fffe,$188,$280
		dc.w	$a435,$fffe,$188,$000

		dc.w	$a735,$fffe,$188,$208
		dc.w	$a835,$fffe,$188,$82f
		dc.w	$a935,$fffe,$188,$208
		dc.w	$aa35,$fffe,$188,$208
		
		dc.w	$ad35,$fffe,$188,$802
		dc.w	$ae35,$fffe,$188,$f28
		dc.w	$af35,$fffe,$188,$802
		dc.w	$b035,$fffe,$188,$000
		
;Raster pour dessus scroll
		dc.w	$b135,$fffe,$180,$92b
		dc.w	$b235,$fffe,$180,$b4d
		dc.w	$b335,$fffe,$180,$d6f
		dc.w	$b435,$fffe,$180,$b4d
		dc.w	$b535,$fffe,$180,$92b
		dc.w	$b635,$fffe,$180,$709

;Raster pour scrolltext
w0		dc.w	$b735,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709

w1		dc.w	$b835,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709
	
w2		dc.w	$b935,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709

w3		dc.w	$ba35,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709

w4		dc.w	$bb35,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709

w5		dc.w	$bc35,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709

w6		dc.w	$bd35,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709

w7		dc.w	$be35,$fffe

		dc.w	$182,$719,$182,$719,$182,$729
		dc.w	$182,$739,$182,$749,$182,$759,$182,$769,$182,$779
		dc.w	$182,$889,$182,$999,$182,$aaa,$182,$bbb,$182,$ccc,$182,$ddd,$182,$eee,$182,$fff
		dc.w	$182,$fff,$182,$fff,$182,$fff
		dc.w	$182,$eee,$182,$ddd,$182,$ccc,$182,$bbb,$182,$aaa,$182,$999,$182,$889
		dc.w	$182,$779,$182,$769
		dc.w	$182,$759,$182,$749,$182,$739,$182,$729,$182,$719,$182,$709
		dc.w	$c001,$fffe,$100,$0

;RASTER BARRES NO 2

		dc.w	$c101,$fffe,$180,$92b
		dc.w	$c201,$fffe,$180,$b4d
		dc.w	$c301,$fffe,$180,$d6f
		dc.w	$c401,$fffe,$180,$b4d
		dc.w	$c501,$fffe,$180,$92b
		dc.w	$c601,$fffe,$180,$000

bmap2		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.w	$c701,$fffe
		dc.w	$0100,$4200
coul_img:
		dc.w	$0180,$0000,$0182,$0eef,$0184,$0c93,$0186,$0960
		dc.w	$0188,$0d80,$018a,$0fe0,$018c,$0500,$018e,$0710
		dc.w	$0190,$0930,$0192,$0b50,$0194,$0d70,$0196,$0f90
		dc.w	$0198,$0fb0,$019a,$0fd0,$019c,$0ff0,$019e,$0fff
		
		dc.l	-2
;------------------------------------------------------------------------
	even
texte
	dc.b	"              NOM DEMO NO 1             "
	dc.b	"              NOM DEMO NO 2             "
	dc.b	"              NOM DEMO NO 3             "
	dc.b	"              NOM DEMO NO 4             "
	dc.b	"              NOM DEMO NO 5             "
	dc.b	"              NOM DEMO NO 6             "
	dc.b	"              NOM DEMO NO 7             "
	dc.b	"              NOM DEMO NO 8             "
	dc.b	"              NOM DEMO NO 9             "
texte2
	dc.b	"SCROLL TEXT                              "
	dc.b	"                                         "	;Ligne de blanc a laisser sinon plantage!
	dc.b	-1	;indique la fin a ne pas enlever!!
	even
texte3
	dc.b	"              GREETINGS                 "
	dc.b	"                 ICI                    " 

	dc.b	-1

	even

logo
	incbin	logo
	even
font
	incbin	font8x8
	even

mt_data
	incbin mod.reflex2
	even
image	
	ds.b	40*hauteurimage*nb_plan
	even
end

