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
add_buffer=$10000
add_buffer_intro=$20000
add_buffer_demo=$30000
debut_piste_introale=146
nb_piste_introale=0
debut_piste_intro=2
nb_piste_intro=20
debut_piste_demo=23
nb_piste_demo=6
add_buffer_music=$a000+133040
add_music=$a002
debut_piste_music1=31
nb_piste_music1=56
debut_piste_music2=89
nb_piste_music2=57

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
;touche:	move.w	#0,d0
;	move.b	$bfec01,d0
;	not.b	d0
;	ror.b	#1,d0
;	cmp.b	#$59,d0
;	bne	touche

;	voir pour 7fc00
;	move.l	4,a6
;	move.l	#$7fc00,a1		;pointeur sur mem
;	move.l	#fin-debprg,d0
;	jsr	allocabs(a6)
;	move.w	#fin-debprg-1,d0
;	lea	debprg,a0
;	lea	$7fc00,a1
;copie	move.b	(a0)+,(a1)+
;	dbf	d0,copie
;	rts

;	jmp	$7fc00

;actuellement le boot marche comme ça ,mais il est difficile de
;savoir ou il se loge, tu pourras essayer de lancer mon
;intro après l'avoir correctement compiler car moi je sais pas ou
; est le bug bon alors a bientot   spectre

debprg:

;	lea	debut_piste(pc),a0
;	move.w	#debut_piste_introale,(a0)
;	lea	nb_piste(pc),a0
;	move.w	#nb_piste_introale,(a0)
;	lea	diskbuff(pc),a0
;	move.l	#add_buffer,(a0)
;	bsr	loader
;save_all:
;	move.l	execbase,a6
;	jsr	-132(a6)
;	lea	save_dmacon(pc),a0
;	move.w	$dff002,(a0)
;	or.w	#$c000,(a0)
;	jsr	add_buffer+36
	
	lea	debut_piste(pc),a0
	move.w	#debut_piste_intro,(a0)
	lea	nb_piste(pc),a0
	move.w	#nb_piste_intro,(a0)
	lea	diskbuff(pc),a0
	move.l	#add_buffer_intro,(a0)
	bsr	loader
;restore_all:
;	move.l	execbase,a6
;	move.w	#$7fff,$dff096
;	lea	save_dmacon(pc),a0
;	move.w	(a0),$dff096
;	lea	grname(pc),a1
;	moveq	#0,d0
;	jsr	-552(a6)
;	move.l	d0,a0
;	move.l	38(a0),$dff080
;	clr.w	$dff088
;	move.l	d0,a1
;	jsr	-414(a6)
;	jsr	-138(a6)
;	clr.l	d0

	jsr	add_buffer_intro+36

	lea	debut_piste(pc),a0
	move.w	#debut_piste_demo,(a0)
	lea	nb_piste(pc),a0
	move.w	#nb_piste_demo,(a0)
	lea	diskbuff(pc),a0
	move.l	#add_buffer_demo,(a0)
	bsr	loader
	jsr	add_buffer_demo+36

	cmp.b	#1,$c0
	bne	music2
	lea	debut_piste(pc),a0
	move.w	#debut_piste_music1,(a0)
	lea	nb_piste(pc),a0
	move.w	#nb_piste_music1,(a0)
	lea	diskbuff(pc),a0
	move.l	#add_buffer_music,(a0)
	bsr	loader
	jsr	add_music
	rts

music2	
	lea	debut_piste(pc),a0
	move.w	#debut_piste_music2,(a0)
	lea	nb_piste(pc),a0
	move.w	#nb_piste_music2,(a0)
	lea	diskbuff(pc),a0
	move.l	#add_buffer_music,(a0)
	bsr	loader
	jsr	add_music
	rts

loader	move.l	execbase,a6
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
	move.w	debut_piste(pc),d0
	muls	#11*512,d0
	move.l	diskbuff(pc),a2
	move.w	nb_piste(pc),d4

piste:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	add.l	#11*512,d0
	add.l	#11*512,a2
	dbf	d4,piste

;	1 disquette = 512*11*80*2 octets	

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
	rts

lecturepiste:
	lea	diskio(pc),a1
	lea	readreply(pc),a0
	move.l	a0,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#11*512,36(a1)
	move.l	d0,44(a1)		;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts
error:
	move.l	#0,d0
	rts

trddevice:	dc.b	'trackdisk.device',0
		even
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even
debut_piste	dc.w	0
nb_piste	dc.w	0
diskio:     ds.l 20
readreply:  ds.l  8
diskbuff	dc.l	0
fin:




