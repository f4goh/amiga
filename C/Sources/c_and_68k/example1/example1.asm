	idnt	"example1.c"
	opt o+,ol+,op+,oc+,ot+,oj+,ob+,om+
	section	"CODE",code
	public	_main
	cnop	0,4
_main
	movem.l	l4,-(a7)
	moveq	#2,d1
	moveq	#3,d0
	jsr	_add_two_numbers
	move.l	d0,d2
	move.l	d2,d3
	move.l	d3,-(a7)
	pea	l3
	jsr	_printf
	moveq	#0,d0
	addq.w	#8,a7
l1
l4	reg	d2/d3
	movem.l	(a7)+,d2/d3
l6	equ	8
	rts
	cnop	0,4
l3
	dc.b	84
	dc.b	104
	dc.b	101
	dc.b	32
	dc.b	114
	dc.b	101
	dc.b	115
	dc.b	117
	dc.b	108
	dc.b	116
	dc.b	32
	dc.b	111
	dc.b	102
	dc.b	32
	dc.b	51
	dc.b	43
	dc.b	50
	dc.b	32
	dc.b	105
	dc.b	115
	dc.b	32
	dc.b	37
	dc.b	108
	dc.b	100
	dc.b	10
	dc.b	0
	public	_printf
	public	_add_two_numbers
