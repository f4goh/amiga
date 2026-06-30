audloc0=$DFF0A0	
audlen0=$DFF0A4
audper0=$DFF0A6
audvol0=$DFF0A8

intenaw=$DFF09A
dmaconw=$DFF096

execbase =4
findtask = -294
addport = -354
remport = -360
openlib = -408
closelib= -414
opendev = -444
closedev= -450
doio	= -456

taille2=512

start:
	move.w	#0,d0
	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	bne	start

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
	move.l	#2*11*512,d0
	move.l	#diskbuff,a2
	move.l	#$29,d4			;nb track29

piste:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
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

playdigit:
	move.w 	#$000f,dmaconw
	move.L	 #diskbuff+$70,audloc0	
	move.L 	#diskbuff+$70,audloc0+16	
	move.w 	#$ffff,D0		;225000
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#10200,D0
	bsr 	convertir	
stop:	btst	#6,$bfe001
	bne	stop
	move.w 	#3,dmaconw
	rts

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
;boucle:	addx	d2,d0
;	cmp.w	#$ffff,d0
;	bne.s	boucle

;	move.L	 #buffer2,audloc0	
;	move.L 	#buffer2,audloc0+16	
;	move.w 	taille2/2,D0	
;	move.w 	d0,audlen0	
;	move.w 	d0,audlen0+16	
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

diskio:		ds.l	20
readreply:	ds.l	8
buffer2:	ds.l	512
diskbuff:	dc.l	0



