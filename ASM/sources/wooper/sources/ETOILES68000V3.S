;-------------------------------------------------------------------
;Aujourd'hui 5 fevrier 1992, je m'attaques aux etoiles
;Je les faient au 68000... En plus, c'est une méthode boeuf...
;Normalement, je devrais en chier quand meme...
;Signe: Wooper/Profecy
;Version retouchée le 24/03/92
;-------------------------------------------------------------------

execbase=4
nb_plan=4
hauteurimage=256		;en ligne
nb_etoiles=50		;nombre d'etoiles (data=*3, Ok?)

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
	;move.w	#$fff,$180(a6)	;test tps machine
	bsr	etoiles
	;clr.w	$180(a6)	;test tps machine 2, le retour
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
etoiles
	move.w	#nb_etoiles-1,d0	;Combien d'iteration?
	lea	data_etoiles,a1
debut	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
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
	
	;Test si meme coord mais au plan 1 est à 1 ou pas

	lea	image,a3
	add.w	d2,a3
	add.w	d1,a3
	btst	d5,(a3)
	bne	on_passe
	bsr	efface_etoiles
	bset	d5,(a0)
					
ret_calcul2

	move.b	d1,(a2)
	add.l	#$4,a2
	move.b	d5,(a2)			;Svg no du bit
	dbf	d0,debut
	rts
on_passe
	bsr	efface_etoiles
	bra	ret_calcul2

efface_etoiles
	subq.w	#$1,a0
	move.b	#$0,(a0)+
	move.b	#$0,(a0)	
	rts
mot_avant
	subq.w	#$2,a0
	sub.w	#$f,d6
	bclr	d6,(a0)+
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
ret
	move.b	(a1)+,d3		;Pas d'incrementation
	add.b	d3,d1			;On incremente la coord x
	;Ici debute le calcul du point sur l'ecran

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

data_etoiles

	;ATTENTION: Voici la structure des donnees pour les etoiles
	;Le premier octet, est la position x (de 0 à 39) en no d'octet
	;Le second octet, est la ligne y (de 0 à ff)
	;Le troisieme est le pas d'incrementation de l'etoile
	;Le 4eme, c'est le no du plan ou se trouve l'etoile
	;Enfin le 5eme c'est le no du bit du mot qui est allumé... 
	;Voila, bonne chance...
	incbin	tools/etoiles.b
	even
copper
		dc.w	$180,$0
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.w	$2e01,$fffe
		dc.w	$0100,$4200
		dc.w	$0180,$0000,$0182,$0f00,$0184,$0555,$0186,$0000	;Reg $184=1er coul etoiles
		dc.w	$0188,$0888,$018a,$0000,$018c,$0000,$018e,$0880	;Reg $188=2eme
		dc.w	$0190,$0fff,$0192,$0620,$0194,$0840,$0196,$0a60	;Reg $190=3eme
		dc.w	$0198,$0c80,$019a,$0ea2,$019c,$0fc4,$019e,$0fe6
		dc.l	-2
;------------------------------------------------------------------------
	even
adresseplan
	dc.l	0
	even
image	
	ds.b	40*256*nb_plan
	even
end


