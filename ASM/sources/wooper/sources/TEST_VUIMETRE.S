;**********************************************************************
;TEST VUIMETRES
;**********************************************************************

vitessetourne=6		;Vitesse a laquelle on reagit au volume
			;ATTENTION: soit 2,4,6,8...
equa1
voix1		;VOIX NO 1
		lea	mt_voice1+$12,a3
		cmp.w	#$0,(a3)
		bge	suite
		move.w	#$0,(a3)

suite
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
voix2		;VOIX NO 2
		subq.w	#vitessetourne,(a3)		;on decremente voix no 1...

		lea	mt_voice2+$12,a3
		cmp.w	#$0,(a3)
		bge	suite2
		move.w	#$0,(a3)

suite2
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
voix3		;VOIX NO 3
		subq.w	#vitessetourne,(a3)		;on decremente voix no 2...

		lea	mt_voice3+$12,a3
		cmp.w	#$0,(a3)
		bge	suite3
		move.w	#$0,(a3)

suite3
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
voix4		;VOIX NO 4
		subq.w	#vitessetourne,(a3)		;on decremente voix no 3...

		lea	mt_voice4+$12,a3
		cmp.w	#$0,(a3)
		bge	suite4
		move.w	#$0,(a3)

suite4
		move.w	(a3),d2
		lsl.w	#$2,d2		;Multiplication par 4
		lea	table_equivalence,a1
		add.w	d2,a1
		move.l	(a1),a1
		;Passe parametres pour copie de blitter
		move.l	a0,source
		move.l	a1,destination
		bsr	copieblit
finvoix
		subq.w	#vitessetourne,(a3)		;on decremente voix no 4...
		rts
copieblit
w_blit		btst	#14,$2(a6)
		bne.s	w_blit
		move.l	source,$54(a6) 			;dest ecran
		move.l	destination,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$09f00000,$40(a6)
		move.l	#$00000024,$64(a6)
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

;************************************************************
	
