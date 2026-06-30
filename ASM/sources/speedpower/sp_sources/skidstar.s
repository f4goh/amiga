;LES RIP CODES DU SPEED POWER ....
;Le scrolling d'etoiles de DAN de ANARCHY pris sur intro sur LEMMING
;Ma routie rippe rend beaucoup moins bien que sur l'intro.Ya qqch qui
;plante mais je sais pas quoi.Ca marche sur 4 bitplan de 10560 oct
;(2*2 et en buffer).ATTENTION l'ecran fait 44 octet de long.
;La routine necessite SKID_GRAPH,SKID_COS,SKID_SIN pour l'exemple.
;elle est peut etre passable sur ST puisqu'elle est qu'au 68000
;Mais ,comme d'habitude sur amiga , c'est programme comme une merde.
;
nbr=200
mot_1=$78
mot_2=$b0
vx=2	;vitesse des sinus en x,y et z
vy=2
vz=6

		jsr	prepare		;a pas oublier
debut		jsr	sauve_tout
		
		move	#$7fff,$dff096
		move	#$7fff,$dff09a

		move	#%0010001000000000,$dff100
		clr	$dff108
		move	#$2c10,$dff08e		
		move	#$3cf0,$dff090
		move	#$0030,$dff092
		move	#$00d8,$dff094		;44 oct de long

		move	#$fff,$dff182
		move	#$77a,$dff184
		move	#$336,$dff186
		
		move.l	#copper_list,$dff080
		clr	$dff088

		move	#%1000000000000000,$dff09a
		move	#%1000011111000000,$dff096	
	
		jsr	prg

		jsr	restaure_tout

		moveq	#0,d0
		rts

sauve_tout	move.b	#%10000111,$bfd100
		move.l	$6c,sauve_irq
		move	$dff01c,sauve_intena
		or	#%1100000000000000,sauve_intena
		move	$dff002,sauve_dmacon
		or	#%1000000100000000,sauve_dmacon
		rts
restaure_tout	move.l	sauve_irq,$6c
		move	#$7fff,$dff09a
		move	sauve_intena,$dff09a
		move	#$7fff,$dff096
		move	sauve_dmacon,$dff096
		move.l	4,a6
		lea	glib,a1
		moveq	#0,d0
		jsr	-552(a6)
		move.l	d0,a0
		move.l	38(a0),$dff080
		clr	$dff088
		rts

		even
sauve_intena	dc	0
		even
sauve_dmacon	dc	0
		even
sauve_irq	dc.l	0
		even
glib		dc.b	"graphics.library",0
		even

prepare	LEA	big_table,A0
	MOVE.W	#$EFFC,D0
	MOVE.W	#$1000,D1
bcl1	MOVE.W	#$2BC,D2
	MOVE.W	#$2BC,D4
	MOVE.W	#$8000,D3	;
	MULS	D3,D2		;700*32768=d2
	SUB.W	D0,D4		;700-4100=d4
	DIVS	D4,D2		;700*32768/(-3400)
	MOVE.W	D2,(A0)+
	ADDI.W	#1,D0		;a quoi ca sert?????
	DBF	D1,bcl1
	LEA	fic_tab,A0
	MOVE.W	nbr_star,D7
bcl2	MOVE.W	#$40,D0
	BSR.S	sub1
	SUBI.W	#$20,D0
	MULS	#$20,D0
	MOVE.W	D0,(A0)+
	MOVE.W	#$40,D0		
	BSR.S	sub1
	SUBI.W	#$20,D0
	MULS	#$20,D0
	MOVE.W	D0,(A0)+
	MOVE.W	#$1F4,D0
	BSR.S	sub1
	MULU	#$10,D0
	MOVE.W	D0,(A0)+
	DBF	D7,bcl2
	LEA	mul44,A0
	MOVE.W	#0,D0
	MOVE.W	#$1FF,D7
bcl3	MOVE.W	D0,D1		;table de multiplication de 44
	MULS	#$2C,D1		;(0 a 511)
	MOVE.W	D1,(A0)+	;probable pour calcul de ligne
	ADDI.W	#1,D0
	DBF	D7,bcl3
	RTS
sub1	MOVE.W	D0,D5
	MOVE.W	D5,D4
	SUBQ.W	#1,D4
	MOVE.L	gener1,D0
	ADD.L	D0,D0
lbl2	BHI.S	lbl1
	EORI.L	#$1D872B41,D0
lbl1	LSR.W	#1,D4
	BNE.S	lbl2
	MOVE.L	D0,gener1
	TST.W	D5
	BNE.S	lbl3
	SWAP	D0
	BRA.S	lbl4
lbl3	MULU	D5,D0
lbl4	CLR.W	D0
	SWAP	D0
	RTS
				;%1000011111100000 dmacon
prg	move.l	$dff004,d2
	ANDI.L	#$1FF00,D2
	BNE.S	prg
	MOVE.L	adr_ecran+8,D0
	MOVE.L	adr_ecran+4,adr_ecran+8
	MOVE.L	adr_ecran,adr_ecran+4
	MOVE.L	D0,adr_ecran
	move.l	d0,d2
	ADDI.L	#$2940,D2
	move	d0,bpl1+6
	swap	d0
	move	d0,bpl1+2
	move	d2,bpl2+6
	swap	d2
	move	d2,bpl2+2	;la j'ai change , c'est pas sur
	move	#7,$dff180
	BSR	c_star		;et la 
	BSR	e_star		;et la
	BSR	a_star		;apparamment c'est la
	move	#0,$dff180
	BTST	#6,$BFE001
	BNE	prg
	RTS

	
c_star	lea	skid_cos,a0
	MOVE.W	v_x,D0
	MOVE.W	v_y,D1	;a mon avis , les vitesses (x,y,z)
	MOVE.W	v_z,D2
	ADD.W	D0,pos_x
	ADD.W	D1,pos_y
	ADD.W	D2,pos_z	;ici c'est le chemin des etoiles
	MOVE.W	pos_x,D0
	MOVE.W	pos_y,D1
	MOVE.W	pos_z,D2
	ANDI.W	#$7FF,pos_x	;que c'est mal programme
	ANDI.W	#$7FF,pos_y	;ca depasse pas(comme dans scr_3d)
	ANDI.W	#$7FF,pos_z
	MOVE.W	0(A0,D0.W),D0	
	ADD.W	D0,D0
	MOVE.W	0(A0,D1.W),D1
	ADD.W	D1,D1
	MOVE.W	0(A0,D2.W),D2
	ASL.W	#3,D2		;z par 8 ??????
	LEA	fic_tab,A0
	MOVE.W	nbr_star,D7
	MOVE.W	#$400,D6	;on calcul pour toute les etoiles
	MOVE.W	#$1FFF,D5
	MOVE.W	#$7FE,D4
	ADDI.W	#$400,D0
	ADDI.W	#$400,D1
bcl5	ADD.W	D0,(A0)		;je suis plus...(heureusement
	AND.W	D4,(A0)		;sinon j'essairai pas de la ripper)
	SUB.W	D6,(A0)+
	ADD.W	D1,(A0)
	AND.W	D4,(A0)
	SUB.W	D6,(A0)+
	ADD.W	D2,(A0)
	AND.W	D5,(A0)+
	DBF	D7,bcl5
	RTS
a_star	LEA	fic_tab,A0
	LEA	skid_graph,A3
	LEA	mul44,A4
	LEA	big_table,A5
	MOVE.W	nbr_star,D7
	MOVE.W	mot2,D4		;faut regarder ce qu'il y dedans
	MOVE.W	mot1,D3
	MOVEA.L	adr_ecran+8,A1
	MOVEA.L	A1,A2
	LEA	$2940(A2),A2
bcl6	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	MULS	0(A5,D2.W),D0
	MULS	0(A5,D2.W),D1
	SWAP	D0
	SWAP	D1
	ADD.W	D4,D0
	ADD.W	D3,D1
	CMP.W	#$EF,D1
	BHI.S	lbl5
	CMP.W	#$15F,D0
	BHI.S	lbl5
	CMP.W	#$7D0,D2
	BLT.S	lbl6
	CMP.W	#$1388,D2
	BLT.S	lbl7
	MOVE.B	0(A3,D0.W),D6
	ASR.W	#3,D0
	ADD.W	D1,D1
	ADD.W	0(A4,D1.W),D0
	OR.B	D6,0(A1,D0.W)
	DBF	D7,bcl6
	RTS
lbl6	MOVE.B	0(A3,D0.W),D6
	ASR.W	#3,D0
	ADD.W	D1,D1
	ADD.W	0(A4,D1.W),D0
	OR.B	D6,0(A1,D0.W)
	OR.B	D6,0(A2,D0.W)
	DBF	D7,bcl6
	RTS
lbl7	MOVE.B	0(A3,D0.W),D6
	ASR.W	#3,D0
	ADD.W	D1,D1
	ADD.W	0(A4,D1.W),D0
	OR.B	D6,0(A2,D0.W)
	DBF	D7,bcl6
	RTS
lbl5	DBF	D7,bcl6
	RTS
e_star	MOVEA.L	adr_ecran+8,A1
	LEA	$DFF000,A6
	CLR.L	$44(A6)
	CLR.L	$64(A6)
	MOVE.L	#$1000000,$40(A6)
	MOVE.L	A1,$54(A6)
	MOVE.W	#$7816,$58(A6)
	RTS

	section	data,data_c
copper_list	dc	$3301,$fffe
bpl1		dc	$00e0,0,$00e2,0
bpl2		dc	$00e4,0,$00e6,0
		dc.l	$fffffffe
		even
v_x		dc	vx
v_y		dc	vy
v_z		dc	vz
pos_x		dc	0
pos_y		dc	0
pos_z		dc	0

mot1		dc	mot_1
mot2		dc	mot_2
gener1		dc.l	$db276d45		;?????
adr_ecran	dc.l	ecran,ecran+2*10560,ecran+4*10560	;(+10240)
nbr_star	dc	nbr
fic_tab		dcb.w	3*(nbr+1),0
skid_cos	incbin	"df0:skid_cos"
skid_graph	incbin	"df0:skid_graph"
table		incbin	"df0:skid_sin"
		section	bss,bss_c
mul44		dcb.w	512,0
big_table	dcb.w	32769,0
ecran		dcb.b	10560*6,0			;(10240)
