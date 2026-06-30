; *********************************************************************
; Ici WOOPER on the beach...
; Cette fois ci j'attaque l'affichage des images...
; Je sens que je vais m'amuser... mais une fois que j'aurais pige ca
; YABASHI !!!
; *********************************************************************

nbrligne=200
ligne1=$3001	;Valeur du 1er WAIT...


	section	principale,code_c
debut
	bsr	save_all	;C'est classique...
	move.l	#$dff000,a6
	bsr	construit_copper	;Ah yeahh
	bsr	active_copper		;Bon...
	lea	couleurs+2,a5

boucle
	cmp.b	#-1,$6(a6)
	bne.s	boucle
	move.w	#$fff,$180(a6)	;test tps machine
	bsr	barres
	clr.w	$180(a6)	;test tps machine 2, le retour
	btst	#6,$bfe001
	bne.s	boucle
fin
	bsr	restore_all	;Ca aussi c'est classique...
	rts			;The end

save_all:
	move.b	#%10000111,$bfd100	;on arrete les drives
	move.l	4,a6			;no comment
	jsr	-132(a6)		;stopper le multitache
	move.w	$dff002,save_dmacon	;save registre dma
	or.w	#$8100,save_dmacon	;bit 15 et 14 à 1
	rts

restore_all:
	move.w	#$7fff,$dff096		;vide le dmacon
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
	rts

; ATTENTION CECI N'EST PAS LE CODE BOEUF DE ALE...
; C'EST PLUS CONCIS ET CA MAAAAAARCHHHEEEE!!!

construit_copper
	lea	copper,a0
	lea	couleurs,a1
	move.w	#ligne1,d0	;ca y en a etre la valeur du premier WAIT
	move.w	#nbrligne-1,d1	;nbr de lignes-1 à mettre
allez_go
	move.w	#$0180,(a0)+	;registre couleur 180 à zero (noir)
	move.w	(a1)+,(a0)+	;on met la couleur...
	move.w	d0,(a0)+
	add.w	#$100,d0	;Incrementation position y de 1
	move.w	#$fffe,(a0)+
	dbf	d1,allez_go
	move.l	#$01800000,(a0)+	
	move.l	#$fffffffe,(a0)+	;Indique fin de la copper!!!
	rts			;Ouf, fini de construire!...
active_copper
	move.w	#$0380,$96(a6)	;Nettoie DMA
	move.l	#copper,$80(a6)	;Adresse COPPER dans COP1LC
	move.w	#$8280,$96(a6)	;Active...
	clr.w	$88(a6)
	rts	
	
barres
	lea	copper+10,a0
	cmp.w	#$ffff,(a5)
	beq	remet_debut
	move.w	#nbrligne-2,d3
	lsr.b	#1,d3
	subq.w	#1,d3		;nombre d'iterations (ya surement plus rapide)
				;faudra que je demande a spectre...
	move.w	(a0),d0		;svg couleur 1
	move.w	(a5)+,(a0)	;on met la nouvelle couleur			
	addq.w	#8,a0
bouge_barre
	move.w	(a0),d1		;svg couleur 2
	move.w	d0,(a0)		;met 1er couleur svgder
	addq.w	#8,a0
	move.w	(a0),d0		;svg couleur 1
	move.w	d1,(a0)
	addq.w	#8,a0
	dbf	d3,bouge_barre
	rts
remet_debut
	lea	couleurs+2,a5
	rts

save_intena:
	dc.w 	0
save_dmacon:
	dc.w	0
name_glib:
	dc.b "graphics.library",0	
	even				
					
couleurs:
	dc.w	$0
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
coulend:

copper:
	dcb.l 1024

end
	
