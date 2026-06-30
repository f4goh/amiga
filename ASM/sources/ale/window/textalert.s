execbase  = 4
openlib   =-408
closelib  =-414
displayalert = -90


start:
	bsr 	openint
	bsr	alert
	move.l	d0,d5
;wait:
;	btst	#6,$bfe001
;	bne.s	wait	
	bsr 	closeint
	clr	d0
	rts


openint:
	move.l	execbase,a6
	lea	intname,a1
	jsr	openlib(a6)
	move.l	d0,intbase
	rts

closeint:
	move.l	execbase,a6
	move.l	intbase,a1
	jsr	closelib(a6)
	rts

alert:
	move.l	intbase,a6
	move.l	#0,d0
	lea	text,a0
	move.l	#200,d1
	jsr	displayalert(a6)
	move.l	d0,d5
	rts

intname:
	dc.b	"intuition.library"
	even
intbase:
	dc.l	0
text:
	dc.b	0
	dc.b	20
	dc.b	20
	dc.b	"                                  TITRE"
	dc.b	0
	dc.b	1
	dc.b	0
	dc.b	"      ligne 1 "
	dc.b	0
	dc.b	1
	dc.b	20
	dc.b	"      ligne 2 "
	dc.b	0
	dc.b	1
	dc.b	40
	dc.b	"      ligne 3 "
	dc.b	0
	dc.b	1
	dc.b	60
	dc.b	"      ligne 4 "
	dc.b	0
	dc.b	1
	dc.b	80
	dc.b	"      ligne 5 "
	dc.b	0
	dc.b	1
	dc.b	100
	dc.b	"      ligne 6 "
	dc.b	0
	dc.b	1
	dc.b	120
	dc.b	"      ligne 7 "
	dc.b	0
	dc.b	1
	dc.b	140
	dc.b	"      ligne 8 "
    ;dc.b	0
	jsr	openlib(a6)
	move.l	d0,intbase
	rts

