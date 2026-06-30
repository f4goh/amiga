execbase = 4
findtask = -294
addport  = -354
remport  = -360
openlib  = -408
closelib = -414
opendev  = -444
closedev = -450
doio     = -456
allocmem = -198
allocabs = -204
forbid   = -132
drivenbr=0

diskbuff1=$2000

start
	move.l	execbase,a6
	sub.l	a1,a1
	jsr	findtask(a6)		;chercher la tache
	lea	readreply(pc),a0
	add	#$10,a0
	move.l	d0,(a0)
	lea	readreply(pc),a1
	jsr	addport(a6)
	lea	diskio(pc),a1		;structure I/O
	move.l	#0,d0
	clr.l	d1
	lea	trddevice(pc),a0
	jsr	opendev(a6)
	tst.l	d0
	bne	error

;on positionne la tete en piste 1 (22)
	move.l	#2*11*512,d3
	move.l	#diskbuff1,a2
	move.l	#32-1,d4

charge:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	add.l	#11*512,a2
	add.l	#11*512,d3
	dbf	d4,charge

;	1 disquette = 512*11*80*2 octets	

;arret disk
	lea	diskio(pc),a0
	add	#32,a0
	move.l	(a0),d6
	lea	diskio(pc),a1
	move	#9,28(a1)
	move.l	#0,36(a1)
	jsr	doio(a6)
	lea	readreply(pc),a1
	jsr	remport(a6)
	lea	diskio(pc),a1
	jsr	closedev(a6)
	clr.l	d0
	jmp	$2000		;saut a l'intro

lecturepiste:
	lea	diskio(pc),a1
	lea	readreply(pc),a0
	move.l	a0,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#11*512,36(a1)
	move.l	d3,44(a1)		;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts
error:
	clr.l	d0
	rts

trddevice:	dc.b	'trackdisk.device',0
		even
diskio:		ds.l	20
readreply:	ds.l	8
fin:


