;-------------------------------------------------------------------
;			SOURCE DE NUMERIC III
;-------------------------------------------------------------------
execbase = 4

plan_scroll=3
hauteurlettre=33
wait_scroll=100		;Attente pour noms

ht_image=225
nb_plan=4

bleu_wait=75		;en vbl

nb_planhb = 6	;en half bright
cbg = $53c	;couleur du 5 eme plan
p_bs = 6-1	;plan scroll


dist_equa= 36

nplan=0
pausecoul1=10		;Nbr VBL pause entre chaque cycle couleur
vitessetourne=6		;Vitesse a laquelle reagisse les carres au volume
			;ATTENTION: soit 2,4,6,8...

AddICRVector	=   -6
RemICRVector	=  -12
LVOOpenResource	= -498
LVOOpenLibrary 	= -552
CloseLibrary	= -414
ciatalo = $400
ciatahi = $500
ciatblo = $600
ciatbhi = $700
ciacra  = $E00
ciacrb  = $F00

n_note		EQU	0  ; W
n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; B
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

;-------------------------------
wait_blit	macro
loop_wait_blt\@
	btst	#14,$2(a6)
	bne.s	loop_wait_blt\@
	endm
;-------------------------------
;-------------------------------
p		macro
loop_pause\@
	vbl
	sub.w	#1,pause_memoire
	cmp.w	#0,pause_memoire
	bne	loop_pause\@
	move.w	#bleu_wait,pause_memoire
	endm
;-------------------------------
;-------------------------------
vbl		macro
loop_vbl\@
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$0ff00,d0
	bne.s	loop_vbl\@
	endm
;-------------------------------
vbl2		macro
loop_vbl2\@
	cmp.b	#180,$dff006
	bne.s	loop_vbl2\@
	endm
;-------------------------------
vbl1		macro
loop_vbl\@
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$0f000,d0
	bne.s	loop_vbl\@
	endm
;-------------------------------


	section	code,code_c
start
	bsr	save_all	;Tres tres classique...
	move.l	#$dff000,a6
	move.w	#$7fff,$96(a6)	;A mettre je crois pour les interruptions...
	;move.w	#$7fff,$9a(a6)	;Ca aussi...
	bsr	init
	BSR	SetCIAInt
	BSR	mt_init
	ST	mt_Enable
	move.l	#$dff000,a6
	bsr	active_copper
	;bra	souris

;AFFICHAGE DU TPS AVANT... TOUT EST A ZERO...
	bsr	affiche_heure_dizaine
	bsr	affiche_heure_unite
	bsr	affiche_minute_dizaine
	bsr	affiche_minute_unite
	bsr	affiche_seconde_dizaine
	bsr	affiche_seconde_unite	
	bsr	affiche_minute_dizaine2
	bsr	affiche_minute_unite2
	bsr	affiche_seconde_dizaine2
	bsr	affiche_seconde_unite2

	move.l	#textebig,ptr_scroll
	move.w	#4,nouvelle_lettre
	move.w	#10,num_colonne

;*****************************************
;BOUCLE PRINCIPALE
;*****************************************
boucle
	vbl
	add.w	#1,nbr_vbl
	cmp.w	#50,nbr_vbl
	bne	suite_boucle
	move.w	#0,nbr_vbl
	bsr	time
	bsr	time_total
suite_boucle
	;move.w	#$f,$180(a6)	;test tps machine
	;bsr	big_scroll
	;clr.w	$180(a6)
	;move.w	#$0f0,$180(a6)	;test tps machine
	bsr	equa1
	;clr.w	$180(a6)
	;move.w	#$00f,$180(a6)	;test tps machine
	;bsr	scrolltext
	;clr.w	$180(a6)
	;move.w	#$f0f,$180(a6)	;test tps machine
	bsr	reflet
	;clr.w	$180(a6)
	;move.w	#$0ff,$180(a6)	;test tps machine
	bsr	desactivate
	;clr.w	$180(a6)
souris	btst	#6,$bfe001
	bne	boucle
	;bne	souris

restore_all
	BSR	mt_end
	BSR	ResetCIAInt
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
fin	clr.l	d0
	rts
save_all
	move.b	#%10000111,$bfd100	;on arrete les drives
	move.l	4,a6			;no comment
 	jsr	-132(a6)		;stopper le multitache
	move.w	$dff002,save_dmacon	;save registre dma
	or.w	#$8100,save_dmacon	;bit 15 et 14 à 1
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena
	rts
pause_memoire
	dc.w	bleu_wait
save_intena
	dc.w	0
save_dmacon
	dc.w 0

DOSname	dc.b "dos.library",0
	even
name_glib
	dc.b "graphics.library",0
	even
nbr_vbl
	dc.w	0
;---------------------------------------------------------------------
; INITIALISATIONS DE TOUS LES DIFFERENTS PLANS...
;---------------------------------------------------------------------

init

install2
	;Install plan provisoire
	lea	bmap,a0
	move.l	#image+2,d0
	moveq	#plan_scroll-1,d1
plan_suivant2
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#(2+44+2+2)*hauteurlettre,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant2

	lea	bmapbig(pc),a0
	move.l	#ecran+2,d0
	moveq	#nb_planhb-1,d1
plan_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#46*ht_image,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant

	lea	bmap_rot(pc),a0
	move.l	#image_rot,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	rts

active_copper
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
	;dma active
	move.w	#$87c0,$96(a6)
	rts
desactivate
	sub.w	#1,pause_mousedroite
	cmp.w	#0,pause_mousedroite
	beq	test_souris_droite
	rts
test_souris_droite
	move.w	#6,pause_mousedroite
	btst	#10,$dff016
	beq	test_si_active
	rts
test_si_active
	cmp.w	#$6200,active_plan
	bne	reactive
	move.w	#$5200,active_plan
	rts
reactive
	move.w	#$6200,active_plan
	rts
pause_mousedroite
	dc.w	6
;**********************************************************************
;  carres_tourne
;**********************************************************************
equa1
		moveq	#0,d2
		move.l	ptrcoul,a2		;Pointeur couleurs dans a2		
		subq.w	#$1,delaicoul
		cmp.w	#$0,delaicoul
		bne	yaundelai
		lea	coulchange(pc),a0
		move.w	(a2)+,d2
ici		move.l	#16-1,d0
ca_gaze		move.w	d2,(a0)
		add.w	#4,a0
		dbf	d0,ca_gaze

		move.w	#pausecoul1,delaicoul	
yaundelai
voix1		;VOIX NO 1
		lea	mt_chan1temp+$12(pc),a3
		cmp.w	#$0,(a3)
		bge	suite
		move.w	#$0,(a3)

suite
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence(pc),a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d0		;x
paste_x		lea	image_rot+nplan,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#dist_equa,d0
		cmp.w	#dist_equa*2,d0
		bne	paste_x

voix2		;VOIX NO 2
		subq.w	#vitessetourne,(a3)		;on decremente voix no 1...

		lea	mt_chan2temp+$12(pc),a3
		cmp.w	#$0,(a3)
		bge	suite2
		move.w	#$0,(a3)

suite2
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence(pc),a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d0		;x
paste_x2	lea	image_rot+(46*32)+nplan,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#dist_equa,d0
		cmp.w	#dist_equa*2,d0
		bne	paste_x2
voix3		;VOIX NO 3
		subq.w	#vitessetourne,(a3)		;on decremente voix no 2...

		lea	mt_chan3temp+$12(pc),a3
		cmp.w	#$0,(a3)
		bge	suite3
		move.w	#$0,(a3)

suite3
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence(pc),a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d0		;x
paste_x3	lea	image_rot+(46*64)+nplan,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#dist_equa,d0
		cmp.w	#dist_equa*2,d0
		bne	paste_x3
voix4		;VOIX NO 4
		subq.w	#vitessetourne,(a3)		;on decremente voix no 3...

		lea	mt_chan4temp+$12(pc),a3
		cmp.w	#$0,(a3)
		bge	suite4
		move.w	#$0,(a3)

suite4
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence(pc),a1
		add.w	d2,a1
		move.l	(a1),a1
		move.l	#0,d0		;x
paste_x4	lea	image_rot+(46*96)+nplan,a0
		add.l	d0,a0
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
		add.w	#dist_equa,d0
		cmp.w	#dist_equa*2,d0
		bne	paste_x4
finvoix
		subq.w	#vitessetourne,(a3)		;on decremente voix no 4...
		cmp.w	#-1,(a2)
		beq	debut_coul
		move.l	a2,ptrcoul
		rts
debut_coul
		move.l	#couleurs,ptrcoul
		rts
copieblit
w_blit		btst	#14,$2(a6)
		bne.s	w_blit
		move.l	source,$54(a6) 			;dest ecran
		move.l	destination,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.l	#$0000002a,$64(a6)
		move.w	#32*64+2,$58(a6)
		rts
source
		dc.l	0
destination
		dc.l	0
table_equivalence
		;Table d'equivalence entre le volume et l'image a afficher
		;1er long mot=image pour volume=0
		;2eme long mot=image pour volume=1 etc...
		;Ici volume de 0 à 6
		dc.l	carre,carre+128,carre+128,carre+128,carre+128
		dc.l	carre+128,carre+128
		;Ici volume de 7 à 12
		dc.l	carre+256,carre+256,carre+256,carre+256
		dc.l	carre+256,carre+256
		;Ici volume de 13 à 18
		dc.l	carre+384,carre+384,carre+384,carre+384
		dc.l	carre+384,carre+384
		;Ici volume de 19 à 24
		dc.l	carre+512,carre+512,carre+512,carre+512
		dc.l	carre+512,carre+512
		;Ici volume de 25 à 30
		dc.l	carre+640,carre+640,carre+640,carre+640
		dc.l	carre+640,carre+640
		;Ici volume de 31 à 36
		dc.l	carre+768,carre+768,carre+768,carre+768
		dc.l	carre+768,carre+768
		;Ici volume de 37 à 42
		dc.l	carre+896,carre+896,carre+896,carre+896
		dc.l	carre+896,carre+896
		;Ici volume de 43 à 48
		dc.l	carre+1024,carre+1024,carre+1024,carre+1024
		dc.l	carre+1024,carre+1024
		;Ici volume de 49 à 54
		dc.l	carre+1152,carre+1152,carre+1152,carre+1152
		dc.l	carre+1152,carre+1152
		;Ici volume de 55 à 64
		dc.l	carre+1280,carre+1280,carre+1280,carre+1280
		dc.l	carre+1280,carre+1280,carre+1280,carre+1280
		dc.l	carre+1280,carre+1280

ptrcoul
		dc.l	couleurs
delaicoul
		dc.w	pausecoul1
couleurs
		dc.w	$f0f,$ff0,$f00,$00f,$0f0,$0ff,$fff
		dc.w	-1
;**********************************************************************
;  big scroll
;**********************************************************************
big_scroll
	moveq	#0,d0
	moveq	#0,d1
	move.l	ptr_scroll,a0
	cmp.w	#4,nouvelle_lettre
	bne	decale_scroll
	cmp.w	#10,num_colonne
	bne	suite_colonne
	clr.w	num_colonne
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	beq	fin_scroll
	move.b	d0,la_lettre
suite_colonne
	move.b	la_lettre,d0
	cmp.b	#" ",d0
	beq	espace_char
	sub.b	#"A",d0
	lea	lettre_a(pc),a4
	mulu.w	#120,d0		;*120
	add.l	d0,a4
	bsr	copie_lettre
fin_lettre
	add.w	#1,num_colonne
	move.l	a0,ptr_scroll
	clr.w	nouvelle_lettre
	bsr	decale_scroll
	rts

fin_scroll
	bsr	decale_scroll
	move.l	#textebig,ptr_scroll
	move.w	#4,nouvelle_lettre
	move.w	#10,num_colonne
	rts
espace_char
	move.b	d0,la_lettre
	lea	lettre_spc(pc),a4
	bsr	copie_lettre
	bra	fin_lettre

copie_lettre
		lea	bmaps(pc),a1
		lea	ecran+42+(46*ht_image*p_bs)+(46*8),a3
		move.l	#12-1,d0		;hauteur
		add.w	num_colonne,a4	;n°de la largeur			
p_colonne	moveq	#0,d2
		move.b	(a4),d2
		lsl.l	#5,d2
		move.l	a1,a2
		add.l	d2,a2		;a2 source a3 dest
		bsr	paste_bmap
		add.w	#10,a4
		add.l	#(46*16),a3
		dbf	d0,p_colonne
		rts

paste_bmap	btst	#14,$2(a6)
		bne.s	paste_bmap
		move.l	a3,$54(a6)
		move.l	a2,$50(a6)
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$0000002c,$64(a6)
		move.w	#16*64+1,$58(a6)
		rts

decale_scroll	btst	#14,$2(a6)
		bne.s	decale_scroll
		move.l	#ecran+(46*ht_image*p_bs)+(46*8),$54(a6)	;dest
		move.l	#ecran+2+(46*ht_image*p_bs)+(46*8),$50(a6)	;srce
		move.l	#$ffffffff,$44(a6)
		move.l	#$c9f00000,$40(a6)
		move.l	#$00020002,$64(a6)
		move.w	#192*64+22,$58(a6)
		add.w	#1,nouvelle_lettre
		rts
num_colonne	dc.w	10
ptr_scroll	dc.l	textebig
nouvelle_lettre	dc.w	8
la_lettre	dc.w	0
;---------------------------------- le  TEXTE
textebig
	dc.b	"PROFECY PRESENT NUMERIC III PREVIEW "
	dc.b	-1
	even	
;**********************************************************************
;SCROLL TEXTE !
;**********************************************************************
scrolltext

copieblocsc
	cmp.w	#$0,arret
	beq	suite_copie
	sub.w	#$1,arret
	rts
suite_copie
	subq.w	#$1,tempo
	cmp.w	#$0,tempo
	bne	affiche_pas
	move.w	#8,tempo
	moveq.l	#$0,d1
	moveq.l	#$0,d0
	move.l	lsuiv,a1	
	move.b	(a1)+,d1
	cmp.b	#-1,d1
	beq	retourdebut
ret_deb	sub.b	#" ",d1		;-32 car 32=ESPACE
	cmp.w	#5,d1
	bne	suite_copie2
	move.w	#wait_scroll,arret
	move.l	a1,lsuiv
	rts
suite_copie2
	move.w	#plan_scroll-1,d2		;Nombre de plan à foutre
	move.w	d1,d4		;Svg no lettre
	lsl.w	#$1,d4		;On multiplie d1 par deux car largeur=16
	move.w	#hauteurlettre*64+1,d1
	move.l	#$ffffffff,$44(a6)		;masque
	move.l	#$09f00000,$40(a6)
	move.w	#118-2,$64(a6)
	move.w	#2+44+2+2-2,$66(a6)

fout_plan
	lea	font,a0		;adresse de font dans a0
	lea	image+2+44,a2

	move.w	d2,d3
	move.w	d2,d5
	mulu.w	#118*hauteurlettre,d3
	mulu.w	#(2+44+2+2)*hauteurlettre,d5
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
		;     d1:Taille à transferer
		
		wait_blit
		move.l	a2,$54(a6) 			;dest ecran
		move.l	a0,$50(a6)			;source smx
		move.w	d1,$58(a6)
		rts
retourdebut
	move.l	ptrtexte,a1
	move.l	ptrtexte,lsuiv
	move.b	(a1)+,d1
	bra	ret_deb	
lsuiv
	dc.l	texte

arret
	dc.w	0
tempo
	dc.w	8
nolettre
	dc.w	0
ptrtexte
	dc.l	texte
scroll
	move.w	#plan_scroll-1,d2		;Nombre de plan à foutre
	move.w	#hauteurlettre*64+(2+44+2+2-2)/2,d1
	move.w	#2,$64(a6)
	move.w	#2,$66(a6)
	move.w	#%1110100111110000,$40(a6)

scroll_plan
	lea	image+2,a0
	lea	image,a1	
	move.w	d2,d3
	mulu.w	#(2+44+2+2)*hauteurlettre,d3
	add.w	d3,a0
	add.w	d3,a1
	wait_blit
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move	d1,$58(a6)

	dbf	d2,scroll_plan
	rts
texte_mery
	dc.b	"        MERY... "
	dc.b	-1
	even
texte_gretzky
	dc.b	"        GRETZKY... "
	dc.b	-1
	even
texte_furio
	dc.b	"        FURIO... "
	dc.b	-1
	even
texte_wooper
	dc.b	"        WOOPER... "
	dc.b	-1
	even
texte_ale
	dc.b	"        ALE... "
	dc.b	-1
	even
texte
	; 20 LETTRES MAX SUR UNE LIGNE...
	;EH les enfants! %=pause
	;Titre à mettre en attente: A centrer sur 18

	dc.b	"#NUMERIC VOL. 3#   % "
	dc.b	" THE COOLEST TECHNO AND DANCE MUSIC DISK ON AMIGA "
	dc.b	"IS BACK AGAIN AND WAS PERFORMED FOR YOU BY:      "
	dc.b	"  $WOOPER$        % "
	dc.b	"FOR CODING AND MUSICS    "
	dc.b	"  $ALE OF FAME$     % "
	dc.b	"FOR CODING    "
	dc.b	"    $GRAF'X$         % "
	dc.b	"FOR... GFX!    "
	dc.b	"SP AND SPECTRE    % "
	dc.b	"FOR HELP AND SUPPORT! "
	dc.b	"                      "
	dc.b	-1	;indique la fin a ne pas enlever!!
	even

;**********************************************************************
;ONDULATION-REFLET
;**********************************************************************
reflet
	lea	table_sinus(pc),a0
	move.w	no_sinus,d0
	lsl.w	#1,d0		;Multiplie par deux car mot...
	add.w	d0,a0		;On pointe le sinus en cours	
	move.w	(a0)+,ondul1
	bsr	test_ondul
	move.w	(a0)+,ondul2
	bsr	test_ondul
	move.w	(a0)+,ondul3
	bsr	test_ondul
	move.w	(a0)+,ondul4
	bsr	test_ondul
	move.w	(a0)+,ondul5
	bsr	test_ondul
	move.w	(a0)+,ondul6
	bsr	test_ondul
	move.w	(a0)+,ondul7
	bsr	test_ondul
	move.w	(a0)+,ondul8
	bsr	test_ondul
	move.w	(a0)+,ondul9
	bsr	test_ondul
	move.w	(a0)+,ondul10
	bsr	test_ondul
	move.w	(a0)+,ondul11
	bsr	test_ondul
	move.w	(a0)+,ondul12
	bsr	test_ondul
	move.w	(a0)+,ondul13
	bsr	test_ondul
	move.w	(a0)+,ondul14
fin_reflet
	add.w	#1,no_sinus
	lea	table_sinus(pc),a0
	move.w	no_sinus,d0
	lsl.w	#1,d0		;Multiplie par deux car mot...
	add.w	d0,a0		;On pointe le sinus en cours	
	cmp.w	#-1,(a0)
	bne	sort_reflet
	move.w	#0,no_sinus
sort_reflet
	rts	
test_ondul
	cmp.w	#-1,(a0)
	bne	s_ondul
	lea	table_sinus(pc),a0
s_ondul
	rts

table_sinus
	dc.w	$66,$77,$77,$88,$88,$88,$88,$77,$77,$66,$66,$55,$44,$33,$22,$11
	dc.w	$11,$00,$00,$00,$00,$11,$11,$22,$33,$44,$55
	dc.w	-1
	;-1 indique la fin, off course
no_sinus
	dc.w	0

;**********************************************************************
;DEFILEMENT DU TEMPS
;**********************************************************************
time
	bsr	test_seconde_unite
	rts

test_seconde_unite
	add.w	#1,seconde_unite
	cmp.w	#10,seconde_unite
	beq	test_seconde_dizaine
	bsr	affiche_seconde_unite
	rts
test_seconde_dizaine
	move.w	#0,seconde_unite
	bsr	affiche_seconde_unite
	add.w	#1,seconde_dizaine
	cmp.w	#6,seconde_dizaine
	beq	test_minute_unite
	bsr	affiche_seconde_dizaine
	rts
test_minute_unite
	move.w	#0,seconde_dizaine
	bsr	affiche_seconde_dizaine
	add.w	#1,minute_unite
	cmp.w	#10,minute_unite
	beq	test_minute_dizaine
	bsr	affiche_minute_unite
	rts

test_minute_dizaine
	move.w	#0,minute_unite
	bsr	affiche_minute_unite
	add.w	#1,minute_dizaine
	cmp.w	#6,minute_dizaine
	beq	test_heure_unite
	bsr	affiche_minute_dizaine
	rts
test_heure_unite
	move.w	#0,minute_dizaine
	bsr	affiche_minute_dizaine
	add.w	#1,heure_unite
	cmp.w	#10,heure_unite
	beq	test_heure_dizaine
	bsr	affiche_heure_unite
	rts
test_heure_dizaine
	move.w	#0,heure_unite
	bsr	affiche_heure_unite
	add.w	#1,heure_dizaine
	cmp.w	#10,heure_dizaine
	beq	error_tps
	bsr	affiche_heure_dizaine
	rts
error_tps
	move.w	#0,seconde_unite
	move.w	#0,seconde_dizaine
	move.w	#0,minute_unite
	move.w	#0,minute_unite
	move.w	#0,heure_unite
	move.w	#0,heure_dizaine
	bsr	affiche_seconde_unite
	bsr	affiche_seconde_dizaine
	bsr	affiche_minute_unite
	bsr	affiche_minute_dizaine
	bsr	affiche_heure_unite
	bsr	affiche_heure_dizaine
	
	rts

affiche_seconde_unite

	move.l	#seconde_unite,val_digit
	bsr	cherche_digit
	move.w	#8,px
	bsr	affiche_digit
	rts

affiche_seconde_dizaine

	move.l	#seconde_dizaine,val_digit
	bsr	cherche_digit
	move.w	#7,px
	bsr	affiche_digit
	rts

affiche_minute_unite

	move.l	#minute_unite,val_digit
	bsr	cherche_digit
	move.w	#5,px
	bsr	affiche_digit
	rts

affiche_minute_dizaine

	move.l	#minute_dizaine,val_digit
	bsr	cherche_digit
	move.w	#4,px
	bsr	affiche_digit
	rts

affiche_heure_unite

	move.l	#heure_unite,val_digit
	bsr	cherche_digit
	move.w	#2,px
	bsr	affiche_digit
	rts

affiche_heure_dizaine

	move.l	#heure_dizaine,val_digit
	bsr	cherche_digit
	move.w	#1,px
	bsr	affiche_digit
	rts

cherche_digit
	;Passer dans val_digit, l'adresse qui contient la digit
	;a retrouver
	move.l	val_digit,a0
	move.w	(a0),d0		;Valeur digit dans d0
	lea	chiffres,a1
	muls.w	#8,d0
	add.w	d0,a1		;Pointe la digit a afficher
	rts
affiche_digit
	;La lettre est pointe dans a1
	lea	ecran+(46*80)+2,a2
	add.w	px,a2
	move.w	#8-1,d0
blurp
	move.b	(a1)+,(a2)
	add.w	#46,a2
	dbf	d0,blurp
	rts
val_digit
	dc.l	0
seconde_unite
	dc.w	0
seconde_dizaine
	dc.w	0
minute_unite
	dc.w	0
minute_dizaine
	dc.w	0
heure_unite
	dc.w	0
heure_dizaine
	dc.w	0
px
	dc.w	0
py
	dc.w	1
chiffres
	incbin	digits2.raw
	even
;*********************************************
time_total
	bsr	test_seconde_unite2
	rts

test_seconde_unite2
	add.w	#1,seconde_unite2
	cmp.w	#10,seconde_unite2
	beq	test_seconde_dizaine2
	bsr	affiche_seconde_unite2
	rts
test_seconde_dizaine2
	move.w	#0,seconde_unite2
	bsr	affiche_seconde_unite2
	add.w	#1,seconde_dizaine2
	cmp.w	#6,seconde_dizaine2
	beq	test_minute_unite2
	bsr	affiche_seconde_dizaine2
	rts
test_minute_unite2
	move.w	#0,seconde_dizaine2
	bsr	affiche_seconde_dizaine2
	add.w	#1,minute_unite2
	cmp.w	#10,minute_unite2
	beq	test_minute_dizaine2
	bsr	affiche_minute_unite2
	rts

test_minute_dizaine2
	move.w	#0,minute_unite2
	bsr	affiche_minute_unite2
	add.w	#1,minute_dizaine2
	cmp.w	#6,minute_dizaine2
	beq	error_tps2
	bsr	affiche_minute_dizaine2
	rts
error_tps2
	move.w	#0,seconde_unite2
	move.w	#0,seconde_dizaine2
	move.w	#0,minute_unite2
	move.w	#0,minute_dizaine2
	bsr	affiche_seconde_unite2
	bsr	affiche_seconde_dizaine2
	bsr	affiche_minute_unite2
	bsr	affiche_minute_dizaine2
	rts

affiche_seconde_unite2

	move.l	#seconde_unite2,val_digit
	bsr	cherche_digit
	move.w	#8,px
	bsr	affiche_digit2
	rts

affiche_seconde_dizaine2

	move.l	#seconde_dizaine2,val_digit
	bsr	cherche_digit
	move.w	#7,px
	bsr	affiche_digit2
	rts

affiche_minute_unite2

	move.l	#minute_unite2,val_digit
	bsr	cherche_digit
	move.w	#5,px
	bsr	affiche_digit2
	rts

affiche_minute_dizaine2

	move.l	#minute_dizaine2,val_digit
	bsr	cherche_digit
	move.w	#4,px
	bsr	affiche_digit2
	rts

affiche_digit2
	;La lettre est pointe dans a1
	lea	ecran+(46*80)+32,a2
	add.w	px,a2
	move.w	#8-1,d0
blurp2
	move.b	(a1)+,(a2)
	add.w	#46,a2
	dbf	d0,blurp2
	rts
seconde_unite2
	dc.w	0
seconde_dizaine2
	dc.w	0
minute_unite2
	dc.w	0
minute_dizaine2
	dc.w	0

;**********************************************************************
;ROUTINE MUSIQUE
;**********************************************************************

SetCIAInt
	MOVEQ	#2,D6
	LEA	$BFD000,A5
	MOVE.B	#'b',CIAAname+3
SetCIALoop
	MOVEQ	#0,D0
	LEA	CIAAname(PC),A1
	MOVE.L	4.W,A6
	JSR	LVOOpenResource(A6)
	MOVE.L	D0,CIAAbase
	BEQ	mt_Return

	LEA	GfxName(PC),A1
	MOVEQ	#0,D0
	JSR	LVOOpenLibrary(A6)
	TST.L	D0
	BEQ	ResetCIAInt
	MOVE.L	D0,A1
	MOVE.W	206(A1),D0	; DisplayFlags
	BTST	#2,D0		; PAL?
	BEQ.S	WasNTSC
	MOVE.L	#1773447,D7 ; PAL
	BRA.S	sciask
WasNTSC	MOVE.L	#1789773,D7 ; NTSC
sciask	MOVE.L	D7,TimerValue
	DIVU	#136,D7 ; Default to normal 50 Hz timer
	JSR	CloseLibrary(A6)

	MOVE.L	CIAAbase(PC),A6
	CMP.W	#2,D6
	BEQ.S	TryTimerA
TryTimerB
	LEA	MusicIntServer(PC),A1
	MOVEQ	#1,D0	; Bit 1: Timer B
	JSR	AddICRVector(A6)
	MOVE.L	#1,TimerFlag
	TST.L	D0
	BNE.S	CIAError
	MOVE.L	A5,CIAAaddr
	MOVE.B	D7,ciatblo(A5)
	LSR.W	#8,D7
	MOVE.B	D7,ciatbhi(A5)
	BSET	#0,ciacrb(A5)
	RTS

TryTimerA
	LEA	MusicIntServer(PC),A1
	MOVEQ	#0,D0	; Bit 0: Timer A
	JSR	AddICRVector(A6)
	CLR.L	TimerFlag
	TST.L	D0
	BNE.S	CIAError
	MOVE.L	A5,CIAAaddr
	MOVE.B	D7,ciatalo(A5)
	LSR.W	#8,D7
	MOVE.B	D7,ciatahi(A5)
	BSET	#0,ciacra(A5)
	RTS

CIAError
	MOVE.B	#'a',CIAAname+3
	LEA	$BFE001,A5
	SUBQ.W	#1,D6
	BNE	SetCIALoop
	CLR.L	CIAAbase
	RTS

ResetCIAInt
	MOVE.L	CIAAbase(PC),D0
	BEQ	mt_Return
	CLR.L	CIAAbase
	MOVE.L	D0,A6
	MOVE.L	CIAAaddr(PC),A5
	TST.L	TimerFlag
	BEQ.S	ResTimerA

	BCLR	#0,ciacrb(A5)
	MOVEQ	#1,D0
	BRA.S	RemInt

ResTimerA
	BCLR	#0,ciacra(A5)
	MOVEQ	#0,D0
RemInt	LEA	MusicIntServer(PC),A1
	MOVEQ	#0,d0
	JSR	RemICRVector(A6)
	RTS

;---- Tempo ----

SetTempo
	MOVE.L	CIAAbase(PC),D2
	BEQ	mt_Return
	CMP.W	#32,D0
	BHS.S	setemsk
	MOVEQ	#32,D0
setemsk	MOVE.W	D0,RealTempo
	MOVE.L	TimerValue(PC),D2
	DIVU	D0,D2
	MOVE.L	CIAAaddr(PC),A4
	MOVE.L	TimerFlag(PC),D0
	BEQ.S	SetTemA
	MOVE.B	D2,ciatblo(A4)
	LSR.W	#8,D2
	MOVE.B	D2,ciatbhi(A4)
	RTS

SetTemA	MOVE.B	D2,ciatalo(A4)
	LSR.W	#8,D2
	MOVE.B	D2,ciatahi(A4)
	RTS

RealTempo	dc.w 125
CIAAaddr	dc.l 0
CIAAname	dc.b "ciaa.resource",0
CIAAbase	dc.l 0
TimerFlag	dc.l 0
TimerValue	dc.l 0
GfxName		dc.b "graphics.library",0,0

MusicIntServer
	dc.l 0,0
	dc.b 2,5 ; type, priority
	dc.l musintname
	dc.l 0,mt_music

musintname	dc.b "Protracker MusicInt",0

;---- Playroutine ----

mt_init	LEA	mt_data,A0
	MOVE.L	A0,mt_SongDataPtr
	MOVE.L	A0,A1
	LEA	952(A1),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
mtloop	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2	MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ.B	#1,D2
			
	LEA	mt_SampleStarts(PC),A1
	ASL.L	#8,D2
	ASL.L	#2,D2
	ADD.L	#1084,D2
	ADD.L	A0,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3	CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	42(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	#30,A0
	DBRA	D0,mtloop3

	OR.B	#2,$BFE001
	MOVE.B	#6,mt_speed
	CLR.B	mt_counter
	CLR.B	mt_SongPos
	CLR.W	mt_PatternPos
mt_end	SF	mt_Enable
	LEA	$DFF000,A0
	CLR.W	$A8(A0)
	CLR.W	$B8(A0)
	CLR.W	$C8(A0)
	CLR.W	$D8(A0)
	MOVE.W	#$F,$DFF096
	RTS

mt_music
	MOVEM.L	D0-D4/A0-A6,-(SP)
route
	bsr	big_scroll
	bsr	scrolltext
	TST.B	mt_Enable
	BEQ	mt_exit
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0B0,A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0C0,A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	$DFF0D0,A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PatternPos(PC),D1
	CLR.W	mt_DMACONtemp

	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	$DFF0B0,A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	$DFF0C0,A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	$DFF0D0,A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR	mt_PerNop
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	AND.B	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	TST.B	D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	(A1,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ.S	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA.S	mt_SetRegs

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D0-D1/A0-A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#36,D2
mt_ftuloop
	CMP.W	(A1,D0.W),D1
	BHS.S	mt_ftufound
	ADDQ.L	#2,D0
	DBRA	D2,mt_ftuloop
mt_ftufound
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	ADD.L	D1,A1
	MOVE.W	(A1,D0.W),n_period(A6)
	MOVEM.L	(SP)+,D0-D1/A0-A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ	mt_CheckMoreEfx

	MOVE.W	n_dmabit(A6),$DFF096
	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)	; Set start
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	n_period(A6),D0
	MOVE.W	D0,6(A5)		; Set period
	MOVE.W	n_dmabit(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.W	#300,D0
mt_WaitDMA
	DBRA	D0,mt_WaitDMA
	MOVE.W	mt_DMACONtemp(PC),D0
	OR.W	#$8000,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#300,D0
mt_WaitDMA2
	DBRA	D0,mt_WaitDMA2

	LEA	$DFF000,A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),$D0(A5)
	MOVE.W	n_replen(A6),$D4(A5)
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),$C0(A5)
	MOVE.W	n_replen(A6),$C4(A5)
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),$B0(A5)
	MOVE.W	n_replen(A6),$B4(A5)
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),$A0(A5)
	MOVE.W	n_replen(A6),$A4(A5)

mt_dskip
	ADD.W	#16,mt_PatternPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PatternPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
mt_nnpysk
	CMP.W	#1024,mt_PatternPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PatternPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
mt_exit	MOVEM.L	(SP)+,D0-D4/A0-A6
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0),D1
	BHS.S	mt_Arpeggio4
	ADDQ.L	#2,A0
	DBRA	D3,mt_arploop
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE.S	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ	mt_end
	CMP.B	#32,D0
	BHS	SetTempo
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ.S	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ.S	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	BRA	mt_PerNop

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#1,D0
	ASL.B	#1,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PatternPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.W	n_dmabit(A6),$DFF096	; Channel DMA off
	MOVE.L	n_start(A6),(A5)	; Set sampledata pointer
	MOVE.W	n_length(A6),4(A5)	; Set length
	MOVE.W	#300,D0
mt_rtnloop1
	DBRA	D0,mt_rtnloop1
	MOVE.W	n_dmabit(A6),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	MOVE.W	#300,D0
mt_rtnloop2
	DBRA	D0,mt_rtnloop2
	MOVE.L	n_loopstart(A6),(A5)
	MOVE.L	n_replen(A6),4(A5)
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return
	MOVE.W	(A6),D0
	BEQ	mt_Return
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS


mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr	dc.l 0
mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
mt_Enable	dc.b 0
mt_PatternPos	dc.w 0
mt_DMACONtemp	dc.w 136

	even
;------------------------------------------------------------------------
lettre_spc	dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0

lettre_a	dc.b	6,1,1,1,1,1,1,1,7,0	;10 long * 16 haut
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	9,1,8,0,0,0,9,1,8,0

lettre_b	dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,4,0
		dc.b	1,1,1,1,1,1,1,1,3,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0

lettre_c	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_d	dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0

lettre_e	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,7,0,0,0
		dc.b	1,1,1,1,1,1,8,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_f	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1,7,0,0
		dc.b	1,1,1,1,1,1,1,8,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	9,1,8,0,0,0,0,0,0,0

lettre_g	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,6,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_h	dc.b	6,1,7,0,0,0,6,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	9,1,8,0,0,0,9,1,8,0

lettre_i	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_j	dc.b	0,0,0,6,1,1,1,1,7,0
		dc.b	0,0,0,1,1,1,1,1,1,0
		dc.b	0,0,0,9,1,1,1,1,1,0
		dc.b	0,0,0,0,0,0,1,1,1,0
		dc.b	0,0,0,0,0,0,1,1,1,0
		dc.b	0,0,0,0,0,0,1,1,1,0
		dc.b	6,1,7,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_k	dc.b	6,1,7,0,0,0,6,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,2,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,4,0
		dc.b	1,1,1,1,1,1,1,1,0,0
		dc.b	1,1,1,1,1,1,1,1,3,0
		dc.b	1,1,1,0,0,5,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	9,1,8,0,0,0,9,1,8,0

lettre_l	dc.b	6,1,7,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_m	dc.b	6,1,3,0,0,0,2,1,7,0
		dc.b	1,1,1,3,0,2,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,5,1,4,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	9,1,8,0,0,0,9,1,8,0

lettre_n	dc.b	6,1,1,0,0,0,1,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,3,0,0,1,1,1,0
		dc.b	1,1,1,1,3,0,1,1,1,0
		dc.b	1,1,1,1,1,3,1,1,1,0
		dc.b	1,1,1,5,1,1,1,1,1,0
		dc.b	1,1,1,0,5,1,1,1,1,0
		dc.b	1,1,1,0,0,5,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	9,1,8,0,0,0,1,1,8,0

lettre_o	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_p	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	9,1,8,0,0,0,0,0,0,0

lettre_q	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,1,3,1,1,1,0
		dc.b	1,1,1,0,5,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,4,0
		dc.b	9,1,1,1,1,1,1,4,0,0

lettre_r	dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,4,0
		dc.b	1,1,1,1,1,1,1,1,3,0
		dc.b	1,1,1,0,0,5,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,8,0

lettre_s	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,8,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,0,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1,1,7,0
		dc.b	9,1,1,1,1,1,1,1,1,0
		dc.b	0,0,0,0,0,0,1,1,1,0
		dc.b	0,0,0,0,0,0,1,1,1,0
		dc.b	6,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_t	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,9,1,8,0,0,0,0

lettre_u	dc.b	6,1,7,0,0,0,6,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0

lettre_v	dc.b	6,1,1,0,0,0,1,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,3,0,2,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	5,1,1,1,1,1,1,1,4,0
		dc.b	0,5,1,1,1,1,1,4,0,0

lettre_w	dc.b	6,1,1,0,0,0,1,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,2,1,3,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	5,1,1,1,1,1,1,1,4,0
		dc.b	0,5,1,1,1,1,1,4,0,0

lettre_x	dc.b	6,1,1,0,0,0,1,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,3,0,2,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,4,0,5,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	9,1,8,0,0,0,1,1,8,0

lettre_y	dc.b	6,1,7,0,0,0,6,1,7,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,0,0,0,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,1,1,1,0,0,0,0
		dc.b	0,0,0,9,1,8,0,0,0,0

lettre_z	dc.b	6,1,1,1,1,1,1,1,7,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,1,0
		dc.b	0,0,0,0,0,0,2,1,3,0
		dc.b	0,0,0,0,0,2,1,3,0,0
		dc.b	0,0,0,0,2,1,3,0,0,0
		dc.b	0,0,0,2,1,3,0,0,0,0
		dc.b	0,0,2,1,3,0,0,0,0,0
		dc.b	0,2,1,3,0,0,0,0,0,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	1,1,1,1,1,1,1,1,1,0
		dc.b	9,1,1,1,1,1,1,1,8,0
		even
;------------------------------------------------------------------------
copper
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080006,$010a0006
bmapbig		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
plan_5		dc.l	$00f00000,$00f20000
		dc.l	$00f40000,$00f60000

		dc.w	$100
active_plan	dc.w	$6200


		dc.w	$0180,$0000,$0182,$0075,$0184,$0063,$0186,$0052
		dc.w	$0188,$0031,$018a,$0020,$018c,$0620,$018e,$0510
		dc.w	$0190,$0800,$0192,$0900,$0194,$0b00,$0196,$0c00
		dc.w	$0198,$0e00,$019a,$0b00,$019c,$0c00,$019e,$0e00

		dc.w	$01a0,cbg,$01a2,cbg,$01a4,cbg,$01a6,cbg
		dc.w	$01a8,cbg,$01aa,cbg,$01ac,cbg,$01ae,cbg
		dc.w	$01b0,cbg,$01b2,cbg,$01b4,cbg,$01b6,cbg
		dc.w	$01b8,cbg,$01ba,cbg,$01bc,cbg,$01be,cbg

		dc.w	$8901,$fffe
bmap_rot	dc.l	$00f00000,$00f20000
		dc.w	$01a0
coulchange	dc.w	cbg,$01a2,cbg,$01a4,cbg,$01a6,cbg
		dc.w	$01a8,cbg,$01aa,cbg,$01ac,cbg,$01ae,cbg
		dc.w	$01b0,cbg,$01b2,cbg,$01b4,cbg,$01b6,cbg
		dc.w	$01b8,cbg,$01ba,cbg,$01bc,cbg,$01be,cbg

		dc.w	$ffdf,$fffe
		dc.w	$0d01,$fffe
		dc.w	$100,$0			


		dc.l	$008e2471,$00902dd1,$00920030,$009400d8
		dc.l	$01020000,$01040000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$01080006,$010a0006
		dc.w	$100,$0


		dc.w	$0180,$0000,$0182,$0fef,$0184,$0dce,$0186,$0b9d
		dc.w	$0188,$0a6c,$018a,$084c,$018c,$072b,$018e,$060a

		dc.w	$0e01,$fffe
		
		dc.w	$0100,$3200
		dc.w	$1e01,$fffe
		dc.w	$102
ondul1		dc.w	$0000
		dc.w	$180
		dc.w	$006
		dc.w	$2001,$fffe
		dc.w	$102
ondul2		dc.w	$0000
		dc.w	$180
		dc.w	$008
		dc.w	$2101,$fffe
		dc.w	$102
ondul3		dc.w	$0000
		dc.w	$2201,$fffe
		dc.w	$102
ondul4		dc.w	$0000
		dc.w	$180
		dc.w	$00a
		dc.w	$2301,$fffe
		dc.w	$102
ondul5		dc.w	$0000
		dc.w	$2401,$fffe
		dc.w	$102
ondul6		dc.w	$0000
		dc.w	$2501,$fffe
		dc.w	$102
ondul7		dc.w	$0000
		dc.w	$180
		dc.w	$00c
		dc.w	$2601,$fffe
		dc.w	$102
ondul8		dc.w	$0000
		dc.w	$2701,$fffe
		dc.w	$102
ondul9		dc.w	$0000
		dc.w	$2801,$fffe
		dc.w	$102
ondul10		dc.w	$0000
		dc.w	$2901,$fffe
		dc.w	$102
ondul11		dc.w	$0000
		dc.w	$180
		dc.w	$00f
		dc.w	$2a01,$fffe
		dc.w	$102
ondul12		dc.w	$0000
		dc.w	$2b01,$fffe
		dc.w	$102
ondul13		dc.w	$0000
		dc.w	$2c01,$fffe
		dc.w	$102
ondul14		dc.w	$0000
		dc.w	$2d01,$fffe
		dc.w	$180,$000
		dc.l	-2
;------------------------------------------------------------------------
bmaps	dcb.b	16*2		;carre noir
	incbin	dh1:numeric3/intro/bmaps.raw	;cp,1c1,2,3,4,1r1,2,3,4
	even
font	incbin	dh1:numeric3/numIII/font16x32
	even
image	
	dcb.b	(2+44+2+2)*hauteurlettre*plan_scroll,0
	even
ecran	incbin	dh1:numeric3/numIII/screen_bidon.raw
	dcb.b	46*ht_image*2
carre	dcb.b	4*32,0
	incbin	dh1:numeric3/numIII/carretourne.raw
image_rot
	ds.b	46*132
	even
;--- mt data  ---
mt_data	
	incbin	dh1:wooper/mod.technomix1
end

