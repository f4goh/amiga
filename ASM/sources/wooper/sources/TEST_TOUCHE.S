test_touche	moveq	#0,d0
		move.b	$bfed01,d0
		btst	#3,d0
		beq	passe
		move.b	$bfec01,d0
		not.b	d0
		ror.b	#1,d0
		bset	#6,$bfee01
		bclr	#6,$bfee01
		cmp.b	#$50,d0		;f1
		beq	show_memoire
		cmp.b	#$51,d0		;f2
		beq	balaie_memoire
passe		rts

