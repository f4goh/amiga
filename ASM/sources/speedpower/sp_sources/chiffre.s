;LE SPEED POWER PROPOSE....
;Une routine de conversion ascii-valeur et inversement.C'est pas moi qui
;les ai faite mais elle marche.A noter que la methode de division pour
;SORTDEC n'est pas la meilleur(comparaison).Pas la peine d'assembler
;y a qu'au debugger qu'on voit qqch.

sorthex		move.l #$4a,d0
		clr.l d2
		move.l d0,d1
		lsr #4,d1
		bsr snibble
		move.b d1,d2
		lsl #8,d2
		move d0,d1
		bsr snibble
		or d1,d2
		rts
snibble		and #$f,d2
		add #$30,d2
		cmp #$3a,d2
		blo ok
		add #7,d2
sok		rts

sortdec		lea 	buffer,a0
		move.l 	#10000,d1
		move.l 	#$fffe7961,d0
		bge 	loop
		move.b	#"-",(a0)+
		neg.l	d0
loop		divu 	d1,d0
		bsr 	chiffre
		divu 	#10,d1
		cmp 	#1,d1
		bne 	loop
chiffre		add 	#$30,d0
		move.b 	d0,(a0)+
		clr.w 	d0
		swap 	d0
		rts
buffer		dcb.b 	50,0
		

entredec	clr.l d1
     		lea buffer(pc),a0
loop		move.b (a0)+,d0
     		beq fin   
trans		sub #$30,d0
		mulu #10,d1  ;d1<$ffff
     		add d0,d1
		bra loop
fin		rts
buffer		dc.b "655359",0  ;donc maxi=65535

