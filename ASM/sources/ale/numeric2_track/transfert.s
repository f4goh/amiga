start
	jmp	ale
buffer:
	incbin	"df1:n2"
fin
ale	lea	$4000,a1
	lea	buffer+32,a0
	move.l	#fin-buffer,d1
stock	move.b	(a0)+,(a1)+
	dbf	d1,stock

	jmp	$4000

	
