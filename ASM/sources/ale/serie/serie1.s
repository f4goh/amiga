;                          Debbug 68000 sur Minitel (version commentaires)
;                          ------------------------

;Realise par ALE OF FAME of PROFECY

;il suffit de loger cette routine dans n'importe quelle source asm,
;de faire un bsr debbug pour avoir un dumping des registres du 68000,
;ainsi que des bloc mémoires determines.
;il suffit de configurer la structure de debbug 68000.
;Cette structure est decrite a la fin de cette source (apres la table)

;Pour utiliser debbug, il faut configurer le Minitel en 80 colonnes
;(Fnct T+F) et la vitesse de transmission a 4800 bauds (Fnct P+4)


;registres de l'UART (port serie) 
serdat = $dff030
serper = $dff032
serdatr= $dff018
adkcon = $dff09e
adkconr= $dff010

;1200 bauds ---> 2982
;3600 bauds ---> 943
;4800 bauds ---> 745

vitesse= 745


start:
	move.w	#vitesse,serper
	move.l	#table,dumpadr
	clr.l	d0
	clr.l	d1
	bsr	titre
	bsr	registres
	bsr	saut
	bsr	handshake
	bsr	charge
	bsr	dmaint
	bsr	dumping
	clr.l	d0
	rts
charge:
	move.l	a0,rega0bis
	lea	regd0,a0
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	move.l	d4,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	move.l	a0,(a0)+
	move.l	a1,(a0)+
	move.l	a2,(a0)+
	move.l	a3,(a0)+
	move.l	a4,(a0)+
	move.l	a5,(a0)+
	move.l	a6,(a0)+
	move.l	a7,(a0)+
	move.l	rega0bis,rega0
	move.w	$dff002,readdma
	move.w	$dff01c,readint
	rts
dumping:
	move.l	dumpadr,a0
	move.l	dumpsize,d0
dumpcnt:
	bsr	dumpligne
	dbf	d0,dumpcnt	
	rts
dumpligne
	move.l	a0,d1
	lea	table2,a1
	bsr	regsc
	move.l	#15,d4
	bsr	dumpl2
	sub	#16,a0
	move.l	#15,d4
	lea	table,a1
toto:
	move.b	(a0)+,d1
	bsr	dumpl3
	dbf	d4,toto

	bsr	saut
	rts
dumpl2:
	move.b	(a0)+,d1
	move.b	d1,d3
	lsr.b	#4,d3
	bsr	affreg
	move.b	d1,d3
	bsr	affreg
	move.w	#$a0,serdat
	bsr	handshake
	dbf	d4,dumpl2	
	rts

dumpl3:
	cmp.b	#$20,d1
	blt	dumpl6
	cmp.b	#$39,d1
	bhi	dumpl6

	sub	#$20,d1
	mulu	#2,d1
	move.w	(a1,d1.w),serdat
	bsr	handshake
	rts
dumpl6:
	move.w	#$a0,serdat
	bsr	handshake
	rts

	
attend:
	btst	#14,serdatr
	beq	attend
	move.b	serdatr,d0
	move.b	d0,touche
	rts

dmaint:
	lea	textc,a0
	lea	table,a1
	clr.l	d1
	move.l	#textcsize,d0
	bsr	affiche
	move.w	readdma,d1
	bsr	dmaaff
	move.l	#0,d4
	bsr	nbspace
	bsr	decode
	bsr	saut

	lea	textd,a0
	lea	table,a1
	clr.l	d1
	move.l	#textdsize,d0
	bsr	affiche
	move.w	readint,d1
	bsr	dmaaff
	move.l	#0,d4
	bsr	nbspace
	bsr	decode
	bsr	saut

	rts
decode:
	move.w	d1,d3
	move.l	#15,d0
dec1:
	bsr	dec2
	bsr	nbspace
	dbf	d0,dec1
	clr.w	d0
dec2:
	btst	d0,d3
	bne	dec3
	move.w	#$130,serdat
	bsr	handshake
	bra	dec4
dec3:	move.w	#$b1,serdat
	bsr	handshake
dec4:	move.l	#3,d4
	rts


dmaaff:
	lea	table2,a1
	move.w	d1,d3
	lsr.w	#8,d3
	lsr.w	#4,d3
	bsr	affreg
	move.w	d1,d3
	lsr.w	#8,d3
	bsr	affreg
	move.w	d1,d3
	lsr.w	#4,d3
	bsr	affreg
	move.w	d1,d3
	bsr	affreg
	rts

nbspace:
	move.w	#$a0,serdat
	bsr	handshake
	dbf	d4,nbspace	
	rts

registres:
	lea	regd0,a0
	lea	table2,a1
	move.w	#$144,serdat
	bsr	handshake
	move.w	#$2e,serdat
	bsr	handshake
	move.w	#$a0,serdat
	bsr	handshake
	bsr	regs
	lea	rega0,a0
	move.w	#$141,serdat
	bsr	handshake
	move.w	#$2e,serdat
	bsr	handshake
	move.w	#$a0,serdat
	bsr	handshake
	bsr	regs
	rts
regs:
	move.w	#7,d0
regsb:	move.l	(a0)+,d1
	bsr	regsc
	dbf	d0,regsb
	bsr	saut
	rts
regsc:
	move.l	d1,d3
	swap	d3
	lsr.w	#8,d3
	lsr.w	#4,d3
	bsr	affreg
	move.l	d1,d3
	swap	d3
	lsr.w	#8,d3
	bsr	affreg
	move.l	d1,d3
	swap	d3
	lsr.w	#4,d3
	bsr	affreg
	move.l	d1,d3
	swap	d3
	bsr	affreg
	move.l	d1,d3
	lsr.w	#8,d3
	lsr.w	#4,d3
	bsr	affreg
	move.l	d1,d3
	lsr.w	#8,d3
	bsr	affreg
	move.l	d1,d3
	lsr.l	#4,d3
	bsr	affreg
	move.l	d1,d3
	bsr	affreg
	move.w	#$a0,serdat
	bsr	handshake
	rts

affreg:
	and.w	#$000f,d3
	mulu	#2,d3
	move.w	(a1,d3.w),serdat
	bsr	handshake
	rts

titre:
	lea	texta,a0
	lea	table,a1
	move.l	#textasize,d0
	bsr	affiche
	bsr	saut
	lea	textb,a0
	move.l	#textbsize,d0
	bsr	affiche
	rts


affiche:
	move.b	(a0)+,d1
	sub	#$20,d1
	mulu	#2,d1
	move.w	(a1,d1.w),serdat
	bsr	handshake
	dbf	d0,affiche
	bsr	saut
	rts

saut:
	move.w	#$8b,serdat
	bsr	handshake
	move.w	#$8d,serdat
	bsr	handshake
	rts
bip:
	move.w	#$87,serdat
	bsr	handshake
	rts

handshake:
	move.l	#0,d2
jj:
	addq	#1,d2
	cmp.l	#vitesse,d2
	bne	jj
	rts

texta:
	dc.b	"               DEBUG 68000/Minitel     Realise par ALE OF FAME of Profecy"
fintexta:
	even
textasize = fintexta-texta-1
textb:
	dc.b	"Reg:   0       1        2         3        4        5        6        7" 
fintextb:
	even
textbsize = fintextb-textb-1
textc:
	dc.b	"DMA: Set  Buzy Zero Nc   Nc Bpri DmaE BplE CopE BltE SprE DskE Au3E Au2E Au1E A0"
fintextc:
	even
textcsize = fintextc-textc-1
textd:
	dc.b	"INT: Set  IntE ExtE Dsyk Bs Aud3 Aud2 Aud1 Aud0 Blit Vert Copp Port Soft DskD Be"
fintextd:
	even
textdsize = fintextd-textd-1

touche:
	dc.w	0

regd0:	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

rega0:	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0

rega0bis
	dc.l	0
readdma:
	dc.w	0
readint:
	dc.w	0



;$88	(del) code non utilise, mais on ne sait jamais !! 


table:
	dc.w	$a0,$121,$122,$a3,$124,$a5,$a6,$127	;Carac. speciaux
	dc.w	$128,$a9,$aa,$12b,$ac,$12d,$12e,$af
	dc.w	$130,$b1,$b2,$133,$b4,$135,$136,$b7	;Chiffres + divers
	dc.w	$b8,$139,$13a,$bb,$13c,$bd,$be,$13f
	dc.w	$a0
	dc.w	$141,$142,$43,$144,$45,$46,$147,$148	;Majuscules
	dc.w	$49,$4a,$14b,$4c,$14d,$14e,$4f,$150
	dc.w	$51,$52,$153,$54,$155,$156,$57,$58
	dc.w	$159,$15a,$a0,$a0,$a0,$a0,$a0,$a0
	dc.w	$21,$22,$163,$24,$165,$166,$27,$28,$169	;Minuscules
	dc.w	$16a,$2b,$16c,$2d,$2e,$16f,$30,$171,$172
	dc.w	$33,$174,$35,$36,$177,$178,$39,$3a,$a0

table2:
	dc.w	$130,$b1,$b2,$133,$b4,$135,$136,$b7
	dc.w	$b8,$139,$141,$142,$43,$144,$45,$46

;Les accents ne sont pas inclus, alors attention !

dumpadr:
	dc.l	0

dumpsize:
	dc.l	12


end

