execbase =4
findtask = -294
addport = -354
remport = -360
openlib = -408
closelib= -414
opendev = -444
closedev= -450
doio	= -456

notrack =1

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

;on calcul le nombre de pistes pour sauver le programme

	move.l	#fin-debut,d4
	divs	#11*512,d4
	and.l	#$ff,d4		;$A0 est le maximum possible 160 dec
	addq	#1,d4
	move.w	d4,nbtrack

	move.l	#notrack,d0	;debut piste 0,face 1
	muls	#11*512,d0
	move.l	#debut,a2	;add debut save
;	move.l	#20,d4		;nb pistes/2 calculé plus haut

piste:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	ecritpiste
	movem.l (a7)+,d0-d7/a0-a6
	add.l	#11*512,d0
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


error:
	move.l	#5,d2
	rts

nbtrack	dc.w	0

trddevice:	dc.b	'trackdisk.device',0
		even

diskio:		ds.l	20
readreply:	ds.l	8


;	ici commence le programme a charger sur disk

debut:
	incbin	"df0:dessinec"
fin:


