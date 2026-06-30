;LE SPEED POWER PROPOSE....
;Ma routine de crunch pour les graphiques.Ok c'est la methode des packbits
; c a d ,si dans une suite d'octets , tous les octets de la suite sont 
;differents , on recopie la suite tels quel ,si il existe une suite d'octets
;semblable, alors on crunch on met le nombre d'octet composant la suite et 
;l'octet qui est semblable sur toute la suite.C'est programme moyennement
;tendance nul a chier , de plus j'ai employe des astuces pour pas me crever
;Impossible de decruncher quoi que ce soit en une vbl.Ca peut se passer sur
;ST (quand j'aurais le temps, faudra que j'y pense).Au fait ,on sauvegarde
;a2-compact dans A-MON pour le fichier crunche.
;necessite l'image 14 plan CHAR_SIN pour l'exemple
 
long_bloc=18
long_ecr=40
n_lig=156
		move	$dff002,s_dma
		or	#%1100000000000000,s_dma

		move	#$7fff,$dff096
		move	#%0001001000000000,$dff100
		move.l	#$298129c1,$dff08e
		move.l	#$003800d0,$dff092
		clr	$dff108
		move.l	#donnee,d0
		move	d0,copper_liste+6
		swap	d0
		move	d0,copper_liste+2
		move.l	#copper_liste,$dff080
		clr	$dff088
		move	#%1000001110000000,$dff096

aze		lea	donnee,a0	;l'image a cruncher
		lea	compact,a1	;l'image crunche
		jsr	crunchd

w1		btst	#6,$bfe001
		bne	w1

		move.l	#30000,d1
zer		dbf	d1,zer

		lea	compact,a0	;l'image a decruncher
		lea	donnee+20,a1	;lea	zob,a1	;l'ecran dest
		jsr	ddecrunch

w		btst	#6,$bfe001
		bne	w

		move	#$7fff,$dff096
		move	s_dma,$dff096
		move.l	4,a6
		lea	graphics,a1
		moveq	#0,d0
		jsr	-552(a6)
		move.l	d0,a0
		move.l	38(a0),$dff080
		clr	$dff088
		moveq	#0,d0
		rts

crunchd		move.b	#1,n_lig*(long_ecr-1)-1(a0)
		move.b	#1,n_lig*long_ecr-1(a0)	;pour l'arreter sinon y crunch 
		moveq	#0,d0
		move.l	a1,a2
		move.l	a0,a1
		bsr	oct_precedent	
crunch		clr.b	(a2)+
		clr	d2
		cmp.b	(a1,d0),d1
		beq	compacte
oct_sui1	move.b	d1,(a2)+
		bsr	oct_precedent	
		bsr	inc127		
		cmp.b	d3,d1
		bne	oct_sui1
		neg	d2
		addq	#1,d2
		move.b	d2,-2(a2,d2)
		tst	d4	
		beq	crunch
		rts
compacte	move.b	d1,(a2)+
oct_sui2	bsr	oct_precedent	
		bsr	inc127
		cmp.b	d3,d1
		beq	oct_sui2
sort_compacte	move.b	d2,-2(a2)
		bsr	oct_precedent
		tst	d4	
		beq	crunch
		rts	
oct_precedent	move.b	(a1,d0),d1
		add	#long_ecr,d0		;image dans un ecran
		cmp	#n_lig*long_ecr-1,d0
		blt	pas_fin_col
		moveq	#0,d0
		lea	1(a0),a0
		move.l	a0,a1
		cmp.l	#donnee+long_bloc,a0
		blt	pas_fin_col
		st	d4			;flag de fin
pas_fin_col	move.b	(a1,d0),d3
		rts
inc127		addq	#1,d2
		cmp	#127,d2
		blt	in_oct
		addq.l	#6,(sp)			;la vieille ruse de sioux
in_oct		rts				;pour me comprendre biscotte
					

ddecrunch	move.l	a1,a2
		move.l	a2,a3
		add.l	#long_bloc,a3
		moveq	#0,d0
decrunch	moveq	#0,d1
		move.b	(a0)+,d1
		bmi	different
		move.b	(a0)+,d2
dmeme		move.b	d2,(a2,d0)
		bsr	dcompteur
		dbra	d1,dmeme
		bra	decrunch
different	neg.b	d1
dcopie		move.b	(a0)+,(a2,d0)
		bsr	dcompteur
		dbra	d1,dcopie
		bra	decrunch
dcompteur	add	#long_ecr,d0
		cmp	#n_lig*long_ecr,d0
		blt	dpas_new_col
		lea	1(a1),a1
		move.l	a1,a2
		moveq	#0,d0
		cmp.l	a3,a2
		blt	dpas_new_col
		addq.l	#4,sp		;fin de la routine
dpas_new_col	rts	

graphics	dc.b	"graphics.library",0
		even
s_dma		dc	0
copper_liste	dc.l	$00e00000,$00e20000
		dc.l	$fffffffe
donnee		incbin	char_sin

		;dc.b	1,4,3,4		
		;dc.b	1,4,8,6
		;dc.b	1,4,3,2		;super mon image(16 oct)
		;dc.b	2,3,4,2

		section	bss,bss_c
		even
compact		ds.b	5000		;une assez grande valeur
;zob		ds.b	100
