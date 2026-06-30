s:	clr.l d0
	clr.l d1
	move.b #$8b,$bfb301
retour:	move.w #$ffff,d1
ret:	sub.w #1,d1
	bne ret
	move.b d0,$bfb001
	add.b #1,d0
	cmp.b #$100,d0
	bne retour
	rts
