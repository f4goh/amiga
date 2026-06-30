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
;====================
KickSumData=-612
KickMemPtr=546
KickTagPtr=550
KickCheckSum=554
;====================

diskbuff1=$50000

begin:
	move.l	execbase,a6		;install trackdisk.device
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
	move.l	execbase,a6
	jsr	doio(a6)

	bsr	checksum		;new checksum
	bsr	copy			;copy own routine

	lea	diskio,a1		;and write new boottrack
	move.w	#3,28(a1)
	move.l	#$40000,40(a1)
	move.l	#22*512,36(a1)
	move.l	#0*512,44(a1)
	move.l	execbase,a6
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
;	move.w	#0,d0
;tou1	move.b	$bfec01,d0
;	not.b	d0
;	ror.b	#1,d0
;	cmp.b	#$59,d0
;	bne	tou1

	lea	start(pc),a0
	lea	start_offset(pc),a1
	move.l	a0,(a1)
	lea	debut_reset(pc),a0
	lea	debut_offset(pc),a1
	move.l	a0,(a1)
	lea	spect(pc),a1
	move.l	a0,(a1)
	lea	pour_KickTagPtr(pc),a1
	move.l	a0,(a1)
	lea	fin_reset(pc),a0
	lea	fin_offset(pc),a1
	move.l	a0,(a1)
	move.l 	$4,a6
	lea 	mem_list(pc),a0
	move.l 	a0,KickMemPtr(a6)
	lea 	pour_KickTagPtr(pc),a0
	move.l 	a0,KickTagPtr(a6)
	jsr 	KickSumData(a6)
	move.l 	d0,KickCheckSum(a6)

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
	move.l	#diskbuff1,a2
	move.l	#6-1,d4

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
	jmp	$50000		;saut a l'intro

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
	even
debut_reset:
	dc.w 	$4afc

debut_offset:
	dc.l 	debut_reset

fin_offset:
	dc.l 	fin_reset
	dc.b 	%00000001
	dc.b 	0
	dc.b 	1
	dc.b 	-59
	dc.l 	name_res
	dc.l 	com_name_res

start_offset:
	dc.l 	start

mem_list:
	dcb.b 	8,0
	dc.b 	16
	dc.b 	0
	dc.l 	name_node
	dc.w 	$01
spect	dc.l 	debut_reset
	dc.l 	fin_reset-debut_reset
	dc.l 	0

com_name_res:
	dc.b 	'fuck you',0
	even

name_res:
	dc.b 	'ripper',0
	even

name_node:
	dc.b 	'a la soupe',0
	even

pour_KickTagPtr:
	dc.l 	debut_reset
	dc.l 0
	even

start:
		lea	$2c190,a0
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#$100,d1
efface1:	clr.l	(a0)+
		dbf	d1,efface1
		lea	$2c300,a0
		move.l	#$100,d1
efface1b:	clr.l	(a0)+
		dbf	d1,efface1b
		lea	$45000,a0
		move.l	#$100,d1
efface2:	clr.l	(a0)+
		dbf	d1,efface2
		lea	$55000,a0
		move.l	#$100,d1
efface3:	clr.l	(a0)+
		dbf	d1,efface3
		lea	$60000,a0
		move.l	#$100,d1
efface4:	clr.l	(a0)+
		dbf	d1,efface4
		rts
fin_reset:

trddevice:	dc.b	'trackdisk.device',0
	even
diskio:		ds.l	20
readreply:	ds.l	8
fin:
