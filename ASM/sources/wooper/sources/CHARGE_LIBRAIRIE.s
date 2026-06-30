openlib=-408

	section	code,code
ouvre
	move.l	4,a6
	lea	nom_librairie,a1
	moveq	#0,d0
	jsr	openlib(a6)
	move.l	d0,dosbase
	beq	error

error	rts

	section	data,data

nom_librairie	dc.b	'dos.library',0
	even
dosbase	dc.l	0
