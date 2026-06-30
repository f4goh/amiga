start:  	move.l 	#tables,$dff0b0
		move.w 	#6,$dff0b4
		move.w 	#64,$dff0b8
		move.l 	#tablem,$dff0a0
		move.w 	#8,$dff0a4
		move.w 	#$c000,$dff0a6
		move.w 	#$8010,$dff09e
		move.w 	#$8203,$dff096
wait:		btst	#6,$bfe001
		bne.s	wait
		move.w	#10,$dff09e
		move.w	#3,$dff096
		rts
tables:
		dc.b	0,40,80,120,80,40,0,-40,-80,-120,-80,-40


tablem:	
		dc.w	600,650,690,720,730,720,690,650,600,550
		dc.w	510,480,470,480,510,550

		
