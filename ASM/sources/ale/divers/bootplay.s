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
audloc0=$DFF0A0	
audlen0=$DFF0A4
audper0=$DFF0A6
audvol0=$DFF0A8

intenaw=$DFF09A
dmaconw=$DFF096
diskbuff1=$1c000
diskbuff2=$1c000+[22*512]


start:
	move.l	execbase.w,a6		;install trackdisk.device
	sub.l	a1,a1
	jsr	findtask(a6)		;find own task
	lea	readreply,a0
	move.l	d0,$10(a0)		;and write to IO_ReadReply

	lea	readreply,a1	;Get Port
	jsr	addport(a6)

	lea	diskio,a1		;IO_structure in a1
	move.l	#drivenbr,d0
	clr.l	d1
	lea	trddevice,a0	;open Trackdisk.device
	jsr	opendev(a6)
	tst.l	d0
	bne	error2

	lea	diskio,a1
	lea	readreply,a0
	move.l	a0,14(a1)
	move.w	#2,28(a1)		;read original boottrack
	move.l	#$40000,40(a1)
	move.l	#22*512,36(a1)
	move.l	#0*512,44(a1)
	move.l	execbase.w,a6
	jsr	doio(a6)

	bsr	checksum		;new checksum
	bsr	copy			;copy own routine

	lea	diskio,a1		;and write new boottrack
	move.w	#3,28(a1)
	move.l	#$40000,40(a1)
	move.l	#22*512,36(a1)
	move.l	#0*512,44(a1)
	move.l	execbase.w,a6
	jsr	doio(a6)

	lea	diskio,a1
	move.w	#9,28(a1)		;stop drive
	move.l	#0,36(a1)
	jsr	doio(a6)

	lea	readreply,a1	;clear Port
	jsr	remport(a6)

	lea	diskio,a1
	jsr	closedev(a6)		;close trackdisk.device
error2:
	rts				;end


checksum:
	lea	BootBlockIntro+8(pc),a0	;start for new checksum
	lea	$3f8(a0),a1		;end of bootblock
	clr.l	d0
	clr.l	d1
	move.w	#$444f,d0		;'DO' in d0
	move.w	#$5300,d1		;'S ' in d1
l1:	add.w	(a0)+,d0		;add 1 word to d0
	bcs.S	m1			;overflow ?
w1:	add.w	(a0)+,d1		;add 1 word to d1
	bcs.S	m2			;overflow ?
w2:	cmp.l	a0,a1			;end reached ?
	bne.S	l1			;if not : continue
	not.w	d0			;invert d0
	not.w	d1			;invert d1
	swap	d0			;LO-word to HI-word
	move.w	d1,d0			;d1 new Lo-word of d0
	move.l	d0,BootBlockIntro+4	;write checksum
	rts				;end
m1:	add.w	#1,d1			;overflow in d0: increment d1
	bra.S	w1
m2:	add.w	#1,d0			;overflow in d1: increment d0
	bra.S	w2

copy:	lea	BootBlockIntro(pc),a0	;startadress of copy
	lea	$40000,a1		;destinationadress of copy
	move.w	#$3ff,d0		;length: 1024 byte
loopy:	move.b	(a0)+,(a1)+		;copyloop
	dbf	d0,loopy
	rts				;End
trddevice2:	dc.b	'trackdisk.device',0
		even
diskio2:     ds.l 20
readreply2:  ds.l  8


deb:
BootBlockIntro:
	dc.l $444f5300,0,$370		;'DOS',checksum,Rootblock
**************HERE THE BOOT PROGRAM**************
;test de touche
	move.w	#0,d0
tou1	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	bne	tou1
;init disk
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
	move.l	#75,d4			;nb track75
	move.l	#diskbuff1,a2
	bsr	charge
	bsr	playdigit1
	add.l	#22*512,d3
	subq	#1,d4
piste:
	move.l	#diskbuff2,a2
	bsr	charge
	bsr	replace1
	bsr	pause
	add.l	#22*512,d3
	subq	#1,d4
	cmp.b	#0,d4
	beq	lafin
	move.l	#diskbuff1,a2
	bsr	charge
	bsr	replace2
	bsr	pause
	add.l	#22*512,d3
	subq	#1,d4
	cmp.b	#0,d4
	beq	lafin
	bra	piste
charge:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	rts

;	1 disquette = 512*11*80*2 octets	

lafin:
	move.w 	#3,dmaconw
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
again:	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	bne	again
	rts

pause:
	clr.l	d0
b1:	add.l	#1,d0
	cmp.l	#$15fff,d0	;precedent et trop $17fff
	bne	b1
	rts


playdigit1:
	move.w 	#$000f,dmaconw
	move.l	#diskbuff1,audloc0	
	move.l	#diskbuff1,audloc0+16	
	move.w 	#[22*512]/2,D0
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#10653,D0		;essai good avec 10200
	bsr 	convertir
	rts

replace1:
	move.l	#diskbuff2,a0
	move.l	a0,audloc0	
	move.l	a0,audloc0+16	
	rts

replace2:
	move.l	#diskbuff1,a0
	move.l	a0,audloc0	
	move.l	a0,audloc0+16	
	rts

convertir:
	move.l 	#715909,d1
	divu 	d0,d1
	lsr 	#1,d1		
	clr.l 	d0		
	addx 	d1,d0
	mulu 	#10,d0 
	move.w 	d0,audper0
	move.w 	d0,audper0+16
	move.w 	#$8203,dmaconw
	clr.w	d0
	rts

lecturepiste:
	lea	diskio(pc),a1
	lea	readreply(pc),a0
	move.l	a0,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#22*512,36(a1)
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


