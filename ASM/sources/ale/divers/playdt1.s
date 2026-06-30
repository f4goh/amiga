audloc0=$DFF0A0	
audlen0=$DFF0A4
audper0=$DFF0A6
audvol0=$DFF0A8

intenaw=$DFF09A
dmaconw=$DFF096

execbase =4
findtask = -294
addport = -354
remport = -360
openlib = -408
closelib= -414
opendev = -444
closedev= -450
doio	= -456


start:
;test de touche
	move.w	#0,d0
	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	bne	start
;init disk
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
	move.l	#2*11*512,d3
	move.l	#14,d4			;nb track29  28/2
	lea	diskbuff1,a2
	bsr	charge
	bsr	playdigit1
	add.l	#22*512,d3
	subq	#1,d4

piste:
	lea	diskbuff2,a2
	bsr	charge
	bsr	replace1
	bsr	pause
	add.l	#22*512,d3
	subq	#1,d4
	cmp.b	#0,d4
	beq	fin
	lea	diskbuff1,a2
	bsr	charge
	bsr	replace2
	bsr	pause
	add.l	#22*512,d3
	subq	#1,d4
	cmp.b	#0,d4
	beq	fin
	bra	piste
charge:
	movem.l d0-d7/a0-a6,-(a7)
	bsr	lecturepiste
	movem.l (a7)+,d0-d7/a0-a6
	rts

;	1 disquette = 512*11*80*2 octets	

fin:
	move.w 	#3,dmaconw
;arret disk
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
pause:
	clr.l	d0
b1:	add.l	#1,d0
	cmp.l	#$15fff,d0	;precedent et trop $17fff
	bne	b1
	rts


playdigit1:
	move.w 	#$000f,dmaconw
	move.L	 #diskbuff1,audloc0	
	move.L 	#diskbuff1,audloc0+16	
	move.w 	#(22*512)/2,D0
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#10200,D0
	bsr 	convertir
	rts

replace1:
	move.L	 #diskbuff2,audloc0	
	move.L 	#diskbuff2,audloc0+16	
	rts

replace2:
	move.L	 #diskbuff1,audloc0	
	move.L 	#diskbuff1,audloc0+16	
	rts

convertir:
	move.l 	#715909,d1
	divu 	d0,d1
	lsr 	#1,d1		
	clr.l 	d0		
	addx 	d1,d0
	mulu 	#10,d0 
	move.w 	d0,audper0
	move.w 	d0,audper0+16
	move.w 	#$8203,dmaconw
	clr.w	d0
	rts
		
lecturepiste:
	lea	diskio,a1
	move.l	#readreply,14(a1)
	move	#2,28(a1)
	move.l	a2,40(a1)
	move.l	#22*512,36(a1)
	move.l	d3,44(a1)		;piste n
	move.l	execbase,a6
	jsr	doio(a6)
	rts

error:
	clr.l	d0
	rts

trddevice:	dc.b	'trackdisk.device',0
		even
diskio:		dcb.l	20,0
readreply:	dcb.l	8,0
	section music,code_c
diskbuff1:	dcb.l	22*512,0
diskbuff2:	dcb.l	22*512,0




