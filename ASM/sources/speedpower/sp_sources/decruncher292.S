;Decrunch Header for STC v2.92
;© 1991 by Mr.Spiv of CAVE
;

destination=	$40000


j:		lea	$dff000,a6
		lea	data(pc),a4		;crunched file
		lea	12(a4),a5
		lea	destination,a0
		add.l	8(a4),a5		;bitlen
		move.l	a0,a3
		add.l	4(a4),a0		;lenght
		moveq	#127,d3
		moveq	#0,d4
		moveq	#3,d5
		moveq	#7,d6
		move.b	3(a4),d4		;scanbit

		move.l	-(a5),d7
deloop:		lsr.l	#1,d7
		bne.s	not_empty0
		move.l	-(a5),d7
		roxr.l	#1,d7
not_empty0:	bcc.s	copydata
		moveq	#0,d2
bytekpl:	move	d5,d1
		bsr.s	getbits
		add	d0,d2
		cmp	d6,d0
		beq.s	bytekpl
		subq	#1,d2
byteloop:	move	d6,d1
bytebits:	lsr.l	#1,d7
		bne.s	not_empty2
		move.l	-(a5),d7
		roxr.l	#1,d7
not_empty2:	roxr.b	#1,d0
		dbf	d1,bytebits
		move.b	d0,-(a0)
		dbf	d2,byteloop
		bra.s	test

copydata:	moveq	#2-1,d1
		bsr.s	getfast
		moveq	#0,d1
		move.l	d0,d2
		move.b	0(a4,d0.w),d1
		cmp	d5,d0
		bne.s	copyfast
		lsr.l	#1,d7
		bne.s	not_empty3
		move.l	-(a5),d7
		roxr.l	#1,d7
not_empty3:	bcs.s	copykpl

copykpl127:	move	d6,d1
		bsr.s	getbits
		add	d0,d2
		cmp	d3,d0
		beq.s	copykpl127
		add	d6,d2
		add	d6,d2
		bra.s	copyskip

copykpl:	move	d5,d1
		bsr.s	getbits
		add	d0,d2
		cmp	d6,d0
		beq.s	copykpl
copyskip:	move	d4,d1
copyfast:	addq	#1,d2
		bsr.s	getfast
copyloop:	move.b	0(a0,d0.w),-(a0)
		dbf	d2,copyloop
test:		cmp.l	a0,a3
		blo.s	deloop
		rts

getbits:	subq	#1,d1
getfast:	moveq	#0,d0
bitloop:	lsr.l	#1,d7
		bne.s	not_empty1
		move.l	-(a5),d7
		move	d7,$180(a6)
		roxr.l	#1,d7
not_empty1:	addx.l	d0,d0
		dbf	d1,bitloop
		rts

;-------------- crunched data
data:

