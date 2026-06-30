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
	bsr	zob
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
;**** determination des valeurs de depart *****
zob:	move.l	#planeadr,a0
	move.w	#planewidth,a1
	move.w	#$ffff,a2
	move.l	coord2,a3	;test fin des coord	
	cmp.w	#-1,(a3)
	beq	ret
	cmp.l	#coordend,a3
	bne	cont
	move.l	#coord,coord2
cont:	move.w	(a3)+,d0	;x
	move.w	(a3)+,d1	;y
	move.w	(a3)+,d2	;x2
	move.w	(a3)+,d3	;y2
	move.l	a3,coord2
	bsr	drawline
	bra	zob
ret:	addq.l	#2,coord2
	rts
drawline:
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
coord2:dc.l	coord	;x1,y1,x2,y2
coord:	
	dc.w	100,100,200,100	;rectangle
	dc.w	200,100,200,150
	dc.w	200,150,100,150
	dc.w	100,150,100,100
	dc.w	-1
	dc.w	150,0,319,255	;triangle
	dc.w	319,255,0,255
	dc.w	0,255,150,0
	dc.w	-1
	dc.w	200,200,300,200	;s
	dc.w	300,200,300,225
	dc.w	300,225,200,225
	dc.w	200,225,200,250
	dc.w	200,250,300,250
	dc.w	-1
coordend:
copper:	ds.w	4
	dc.w	$ffff,$fffe
d:	ds.b	40*200
	even
planeadr:ds.b	40*256
