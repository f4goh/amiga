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

add_buffer_music=$a000+133040	;133040 offset de numeric
;il faut changer l'offset et mettre une adresse fixe...
add_music=$a002			;longueur de la musique
debut_piste_music1=31
nb_piste_music1=56
debut_piste_music2=89
nb_piste_music2=57

debprg:
	
	lea	debut_piste(pc),a0
	move.w	#debut_piste_music1,(a0)
	lea	nb_piste(pc),a0
	move.w	#nb_piste_music1,(a0)
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




