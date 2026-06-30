;-------------------------------------------------------------------
;-                 	Le Boot  de NUMERIC 3		       	   -
;-------------------------------------------------------------------

;	rem utiliser avec masterseka

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

diskbuff1=$10000
ecran = $a500

start:
	move.l	execbase,a6		;install trackdisk.device
	sub.l	a1,a1
	jsr	findtask(a6)		;find own task
	lea	readreply2,a0
	move.l	d0,$10(a0)		;and write to IO_ReadReply

	lea	readreply2,a1	;Get Port
	jsr	addport(a6)

	lea	diskio2,a1		;IO_structure in a1
	move.l	#drivenbr,d0
	clr.l	d1
	lea	trddevice2,a0	;open Trackdisk.device
	jsr	opendev(a6)
	tst.l	d0
	bne	error2

	lea	diskio2,a1
	lea	readreply2,a0
	move.l	a0,14(a1)
	move.w	#2,28(a1)		;read original boottrack
	move.l	#$40000,40(a1)
	move.l	#22*512,36(a1)
	move.l	#0*512,44(a1)
	move.l	execbase,a6
	jsr	doio(a6)

	bsr	checksum		;new checksum
	bsr	copy			;copy own routine

	lea	diskio2,a1		;and write new boottrack
	move.w	#3,28(a1)
	move.l	#$40000,40(a1)
	move.l	#22*512,36(a1)
	move.l	#0*512,44(a1)
	move.l	execbase,a6
	jsr	doio(a6)

	lea	diskio2,a1
	move.w	#9,28(a1)		;stop drive
	move.l	#0,36(a1)
	jsr	doio(a6)

	lea	readreply2,a1	;clear Port
	jsr	remport(a6)

	lea	diskio2,a1
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
	bra	save_all
	dc.b	"NU31"		;reconaissance disquette
save_all:
la:	move.l	#$dff000,a6

	bsr	plans_logo

;copper initialise
	move.w	#$7fff,$96(a6)
	lea	copperlist(pc),a0
	move.l	a0,$80(a6)
	clr.w	$88(a6)
	clr.l	$144(a6)
;dma active
	move.w	#$83d0,$96(a6)
ici	bsr	menu
	bsr	load_zoom	
ss	btst	#6,$bfe001
	bne	ss
restore_all
;	jmp	$adresse_zoom		;saut zoom
	rts
;-------------------------------- pour les 4 plans logo
plans_logo
	move.l	#ecran,a0
	move.l	#[40*256]-1,d0
clear	clr.b	(a0)+
	dbf	d0,clear

	lea	bmap(pc),a0
	move.l	#ecran,a1
	move.l	a1,d0
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

 	move.l	#ecran,a0
 	add.l	#[120*40]+12,a0
	lea	loading(pc),a1
	move.l	#8-1,d1
vert	move.l	#16-1,d0
horiz	move.b	(a1)+,(a0)+
	dbf	d0,horiz
	add.w	#24,a0
	dbf	d1,vert
	rts
;------------------------------------------------------------------------
menu
vbl
		cmp.b	#-1,$dff006
		bne	vbl
souris		btst	#6,$bfe001
		bne	souris
		rts
;------------------------------------------------------------------------
load_zoom	
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
	move.l	#2*11*512,d3		;depart piste
	move.l	#diskbuff1,a2		;adresse zoom
	move.l	#6-1,d4			;nb demi-pistes

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
	rts

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
	dc.l	0,0
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000,$01001200

		dc.w	$180,$000
		dc.w	$9a01,$fffe,$180,$300
		dc.w	$9b01,$fffe,$180,$520
		dc.w	$9c01,$fffe,$180,$740
		dc.w	$9d01,$fffe,$180,$960
		dc.w	$9e01,$fffe,$180,$b82
		dc.w	$9f01,$fffe,$180,$da4
		dc.w	$a001,$fffe,$180,$fc6
		dc.w	$a101,$fffe,$180,$fe8
		dc.w	$a201,$fffe,$180,$000
		dc.w	$a401,$fffe,$182,$f8e
		dc.w	$a501,$fffe,$182,$f6c
		dc.w	$a601,$fffe,$182,$d4a
		dc.w	$a701,$fffe,$182,$b28
		dc.w	$a801,$fffe,$182,$906
		dc.w	$a901,$fffe,$182,$704
		dc.w	$aa01,$fffe,$182,$502
		dc.w	$ad01,$fffe,$180,$fe8
		dc.w	$ae01,$fffe,$180,$fc6
		dc.w	$af01,$fffe,$180,$da4
		dc.w	$b001,$fffe,$180,$b82
		dc.w	$b101,$fffe,$180,$960
		dc.w	$b201,$fffe,$180,$740
		dc.w	$b301,$fffe,$180,$520
		dc.w	$b401,$fffe,$180,$300
		dc.w	$b501,$fffe,$180,$000
		dc.l	-2
;------------------------------------------------------------------------
loading		incbin	"df0:loading.raw"
;------------------------------------------------------------------------
;ecran	dcb.b	40*256
end

