s:	clr.l d0
	clr.l d1
	move.b #$8b,$bfb301
ret:	move.b #$ff,$bfb001
	move.b #$00,$bfb001
	bra ret
