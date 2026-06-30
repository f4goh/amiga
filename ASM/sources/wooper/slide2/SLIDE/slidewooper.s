;-------------------------------------------------------------------
;SOURCE SLIDE-SHOW by WOOPER/PROFECY and ale of fame
;David CALLY
;23, rue de l'aubepine
;49124 St barthelemy d'anjou
;FRANCE
;Tel:41 93 96 41 
;-------------------------------------------------------------------
;		DE TOUTES MANIERE POUR MOI CA GAZE !!!
;-------------------------------------------------------------------
;		il y a juste la syncro เ modifier เ la fin
;-------------------------------------------------------------------
;	commence a en avoir plein le ... ce ce slide de sauvage
;-------------------------------------------------------------------
execbase  = 4
openlib   = -408
closelib  = -414
open      = -30
close     = -36
read      = -42
mode_old  = 1005
mode_new  = 1006

nbrligne=22	;pour rasters

nbr_image=12	;NBR IMAGE DU SLIDE

nb_plan=6	


bleu_wait=475		;en vbl

bleu_wait2=20		;en vbl

nb_couleurs=32
pause_fondu=5

debutecriture=248*40
pause_scroll=2

plan_scroll=3
hauteurlettre=8
largeurfont=944		;en pixels
wait_scroll=100		;Attente pour noms  a modif

;-------------------------------
wait_blit	macro
loop_wait_blt\@
	btst	#14,$2(a6)
	bne.s	loop_wait_blt\@
	endm
;-------------------------------
;-------------------------------
pause		macro
loop_pause\@
	vbl
	sub.w	#1,pause_memoire
	cmp.w	#0,pause_memoire
	bne	loop_pause\@
	move.w	#bleu_wait,pause_memoire
	endm
;-------------------------------
;-------------------------------
pause2		macro
loop_pause2\@
	vbl
	sub.w	#1,pause_memoire2
	cmp.w	#0,pause_memoire2
	bne	loop_pause2\@
	move.w	#bleu_wait2,pause_memoire2
	endm
;-------------------------------
;-------------------------------
vbl		macro
loop_vbl\@
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$13000,d0
	bne	loop_vbl\@
	endm
;-------------------------------


	section	code,code_c
start
	move.w	#$1111,$c0a000
	move.w	#$1111,$210000

	move.l	$80004,d0
	cmp.l	#$676,d0	;reflexion de la chip ram
	beq	mem2
	cmp.l	#$c00276,d0
	beq	mem2
	move.l	#$85000,zone
	bra	charge
mem2	move.w	$c0a000,d0
	cmp.w	#$1111,d0
	bne	mem3
	move.l	#$c0a000,zone
	bra	charge
mem3	move.w	$210000,d0
	cmp.w	#$1111,d0
	bne	mem4
	move.l	#$210000,zone
	bra	charge
mem4	bra	error
charge
	move.l	zone,d0
	add.l	d0,zone1
	add.l	d0,zone2
	add.l	d0,zone3
	clr.l	d0
	move.l	execbase,a6
	lea	dosname,a1
	moveq	#0,d0
	jsr	openlib(a6)
	move.l	d0,dosbase
	beq	error

;wait1	btst	#6,$bfe001	;pour change disk
;	bne	wait1

	move.l	#mode_old,d2    ;fichier fic.p1
	bsr	openfile1
	move.l	zone1,d2
	bsr	readdata
	move.l	d0,d6
	bsr	closefile
	move.l	#mode_old,d2    ;fichier fic.p2
	bsr	openfile2
	move.l	zone2,d2
	bsr	readdata
	move.l	d0,d6
	bsr	closefile
	move.l	#mode_old,d2	;fichier fic.p3
	bsr	openfile3
	move.l	zone3,d2
	bsr	readdata
	move.l	d0,d6
	bsr	closefile

	move.l	dosbase,a1
	move.l	execbase,a6
	jsr	closelib(a6)
	bra	debut		;saut au debut du slide
openfile1:
	move.l	dosbase,a6
	move.l	#filename1,d1
	jsr	open(a6)
	move.l	d0,filehd
	rts
openfile2:
	move.l	dosbase,a6
	move.l	#filename2,d1
	jsr	open(a6)
	move.l	d0,filehd
	rts
openfile3:
	move.l	dosbase,a6
	move.l	#filename3,d1
	jsr	open(a6)
	move.l	d0,filehd
	rts
closefile:
	move.l	dosbase,a6
	move.l	filehd,d1
	jsr	close(a6)
	rts
readdata:
	move.l	dosbase,a6
	move.l	filehd,d1
	move.l	#$ffffff,d3
	jsr	read(a6)
	rts
zone	dc.l	0
zone1	dc.l	0
zone2	dc.l	186760
zone3	dc.l	186760+135914

filehd:dc.l	0
dosbase:dc.l 	0
filename1:dc.b	"df0:fic.p1",0
 even
filename2:dc.b	"df0:fic.p2",0
 even
filename3:dc.b	"df0:fic.p3",0
 even
dosname:dc.b	"dos.library",0
 even

debut
	bsr	save_all	;Tres tres classique...

	move.l	#$dff000,a6
	clr.l	$144(a6)	;sprite souris off
	move.w	#$7fff,$96(a6)
;	move.w	#$c060,$9a(a6)	;Ca aussi...AU PIF JOE !!
	bsr	init_copper1
	bsr	active_copper1
	bsr	mt_init

	lea	image_intro,a0
	lea	palette_slide,a1	;dest
	bsr	normaldecrunch
	move.l	#palette_copper1+2,palette_destination	;on est en $182
	move.l	#palette_slide,palette_source
	move.w	#$1,mode_fade
	move.w	#$0,blanc
;APPARITION DE L'ECRAN D'INTRO EN FONDU

vbl1
	vbl
	bsr	fondu
	cmp.w	#16,nb_changement
	bne	vbl1
	move.w	#0,nb_changement
	
	pause

;ON EFFACE
	move.w	#pause_fondu,pause	;remet pause
	move.l	#palette_copper1+2,palette_destination	;on est en $182
	move.l	#palette_slide,palette_source		;idem...
	move.w	#$0,mode_fade
	move.w	#$0,blanc

vbl2
	vbl
	bsr	fondu
	cmp.w	#16,nb_changement
	bne	vbl2
	move.w	#0,nb_changement

	;ACTIVE 2EME COPPER-LIST
	vbl
	move.l	#copper0,$80(a6)
	clr.w	$88(a6)

	;APPARITION LOGO
	move.l	#palette_copper0+2,palette_destination	;on est en $182
	move.l	#palette_logo,palette_source
	move.w	#$1,mode_fade
	move.w	#$0,blanc

blogo1
	vbl
	bsr	fondu
	cmp.w	#16,nb_changement
	bne	blogo1
	move.w	#0,nb_changement
	
	pause

;ON EFFACE
	move.w	#pause_fondu,pause	;remet pause
	move.l	#palette_copper0+2,palette_destination	;on est en $182
	move.l	#palette_logo,palette_source		;idem...
	move.w	#$0,mode_fade
	move.w	#$0,blanc

blogo2
	vbl
	bsr	fondu
	cmp.w	#16,nb_changement
	bne	blogo2
	move.w	#0,nb_changement
	bsr	efface_screen
	;ACTIVE 2EME COPPER-LIST
	vbl
	move.l	#copper4,$80(a6)
	clr.w	$88(a6)
; COPIES DE BLIBLIT!
	wait_blit
	move.l	#image_slide+40*100,$54(a6)		;dest
	move.l	#t1,$50(a6)	;source
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	move.l	#$00000000,$64(a6)
	move.w	#16*64+20,$58(a6)

	wait_blit
	move.l	#image_slide+40*130,$54(a6)		;dest
	move.l	#t2,$50(a6)	;source
	move.l	#$ffffffff,$44(a6)
	move.l	#$09f00000,$40(a6)
	move.l	#$00000000,$64(a6)
	move.w	#16*64+20,$58(a6)

ccoul1
	pause2
	cmp.w	#$fff,dd1
	beq	fcoul1
	add.w	#$111,dd1
	bra	ccoul1
fcoul1
	pause2
	cmp.w	#$fff,dd2
	beq	fcoul2
	add.w	#$111,dd2
	bra	fcoul1
fcoul2
	pause
	move.w	#15-1,d1
zob	
	sub.w	#$111,dd1
	sub.w	#$111,dd2
	pause2

	dbf	d1,zob
	
	bsr	bouton_active
	;ACTIVE 3EME COPPER-LIST
	vbl
	move.l	#copper2,$80(a6)
	clr.w	$88(a6)
	move.w	#$1,fin_intro

boucle2
	cmp.b	#-1,$6(a6)
	bne	boucle2
	;move.w	#$fff,$180(a6)	;test tps machine
;	bsr	affiche_lettre	;sous interruption now
	bsr	test_souris
	;clr.w	$180(a6)	;test tps machine 2, le retour
	btst	#6,$bfe001
	bne.s	boucle2

	bsr	efface_screen
	;Change a nouveau de COPPER-LIST
	vbl
	move.l	#copper3,$80(a6)
	clr.w	$88(a6)
	move.w	#$0,fin_intro
	
;	scroll de fin
; attention l l'install plan est modifi้ de :40*(256+1)

	bsr	install_stars1		;install etoiles
	move.w	#$2,fin_intro

boucle3
;	move.l	$4(a6),d0
;	and.l	#$1ff00,d0
;	cmp.l	#$10500,d0

	cmp.b	#$9a,$6(a6)		;syncro $ff
	bne.s	boucle3

;	move.w	#$f,$180(a6)
	bsr	starsp		;stars avant car beaucoup de
	bsr	scroll2		;copies de blitter
;	clr.w	$180(a6)	
	btst	#10,$dff016
	bne.s	boucle3
	wait_blit	;et oui il faut le faire car autrement
			;GURU LEFFE MEDITATION BRAZIL TUUUT !!!

restore_all
	bsr	mt_end
	move.w	#$7fff,$dff096		;vide le dmacon
	move.w	#$7fff,$dff09a		;vide intena
	move.w	save_dmacon,$dff096	;place la copie sauv้e avant 
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
error:	clr.l	d0
	rts

save_all
	move.b	#%10000111,$bfd100	;on arrete les drives
	move.l	4,a6			;no comment
 	jsr	-132(a6)		;stopper le multitache
	move.w	$dff002,save_dmacon	;save registre dma
	or.w	#$8100,save_dmacon	;bit 15 et 14 เ 1
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena
	rts
pause_memoire
	dc.w	bleu_wait
pause_memoire2
	dc.w	bleu_wait2
save_intena
	dc.w	0
save_dmacon
	dc.w 	0
oldirq
	dc.l	0
name_glib
	dc.b "graphics.library",0
	even
;---------------------------------------------------------------------
; INITIALISATIONS DE TOUS LES DIFFERENTS PLANS...
;---------------------------------------------------------------------
init_copper1

install5
	lea	plan_copper4,a0
	move.l	#image_slide,d0
	moveq	#1-1,d1
plan_suivant5
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant5

install0
	lea	plan_copper0,a0
	move.l	#logo,d0
	moveq	#4-1,d1
plan_suivant0	
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*86,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant0


install1
	;installation de la 1ere liste copper
	lea	plan_copper1,a0
	move.l	#image_slide,d0
	moveq	#nb_plan-1,d1
plan_suivant	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
	
install2
	;installation de la 2eme liste copper
	lea	plan_copper2,a0
	move.l	#image_slide,d0
	moveq	#nb_plan-1,d1
plan_suivant2
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*240,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant2
	
install3
	;Install plan provisoire
	lea	plan_scroll2,a0
	move.l	#image+2,d0
	moveq	#plan_scroll-1,d1
plan_suivant3
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(2+44+2+2)*hauteurlettre,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant3

install4
	;installation de la 3me liste copper
	lea	plan_copper3,a0
	move.l	#image_slide,d0
	moveq	#nb_plan-4,d1		;6-4+1=3 plans
plan_suivant4
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*257,d0		;ici change plan
	addq.l	#8,a0
	dbf	d1,plan_suivant4
	rts

active_copper1
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper1,$80(a6)
	clr.w	$88(a6)
	;dma active
	move.w	#$83c0,$96(a6)
;	move.w	#$87d0,$96(a6)
	rts
	
;**********************************************************************
;FONDU Version Wooper!
;Parametres เ passer: dans palette_destination: l'adresse de la palette
;de couleurs dans la copper_list
;Dans palette_source: l'adresse de la palette de couleurs de l'image
;(au format: $0000 $0111 $0222 etc...) 
;Enfin, dans mode_fade, soit 1=fade in ou 0=fade out!
;Et comme ceci est la version 2.0 un autre parametre:
;BLANC qui indique si l'on veut passer par un flash blanc(=1) ou non(=0)
;**********************************************************************

fondu
	sub.w	#$1,pause
	cmp.w	#$0,pause
	beq	ok
	rts
ok
	move.w	#pause_fondu,pause	;remet pause
	cmp.w	#$1,blanc
	bne	suite_ok
	cmp.w	#15,flash
	beq	suite_ok
	move.w	#nb_couleurs-2,d0	;Nbr it้ration
boucle_blancs
	move.l	palette_source,a0
	move.l	palette_destination,a1	;On passe le $180
	bsr	pointe_copper		;pointe couleur dans copper
	add.w	#$111,(a1)
	dbf	d0,boucle_blancs
	add.w	#$1,flash
	rts
suite_ok		
	move.w	#nb_couleurs-1,d0	;Nbr it้ration

boucle_fondu

	move.l	palette_source,a0
	move.l	palette_destination,a1	
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
	cmp.w	#$1,blanc
	bne	suite_rouge
	rts
suite_rouge
	cmp.w	#$1,mode_fade
	beq	add_rouge
sub_rouge
	sub.w	#$100,(a1)
	rts
add_rouge
	add.w	#$100,(a1)
	rts
va_vert
	cmp.w	#$1,blanc
	beq	sub_rouge
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
	;On incremente le vert
	cmp.w	#$1,blanc
	bne	suite_vert
	rts
suite_vert
	cmp.w	#$1,mode_fade
	beq	add_vert
sub_vert
	sub.w	#$10,(a1)
	rts
add_vert
	add.w	#$10,(a1)
	rts
va_bleu	
	cmp.w	#$1,blanc
	beq	sub_vert
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
	cmp.w	#$1,blanc
	bne	suite_bleu
	rts
suite_bleu
	cmp.w	#$1,mode_fade
	beq	add_bleu
sub_bleu
	sub.w	#$1,(a1)
	rts
add_bleu
	add.w	#$1,(a1)
	rts
fin_fondu	
	cmp.w	#$1,blanc
	beq	sub_bleu
	rts

pointe_couleur
	move.w	d0,d1			;SVG
	lsl.w	#1,d1			;* par 2
	add.w	d1,a0			;On pointe la couleur เ traiter
	rts

pointe_copper
	move.w	d0,d1			;SVG
	lsl.w	#2,d1			;* par 4
	add.w	d1,a1			;On pointe la couleur เ traiter
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
blanc
	dc.w	0
flash
	dc.w	0
;**********************************************************************
;TEST SOURIS
;**********************************************************************
test_souris
	btst	#10,$dff016
	beq	bouton_active
	rts
bouton_active
	move.w	#$0,bplcon02
	move.w	noimage,d0
	lea	table_image,a0
	muls.w	#4,d0
	add.w	d0,a0		;On pointe sur l'adresse de l'image
	move.l	(a0),a0		;Eh,eh source
	add.l	zone,a0		;debut
	lea	palette_slide,a1	;dest
	bsr	normaldecrunch

	;Installation de la palette
	lea	palette_slide,a0
	lea	palette_copper2+2,a1
	move.w	#32-1,d0
recopie_palette
	move.w	(a0)+,(a1)+
	add.w	#$2,a1
	dbf	d0,recopie_palette
	cmp.w	#nbr_image-1,noimage
	bne	fin_test
	move.w	#$0,noimage
	bra	fin_t2
fin_test
	add.w	#1,noimage
	move.w	#$0,coul0
fin_t2	move.w	#$6a00,bplcon02
	rts	
table_image
	dc.l	0,33450,47936,63224,106618,143750,186760
	dc.l	236482,283872,322674,322674+40078,322674+81198
	even
noimage
	dc.w	0
	even	
efface_image
	lea	palette_copper2+2,a0
	move.w	#32-1,d0
boucle_efface
	move.w	#0,(a0)+
	addq.w	#$2,a0
	dbf	d0,boucle_efface
	rts

;**********************************************************************
; SCROLL DE FIN
;**********************************************************************

scroll_fin
	subq.w	#$1,tempo2
	cmp.w	#$0,tempo2
	bne	copiepas
	move.w	#16,tempo2
							;MODIF
	move.l	#image_slide+(40*257*2)+debutecriture,posecran
	move.w	#39,d2		;40-1 lettres a afficher sur la ligne
copiebloc
	clr.w	d1
	clr.w	d0
	moveq.w	#$7,d0		;iteration (8-1)
	move.l	lsuiv2,a1	;valeur ascii lettre dans d1
	move.b	(a1),d1
	cmp.b	#-1,d1
	beq	retourdebut2
ret_deb2
	sub.b	#32,d1		;-32 car 32=ESPACE
	lea	font2,a0		;adresse de font dans a0
	add.w	d1,a0		;Voila, a0 contient l'adresse de la lettre
	move.l	posecran,a2	;Dans a0=adresse de lettre
				;Dans a1=valeur ascii de la lettre
				;Dans a2=position sur ecran
bcopie	move.b	(a0),(a2)	;Affiche parti de la lettre
	add.w	#64,a0		;Nouvelle partie de la lettre
	add.w	#40,a2		;
	dbf	d0,bcopie
	addq.l	#$1,a1
	move.l	a1,lsuiv2
	add.w	#$1,nolettre2
ret_saut
	addq.l	#$1,posecran	;On svg la pos de la prochaine lettre
				;ne pas oublier d'ajouter 1 octet pour
				;la lettre suivante!...
	dbf	d2,copiebloc
							;MODIF
	move.l	#image_slide+(40*257*2)+debutecriture,posecran
copiepas
	rts
retourdebut2
	lea	texte_fin,a1
	move.b	(a1),d1
	bra	ret_deb2
lsuiv2
	dc.l	texte_fin
nolettre2
	dc.w	0
posecran						;MODIF
	dc.l	image_slide+(40*257*2)+debutecriture

scroll2
		subq.w	#$1,tempo1
		cmp.w	#$0,tempo1
		bne	pas_scroll
		move.w	#pause_scroll,tempo1
		bsr	scroll_fin
ret_mettre
		lea	image_slide+(40*257*2)+3*40,a0	;MODIF PLAN
		lea	image_slide+(40*257*2)+3*40+40,a1
w_blit		btst	#14,$2(a6)
		bne.s	w_blit
		move.l	a0,$54(a6) 			;dest ecran
		move.l	a1,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#253*64+20,$58(a6)
pas_scroll
		rts
tempo1				;tempo pour scroll
	dc.w	pause_scroll
tempo2				;tempo pour affichage de la ligne de texte
	dc.w	16
;********************************************************
texte_fin
	dc.b	"       YES! ALL THINGS HAVE A END !     "
	dc.b	"     THIS SCROLL IS FOR INFORMATIONS    "
	dc.b	"      ABOUT PROFECY AND OFF COURSE      "
	dc.b	"   IT CONTAINS THE LATEST GREETZ-LIST!  "
	dc.b	"             (THANX MERY!!!)            "
	dc.b	"                                        "
	dc.b	"SOME LAMERS SAID THAT THEY BELONG TO OUR"
	dc.b	"  TEAM, IT'S WHY HERE ARE FOLLOWING THE "
	dc.b	"           REAL MEMBERLIST:             "
	dc.b	"                                        "
	dc.b	" SPECTRE...............CODER            "
	dc.b	" SPEED POWER...........CODER            "
	dc.b	" ALE OF FAME...........CODER & HARDWARE "
	dc.b	" WOOPER................CODER & SFX      "
	dc.b	" MERY..................SWAPPER          "
	dc.b	" GRETZKY...............SWAPPER          "
	dc.b	" FX COBRA..............SWAPPER          "
	dc.b	" FURIO.................GFX              "
	dc.b	" SLN...................MUSIC            " 
	dc.b	"                                        "
	dc.b	"OK... NOW A MESSY TO ALL THE TECHNO-FANS"
	dc.b	"IN A VERY FIEW TIME (18/04/92) I(WOOPER)"
	dc.b	"WILL BE IN A RAVE PARTY NEAR ANGERS WITH"
	dc.b	"  MY AMIGA (AND OFF COURSE, WITH GREAT  "
	dc.b	"            MODULES AND SAMPLES!)       "
	dc.b	" SO, YOU'RE NOT ALLOWED TO MISS THAT !!!"
	dc.b	"                                        "
	dc.b	"TAKE A PEN, GUY! YOU CAN CONTACT US AT: "
	dc.b	"                                        "
	dc.b	"              MERY/PROFECY              "
	dc.b	"            (LEGAL SWAPPING)            "
	dc.b	"              DAVY SAUNIER              "
	dc.b	"        55, GALERIES DES BALADINS       "
	dc.b	"             38100 GRENOBLE             "
	dc.b	"                 FRANCE                 "
	dc.b	"                                        "
	dc.b	"             GRETZKY/PROFECY            "
	dc.b	"            (LEGAL SWAPPING)            "
	dc.b	"              FRANCK VESCO              "
	dc.b	"             50, RUE JACOTOT            "
	dc.b	"           73100 AIX-LES-BAINS          "
	dc.b	"                 FRANCE                 "
	dc.b	"                                        "
	dc.b	"             WOOPER/PROFECY             "
	dc.b	"   (ONLY TECHNO-FANS AND NO SWAPPING)   "
	dc.b	"              DAVID CALLY               "
	dc.b	"         23, RUE DE L'AUBEPINE          "
	dc.b	"          49124 ST BARTHELEMY           "
	dc.b	"                 FRANCE                 "
	dc.b	"                                        "
	dc.b	"VERY IMPORTANT: DON'T WRITE TO OUR POBOX"
	dc.B	"                 ANYMORE!               "	
	dc.b	"                                        "
	dc.b	"OK, NOW LET'S GO WITH THE BORING GREETZ:"
	dc.b	"            (AND BYE, BYE!)             "
	dc.b	"                                        "
       	dc.b	"             ABUNDANCE (ANTEX)          "
	dc.b	"              ADEPT (SLEDGE)            "
	DC.B    "  ALLIANCE DESIGN (7TH EYE - ZEBIGBOSS) "
	dc.b	"          AMAZE AUSTRIA (DALMET)        "
	dc.b	"          AMAZE GERMANY (DAMION)        "
	DC.B    "      ANALOG (SPOKY - AXIS - ALFA)      "
        DC.B    "             ANTHROX (EMPTY)            "
        DC.B    "               AWAKE (ART)              "
        DC.B    "                BILLY JOHN              "
        DC.B    "            BLACK ROBES (BART)          "
        DC.B    "           BNK TEAM (MORELOVE)          "
        DC.B    "          CATASTROPHY (MANIAC)          "
        DC.B    "            COMPLEX (DER HM)            "
        DC.B    "          CRIMINALS (AL CAPONE)         "
        DC.B    "         CRUSADERS (LAZERBRAIN)         "
        DC.B    "           CURARE (JAYWALKER)           "
	DC.B    "            CYCLONE (EUREKA)            "
        DC.B    "             DAMAGE INC.(SI)            "
        DC.B    "           DARKNESS (ESTRAYK)           "
        DC.B    "        DARKSOLDIERS (CAMPARI'91)       "
	dc.b	"        DEFCON 4 (CODY - KRAFTON)       " 
        DC.B    "         DEVILS (RHAH - MR KEEL)        "
	DC.B    "        DREAMDEALERS (SUN - TONY)       "
	dc.b	"       DRIFTERS (HOOKED - CORONAL)      "
	dc.b	"      END OF CENTURY 1999 (CYPHER)      "
	DC.B    "    EREMATION (BABYBOB -                "
	dc.b	"               DOC SAVAGE - BRAINWASHER)"
	DC.B    "        FLASH PRODUCTION (CEDRIC)       "
        DC.B    "             FUSION (OPTIMA)            "
        DC.B    "           GERYON (SIDE ARMS)           "
        DC.B    "             GHOST (FABIO)              "
	dc.b	"       GRACE ITALY (BILLY THE KID)      "
	dc.b	"     HARDLINE (POWERSWAP -  TRASHER)    "
	DC.B 	"       HERETIQUES (NATAS - ZORGAN)      "
	dc.b    "      HYSTERIC (POULY - DEAD SNAKE)     "
	DC.B 	"  INTENSE (MAXXIMUM - TOURIST - FUCK)   "
	DC.B    "            INSANITY (BULLET)           "
	DC.B 	"   JAM (MAD - SPOKE - VIPER - TROLL)    "
        DC.B    "             JUSTICE (BUSH)             "
	DC.B    "            KEFRENS (KRUEGER)           "
	DC.B    "                  LEO                   "
        DC.B    "            MAJIC 12 (LUCAS)            "
	DC.B	"             MYSTICS (HCL)              "
        DC.B    "               MR FOLEY                 "
	DC.B	"                  MS                    "
	DC.B	"                NIETOU                  "
        DC.B    "            NEXUS (HESIODOS)            "
        DC.B    "            OFFWORLD (BUNDY)            "
        DC.B    "            PARADISE (BRUTUS)           "
        DC.B    "           PARAGON (DR VOODOO)          "
	DC.B 	"     PASSION (SPEEDY - ZELTRON TKC)     "
	DC.B	"           POLARIS (MAGELLAN)           "
	DC.B	"          QUARTZ (BIBI - SAM)           "
        DC.B    "             RAF UK (MR.B)              "
	DC.B 	"            SATURNE (ERIK)              "
        DC.B    "            SILENTS (DARYL)             "
        DC.B    "             SPIRIT (CONE)              "
        DC.B    "        SUBCULTURE 89 (OPUS 12)         "
        DC.B    "          SYNTAX ERROR (SOACH)          "
	dc.b	"            TECH (SLAUGHTER)            "
	DC.B    "                TOUNIF                  "
	DC.B	"    TSB (FREDDOX - EKTAR - NEWMARK)     "
        DC.B    "             TRSI (DRAGSTER)            "
	dc.b	"             VEGA (HELIOTH)             "
        DC.B    "         VISUAL BYTES (WARHAWK)         " 
        DC.B    "             WIZZCAT (MUSSE)            "
        DC.B    "                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"        (C) PROFECY 15/04/1992          "
	dc.b	"                                        "
	dc.b	"      CODE : ALE OF FAME & WOOPER       "
	dc.b	"      GFX  : FURIO & WOOPER             "
	dc.b	"      MUSIC: SLN                        "
	dc.b	"                                        "
	dc.b	"   PD DISTRIBUTORS: WE FUCK YOU ALL!    "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	-1	
	even
;**********************************************************************
;EFFACE SCREEN
;**********************************************************************
efface_screen
		lea	ligne,a0		;MODIF
		move.l	#10-1,d0
eff_ligne	clr.l	(a0)+
		dbf	d0,eff_ligne
		move.l	#6-1,d0		;Efface les 6 plans...
		lea	image_slide,a0
do_it
		wait_blit
		move.l	a0,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#0,$66(a6)
		move.w	#257*64+20,$58(a6)	;MODIF
		add.w	#40*257,a0
		dbf	d0,do_it
		wait_blit
		rts
;**********************************************************************
;ETOILES 68000			version blitter
;**********************************************************************
;---------------------------------- installe les etoiles
install_stars1	btst	#14,$2(a6)
		bne.s	install_stars1
		move.l	#image_slide,$54(a6)		;dest
		move.l	#etoiles,$50(a6)	;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#256*64+20,$58(a6)
install_stars2	btst	#14,$2(a6)
		bne.s	install_stars2
		move.l	#image_slide+(40*(257+128)),$54(a6)	;dest
		move.l	#etoiles,$50(a6)	;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#128*64+20,$58(a6)
install_stars3	btst	#14,$2(a6)
		bne.s	install_stars3
		move.l	#image_slide+(40*257),$54(a6)	;dest
		move.l	#etoiles+(40*128),$50(a6)	;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#128*64+20,$58(a6)
		rts
;---------------------------------- deplace les etoiles pointeur
starsp
		cmp.w	#2,p1
		bne	suite1
		bsr	copie_ligne1
		clr.w	p1
suite1		cmp.w	#(320/4),p2
		bne	suite2
		bsr	copie_ligne2
		clr.w	p2
		add.w	#1,p1
suite2		bsr	deplace_stars1
		add.w	#1,p2
		rts
p1	dc.w	0
p2	dc.w	0
;---------------------------------- copie la ligne du bas
copie_ligne1	btst	#14,$2(a6)
		bne.s	copie_ligne1
		move.l	#ligne,$54(a6)		;dest
		move.l	#image_slide+(40*255),$50(a6)	;source du bas
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#1*64+20,$58(a6)	;une ligne
		rts
copie_ligne2	btst	#14,$2(a6)
		bne.s	copie_ligne2
		move.l	#ligne+(40*257),$54(a6)		;dest
		move.l	#image_slide+(40*(256+256)),$50(a6)	;source du bas
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#1*64+20,$58(a6)	;une ligne
		rts
;---------------------------------- blitte les etoiles
deplace_stars1	btst	#14,$2(a6)
		bne.s	deplace_stars1
		move.l	#ligne,$54(a6)		;dest
		move.l	#ligne,$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$19f00000,$40(a6)	;1 pas
		move.l	#$00000000,$64(a6)
		move.w	#257*64+20,$58(a6)
deplace_stars2	btst	#14,$2(a6)
		bne.s	deplace_stars2
		move.l	#ligne+(40*257),$54(a6)		;dest
		move.l	#ligne+(40*257),$50(a6)		;source
		move.l	#$ffffffff,$44(a6)
		move.l	#$49f00000,$40(a6)		;4 pas
		move.l	#$00000000,$64(a6)
		move.w	#257*64+20,$58(a6)
		rts

;**********************************************************************
;SCROLL TEXTE !
;**********************************************************************

affiche_lettre
	cmp.w	#$0,arret
	beq	suite_copie
	sub.w	#$1,arret
	rts
suite_copie
	subq.w	#$1,tempo
	cmp.w	#$0,tempo
	bne	affiche_pas
	move.w	#4,tempo
	moveq.l	#$0,d1
	moveq.l	#$0,d0
	move.l	lsuiv,a1	
	move.b	(a1)+,d1
	cmp.b	#-1,d1
	beq	retourdebut
ret_deb	sub.b	#" ",d1		;-32 car 32=ESPACE
	cmp.w	#3,d1
	bne	suite_copie2
	move.w	#wait_scroll,arret
	move.l	a1,lsuiv
	rts
suite_copie2
	move.w	#plan_scroll-1,d2		;Nombre de plan เ foutre
	lsl.w	#$1,d1
	move.w	d1,d4		;Svg no lettre
	move.w	#hauteurlettre*64+1,d1

fout_plan
	lea	font,a0		;adresse de font dans a0
	lea	image+2+44,a2	

	move.w	d2,d3
	move.w	d2,d5
	muls.w	#(largeurfont/8)*hauteurlettre,d3
	muls.w	#(2+44+2+2)*hauteurlettre,d5
	add.w	d3,a0
	add.w	d4,a0		;Voila, a0 contient l'adresse de la lettre
	add.w	d5,a2
	bsr	copie_blit
	dbf	d2,fout_plan
	move.l	a1,lsuiv

affiche_pas
	bsr	scroll
	rts

copie_blit	;PARAMETRES A PASSER:
		;Dans a0: Adresse source
		;     a2: Adresse destination
		;     d0:BLTCON0 et 1
		;     d1:Taille เ transferer
		
		wait_blit
		move.l	a2,$54(a6) 			;dest ecran
		move.l	a0,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.w	#(largeurfont/8)-2,$64(a6)
		move.w	#2+44+2+2-2,$66(a6)
		move.w	d1,$58(a6)
		rts
copie_blit2	;PARAMETRES A PASSER:
		;Dans a0: Adresse source
		;     a2: Adresse destination
		;     d0:BLTCON0 et 1
		;     d1:Taille เ transferer
		
		wait_blit
		move.l	a2,$54(a6) 			;dest ecran
		move.l	a0,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.w	#0,$64(a6)
		move.w	#28,$66(a6)
		move.w	#8*64+8,$58(a6)
		rts
retourdebut
	lea	texte,a1
	move.b	(a1)+,d1
	bra	ret_deb	
lsuiv
	dc.l	texte

arret
	dc.w	0
tempo
	dc.w	4
nolettre
	dc.w	0

scroll
	move.w	#plan_scroll-1,d2		;Nombre de plan เ foutre
	move.w	#hauteurlettre*64+(2+44+2+2-2)/2,d1

scroll_plan
	lea	image+2,a0
	lea	image,a1	
	move.w	d2,d3
	muls.w	#(2+44+2+2)*hauteurlettre,d3
	add.w	d3,a0
	add.w	d3,a1
	wait_blit
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move	#2,$64(a6)
	move	#2,$66(a6)
	move	#%1110100111110000,$40(a6)
	move	d1,$58(a6)

	dbf	d2,scroll_plan
	rts
texte
	; 20 LETTRES MAX SUR UNE LIGNE...
	;EH les enfants! #=pause
	;Titre เ mettre en attente: A centrer sur 18
	dc.b	"                            (PRESS RIGHT MOUSE TO "
	dc.b	"CHANGE PICTURE!)                  "
	dc.b	"PROFECY PRESENTS A LITTLE SLIDE-SHOW DONE ON THE 31/03/92... "
	dc.b	"    SPECIAL THANX TO $ FURIO $ FOR THE DIGITISED PICTURES ! "
	dc.b	"    AT LAST THIS IS A NEW GREAT INTRO FROM PROFECY... IN FACT, "
	dc.b	"IT'S REALLY SHIT... COMPARE TOO THE SOON COMING:  $ NUMERIC 3 $ "
	dc.b	"    $ LET'S RAVE DEMO $       $ OLYMPIA DEMO $         "
	dc.b	"YOU KNOW, WE ARE FRENCH GUYS, SO I STOP NOW THE ENGLISH TEXT ! "
	DC.B	"    BON, BON, BON... ICI C'EST WOOPER (THE CODER, EH, EH!)... TOUT "
	DC.B	"DE SUITE JE VOUDRAIS REAGIR A L'ARTICLE PARU DANS AMIGA-REVUE A PROPOS "
	DC.B	"DE NUMERIC II... L'ARTICLE COMMENCAIT BIEN... MAIS ALORS QU'ON DISE A LA FIN "
	DC.B	"QUE LES SAMPLES SONT RECUPERES DE DIGITAL CONCERT, C'EST LA PREUVE QUE LE TESTEUR "
	DC.B	"REGARDE ET ECOUTE LES DEMOS AVEC UN MONITEUR POURAVE! EH, MON POTE! MES DIGITS NE SE "
	DC.B	"COMPARE PAS AVEC LES SAMPLES MINABLES DE FLASH PRODUCTION! C'EST DU DO IT BY MYSELF! "
	DC.B	"ET PUIS QUAND ON VOIT LA DEMO DE PHENOMENA FRANCE (?!!!) TESTEE DANS CE MEME AMIGA-REVUE "
	DC.B	"PAR UN CERTAIN ANTOINE MUSSARD QUI N'EST AUTRE QUE L'UN DES CONCEPTEURS DE LA DEMO, ON NE S'ETONNE "
	DC.B	"PAS QUE LES NOTES TOURNENT AUTOUR DE 18 OU 19 !    "
	dc.b	"ET NOW, VITE FAIT BIEN FAIT, QUELQUES MESSAGES:       "
	dc.b	"CHERS HOOKED AND CORONAL OF DRIFTERS, DOC SAVAGE AND BRAINWASHER OF EREMATION, TRASHER OF HARDLINE, "
	dc.b	"SLEDGE OF ADEPT, SLAUGHTER OF TECH : I'M SORRY... I STOP SWAPPING! (CODE IS GREAT)... BUT "
	dc.b	"DON'T BE CRUEL (YEAH! WHO IS ELVIS!?): I WILL SEND YOU ALL OUR NEXT PRODUCTIONS... "
	dc.b	"          CHER SPECTRE (=SPECIALISTE EN CONTRE ESPIONNAGE, ACTE DE TERRORISME"
	dc.b	" REPRESAILLES ET EXTORSION HE HE HE AH AH !!): ES-TU MORT ? J'ATTENDS AINSI QUE GRETZKY ET MERY "
	dc.b	"(ET TOUS LES AUTRES JE SUPPOSE?), LA DEMO $ OLYMPIA $ (LES JEUX OLYMPIQUES SONT TERMINES DEPUIS N "
	DC.B	"M'ENFIN, TANT PIS... C'EST L'INTENTION QUI COMPTE!)...    BON, JE VAIS CONTINUER MON P'TIT DELIRE! "
	DC.B	"EN FAIT, JE SUIS BIEN CONTENT QUE CE PUT... DE SLIDE SOIT OUT! MAINTENANT JE ME MET A 100 POUR 100 "
	DC.B	"SUR LE TANT ATTENDU NUMERIC 3 (CA VA ETRE SOOOO COOL, COMME DIRAIT GRETZKY...). A PART CA, SI TOUT VAS "
	dc.b	"BIEN, APRES DEMAIN ALE OF FAME (TONIO, LE ROI DE LA RADIO), ET MOI, ON SERA A TOURS, ET LE LENDEMAIN (APRES "
	DC.B	"UNE MEGA SOIREE ETUDIANTE), ON PART EN BELGIQUE, LE PAYS DES BONNES BIERES (EN SECONDE POSITION APRES L'IRLANDE... "
	DC.B	"GUINNESS, GUINNESS...). LA-BAS, LES CHIMAYS ET LES LEFFES AURONT INTERET A FAIRE GAFFE A LEUR C... EN PLUS, ALE "
	DC.B	"EMMENE SES RAYBAN AVEC LEDS (C'EST GOOD POUR LES TECHNOS-PARTIES!)... BON, C'EST PAS TOUT CA, MAIS CA FAIT UNE SEMAINE "
	DC.B	"ET DEMI QUE L'ON VEUT TERMINER CE SLIDE, ALORS ON VOUS DIT A PLUS... A MOINS QUE ALE VEUILLE TAPER DU TEXTE ?... OUI! ALORS "
	DC.B	"JE LUI LAISSE MON CLAVIER... ROGER A MOI ... PILE CABLEE LEDS BRANCHEES AH AH AH AH AH AH FREE FREE FREEDOM BLOUM BLOUM "
	DC.B	" TU TU TI TI TU TU TI TI TU TU... DE TOUTES MANIERES POUR MOI CA GAZE ... PROFECY ... A YEAR TI TU TU...   VOILA, ICI WOOPER "
	DC.B	"DE NOUVEAU... ALE A FINI SON DELIRE... ON VOUS DIT AU 18 04 92 (PREPAREZ VOS PALMES !): RAVE PARTY A LA POMMERAY (PRES D'ANGERS!) "
	DC.B	" ALLEZ LES ENFANTS, IL EST L'HEURE D'ALLER AU LIT... ENFIN POUR NOUS, C'EST L'HEURE D'ASSEMBLER ET DE CRUNCHER... ALLEZ A PLUS, BANDE "
	DC.B	"DE SEREX!                                           " 
	
	dc.b	-1	;indique la fin a ne pas enlever!!
	even
;**********************************************************************
;RASTERS
;**********************************************************************
barres:
	lea	raster1,a0
	lea	raster2,a1
	move.l	ptrcoul2,a5
	cmp.w	#$ffff,(a5)
	beq	remet_debut
	move.w	#nbrligne-1,d3	;nombre d'iterations
	move.w	(a0),d0		;svg couleur 1
	move.w	(a5)+,(a0)	;on met la nouvelle couleur			
	move.w	(a5),(a1)
	move.l	a5,ptrcoul2
	addq.w	#4,a0
	addq.w	#4,a1
bouge_barre
	move.w	(a0),d1		;svg couleur 2
	move.w	d0,(a0)		;met 1er couleur svgder
	move.w	d0,(a1)
	addq.w	#4,a0
	addq.w	#4,a1
	move.w	(a0),d0		;svg couleur 1
	move.w	d1,(a0)
	move.w	d1,(a1)
	addq.w	#4,a1	
	addq.w	#4,a0
	dbf	d3,bouge_barre
	rts

remet_debut
	move.l	#couleurs,ptrcoul2
	rts

ptrcoul2
	dc.l	couleurs	

couleurs:
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
**------------------------------------------------ DECRUNCHER
normaldecrunch:
	movem.l	d0-d7/a0-a6,-(sp)
	cmp.l	#"CrM!",(a0)+
	bne.s	.notcrunched
	tst.w	(a0)+
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	a0,a2
	bsr.s	fastdecruncher
.notcrunched:
	movem.l	(sp)+,d0-d7/a0-a6
	rts
fastdecruncher:
	move.l	a1,a5
	add.l	d1,a1
	add.l	d2,a2
	move.w	-(a2),d0
	move.l	-(a2),d6
	moveq	#16,d7
	sub.w	d0,d7
	lsr.l	d7,d6
	move.w	d0,d7
	moveq	#16,d3
	moveq	#0,d4
.decrloop:
	cmp.l	a5,a1
	ble	.decrend

	bsr.s	.bittest
	bcc.s	.insertseq
	moveq	#0,d4
** einzelne bytes einfügen **
.insertbytes:
	moveq	#8,d1
	bsr.w	.getbits
	move.b	d0,-(a1)
	dbf	d4,.insertbytes
	bra.s	.decrloop
*------------
.specialinsert:
	moveq	#14,d4
	moveq	#5,d1
	bsr.s	.bittest
	bcs.s	.ib1
	moveq	#14,d1
.ib1:	bsr.s	.getbits
	add.w	d0,d4
	bra.s	.insertbytes
*------------
.insertseq:
** anzahl der gleichen bits holen **
	bsr.s	.bittest
	bcs.s	.ab1
	moveq	#1,d1
	moveq	#1,d4
	bra.s	.abget
.ab1:
	bsr.s	.bittest
	bcs.s	.ab2
	moveq	#2,d1
	moveq	#3,d4
	bra.s	.abget
.ab2:
	bsr.s	.bittest
	bcs.s	.ab3
	moveq	#4,d1
	moveq	#7,d4
	bra.s	.abget
.ab3:
	moveq	#8,d1
	moveq	#$17,d4
.abget:
	bsr.s	.getbits
	add.w	d0,d4
	cmp.w	#22,d4
	beq.s	.specialinsert
	blt.s	.cont
	subq.w	#1,d4
.cont:
** sequenzanbstand holen **
	bsr.s	.bittest
	bcs.s	.db1
	moveq	#9,d1
	moveq	#$20,d2
	bra.s	.dbget
.db1:
	bsr.s	.bittest
	bcs.s	.db2
	moveq	#5,d1
	moveq	#0,d2
	bra.s	.dbget
.db2:
	moveq	#14,d1
	move.w	#$220,d2
.dbget:
	bsr.s	.getbits
	add.w	d2,d0
	lea	0(a1,d0.w),a3
.insseqloop:
	move.b	-(a3),-(a1)
	dbf	d4,.insseqloop

	bra.w	.decrloop
*------------
.bittest:
	subq.w	#1,d7
	bne.s	.btnoloop
	moveq	#16,d7
	move.w	d6,d0
	lsr.l	#1,d6
	swap	d6
	move.w	-(a2),d6
	swap	d6
	lsr.w	#1,d0
	rts
.btnoloop:
	lsr.l	#1,d6
	rts
*----------
.getbits:		
	move.w	d6,d0
	lsr.l	d1,d6
	sub.w	d1,d7
	bgt.s	.gbnoloop
;	add.w	#16,d7
	add.w	d3,d7
	ror.l	d7,d6
	move.w	-(a2),d6
	rol.l	d7,d6
.gbnoloop:
	add.w	d1,d1
	and.w	.anddata-2(pc,d1.w),d0
	rts
*----------
.anddata:
	dc.w	%1,%11,%111,%1111,%11111,%111111,%1111111
	dc.w	%11111111,%111111111,%1111111111
	dc.w	%11111111111,%111111111111
	dc.w	%1111111111111,%11111111111111
*-----------
.decrend:
	rts		;a5: start of decrunched data
;------------------------------------

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;REPLAY
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
new:
	movem.L	a0-a6/d0-d7,-(a7)
	bsr	mt_music
	cmp.w	#$1,fin_intro
	bne	fin_new
	bsr	affiche_lettre
	bsr	barres
fin_new
;	cmp.w	#$2,fin_intro
;	bne	fin_new2
;	bsr	starsp
;	bsr	scroll2
fin_new2
	movem.L	(a7)+,a0-a6/d0-d7
lev3save:
	jmp	$0
fin_intro
	dc.w	0

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
	move.l	$6c,lev3save+2
	move.l	#new,$6c
	rts

mt_end:	move.l	lev3save+2,$6c
	clr.w	$dff0a8
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

;************************************
copper0
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
palette_copper0
		dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
		dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
		dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
		dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
		dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
		dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
		dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
		dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

plan_copper0
		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.w	$6101,$fffe
		dc.w	$0100
		dc.w	$4200
		dc.w	$6101+$5600,$fffe
		dc.w	$100,$0
		dc.w	-2
		even


;************************************
copper1
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
palette_copper1
		dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
		dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
		dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
		dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
		dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
		dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
		dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
		dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

plan_copper1
		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
		dc.l	$00f40000,$00f60000
		dc.w	$0100
		dc.w	$6200
		dc.w	-2
		even
;************************************
copper2
		dc.w	$2e01,$fffe
		dc.w	$100,$0
		dc.w	$180,$0
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
palette_copper2
		dc.w	$0180
coul0		dc.w	$0000,$0182,$0000,$0184,$0000,$0186,$0000
		dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
		dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
		dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
		dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
		dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
		dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
		dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
plan_copper2
		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000
		dc.l	$00f40000,$00f60000
		dc.w	$0100
bplcon02	dc.w	$6200

; 2eme ECRAN
		dc.w	$ffdf,$fffe
		dc.w	$1f01,$fffe
		dc.w	$100,$0
		dc.w	$2035,$fffe,$180

raster1		dc.w	$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$100,$0
		dc.l	$008e2471,$00902dd1,$00920030,$009400d8
		dc.l	$01020000,$01040000
plan_scroll2	dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.w	$0180,$0000,$0182,$0eca,$0184,$0940,$0186,$0b63
		dc.w	$0188,$0d85,$018a,$0fa7,$018c,$0fc9,$018e,$0feb
		
		dc.l	$01080006,$010a0006
		dc.w	$2201,$fffe
		dc.w	$0100,$3200
		dc.w	$2a01,$fffe
		dc.w	$100,$0

		dc.w	$2b35,$fffe,$180
	
raster2		dc.w	$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.w	$180,$000,$180,$000,$180,$000,$180,$000,$180,$000
		dc.l	-2
		even
;************************************
copper3
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
palette_copper3
		dc.w	$0182,$0999,$0184,$0fff,$0186,$0fff
plan_copper3
		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.w	$2c01,$fffe
		dc.w	$0100
		dc.w	$3200		; 3 plans actives
		dc.w	$3401,$fffe
		dc.w	$188,$001,$18a,$001,$18c,$001,$18e,$001
		dc.w	$3501,$fffe
		dc.w	$188,$003,$18a,$003,$18c,$003,$18e,$003
		dc.w	$3701,$fffe
		dc.w	$188,$005,$18a,$005,$18c,$005,$18e,$005
		dc.w	$3901,$fffe
		dc.w	$188,$207,$18a,$207,$18c,$207,$18e,$207
		dc.w	$3c01,$fffe
		dc.w	$188,$409,$18a,$409,$18c,$409,$18e,$409
		dc.w	$3f01,$fffe
		dc.w	$188,$62b,$18a,$62b,$18c,$62b,$18e,$62b
		dc.w	$4301,$fffe
		dc.w	$188,$84d,$18a,$84d,$18c,$84d,$18e,$84d
		dc.w	$4701,$fffe
		dc.w	$188,$a6f,$18a,$a6f,$18c,$a6f,$18e,$a6f
		;Ceux du bas
		dc.w	$ffdf,$fffe
		dc.w	$1301,$fffe
		dc.w	$188,$84d,$18a,$84d,$18c,$84d,$18e,$84d
		dc.w	$1701,$fffe
		dc.w	$188,$62b,$18a,$62b,$18c,$62b,$18e,$62b
		dc.w	$1b01,$fffe
		dc.w	$188,$409,$18a,$409,$18c,$409,$18e,$409
		dc.w	$1e01,$fffe
		dc.w	$188,$207,$18a,$207,$18c,$207,$18e,$207
		dc.w	$2101,$fffe
		dc.w	$188,$005,$18a,$005,$18c,$005,$18e,$005
		dc.w	$2301,$fffe
		dc.w	$188,$003,$18a,$003,$18c,$003,$18e,$003
		dc.w	$2501,$fffe
		dc.w	$188,$001,$18a,$001,$18c,$001,$18e,$001
		dc.w	$2601,$fffe
		dc.w	$188,$000,$18a,$000,$18c,$001,$18e,$000
		dc.l	-2

;------------------------------------------------------------------------
	even
copper4
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
palette_copper4
		dc.w	$0180,$0000

plan_copper4
		dc.l	$00e00000,$00e20000
		dc.w	$0100
		dc.w	$1200
		dc.w	$9001,$fffe
		dc.w	$182
dd1		dc.w	$0
		dc.w	$ad01,$fffe
		dc.w	$182
dd2
		dc.w	$0
		dc.w	-2
		even

;*************************************
palette_logo
	dc.w	$0000,$060e,$0101,$0202
	dc.w	$0303,$0304,$0405,$0406
	dc.w	$0407,$0408,$040a,$030b
	dc.w	$030c,$020d,$010e,$000f
	dc.w	$0000,$060e,$0101,$0202	;Tres boeuf
	dc.w	$0303,$0304,$0405,$0406
	dc.w	$0407,$0408,$040a,$030b
	dc.w	$030c,$020d,$010e,$000f
	even
t1
	incbin	present.raw
	even
t2
	incbin	slidetro.raw
	even
logo
	incbin	logo
	even
etoiles
	incbin	etoiles.raw
	even
image_intro
	incbin	"fic4.raw"
	even
font2
	incbin	font8x8no2
	even
font
	incbin	font
	even
mt_data
	incbin mod.sln
	even
image
	dcb.b	(2+44+2+2)*hauteurlettre*plan_scroll,0
	even
palette_slide
	dcb.w	12
ligne	dcb.b	40
image_slide
;	dcb.b	40*(256+1)*nb_plan		;40*256*nb_plan
	even
end

