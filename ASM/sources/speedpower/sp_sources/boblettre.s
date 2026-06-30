;made by spectre profecy
;so if you use this source write my name in your scroll..
;***********DONNEES POUR LIBRAIRIES ***********
execbase equ 4
allocmem equ -30-168
freemem equ -30-180
tailleplan equ 40*256
largplan equ 40
nbrdeplan equ 1
nblettre equ 20
dist equ 4
taillelettre equ 40*200
cltaille equ nbrdeplan*8+4
chip equ 2
clear equ chip+$10000
;*********** DEBUT DU PRG ***********
s:	jsr	save_all
	move.l	#tailleplan,d0
	move.l	#clear,d1
	jsr	allocmem(a6)
	move.l	d0,addplan
	tst.l	d0
	beq	fin
	move.l	#cltaille,d0
	move.l	#clear,d1
	jsr	allocmem(a6)
	move.l	d0,copper
	tst.l	d0
	beq	fin
	move.l	#taillelettre,d0
	move.l	#clear,d1
	jsr	allocmem(a6)
	move.l	d0,addlettre
	tst.l	d0
	beq	fin
	move.l	copper,a0
	move.w	#$e0,d0
	move.l	addplan,d1
	move.w	#nbrdeplan-1,d2
plan:	move.w	d0,(a0)+
	addq.w	#2,d0
	swap	d1
	move.w	d1,(a0)+
	move.w	d0,(a0)+
	addq.w	#2,d0
	swap	d1
	move.w	d1,(a0)+
	add.l	#tailleplan,d1
	dbf	d2,plan
	move.l	#$fffffffe,(a0)
	move.l	addlettre,a0
	lea	imglettre,a1
	move.w	#(40/4)*200,d0
remplie:move.l	(a1)+,(a0)+
	dbf	d0,remplie
	move.w	#" ",d1
	bsr	paslafin
	lea	boblettre,a0
	moveq	#nblettre-1,d3
	clr.w	d2
	lea	fcourbe-4,a2
coord:	move.l	addplan,a1
	move.l	a2,(a0)
	sub.l	#24,a2
	move.l	a4,4(a0)
	move.l	(a0),a3
	move.w	(a3),d0
	move.w	2(a3),d1
	lsr.w	#3,d0
	and.w	#$fffe,d0
	mulu	#40,d1
	add.w	d1,d0
	add.w	d0,a1
	move.l	a1,8(a0)
	add.w	#14,a0
	dbf	d3,coord
	lea	palette,a0
	move.l	#$dff180,a1
	move.w	#8-1,d0
pal:	move.w	(a0)+,(a1)+
	dbf	d0,pal
	move.w	#$2981,$dff08e
	move.w	#$29C1,$dff090
	move.w	#$0038,$dff092
	move.w	#$00D0,$dff094
	move.w	#$1200,$dff100
	clr.w	$dff102
	clr.w	$dff104
	clr.w	$dff108
	clr.w 	$dff10a
	clr.w	$dff042
	move.w	#$7fff,d0
	move.w	d0,$dff09a
	move.w	d0,$dff096
	move.l	copper,$dff080
	clr.w	$dff088
	move.w	#$c020,$dff09a
	move.w	#$87c0,$dff096
	move.l	#MA_VBL,$6c

souris:	btst.b	#6,$bfe001
	bne.s	souris

wait:	btst	#14,$dff002
	bne.s	wait
	move.l	4,a6
	move.l	#tailleplan,d0
	move.l	addplan,a1
	jsr	freemem(a6)
	move.l	#cltaille,d0
	move.l	copper,a1
	jsr	freemem(a6)
	move.l	#taillelettre,d0
	move.l	addlettre,a1
	jsr	freemem(a6)
	bsr.s	restore_all
fin:	clr.l	d0
	rts
save_all:
	move.b	#%10000111,$bfd100	;stop les drives
	move.l	4,a6			;base exec
	jsr	-132(a6)			;forbid
	move.w	$dff01c,save_intena
	or.w	#$8100,save_intena		;mettre certain bits a 1 
	move.w	$dff002,save_dmacon	;pour pouvoir les replacer avec un or
	or.w	#$c000,save_dmacon
	move.l	$6c,save_vecteur_irq
	rts
restore_all:
	move.l	save_vecteur_irq,$6c
	move.w	#$7fff,$dff09a		;vide intena
	move.w	save_intena,$dff09a	;place la copie
	move.w	#$7fff,$dff096		;vide le dmacon
	move.w	save_dmacon,$dff096	;place la copie
	move.l	4,a6			;base d'exec
	lea	name_glib,a1		;ouvre la library
	moveq	#0,d0			;vide d0
	jsr	-552(a6)			;open-library
	move.l	d0,a0			;sauve handler
	move.l	38(a0),$dff080		;startupcl ds cop1lc
	clr.w	$dff088			;copjmp1
	move.l	d0,a1			;adr de library
	jsr	-414(a6)			;closelibrary
	jsr	-138(a6)			;permit
	rts
save_intena:dc.w 0
save_dmacon:dc.w 0
save_vecteur_irq:dc.l 0
name_glib:dc.b "graphics.library",0
	even
MA_VBL:	
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$dff01e,d0
	and.w	$dff01c,d0
	btst	#5,d0
	beq.s	firq
	move.w	#$f00,$dff180
	bsr	affichage
	clr.w	$dff180
	move.w	#$20,$dff09c
firq:	movem.l	(sp)+,d0-d7/a0-a6
	rte

affichage:
	moveq	#nblettre-1,d2
	lea	boblettre,a0
	move.w	#$0024,$dff066
effbob:	move.w	12(a0),d1
	or.w	#$0900,d1
	move.w	d1,$dff040
imp:	move.l	8(a0),$dff054
	move.w	#16*64+2,$dff058
	add.w	#14,a0
	dbf	d2,effbob
	lea	boblettre,a0
	moveq	#nblettre-1,d3
calcul:	addq.l	#4,(a0)
	cmp.l	#fcourbe,(a0)
	blt	vas_y
	move.l	#courbe,(a0)
	bsr	search
	move.l	a4,4(a0)
vas_y:	move.l	(a0),a2
	move.w	(a2),d0
	move.w	2(a2),d1
	move.w	d0,d2
	lsr.w	#3,d0
	and.w	#$fffe,d0
	mulu	#40,d1
	add.w	d1,d0
	move.l	addplan,a1
	add.w	d0,a1
	move.l	a1,8(a0)
	and.w	#$f,d2
	ror.w	#4,d2
	move.w	d2,12(a0)
	add.w	#14,a0
	dbf	d3,calcul
	lea	boblettre,a0
	moveq	#nblettre-1,d2
pas_fin:move.l	#$ffff0000,$dff044
	move.w	12(a0),d1
	or.w	#$dfc,d1
	move.l	#$00240024,$dff064
	move.w	#$0024,$dff062
	move.l	4(a0),$dff050
	move.l	8(a0),$dff04c
	move.l	8(a0),$dff054
	move.w	d1,$dff040
	move.w	#16*64+2,$dff058
	add.w	#14,a0
	dbf	d2,pas_fin
	rts
search:	lea	ptexte(pc),a3
	moveq	#0,d1
	move.l	(a3),a2
	move.b	(a2)+,d1
	addq.l	#1,(a3)
	tst.b	d1
	bne.s	paslafin
	move.l	#texte,(a3)
	bra.s	search
paslafin:
	lea	tablechars(pc),a2
	moveq	#0,d0
recherche:
	cmp.w	(a2),d1
	beq.s	found
	addq.l	#4,a2
	bra.s	recherche
found:	move.l	d0,a4
	move.w	2(a2),a4
	add.l	addlettre,a4
	rts
;**** donnees *****
texte:
	dc.b	"SPECTRE OF PROFECY A REALISER SE SCROLLING "
	dc.b	"ET EST FIERE DE CE QU IL A FAIT HO YEAH !!!"
	dc.b	0
	EVEN
ptexte:	dc.l texte
tablechars:
	DC.W "A",$0000,"B",$0002,"C",$0004,"D",$0006,"E",$0008,"F",$000A
	DC.W "G",$000C,"H",$000E,"I",$0010,"J",$0012,"K",$0014,"L",$0016
	DC.W "M",$0018,"N",$001A,"O",$001C,"P",$001E,"Q",$0020,"R",$0022
	DC.W "S",$0024,"T",$0026,"U",$0258,"V",$025A,"W",$025C,"X",$025E
	DC.W "Y",$0260,"Z",$0262,"0",$0264,"1",$0266,"2",$0268,"3",$026A
	DC.W "4",$026C,"5",$026E,"6",$0270,"7",$0272,"8",$0274,"9",$0276
	DC.W "!",$0278,"?",$027A,":",$027C,".",$027E," ",$04D8
palette:dc.w	$0,$fff,$f00,$500,$0f0,$f00,$050,$00f
addplan:dc.l 0
copper:dc.l 0
addlettre:dc.l 0
boblettre:ds.w	nblettre*7
courbe:incbin	"courbe2.b"
fcourbe:
imglettre:incbin "boblettre"
