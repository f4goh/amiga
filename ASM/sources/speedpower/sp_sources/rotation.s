centrex=160
centrey=168
nb_pt_max=50
ang_max=359


;****** PRG DE DROITES *******
DMACONR equ $dff002
INTENA equ $dff09A
INTREQ equ $dff09C
INTREQR equ $dff01E
INTENAR equ $dff01C
DMACON equ $dff096
COLOR00 equ $dff0180
VHPOSR equ $dff006
;REGISTRE COPPER
COP1LC equ $dff080
COP2LC equ $dff084
COPJMP1 equ $dff088
COPJMP2 equ $dff08A
;REGISTRE BITPLANE
BPLCON0 equ $dff100
BPLCON1 equ $dff102
BPLCON2 equ $dff104
BPL1PTH equ $E0
BPL1PTL equ $E2
BPL2PTH equ $E4
BPL2PTL equ $E6
BPL3PTH equ $E8
BPL3PTL equ $EA
BPL4PTH equ $EC
BPL4PTL equ $EE
BPL5PTH equ $F0
BPL5PTL equ $F2
BPL6PTH equ $F4
BPL6PTL equ $F6
BPL1MOD equ $dff108
BPL2MOD equ $dff10A
DIWSTRT equ $dff08E
DIWSTOP equ $dff090
DDFSTRT equ $dff092
DDFSTOP equ $dff094
;registre blitter
BLTCON0 equ $dff040
BLTCON1 equ $dff042
BLTAPTH equ $dff050
BLTAPTL equ $dff052
BLTBPTH equ $dff04c
BLTDPTH equ $dff054
BLTCPTH equ $dff048
BLTSIZE equ $dff058
BLTAMOD equ $dff064
BLTBMOD equ $dff062
BLTDMOD equ $dff066
BLTCMOD equ $dff060
BLTAFWM equ $dff044
;****** label *****
allocmen equ -30-168
freemen equ -30-180
execbase equ 4
bplsize equ 40*256
planewidth equ 40
clsize equ 3*4
chip equ 2
clear equ chip+$10000
	section un,code_c
start:
;******* debut ******
	jsr	save_all
;****** installation copper *****
	bsr	initbitplan
	move.w	#$03e0,DMACON
	move.l	#copper,COP1LC
	clr.w	COPJMP1
;****** creation palette couleur ******
	move.l	#$dff180,$0
	move.l	#$dff182,$fa0
	move.w	#$2981,DIWSTRT
	move.w	#$29C1,DIWSTOP
	move.w	#$0038,DDFSTRT
	move.w	#$00D0,DDFSTOP
	move.w	#%0001001000000000,BPLCON0
	clr.w	BPLCON1
	clr.w	BPLCON2
	clr.w	BPL1MOD
	clr.w 	BPL2MOD
;****** dma active ******
	move.w	#$83c0,DMACON
wait:	cmp.b	#$ff,$dff006
	bne.s	wait
	move	#$f,$dff180
	bsr	efface
	bsr	zob
	move	#$0,$dff180
	btst.b	#6,$bfe001
	bne.s	wait
;***** fin de programme *****
;**** attendre jusqu'a blitter termine ****
wblit:	btst	#14,DMACONR
	bne	wblit
	bsr.s	restore_all
fin:	clr.l	d0
	rts
save_all:
	move.l	execbase,a6
	jsr	-132(a6)
	move.w	$dff002,save_dmacon
	or.w	#$c000,save_dmacon
	rts
restore_all:
	move.l	execbase,a6
	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
	lea	grname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
	jsr	-138(a6)
	rts
initbitplan:	move.l #copper,a0
	move.l	#planeadr,d0
	move.w	#$e0,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#$e2,(a0)+
	swap	d0
	move.w	d0,(a0)+
	rts
;***** EFFACE L'ANCIEN DESSIN ******
efface:	btst	#14,$dff002
	bne.s	efface
	move.w	#-1,$dff044
	clr.w	$dff042
	clr.w	$dff066
	move.w	#$900,$dff040
	move.l	#planeadr+(centrey-88)*40,$dff054
	move.w	#88*2*64+20,$dff058
	rts	
;**** determination des valeurs de depart *****
zob	add	#4,angle_rot
	cmp	#ang_max,angle_rot
	ble	anglok
	move	#0,angle_rot
anglok	move	angle_rot,d0
	
	lea	logo6,a0
	lea	rlogo6,a1
	bsr	rotation
	
	rts

rotation	move.l	(a0)+,d1
		move.l	a1,a3
		lea	sincos,a1
		lea	result,a2
pt_sui		move.l	(a0)+,d2	;angle,rayon
		move	d2,d3
		swap	d2		;d2=angle d3=rayon
		add	d0,d2		;nouvel angle,on a tourne
		bge.s	angplus
		add	#ang_max,d2
		bra.s	bon_ang
angplus		cmp	#ang_max,d2
		ble.s	bon_ang
		sub	#ang_max,d2
bon_ang		lsl	#2,d2		;d2  0<angle<360
		move.l	(a1,d2),d2		sin puis cos
		move	d2,d4
		swap	d2		;d2=sin d4=cos
		muls	d3,d2		;y
		muls	d3,d4		;x
		asr	#7,d2
		asr	#7,d4
		add	#centrey,d2
		add	#centrex,d4
		swap	d4
		move	d2,d4
		move.l	d4,(a2)+
		dbra	d1,pt_sui

		lea	result,a4
		move.l	(a3)+,d7
ligne_sui	move.l	(a3)+,d0	;pt source, pt dest
		move	d0,d1
		swap	d0		;d1=pt source d2=pt dest
		lsl	#2,d0
		lsl	#2,d1
		move.l	(a4,d0),d0
		move.l	(a4,d1),d2
		move	d0,d1
		swap	d0
		move	d2,d3
		swap	d2
		add	#1,d0
		add	#1,d1
		add	#1,d2
		add	#1,d3
		;move	#110,d0
		;;move	#220,d1
		;move	#110,d2
		;move	#210,d3
		bsr.s	drawline
		dbra	d7,ligne_sui
		rts

drawline:
	move.l	#planeadr,a0
	move.w	#planewidth,a1
	move.w	#$ffff,a2

	move.l	#planeadr,a0
	move.w	d1,d4
	mulu	#40,d4	;d4=y*40
	lea	(a0,d4),a0
	move.w	d0,d5
	lsr.w	#3,d5	;d5=x/8
	and.w	#$fffe,d5	;on met l'add paire
	lea	(a0,d5),a0
	move.l	a0,d4
	clr.l	d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.s	y2gy1
	neg.w	d3
y2gy1:	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.s	x2gx1
	neg.w	d2
x2gx1:	move.w	d3,d1
	sub.w	d2,d1
	bge.s	dygdx
	exg	d2,d3
dygdx:	roxl.b	#1,d5
	move.b	table(pc,d5),d5
	add.w	d2,d2
wblit2:	btst	#14,DMACONR
	bne.s	wblit2
	move.w	d2,BLTBMOD
	sub.w	d3,d2
	bge.s	signnl
	or.b	#$40,d5
signnl:	move.w	d2,BLTAPTL
	sub.w	d3,d2
	move.w	d2,BLTAMOD
	move.w	#$8000,$dff074
	move.w	a2,$dff072
	move.w	#$ffff,BLTAFWM
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,BLTCON0
	move.w	d5,BLTCON1
	move.l	d4,BLTCPTH
	move.l	d4,BLTDPTH
	move.w	a1,BLTCMOD
	move.w	a1,BLTDMOD
;***** init de bltsize *****
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,BLTSIZE
	rts
table:	dc.b	0*4+1
	dc.b	4*4+1
	dc.b	2*4+1
	dc.b	5*4+1
	dc.b	1*4+1
	dc.b	6*4+1
	dc.b	3*4+1
	dc.b	7*4+1
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even
angle_rot	dc.w	0
sincos		incbin	"df0:sincos1"
		

		;	angle,rayon
logo2		dc.l	47-1	;nombre de point
		
		dc.w	173,90,173,90,172,78,170,72,169,54,166,43,161,31,151,21,140,15,90,10
		dc.w	39,15,22,26,18,31,13,43,11,49,9,60,8,66,7,78
		dc.w	180,90,180,78,180,54,180,42,180,12,0,0,0,12,0,24,0,30,0,42,0,54,0,66,0,78
		dc.w	187,90,187,78,187,72,189,60,190,55,193,43,198,31,209,20,219,15
		dc.w	320,15,341,31,346,43,348,49,350,60,351,66,352,78
		dc.w	0,0



		
rlogo2		dc.l	32-1	;nombre de ligne		
		dc.w	1,2	;A
		dc.w	2,32	
		dc.w	1,31	
		dc.w	18,19
	
		dc.w	3,33	;L
		dc.w	33,34
	
		dc.w	4,5	;E
		dc.w	4,35	
		dc.w	35,36	
		dc.w	20,21
	
		dc.w	6,7	;O
		dc.w	7,38	
		dc.w	38,37	
		dc.w	37,6
	
		dc.w	8,9	;F
		dc.w	22,23	
		dc.w	8,39
	
		dc.w	10,11	;F
		dc.w	10,40	
		dc.w	24,25
	
		dc.w	12,13	;A
		dc.w	13,42	
		dc.w	12,41	
		dc.w	26,27
	
		dc.w	43,14	;M
		dc.w	14,28	
		dc.w	28,15	
		dc.w	15,44
	
		dc.w	16,17	;E
		dc.w	16,45	
		dc.w	45,46	
		dc.w	29,30
	

		;	angle,rayon
logo3		dc.l	39-1	;nombre de point
		
		dc.w	171,60,171,60,169,49,166,43,161,31,157,26,140,15,120,11
		dc.w	59,11,39,15,30,20,22,26,18,31,13,43,11,49,9,60
		dc.w	180,60,180,48,180,42,180,30,180,24,180,12
		dc.w	0,30,0,36,0,42,0,48,0,60
		dc.w	189,60,191,49,193,43,202,26,219,15,239,11
		dc.w	300,11,330,20,341,31,346,43,348,49,351,60
		dc.w	0,0



		
rlogo3		dc.l	27-1	;nombre de ligne		
		dc.w	1,2	;S
		dc.w	1,16	
		dc.w	16,17	
		dc.w	17,28
		dc.w	28,27
	
		dc.w	3,4	;P
		dc.w	4,19
		dc.w	19,18
		dc.w	3,29

	
		dc.w	5,6	;E
		dc.w	5,30	
		dc.w	20,21	
		dc.w	30,31
	
		dc.w	7,8	;C
		dc.w	7,32	
		dc.w	32,33	
	
		dc.w	9,11	;T
		dc.w	10,34	
	
		dc.w	12,13	;R
		dc.w	12,35	
		dc.w	13,24
		dc.w	24,22
		dc.w	23,36

		dc.w	14,15	;E
		dc.w	14,37	
		dc.w	37,38	
		dc.w	25,26
	

logo4		dc.l	32-1	;nombre de point
		
		dc.w	166,43,166,43,161,31,157,26,140,15,120,11
		dc.w	59,11,39,15,22,26,18,31,13,43,11,49,9,60
		dc.w	180,36
		dc.w	0,12,0,24,0,30,0,42,0,48,0,54,0,60
		dc.w	193,43,198,31,202,26,219,15,239,11
		dc.w	300,11,320,15,341,31,346,43,348,49,350,62
		dc.w	0,0



		
rlogo4		dc.l	25-1	;nombre de ligne		
		dc.w	1,21	;W
		dc.w	21,13	
		dc.w	13,22	
		dc.w	22,2
	
		dc.w	3,4	;O
		dc.w	4,24
		dc.w	24,23
		dc.w	23,3

	
		dc.w	5,6	;O
		dc.w	6,26	
		dc.w	26,25	
		dc.w	25,5
	
		dc.w	7,8	;P
		dc.w	7,27	
		dc.w	14,15	
		dc.w	8,15

		dc.w	9,10	;E
		dc.w	9,28	
		dc.w	28,29	
		dc.w	16,17
	

		dc.w	11,12	;R
		dc.w	11,30	
		dc.w	12,20
		dc.w	18,20
		dc.w	19,31

logo5		dc.l	35-1	;nombre de point
		
		dc.w	169,54,169,54,166,43,164,37,157,26,150,21,120,11,90,10
		dc.w	39,15,29,21,18,31,15,37,11,49
		dc.w	180,54,180,42,180,18,180,6,0,0
		dc.w	0,18,0,30,0,36,0,42,0,48
		dc.w	190,54,193,43,195,37,202,26,209,20,239,11,270,10
		dc.w	320,15,330,20,341,31,344,37,348,49
		dc.w	0,0
		
rlogo5		dc.l	24-1	;nombre de ligne		
		dc.w	1,2	;S
		dc.w	1,13	
		dc.w	13,14	
		dc.w	14,24
		dc.w	24,23
	
		dc.w	25,3	;N
		dc.w	3,26
		dc.w	26,4

	
		dc.w	5,6	;A
		dc.w	27,5	
		dc.w	6,28	
		dc.w	15,16
	
		dc.w	7,29	;K
		dc.w	17,8	
		dc.w	17,30	

		dc.w	9,10	;E
		dc.w	9,31	
		dc.w	31,32	
		dc.w	18,19
	

		dc.w	11,12	;R
		dc.w	11,33	
		dc.w	12,22
		dc.w	22,20
		dc.w	21,34


		;	angle,rayon
logo1		dc.l	36-1	;nombre de point
		
		dc.w	171,60,171,60,169,49,166,43,161,31,157,26,140,15,120,11
		dc.w	59,11,39,15,22,26,18,31,13,43,11,49,9,60
		dc.w	180,60,180,48,180,42,180,36,180,30,180,6
		dc.w	0,6,0,12,0,20,0,54
		dc.w	189,60,193,43,198,31,202,26,219,15,239,11
		dc.w	320,15,333,22,341,31,346,43,348,49
		dc.w	0,0



		
rlogo1		dc.l	25-1	;nombre de ligne		
		dc.w	1,2	;P
		dc.w	1,25	
		dc.w	15,16	
		dc.w	2,16
	
		dc.w	3,4	;R
		dc.w	3,26
		dc.w	4,19
		dc.w	19,17
		dc.w	18,27

		dc.w	5,6	;O
		dc.w	5,28	
		dc.w	28,29	
		dc.w	6,29
	
		dc.w	7,8	;F
		dc.w	7,30	
		dc.w	20,21	

		dc.w	9,10	;E
		dc.w	9,31	
		dc.w	31,32	
		dc.w	22,23
	
	
		dc.w	11,12	;C
		dc.w	11,33	
		dc.w	33,34

		dc.w	14,35	;Y
		dc.w	13,24
	
		
logo6		dc.l	58-1
		dc	207,88	
		dc	210,69	
		dc	213,68	
		dc	209,65	
		dc	207,67	
		dc	206,53	
		dc	208,51	
		dc	217,57	
		dc	212,50	
		dc	207,38	
		dc	207,34	
		dc	208,25	
		dc	216,33	
		dc	234,36	
		dc	225,44	
		dc	227,25	
		dc	207,7	
		dc	228,15	
		dc	257,27	
		dc	241,33	
		dc	207,2	
		dc	27,7	
		dc	0,10	
		dc	299,21	
		dc	287,24	
		dc	265,25	
		dc	207,11	
		dc	114,24	
		dc	70,28	
		dc	90,16	
		dc	65,17	
		dc	28,17	
		dc	41,32	
		dc	51,22	
		dc	52,37	
		dc	29,31	
		dc	27,42	
		dc	42,47	
		dc	34,42	
		dc	37,39	
		dc	39,44	
		dc	40,52	
		dc	36,63	
		dc	32,53	
		dc	29,48	
		dc	27,45	
		dc	35,65	
		dc	31,76	
		dc	30,70	
		dc	29,75	
		dc	27,88	
		dc	27,75	
		dc	30,68	
		dc	27,68	
		dc	26,61	
		dc	245,26	
		dc	225,38	
		dc	30,50	

rlogo6		dc.l	57-1

		dc	0,1
		dc	1,4
		dc	4,5
		dc	5,3
		dc	3,2
		dc	2,0

		dc	6,9
		dc	9,8
		dc	8,7
		dc	7,6

		dc	10,11
		dc	11,12
		dc	12,56
		dc	56,13
		dc	13,14
		dc	14,10

		dc	15,16
		dc	16,17
		dc	17,55
		dc	55,18
		dc	18,19
		dc	19,15

		dc	20,21
		dc	21,22
		dc	22,23
		dc	23,24
		dc	24,25
		dc	25,20

		dc	26,27
		dc	27,28
		dc	28,29
		dc	29,26

		dc	30,31
		dc	31,32
		dc	32,28
		dc	28,30

		dc	34,35
		dc	35,36
		dc	36,37
		dc	37,40
		dc	40,39
		dc	39,34

		dc	41,42
		dc	42,43
		dc	43,57
		dc	57,44
		dc	44,45
		dc	45,41

		dc	46,47
		dc	47,48
		dc	48,49
		dc	49,50
		dc	50,51
		dc	51,52
		dc	52,53
		dc	53,54
		dc	54,46

copper:	ds.w	4
	dc.w	$ffff,$fffe
result		dcb.w	nb_pt_max*2,0								
planeadr:ds.b	40*256
ecranend:

