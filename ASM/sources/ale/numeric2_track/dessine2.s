;LE SPEED POWER PROPOSE....
;Une routine amusante .elle dessine .On fait les dessins avec COURBE.GFA
;Et ca dessine tout seul.A poser lors des presentation d'auteurs....
;Le graph du crayon est en bas.Necessite dess.profecy et dess.numlog
;pour l'exemple....

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
nb_piste_a_charger = 30
adresse_numeric=$500
adresse_numeric_cruncher=$500-2		;on sait pas
offset	=  43542	
mt_data3 = $60000
mt_data4 = mt_data3+$3b6

;	org	$50000
	section	moi,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	bsr	decrunch
	bsr	mt_init
	clr.b	$bfde00
	move.b	#$82,$bfd400
	move.b	#$37,$bfd500
	move.b	#$81,$bfdd00
	move.b	#$11,$bfde00
	move.l	$78,oldirq
	move.l	#new,$78	
;installation de la 1ere liste copper
	lea	pt_ecr(pc),a0
	move.l	#ecran,d0
	move.w	#$e0,(a0)+
	swap	d0
	move.w	d0,(a0)+
	move.w	#$e2,(a0)+
	swap	d0
	move.w	d0,(a0)
;copper initialise
	move.w	#$7fff,$96(a6)
	lea	ecran,a0
	move.w	#256*40-1,d0
eff_ecr	clr.b	(a0)+
	dbra	d0,eff_ecr
	move.l	#copper,$80(a6)
	clr.w	$88(a6)
;creation de la palette couleur
;bitplane initialise
;dma active
	move.w	#$83d0,$96(a6)

;attendre jusqu'a blitter termine
	bsr	pion
	bsr	fondu
	clr.l	d0
	bsr	w
	bsr	pion2
	bsr	fondu2
	
s1	btst	#6,$bfe001
	bne	s1
	bsr	chargeur

restore_all
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
fin	clr.l	d0
	move.l	oldirq,$78
;	bsr	decrunch_numeric
	bsr	mt_end
;	jmp	adresse_numeric
	rts

fondu
	move.l	#15,d0	
	lea	fcouleurs,a0
	lea	coul1,a1
fon1	move.w	(a0)+,2(a1)
	moveq	#50-1,d1
fon2	cmp.b	#6,$dff006
	bne.s	fon2
	dbf	d1,fon2
	dbf	d0,fon1
	rts
fondu2	move.l	#15,d0	
	lea	fcouleurs,a0
	lea	coul2,a1
fon3	move.w	(a0)+,2(a1)
	moveq	#50-1,d1
fon4	cmp.b	#6,$dff006
	bne.s	fon4
	dbf	d1,fon4
	dbf	d0,fon3
	rts

w	cmp.b	#1,$dff006
	bne.s	w
	tst	d0
	bmi	a_oter	
	bsr	dessine
	tst	d0
	bmi	a_oter	
	bsr	dessine
	bra	w
a_oter	rts

pion	lea	logo,a0
	lea	ecran+15+40*35,a1
	moveq	#haut_logo-1,d0
copie2	moveq	#larg_logo-1,d1
copie	move.b	(a0)+,(a1)+
	dbf	d1,copie
	add.l	#(40-larg_logo),a1
	dbf	d0,copie2
	rts

pion2	lea	logo2,a0
	lea	ecran+4+40*110,a1
	moveq	#haut_logo2-1,d0
copi2	moveq	#larg_logo2-1,d1
copi	move.b	(a0)+,(a1)+
	dbf	d1,copi
	add.l	#(40-larg_logo2),a1
	dbf	d0,copi2
	rts

dessine:
	move.l	pos_cray,a0
	tst	(a0)
	bmi	fin_dessin		
	move	(a0)+,d0
	move	(a0)+,d1
	move.l	a0,pos_cray
	mulu	#long_ecr,d1
	move	d0,d2
	lsr	#4,d2
	lsl	d2
	add	d2,d1
	add.l	#ecran,d1
	lsl	#8,d0
	lsl	#4,d0
	or	#%0000110111111100,d0
	clr.w	$dff042
	move.l	#-1,$dff044
	move.l	#crayon,$dff050
	move.l	d1,$dff04c
	move.l	d1,$dff054
	move	#0,$dff064
	move	#long_ecr-(long_cray+1)*2,$dff062
	move	#long_ecr-(long_cray+1)*2,$dff066
	move	d0,$dff040
	move	#haut_cray<<6+long_cray+1,$dff058
	move	#0,d0
	rts
fin_dessin:
	move	#-1,d0
	rts
		
pos_cray:
	dc.l	dessin2

dessin2:
;	dc	119,30,183,30	
	dc	119,30,121,30,123,30,125,30,127,30
	dc	129,30,131,30,133,30,135,30,137,30
	dc	139,30,141,30,143,30,145,30,147,30
	dc	149,30,151,30,153,30,155,30,157,30
	dc	159,30,161,30,163,30,165,30,167,30
	dc	169,30,171,30,173,30,175,30,177,30
	dc	179,30,181,30,183,30

	dc	119,25,121,25,123,25,125,25,127,25
	dc	129,25,131,25,133,25,135,25,137,25
	dc	139,25,141,25,143,25,145,25,147,25
	dc	149,25,151,25,153,25,155,25,157,25
	dc	159,25,161,25,163,25,165,25,167,25
	dc	169,25,171,25,173,25,175,25,177,25
	dc	179,25,181,25,183,25

	dc	119,20,121,20,123,20,125,20,127,20
	dc	129,20,131,20,133,20,135,20,137,20
	dc	139,20,141,20,143,20,145,20,147,20
	dc	149,20,151,20,153,20,155,20,157,20
	dc	159,20,161,20,163,20,165,20,167,20
	dc	169,20,171,20,173,20,175,20,177,20
	dc	179,20,181,20,183,20

	dc	119,15,121,15,123,15,125,15,127,15
	dc	129,15,131,15,133,15,135,15,137,15
	dc	139,15,141,15,143,15,145,15,147,15
	dc	149,15,151,15,153,15,155,15,157,15
	dc	159,15,161,15,163,15,165,15,167,15
	dc	169,15,171,15,173,15,175,15,177,15
	dc	179,15,181,15,183,15
	dc	119,10,121,10,123,10,125,10,127,10
	dc	129,10,131,10,133,10,135,10,137,10
	dc	139,10,141,10,143,10,145,10,147,10
	dc	149,10,151,10,153,10,155,10,157,10
	dc	159,10,161,10,163,10,165,10,167,10
	dc	169,10,171,10,173,10,175,10,177,10
	dc	179,10,181,10,183,10

;	dc	-1
dessin:		
n:	dc	2,218,3,216,4,215,5,213,6,211,7,209,8,208,8,207,9,209
	dc	9,210,9,211,8,213,8,214,7,215,7,217,8,217,9,216,10,215
	dc	11,214,11,213,12,212,13,210,14,208,15,206
o:	dc	14,215,15,214,16,213,17,213,18,214,18,215,17,216,16,218
	dc	15,218,14,217,14,216
i:	dc	23,219,24,217,25,215,26,214,27,212
ll:	dc	34,208,33,209,33,210,32,211,31,213,30,215,29,217,29,218
	dc	30,219,31,218,32,217,33,216,34,215,35,213,36,211,37,209
	dc	38,208
e:	dc	33,217,35,218,36,218,37,217,39,216,40,215,41,213,41,211
	dc	40,212,39,212,38,213,37,215,37,217,38,218,39,218,40,218
	dc	41,218
g:	dc	50,212,49,212,48,213,47,213,46,214,45,215,44,216,43,217
	dc	43,219,44,220,45,219,46,219,47,218,48,217,49,215,50,213
	dc	47,219,47,220,46,221,45,223,44,224,44,225
a:	dc	58,214,57,213,56,213,55,214,54,214,53,215,52,217
	dc	52,218,53,218,55,217,55,217,57,216,57,214,56,218,57,218
l:	dc	58,217,59,217,60,216,62,215,63,214,64,213,65,211,66,209
	dc	65,209,63,211,62,212,61,213,60,215,61,218,62,219,63,219
	dc	64,219,65,218,66,218,67,217,68,217,69,216,70,216
s:	dc	85,209,85,207,83,207,81,208,80,209,78,209,77,210,79,211
	dc	80,212,81,212,83,213,83,215,82,216,81,217,80,217,79,218
	dc	77,218,75,218,73,217,73,216,75,215,77,215
t:	dc	91,208,90,209,89,210,88,212,87,214,86,215,85,217,85,219
	dc	86,211,88,211,90,211,92,211
u:	dc	92,214,91,215,91,217,92,218,93,218,94,217,95,215,96,213
	dc	97,212,95,218,97,218,98,217
f:	dc	101,214,103,213,104,212,105,216,107,210,108,209,109,208
	dc	110,205,108,206,106,208,105,210,103,215
	dc	101,219,99,221,97,223,96,225,96,225,96,227,97,223,97,221
	dc	98,219,99,218,101,217,103,216
f2:	dc	106,214,108,213,109,212,110,216,112,210,113,209,114,208
	dc	115,205,113,206,111,208,110,210,108,215
	dc	106,219,104,221,102,223,101,225,101,225,101,227,102,223,102,221
	dc	103,219,104,218,106,217,108,216
pt1	dc	119,217
no:	dc	126,218,127,216,128,215,129,213,130,211,131,209,132,208,132,207,133,209
	dc	133,210,133,211,132,213,132,214,131,215,131,217,132,217,133,216,134,215
	dc	135,214,135,213,136,212,137,210,138,208,139,206
	dc	138,215,139,214,140,213,141,213,142,214,142,215,141,216,140,218
	dc	139,218,138,217,138,216
s2:	dc	156,208,157,207,155,206,153,207,152,208,151,209,149,210,148,212
	dc	149,214,151,216,151,218,149,219,147,219,145,218,142,217
	dc	146,216,148,216,150,216,151,216
e2:	dc	152,216,154,215,156,213,156,212,154,212,152,214,153,217
	dc	154,217,155,217,157,216
ll2:	dc	163,208,162,209,162,210,161,211,160,213,159,215,158,217,158,218
	dc	159,219,160,218,161,217,162,216,163,215,164,213,165,211,166,209
	dc	167,208
i2:	dc	163,217,165,218,167,216,168,215,169,213,170,212,169,217,171,217
n2:	dc	176,213,175,215,174,217,176,214,177,216,177,218,178,218
g2:	dc	186,212,184,212,183,213,182,214,181,215,180,217,181,218
	dc	182,218,183,217,184,217,185,216,186,215,187,213
	dc	185,217,185,218,184,219,183,221,182,223,181,225,180,227
	dc	179,228,178,230,177,232,176,232,176,230,176,228,177,226
	dc	178,226,178,225,180,223,185,221,186,220,187,220,188,219
	dc	189,219,190,219
pt2:	dc	201,217
no2:	dc	209,218,210,216,211,215,212,213,213,211,214,209,215,208,215,207,216,209
	dc	216,210,216,211,215,213,215,214,214,215,214,217,215,217,216,216,217,215
	dc	218,214,218,213,219,212,220,210,221,208,222,206
	dc	221,215,222,214,223,213,224,213,225,214,225,215,224,216,223,218
	dc	222,218,221,217,221,216
c:	dc	241,209,240,208,239,208,238,209,237,209,236,211,235,212,234,213
	dc	233,215,234,217,235,218,236,218,237,217,238,218,239,216,214,215
	dc	241,214,240,214,242,214,243,213
a2:	dc	215,213,249,213,248,214,247,214,246,215,245,216,244,217,245,218
	dc	247,217,248,216,249,216,250,215,249,217,240,218
c2:	dc	257,213,256,213,255,213,253,214,252,215,252,217,253,218,254,218
	dc	255,218,256,217,257,216
k:	dc	264,207,263,208,262,210,261,211,260,213,259,215,258,216,257,217
	dc	261,214,262,214,263,213,265,212,266,212,260,215,262,216,263,212
i3:	dc	268,215,267,216,266,217,266,218
n3:	dc	273,213,272,215,271,217,273,214,274,216,274,218,275,218
g3:	dc	283,212,281,212,280,213,279,214,278,215,277,217,278,218
	dc	279,218,280,217,281,217,282,216,283,215,284,213
	dc	282,217,282,218,281,219,280,221,279,223,278,225,277,227
	dc	276,228,275,230,274,232,273,232,273,230,273,228,274,226
	dc	275,226,275,225,277,223,282,221,283,220,284,220,285,219
	dc	286,219,287,219
pt3:	dc	292,217

	dc	-1

crayon:	dc	%0000000110000000,0			
	dc	%0000000110000000,0

	even
fcouleurs:
	dc.w	$fff,$eee,$ddd,$ccc,$bbb,$aaa,$999,$888,$777
	dc.w	$666,$555,$444,$333,$222,$111,$000
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even

copper:	
	dc.w	$8e,$2981,$90,$29C1,$92,$0038,$94,$00D0
	dc.w	$100,$1200,$102,0,$104,0,$108,0,$10a,0
pt_ecr	ds.w	nb_ecran*4
	dc.w	$180,$fff
coul1	dc.w	$182,0
	dc.w	$900f,$fffe
coul2	dc.w	$182,$fff
	dc.w	$f00f,$fffe,$182,0
	dc.w	$ffff,$fffe	
logo	incbin	"dess.profecy"
	even
logo2	incbin	"dess.numlog"
	even
new:
	movem.L	a0-a6/d0-d7,-(a7)
	bsr	mt_music
	btst	#6,$bfe001
	bne	notirq
	move.w	#1,light
notirq:
	move.b	$bfdd00,d0
	movem.L	(a7)+,a0-a6/d0-d7
	move.w	#$2000,$dff09c
	rte
light:dc.w 0
oldirq:dc.l 0

;нннннннннннннннннннннннннннннннннннннн
;н   NoisetrackerV1.0 replayroutine   н
;н Mahoney & Kaktus - HALLONSOFT 1989 н
;нннннннннннннннннннннннннннннннннннннн

mt_init:move.l	#mt_data3,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	move.l	#mt_data3,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	move.l	#mt_data3,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	move.l	#mt_data4,a0
	cmp.b	(a0),d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0

; -----------------------------------------el decompactor
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
	move.l	#3*11*512,d0
	move.l	#adresse_numeric,a2
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
data:		incbin mod.intro
		even
ecran	;ds.b	256*long_ecr
	;even
end

