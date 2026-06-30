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
	move.l	#debut,a2
	move.l	#30,d4

piste:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	ecritpiste
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


;lecture du programme
;	lea	diskio,a1
;	move.l	#readreply,14(a1)
;	move	#2,28(a1)
;	move.l	#diskbuff,40(a1)
;	move.l	#2*512,36(a1)
;	move.l	#990*512,44(a1)		;piste 45
;	move.l	execbase,a6
;	jsr	doio(a6)


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

diskbuff:	ds.b	1024,0






audloc0=$DFF0A0	
audlen0=$DFF0A4
audper0=$DFF0A6
audvol0=$DFF0A8
; longueur des samples
soundlength1=33830
soundlength2=19832
soundlength3=55208
soundlength4=31888
; frequence de restitution
samplefreq1=25208
samplefreq2=16726
samplefreq3=8363
samplefreq4=16726


intenaw=$DFF09A
dmaconw=$DFF096
drb1=$BFE101  
ddrb1=$BFE301
touche=$BFE001

debut:

wait:	move.w	#0,d0
	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	beq	playfeu
	cmp.b	#$58,d0
	beq	playptc
	cmp.b	#$57,d0
	beq	playexp
	cmp.b	#$56,d0
	beq	playtrou
	cmp.b	#$55,d0
	beq	stop
	clr.l	d0
	
retour:	btst 	#6,touche
	bne.s 	wait

stop:	move.w 	#3,dmaconw
	btst 	#6,touche
	bne.s 	wait
	rts


playfeu:
	move.w 	#$000f,dmaconw
	move.L	 #datafeu,audloc0	
	move.L 	#datafeu,audloc0+16	
	move.w 	#soundlength1/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq1,D0
	bsr 	convertir	
	bra	retour

playptc:
	move.w 	#$000f,dmaconw
	move.L	 #dataptc,audloc0	
	move.L 	#dataptc,audloc0+16	
	move.w 	#soundlength2/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq2,D0
	bsr 	convertir	
	bra	retour
playexp:
	move.w 	#$000f,dmaconw
	move.L	 #dataexp,audloc0	
	move.L 	#dataexp,audloc0+16	
	move.w 	#soundlength3/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq3,D0
	bsr 	convertir	
	bra	retour
playtrou:
	move.w 	#$000f,dmaconw
	move.L	 #datatrou,audloc0	
	move.L 	#datatrou,audloc0+16	
	move.w 	#soundlength4/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq4,D0
	bsr 	convertir	
	bra	retour


convertir:
	move.l 	#715909,D3	
	divu 	D0,D3		
	lsr 	#1,D3		
	clr.l 	D0		
	addx 	D3,D0
	mulu 	#10,D0 
	move.w 	d0,audper0
	move.w 	d0,audper0+16
	move.w 	#$8203,dmaconw
	move.w	#0001,d2
	clr.w	d0
boucle:	addx	d2,d0
	cmp.w	#$ffff,d0
	bne.s	boucle

	move.L	 #buffer2,audloc0	
	move.L 	#buffer2,audloc0+16	
	move.w 	#taille2/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	rts
		

datafeu:	incbin "df0:feu"	;sample rate 25208
dataptc:	incbin "df0:ptc"	;	     16726
dataexp:	incbin "df0:exp"	;	     8363
datatrou:	incbin "df0:trou"	;	     16726


taille2= 1024
buffer2:dcb.l	taille2,0
fin:





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


