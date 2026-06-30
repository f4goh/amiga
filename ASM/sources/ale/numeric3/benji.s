
; ***********************************************************
; *                     LE ROYAUME                          *
; ***********************************************************


audloc0=$DFF0A0	
audlen0=$DFF0A4
audper0=$DFF0A6
audvol0=$DFF0A8
; longueur des samples
soundlength1=47876
soundlength2=36094
soundlength3=46882
soundlength4=20312
; frequence de restitution
samplefreq1=17000
samplefreq2=19000
samplefreq3=17000
samplefreq4=17000


intenaw=$DFF09A
dmaconw=$DFF096
drb1=$BFE101  
ddrb1=$BFE301
touche=$BFE001

start:	

wait:	move.w	#0,d0
	move.b	$bfec01,d0
	not.b	d0
	ror.b	#1,d0
	cmp.b	#$59,d0
	beq	playfeu
	cmp.b	#$58,d0
	beq	playptc
	cmp.b	#$57,d0
	beq	playexp
	cmp.b	#$56,d0
	beq	playtrou
	cmp.b	#$55,d0
	beq	stop
	clr.l	d0
	
retour:	btst 	#6,touche
	bne.s 	wait

stop:	move.w 	#3,dmaconw
	btst 	#6,touche
	bne.s 	wait
	rts


playfeu:
	move.w 	#$000f,dmaconw
	move.L	 #datafeu,audloc0	
	move.L 	#datafeu,audloc0+16	
	move.w 	#soundlength1/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq1,D0
	bsr 	convertir	
	bra	retour

playptc:
	move.w 	#$000f,dmaconw
	move.L	 #dataptc,audloc0	
	move.L 	#dataptc,audloc0+16	
	move.w 	#soundlength2/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq2,D0
	bsr 	convertir	
	bra	retour
playexp:
	move.w 	#$000f,dmaconw
	move.L	 #dataexp,audloc0	
	move.L 	#dataexp,audloc0+16	
	move.w 	#soundlength3/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq3,D0
	bsr 	convertir	
	bra	retour
playtrou:
	move.w 	#$000f,dmaconw
	move.L	 #datatrou,audloc0	
	move.L 	#datatrou,audloc0+16	
	move.w 	#soundlength4/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	move.w 	#64,audvol0	
	move.w 	#64,audvol0+16
	move.l 	#samplefreq4,D0
	bsr 	convertir	
	bra	retour


convertir:
	move.l 	#715909,D3	
	divu 	D0,D3		
	lsr 	#1,D3		
	clr.l 	D0		
	addx 	D3,D0
	mulu 	#10,D0 
	move.w 	d0,audper0
	move.w 	d0,audper0+16
	move.w 	#$8203,dmaconw
	move.w	#0001,d2
	clr.w	d0
boucle:	addx	d2,d0
	cmp.w	#$ffff,d0
	bne.s	boucle

	move.L	 #buffer2,audloc0	
	move.L 	#buffer2,audloc0+16	
	move.w 	#taille2/2,D0	
	move.w 	d0,audlen0	
	move.w 	d0,audlen0+16	
	rts
		
	section ale,code_c

datafeu:	incbin "df0:bienvenue"	;sample rate 25208
dataptc:	incbin "df0:pfypresente22"	;	     16726
dataexp:	incbin "df0:nousallons"	;	     8363
datatrou:	incbin "df0:numeric2"	;	     16726


taille2= 1024
buffer2:dcb.l	taille2,0
END
