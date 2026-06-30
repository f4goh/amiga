;--------------------------	interface I2C

; scl sur cia-b bit pa0		sortie
; sda sur cia-b bit pa1		entree sortie
; ddra	= #$1	si scl a 1 et sda 0
; ddra	= #$3	si scl a 1 et sda 1

; trig sur cia-b bit pa2

; adresses cia b

pra=$bfd000		;données port
ddra=$bfd200		;direction port  sortie 1,entree 0

scl=0
sda=1
trig=2

debut
	btst	#6,$bfe001
	bne	debut
	or.b	#%111,ddra		;scl,sda,trig a 1

	bsr	write_data


	rts

donnees
	dc.b	$40,1-1,$0f,0

write_data
reset
	bset	#trig,pra		
	bset	#sda,pra		
	bset	#scl,pra
	bclr	#trig,pra
ecriture
	lea	donnees,a0
	move.b	(a0),d0
	bsr	start
	tst.b	d0
	bne	end
	add.l	#1,a0
	move.b	(a0),d1

trans	add.l	#1,a0
	move.b	(a0),d0
	bsr	mtdat
	tst.b	d0
	bne	end
	dbf	d1,trans
end	bsr	stop
	rts

start	bclr	#sda,pra
	nop
	nop
	nop
	nop
	bclr	#scl,pra
mtdat
	move.l	#8-1,d2
	nop
mstdat
	lsl.w	#1,d0
	and.w	#$1ff,d0
	clr.l	d3
	move.w	d0,d3
	lsr.w	#8,d3
	tst.b	d3
	bne	bit_a_1
	bclr	#sda,pra
	bra	suite_mstdat
bit_a_1
	bset	#sda,pra
suite_mstdat
	bset	#scl,pra
	nop	
	nop	
	nop	
	nop	
	nop	
	bclr	#scl,pra
	nop
	dbf	d2,mstdat
	bset	#sda,pra
	nop
	nop
	bset	#scl,pra
	nop
	and.b	#%11111101,ddra
	move.b	pra,d0
	and.b	#%10,d0
	nop
	nop
	or.b	#%111,ddra		;scl,sda,trig a 1
	bclr	#sda,pra
	nop
	nop
	bclr	#scl,pra
	rts	
stop
	bclr	#sda,pra
	bset	#scl,pra
	nop
	nop
	nop
	nop
	nop
	bset	#sda,pra
	bset	#trig,pra
	rts

