
execbase= 4
long_ecr=40
long_cray=1
haut_cray=2	;13
nb_ecran=1
taille_ecran=40*256
haut_logo=62
larg_logo=10
haut_logo2=83
larg_logo2=32
findtask = -294
addport = -354
remport = -360
openlib = -408
closelib= -414
opendev = -444
closedev= -450
doio	= -456
nb_piste_a_charger = 20
adresse_numeric=$a500-32
adresse_numeric_cruncher=$a500-32-10		;on sait pas
offset	=  43542	
mt_data3 = $60000
mt_data4 = mt_data3+$3b6

;	org	$50000
start:
	bsr	chargeur
	bsr	decrunch_numeric

	jmp	$a500
	rts

decrunch:	lea	$dff000,a6
		lea	data,a4		;crunched file
		lea	12(a4),a5
		move.l	#mt_data3,a0
ca_continue:
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
		move	d7,$182(a6)	;couleur du decrunch
		roxr.l	#1,d7
not_empty1:	addx.l	d0,d0
		dbf	d1,bitloop
		rts
;--------------------------------------------decrunch pour numeric
decrunch_numeric:
		lea	$dff000,a6
		move.l	#adresse_numeric_cruncher,a4	;crunched file
		lea	12(a4),a5
		move.l	#adresse_numeric,a0
		bra	ca_continue
chargeur
	move.l	execbase,a6
	sub.l	a1,a1
	jsr	findtask(a6)		;chercher la tache
	move.l	d0,readreply+$10
	
	lea	readreply,a1
	jsr	addport(a6)

	
	lea	diskio,a1		;structure I/O
	move.l	#0,d0
	clr.l	d1
	lea	trddevice,a0
	jsr	opendev(a6)
	tst.l	d0
	bne	error

;on positionne la tete en piste 1 (22)
	move.l	#12*11*512,d0		;piste demarre numeric
	move.l	#adresse_numeric_cruncher,a2
	move.l	#nb_piste_a_charger,d4

piste:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	add.l	#11*512,d0
	add.l	#11*512,a2
	dbf	d4,piste

;	1 disquette = 512*11*80*2 octets	


	move.l	diskio+32,d6
	lea	diskio,a1
	move	#9,28(a1)
	move.l	#0,36(a1)
	jsr	doio(a6)

	lea	readreply,a1
	jsr	remport(a6)

	lea	diskio,a1
	jsr	closedev(a6)
	rts

lecturepiste:

	lea	diskio,a1
	move.l	#readreply,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#11*512,36(a1)
	move.l	d0,44(a1)		;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts

error:
	move.l	#5,d2
	rts

nbtrack:	dc.l	0
nbadresse:	dc.l	0
notrack		dc.l	0


trddevice:	dc.b	'trackdisk.device',0
		even
	
diskio:		ds.l	20
readreply:	ds.l	8

;data decruncher
;-------------- crunched data
data:	incbin	"df1:n3"

	;even
end

