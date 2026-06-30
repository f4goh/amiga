;-------------------------------------------------------------------
;			SOURCE DE NUMERIC III
;-------------------------------------------------------------------
execbase = 4

plan_scroll=3
hauteurlettre=33
wait_scroll=100		;Attente pour noms


;-------------------------------
wait_blit	macro
loop_wait_blt\@
	btst	#14,$2(a6)
	bne.s	loop_wait_blt\@
	endm
;-------------------------------
;-------------------------------
vbl		macro
loop_vbl\@
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$13000,d0
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
	move.l	#$dff000,a6
	bsr	active_copper

;*****************************************
;BOUCLE PRINCIPALE
;*****************************************
boucle
	vbl
	bsr	scrolltext
	bsr	reflet
souris	btst	#6,$bfe001
	bne	boucle

restore_all
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
save_intena
	dc.w	0
save_dmacon
	dc.w 0

DOSname	dc.b "dos.library",0
	even
name_glib
	dc.b "graphics.library",0
	even
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

	rts

active_copper
	;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
	;dma active
	move.w	#$87c0,$96(a6)
	rts
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
;--------------------------------------------------------------
copper
		dc.l	$008e2471,$00902dd1,$00920030,$009400d8
		dc.l	$01020000,$01040000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$01080006,$010a0006
		dc.w	$100,$0


		dc.w	$0180,$0000,$0182,$0fef,$0184,$0dce,$0186,$0b9d
		dc.w	$0188,$0a6c,$018a,$084c,$018c,$072b,$018e,$060a
		dc.w	$ffdf,$fffe
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
font	incbin	font16x32
	even
image	
	dcb.b	(2+44+2+2)*hauteurlettre*plan_scroll,0
	even
end

