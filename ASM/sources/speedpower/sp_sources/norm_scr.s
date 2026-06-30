;LE SPEED POWER PROPOSE...
;Ma routine de scroll on ne peut plus normal .Elle est fonctionne le blitter
;et marche en SI ON VEUT UN DEPLACEMENT VERTICAL.On peut calculer les sinus
;a la main ou avec un prg quelconque en GFA.Puisqu'e c'est un truc parametre
;l'editeur de SEKA va pas l'accepter....(il faut donc noter sur un papier les 
;valeurs qu'on veut)....
;IL FAUT 2 OCT A GAUCHE EN MODULO + (2 OCT + LONG_LET )A DROITE sur le plan du
;scrolling et les plan de meme parite (si on veut faire quequechose  en 
; dessous ...)
;Pour les charsets il faut prevoir des cases qui efface ce qui ya en haut et 
;en bas..... 
;Si on veut rajouter des plans , il faut modifier les appel blitter dans
;SCROLLING et aussi le nombre de bitplan dans ECRAN(bss).....
 
long_ecr=40+4+2+2 ;2 * 2 oct pour les decalages 
hauteur_let=32
long_let=4
vitesse=1

debut		jsr	sauve_tout
		
		move	#$7fff,$dff096
		move	#$7fff,$dff09a

		move	#%0001001000000000,$dff100
		clr	$dff104
		move	#long_let+2+2,$dff108	;plus 2*2 pour decalage
		move	#$2981,$dff08e		
		move	#$19c1,$dff090
		move	#$0038,$dff092
		move	#$00d0,$dff094

		move	#$fff,$dff182
		
		move	#%1000000001000000,$dff09a
		move	#%1000001101000000,$dff096	
	
w		cmp.b	#0,$dff006
		bne	w
		move	#5,$dff180
		bsr	flippe		
		move	#0,$dff180
		bsr	scrolling		
		btst.b	#6,$bfe001
		bne	w

		jsr	restaure_tout

		moveq	#0,d0
		rts

sauve_tout	move.b	#%10000111,$bfd100
		move.l	$6c,sauve_irq
		move	$dff01c,sauve_intena
		or	#%1100000000000000,sauve_intena
		move	$dff002,sauve_dmacon
		or	#%1000000100000000,sauve_dmacon
		rts
restaure_tout	move.l	sauve_irq,$6c
		move	#$7fff,$dff09a
		move	sauve_intena,$dff09a
		move	#$7fff,$dff096
		move	sauve_dmacon,$dff096
		move.l	4,a6
		lea	glib,a1
		moveq	#0,d0
		jsr	-552(a6)
		move.l	d0,a0
		move.l	38(a0),$dff080
		clr	$dff088
		rts

		even
sauve_intena	dc	0
		even
sauve_dmacon	dc	0
		even
sauve_irq	dc.l	0
		even
glib		dc.b	"graphics.library",0
		even

flippe		move.l	adr_ecran,a0
		move.l	adr_ecran+4,adr_ecran
		move.l	a0,adr_ecran+4
		add	#2,a0			;c'est xerces qui m'a dit ca
		move.l	a0,$dff0e0		;pour pas voir le resultat 		
		rts				;du decalage

scrolling	move.l	act_pos,a0
		lea	2(a0),a0		;c'est visible (le debut)
		move.l	point_sin,a1
		tst	(a1)
		bge	sin_ok
		lea	sin_scr,a1
sin_ok		move	(a1)+,d0
		move.l	a1,point_sin
		move.l	adr_ecran,a1
		lea	(a1,d0),a1		; la ca l'est pas
		move.l	a1,act_pos
		lea	$dff000,a2
		bsr	wb		
		move.l	a0,$50(a2)	
		move.l	a1,$54(a2)
		move	#2,$64(a2)		;ici 2 oct parce que 1 mot 
		move	#2,$66(a2)		;entre les blocs
		move	#(16-vitesse)<<12+%100111110000,$40(a2)
		move	#hauteur_let<<6+(long_ecr-2)/2,$58(a2)
		subq	#vitesse,compteur32	
		bge	no_new_let
		move	#32,compteur32
		move.l	pointeur_let,a0
		tst.b	(a0)
		bne	letr_ok
		lea	texte,a0
letr_ok		moveq	#0,d0
		move.b	(a0)+,d0
		move.l	a0,pointeur_let
		add	d0,d0
		add	d0,d0
		lea	tab_adr,a0
		move.l	(a0,d0),a0
		lea	(long_ecr-long_let-2)(a1),a1
		bsr	wb
		move.l	a0,$50(a2)
		move.l	a1,$54(a2)
		move	#40-long_let,$64(a2)
		move	#long_ecr-long_let,$66(a2)
		move	#%0000100111110000,$40(a2)
		move	#hauteur_let<<6+long_let/2,$58(a2)
no_new_let	rts

wb		btst	#14,$dff002
		bne	wb
		rts

adr_ecran	dc.l	ecran
		dc.l	ecran+long_ecr*256

point_sin	dc.l	sin_scr
act_pos		dc.l	ecran+101*long_ecr

sin_scr		dc	101*long_ecr
		dc	102*long_ecr
		dc	103*long_ecr
		dc	104*long_ecr
		dc	105*long_ecr
		dc	106*long_ecr
		dc	107*long_ecr
		dc	108*long_ecr
		dc	109*long_ecr
		dc	108*long_ecr
		dc	107*long_ecr
		dc	106*long_ecr
		dc	105*long_ecr
		dc	104*long_ecr
		dc	103*long_ecr
		dc	102*long_ecr
		dc	101*long_ecr

		dc	-1

compteur32	dc	32

pointeur_let	dc.l	texte
		EVEN			
texte		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ "
		DC.B	0
		EVEN
tab_adr	
		dcb.l	32,0
		dc.l	c+5152,c+3040,c+3064,c+3068,0,0,0,c+3060,c+2584,c+2588,0,0,c+2596,c+3048,c+2592,0,c+3072,c+3076,c+5120,c+5124,c+5128,c+5132,c+5136,c+5140,c+5144,c+5148,c+3052,c+3056,0,0,0,c+3044,0,c,c+4
		dc.l	c+8,c+12,c+16,c+20,c+24,c+28,c+32,c+36,c+1280,c+1284,c+1288,c+1292,c+1296,c+1300,c+1304,c+1308,c+1312,c+1316,c+2560,c+2564,c+2568,c+2572,c+2576,c+2580,0,0,0,0,0,0

		even
c		incbin	"df0:char_sin"
		even

		even
ecran		dcb.b	long_ecr*256*2,0
