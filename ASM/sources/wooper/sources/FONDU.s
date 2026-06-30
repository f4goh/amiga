;**********************************************************************
;FONDU Version Wooper!
;Parametres à passer: dans palette_destination: l'adresse de la palette
;de couleurs dans la copper_list
;Dans palette_source: l'adresse de la palette de couleurs de l'image
;(au format: $0000 $0111 $0222 etc...) 
;Enfin, dans mode_fade, soit 1=fade in ou 0=fade out!
;**********************************************************************
;-------------------------------------------------------------------
;SOURCE by WOOPER/PROFECY 
;David CALLY
;23, rue de l'aubepine
;49124 St barthelemy d'anjou
;FRANCE
;Tel:41 93 96 41 
;-------------------------------------------------------------------

nb_couleurs=32
pause_fondu=5

;ON EFFACE
	move.w	#pause_fondu,pause	;remet pause
	move.l	#palette_copper1+2,palette_destination
	move.l	#palette_slide,palette_source
	move.w	#$0,mode_fade
vbl2
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$13000,d0
	bne.s	vbl2
	bsr	fondu
	cmp.w	#16,nb_changement
	bne	vbl2
	move.w	#0,nb_changement
	rts
	
;************************************************************
;FONDU
;************************************************************
fondu
	sub.w	#$1,pause
	cmp.w	#$0,pause
	beq	ok
	rts
ok
	move.w	#pause_fondu,pause	;remet pause
	move.w	#nb_couleurs-1,d0	;Nbr itération

boucle_fondu

	move.l	palette_source,a0
	move.l	palette_destination,a1	;On passe le $180
	bsr	pointe_couleur		;pointe couleur dans image
	bsr	pointe_copper		;pointe couleur dans copper
	bsr	rouge
	bsr	vert
	bsr	bleu
	dbf	d0,boucle_fondu
	add.w	#$1,nb_changement
	rts
rouge
	move.w	(a0),d2
	lsr.w	#8,d2			;On a le rouge
	;Maintenant, on va localiser la table correspondant
	;a la valeur du rouge (ex:1, 2 ou 3...)
	lsl.w	#5,d2
	bsr	pointe_table
	cmp.w	#$1,(a2)		;Test si = 1
	bne	va_vert
	;On incremente le rouge
	cmp.w	#$1,mode_fade
	beq	add_rouge
	sub.w	#$100,(a1)
	rts
add_rouge
	add.w	#$100,(a1)
va_vert	
	rts
vert
	move.w	(a0),d2
	lsr.w	#4,d2			;On a le vert
	and.w	#$000f,d2
	;Maintenant, on va localiser la table correspondant
	;a la valeur du vert (ex:1, 2 ou 3...)
	lsl.w	#5,d2
	bsr	pointe_table
	cmp.w	#$1,(a2)		;Test si = 1
	bne	va_bleu
	;On incremente le bleu
	cmp.w	#$1,mode_fade
	beq	add_vert
	sub.w	#$10,(a1)
	rts
add_vert
	add.w	#$10,(a1)
va_bleu	
	rts
bleu
	move.w	(a0),d2
	and.w	#$f,d2
	;Maintenant, on va localiser la table correspondant
	;a la valeur du bleu (ex:1, 2 ou 3...)
	lsl.w	#5,d2
	bsr	pointe_table
	cmp.w	#$1,(a2)		;Test si = 1
	bne	fin_fondu
	;On incremente le bleu
	cmp.w	#$1,mode_fade
	beq	add_bleu
	sub.w	#$1,(a1)
	rts
add_bleu
	add.w	#$1,(a1)
fin_fondu	
	rts

pointe_couleur
	move.w	d0,d1			;SVG
	lsl.w	#1,d1			;* par 2
	add.w	d1,a0			;On pointe la couleur à traiter
	rts

pointe_copper
	move.w	d0,d1			;SVG
	lsl.w	#2,d1			;* par 4
	add.w	d1,a1			;On pointe la couleur à traiter
	rts

pointe_table
	lea	zero,a2			;Debut de la table
	add.w	d2,a2			;On pointe au debut de la table
					;qui nous interesse...
	move.w	nb_changement,d1
	lsl.w	#1,d1
	add.w	d1,a2			;On pointe sur la valeur BOOLEENE
	rts
zero
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
un
	dc.w	0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
deux
	dc.w	0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1
trois
	dc.w	0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,1
quatre
	dc.w	0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
cinq
	dc.w	0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,1
six
	dc.w	0,0,1,0,0,1,0,0,1,0,1,0,0,1,0,1
sept
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,0,1,0
huit
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
neuf
	dc.w	0,1,0,1,0,1,0,1,1,0,1,0,1,0,1,1
dix
	dc.w	0,1,0,1,1,0,1,0,1,1,0,1,0,1,1,1
onze
	dc.w	1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,1
douze
	dc.w	1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1
treize
	dc.w	1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1
quatorze
	dc.w	1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,1
quinze
	dc.w	1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1
seize
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

nb_changement
	dc.w	0
pause
	dc.w	pause_fondu

palette_destination
	dc.l	0
palette_source
	dc.l	0
	even
mode_fade
	dc.w	0

