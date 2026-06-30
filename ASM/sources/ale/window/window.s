
; test d'une librairy
; ouverture et fermeture d'une fenetre

execbase=4
openlib=-408
closelib=-414
open=-30
close=-36


start:

	move.l	execbase,a6
	lea	dosname,a1
	moveq	#0,d0
	jsr	openlib(a6)
	move.l	d0,dosbase
	beq error

	move.l	#nomfenetre,d1
	move.l 	#1005,d2
	move.l	dosbase,a6
	jsr	open(a6)
	tst.l	d0
	beq error
	move.l	d0,handle

ret1:	btst	#6,$bfe001
	bne	ret1
	
	move.l	handle,d1
	move.l	dosbase,a6
	jsr	close(a6)
	
	move.l	execbase,a6
	move.l	dosbase,a1
	jsr closelib(a6)

	rts

error:
	rts
nomfenetre:
	dc.b	'con:0/10/640/200/** HALL OF FAME **',0
handle:
	dc.l 	1
dosname:
	dc.b	'dos.library',0
dosbase:
	dc.l	1

