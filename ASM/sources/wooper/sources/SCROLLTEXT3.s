;-------------------------------------------------------------------
;SCROLL TEXT FONT 16x32 en 4 PLANS by WOOPER/PROFECY
;-------------------------------------------------------------------

nb_plan=4
v_scroll=2
poscroll=224	;en ligne
	section	code,code_c
start
	bsr	save_all	;Tres tres classique...
	move.l	#$dff000,a6
	clr.l	$144(a6)	;sprite souris off
	bsr	install1	
	bsr	active_copper

boucle
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$12000,d0
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
	add.l	#42*256,d0
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
	subq.w	#$1,tempo
	cmp.w	#$0,tempo
	bne	affiche_pas
	move.w	#8,tempo
	clr.w	d1
	clr.w	d0
	move.l	lsuiv,a1	
	move.b	(a1)+,d1
	cmp.b	#-1,d1
	beq	retourdebut
ret_deb	sub.b	#" ",d1		;-32 car 32=ESPACE
	move.w	#4-1,d2		;Nombre de plan à foutre
	move.w	d1,d4		;Svg no lettre
	lsl.w	#$1,d4		;On multiplie d1 par deux car largeur=16
	move.w	#32*64+1,d1

fout_plan
	lea	font,a0		;adresse de font dans a0
	lea	image+42*poscroll+40,a2

	move.w	d2,d3
	move.w	d2,d5
	muls.w	#118*32,d3
	muls.w	#42*256,d5
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

		btst	#14,$2(a6)
		bne.s	copie_blit
		move.l	a2,$54(a6) 			;dest ecran
		move.l	a0,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.w	#116,$64(a6)
		move.w	#41,$66(a6)
		move.w	d1,$58(a6)
		rts


retourdebut
	lea	texte,a1
	move.b	(a1)+,d1
	bra	ret_deb	
lsuiv
	dc.l	texte

tempo
	dc.w	8
nolettre
	dc.w	0

scroll
	move.w	#4-1,d2		;Nombre de plan à foutre
	move.w	#32*64+20,d1

scroll_plan
	lea	image+42*poscroll+2,a0
	lea	image+42*poscroll,a1	
	move.w	d2,d3
	muls.w	#42*256,d3
	add.w	d3,a0
	add.w	d3,a1
wait_blit
	btst	#14,$2(a6)
	bne.s	wait_blit
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move	#0,$64(a6)
	move	#0,$66(a6)
	move	#(16-v_scroll)<<12+%100111110000,$40(a6)
	move	d1,$58(a6)

	dbf	d2,scroll_plan
	rts

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

copper
		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080002,$010a0002
bmap		dc.l	$00e00000,$00e20000
		dc.l	$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000
		dc.l	$00ec0000,$00ee0000
		dc.w	$0100,$4200
		dc.w	$0180,$0000,$0182,$0fff,$0184,$0ffb,$0186,$0ff6
		dc.w	$0188,$0ff0,$018a,$0fd0,$018c,$0fb0,$018e,$0f90
		dc.w	$0190,$0d70,$0192,$0b50,$0194,$0930,$0196,$0710
		dc.w	$0198,$0500,$019a,$0300,$019c,$0200,$019e,$09f4
		dc.l	-2
;------------------------------------------------------------------------
	even
adresseplan
	dc.l	0
	even
texte
	; 20 LETTRES MAX SUR UNE LIGNE...

	dc.b	"PROFECY IS PROUD TO PRESENT A LITTLE DENTRO "
	dc.b	"CODED BY WOOPER! THE MUSIC YOU ARE LISTENING TO WAS "
	dc.b	"COMPOSED BY THE GREAT SLN, AND GFX WERE PAINTED BY FURIO! "

	dc.b	-1	;indique la fin a ne pas enlever!!
	even
font
	incbin	font16x32
	even
image
	dcb.b	42*256*nb_plan,0
	even
end


