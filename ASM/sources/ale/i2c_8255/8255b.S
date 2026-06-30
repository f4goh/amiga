s:	clr.l d0
	move.b #$8b,$bfb301
	lea test,a0
retour:	move.b 0(a0,d0.b),$bfb001
	add.b #1,d0
	cmp.b #2,d0
	bne retour
	move.b #0,d0
	btst #6,$bfe001
	bne retour
	rts
test: dc.b 0,255
