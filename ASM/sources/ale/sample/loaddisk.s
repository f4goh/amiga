execbase =4
findtask = -294
addport = -354
remport = -360
openlib = -408
closelib= -414
opendev = -444
closedev= -450
doio	= -456

displayalert = -90


start:
	move.l	execbase,a6
	sub.l	a1,a1
	jsr	findtask(a6)		;chercher la tache
	move.l	d0,readreply+$10
	
	lea	readreply,a1
	jsr	addport(a6)

	
	lea	diskio,a1		;structure I/O
	move.l	#0,d0
	clr.l	d1
	lea	trddevice,a0
	jsr	opendev(a6)
	tst.l	d0
	bne	error

;on positionne la tete en piste 1 (22)
	move.l	#11*512,d0
	move.l	#diskbuff,a2
	move.l	#30,d4

piste:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	add.l	#22*512,d0
	add.l	#11*512,a2
	dbf	d4,piste

;	1 disquette = 512*11*80*2 octets	


	move.l	diskio+32,d6
	lea	diskio,a1
	move	#9,28(a1)
	move.l	#0,36(a1)
	jsr	doio(a6)

	lea	readreply,a1
	jsr	remport(a6)

	lea	diskio,a1
	jsr	closedev(a6)
	bsr	diskbuff
	rts


ecritpiste:

	lea	diskio,a1
	move.l	#readreply,14(a1)
	move	#3,28(a1)
	move.l	a2,40(a1)
	move.l	#11*512,36(a1)
	move.l	d0,44(a1)		;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts


lecturepiste:

	lea	diskio,a1
	move.l	#readreply,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#11*512,36(a1)
	move.l	d0,44(a1)		;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts


error:
	move.l	#5,d2
	rts

nbtrack:	dc.l	0
nbadresse:	dc.l	0
notrack		dc.l	0


trddevice:	dc.b	'trackdisk.device',0
		even

diskio:		ds.l	20,0
readreply:	ds.l	8,0

diskbuff:	ds.b	150000,0



;	nb track	0 	79
;	nb bloc 	0 	1759
;	nb secteur	0	11	1 secteur = 512 octets
;	1 disquette = 512*11*80*2 octets	


;	Quelques experiences sur les commandes du lecteur de disquette


;	LECTURE DE SECTEURS
;	lea	diskio,a1
;	move.l	#readreply,14(a1)
;	move	#2,28(a1)	;lecture de 2 secteurs
;	move.l	#diskbuff,40(a1)
;	move.l	#2*512,36(a1)	;ici 2 secteurs
;	move.l	#880*512,44(a1)	;piste 40
;	move.l	execbase,a6
;	jsr	doio(a6)


;	POSITIONNEMENT DE LA TETE DE LECTURE
;	lea	diskio,a1
;	move.l	#readreply,14(a1)
;	move	#10,28(a1)	;positionner la tete sur un track
;	move.l	#0,36(a1)	;aucune valeur a transferer
;	move.l	#880*512,44(a1) ;valeur de la track  (*)
;	move.l	execbase,a6
;	jsr	doio(a6)

;(*) en fait on positionne l'emplacement de l'octet sur la disquette
;ici la valeur de la piste est 880/22=40


