
;	Assemble Program with no Options,then read
;	-CHARSET  with RI to  PICTURE
;	Save with WI  begin> BEGIN  end> ABSEND


org $70000	
load $70000	

begin:
move.l	$4,a6
jsr	-132(a6)	; Forbid !!!

move.b	#$ff,$bfd100	; switch df0: Drive Motor
move.b	#$87,$bfd100	; off

lea	gfxname,a1
jsr	-408(a6)
move.l	d0,gfxbase

; ------------------- delete RAM $50000-$70000

lea	$50000,a0
lea	$70000,a1

clloop:
clr.l	(a0)+
cmp.l	a0,a1
bne	clloop

; ------------------- Depacking of the CHARSET

lea	picture,a0	; Beginning of Picture
lea	$50000,a1	; Entpackted Picture
bsr	unpack
bsr	setupcol

; ------------------- Calc the 2.Turnphase of Scrolly

lea	rot,a0
lea	rot-32,a1
move.l	#17,d0

marot9:
move.l	#32,d7

marot:
move.b	(a1)+,d1
bmi	marot2
move.b	#31,d2
sub.b	d1,d2
move.b	d2,d1

marot2:
move.b	d1,(a0)+
sub.w	#1,d7
bne	marot

sub.w	#64,a1
sub.w	#1,d0
bne	marot9

; -------------------- Set Stripes

lea	sincop,a0
move.l	#$01800000,d0
move.l	#$2b11fffe,d1

move.l	#$63,d7

setsincop:
move.l	d1,(a0)+
move.l	d0,(a0)+
add.l	#$01000000,d1
sub.w	#1,d7
bne	setsincop

bsr	print		; Print PRG-Table

; ------------------ Set Stripe to first Program

clr.l	d1
move.w	prgtable,d1	
move.w	#$b1,d0
btst	#0,d1
bne	next
add.b	#5,d0

next:
lsr.w	#1,d1
mulu	#10,d1
sub.w	d1,d0
move.w	d0,str
bsr	setcop
move.w	#0,prg

; --------------------- Strange World

move.l	$6c,oldirq+2	; Set IRQ

move.l	gfxbase,a0
move.l	38(a0),oldclist ; Copper cabana set

move.w	#$8180,$dff096
move.l	#newclist,$dff080
clr.w	$dff088

move.b	$dff00a,mouse
move.l	#newirq,$6c

wait:			; wait,wait,wait ....
btst	#6,$bfe001
bne	wait

move.l	oldirq+2,$6c	; Set Old Times
move.l	oldclist,$dff080
clr.w	$dff088

move.w	prg,$0100

move.l	$4,a6
move.l	gfxbase,a1
jsr	-414(a6)

move.w	dma,$dff096

jsr	-138(a6)

rts			; Away Away Awy Ay A ...

dma:	dc.w	0
prg:	dc.w	0
str:	dc.w	0

setcop:
move.b	d0,chadr1
add.b	#1,d0
move.b	d0,chadr2
add.b	#1,d0
move.b	d0,chadr3
add.b	#8,d0
move.b	d0,chadr4
add.b	#1,d0
move.b	d0,chadr5
add.b	#1,d0
move.b	d0,chadr6
rts

nextchr:
move.w	#26,newchar
move.l	textzeiger,a6

nextchr1:
move.b	(a6)+,d0
bne	nextchr2
move.l	#text,a6
bra	nextchr1

nextchr2:
cmp.b	#'\',d0
bne	nextchr3
move.b	(a6)+,d0
sub.b	#'0',d0
move.b	d0,xshft+1
bra	nextchr1

nextchr3:
move.l	#38,d1
lea	asc,a0

lprint:
cmp.b	(a0,d1.l),d0
beq	okprint
sub.l	#1,d1
bpl	lprint
add.l	#1,a6
move.l	a6,textzeiger
rts

okprint:
lsl.l	#2,d1
add.l	#atable,d1
move.l	d1,a2
move.l	(a2),a0
lea	$60028,a1

move.l	a6,textzeiger

return:
move.l	#32,d0

loopset:
move.b	(a0),(a1)
move.b	1(a0),1(a1)
move.b	2(a0),2(a1)
clr.b	3(a1)
move.b	$28(a0),$2c(a1)
move.b	$29(a0),$2d(a1)
move.b	$2a(a0),$2e(a1)
clr.b	$2f(a1)
move.b	$50(a0),$58(a1)
move.b	$51(a0),$59(a1)
move.b	$52(a0),$5a(a1)
clr.b	$5b(a1)
add.l	#$78,a0
add.l	#$84,a1
sub.w	#1,d0
bne	loopset
rts

a = $50000
b = $50000 + [$28*3*32]
c = $50000 + [$28*3*64]
d = $50000 + [$28*3*96]

set8char:
lea	asc,a1
move.l	#38,d7

set8char2:
cmp.b	(a1,d7.l),d0
beq	set8ok
sub.w	#1,d7
bpl	set8char2
rts

set8ok:
lea	$50000+[96*$78],a1
add.l	d7,a1

move.l	#8,d7

set81:
move.b	(a1),(a0)
move.b	$28(a1),$28(a0)
move.b	$50(a1),$50(a0)
add.l	#$78,a1
add.l	#$78,a0
sub.w	#1,d7
bne	set81
rts

print:
lea	prgtable,a0
clr.l	d0
move.w	(a0)+,d7
move.w	d7,d0
lea	$56180,a1
move.l	#$48,d1
mulu	#10,d0
sub.l	d0,d1
lsr.l	#1,d1
mulu	#120,d1
add.l	d1,a1

nxtword:
clr.l	d1

cou:
tst.b	(a0,d1)
beq	endcou
add.l	#1,d1
bra	cou

endcou:
move.l	#40,d2
sub.l	d1,d2
lsr.l	#1,d2
move.l	d2,d5

nxtprt2:
clr.l	d0
move.b	(a0)+,d0
sub.w	#1,d1
bmi	nxttest

lea	$7e000,a6
movem.l	d0-d7/a0-a5,-(a6)
move.l	a1,a0
add.l	d5,a0
bsr	set8char
movem.l	(a6)+,d0-d7/a0-a5
add.l	#1,d5
bra	nxtprt2

nxttest:
add.l	#10*$78,a1
sub.w	#1,d7
bne	nxtword
rts

asc:	dc.b	"abcdefghijklmnopqrstuvwxyz0123456789?- "

even
atable:	dc.l	a,a+3,a+6,a+9,a+12,a+15,a+18,a+21,a+24,a+27
	dc.l	a+30,a+33,a+36
	dc.l	b,b+3,b+6,b+9,b+12,b+15,b+18,b+21,b+24,b+27
	dc.l	b+30,b+33,b+36
	dc.l	c,c+3,c+6,c+9,c+12,c+15,c+18,c+21,c+24,c+27
	dc.l	c+30,c+33,c+36

textzeiger:	dc.l	text

pointer:dc.l	eturntab-$20
addpoi:	dc.l	$ffffffe0
count:	dc.w	1

turntext:
sub.w	#1,count
bpl	turnte2
move.w	#1,count

turnte2:
bsr	clear

move.l	pointer,a0
lea	$60000,a1
move.l	#$20,d7

turn1:
clr.l	d0
move.b	(a0)+,d0
bmi	turn0
mulu	#120,d0
add.l	#$62000,d0
move.l	d0,$dff054
move.l	a1,$dff050
clr.w	$dff066
move.w	#4,$dff064
move.l	#$ffffffff,$dff044
clr.w	$dff042
move.w	#$09f0,$dff040
move.w	#$00d4,$dff058

turn2:
btst	#6,$dff002
bne	turn2

turn0:
add.l	#$84,a1
sub.w	#1,d7
bne	turn1
tst.w	count
bne	turn4
move.l	addpoi,d0
add.l	d0,pointer
cmp.l	#eturntab-$20,pointer
beq	turn3
cmp.l	#turntab,pointer
bne	turn4
neg.l	addpoi
bra	turn4

turn3:
neg.l	addpoi

turn4:
rts

clear:
clr.w	$dff066
clr.w	$dff042
move.l	#$62000,$dff054
move.w	#$0100,$dff040
move.w	#$103c,$dff058

clear1:
btst	#6,$dff002
bne	clear1
rts

stick:	dc.w	0

mouse:	dc.w	0
adress:	dc.w	0,0,0,1,2,3
sinpo:	dc.l	sin,sin+2,sin+4,sin+6,sin+8,sin+10

colour1:dc.w	$034,$038,$04c,$05f,$04c,$038,$034,0
	dc.w	$064,$078,$08c,$09f,$08c,$078,$064,0
	dc.w	$264,$387,$4aa,$5cd,$4aa,$387,$264,0
	dc.w	$462,$6a6,$8ca,$afc,$8ca,$6a6,$462,0
	dc.w	$460,$7a0,$ac0,$cf0,$ac0,$7a0,$460,0
	dc.w	$660,$aa0,$cc0,$ee0,$cc0,$aa0,$660,0
sin:
dc.w	0,0,0,1,1,1,2,2,2,3,3,4,4,5,6,7,9,7,6,5,4,4
dc.w	3,3,2,2,2,1,1,1,0,0,0
dc.w	0,0,0,-1,-1,-1,-2,-2,-2,-3,-3,-4,-4,-5,-6,-7,-9
dc.w	-7,-6,-5,-4,-4,-3,-3,-2,-2,-2,-1,-1,-1,0,0,0
esin:

newirq:
movem.l	d0-d7/a0-a6,-(a7)

lea	sincop,a0
add.l	#6,a0
move.l	#$63,d0

delcop:
clr.w	(a0)
add.l	#8,a0
sub.w	#1,d0
bne	delcop

lea	adress,a2
lea	sinpo,a3
lea	colour1,a1

move.l	#6,d7

setit:
clr.l	d0
move.w	(a2),d0
bsr	setstripes
bsr	setnew
sub.w	#1,d7
bne	setit
bra	nextirq

setnew:
move.l	(a3),a0
add.l	#2,a0
cmp.l	#esin,a0
blo	oksetnew
move.l	#sin,a0

oksetnew:
move.l	a0,(a3)+
move.w	(a0),d0
add.w	d0,(a2)+
rts

setstripes:		; D0 = Zeile / A1 = Colour
lea	sincop,a0
add.l	#6,a0
lsl.l	#3,d0
add.l	d0,a0
move.l	#8,d0

setstr:
move.w	(a1)+,(a0)
add.l	#8,a0
sub.w	#1,d0
bne	setstr
rts

nextirq:
clr.l	d0
move.b	mouse,d1
move.b	$dff00a,d0
tst.b	d1
cmp.b	#$e0,d1
blo	nok1
cmp.b	#$40,d0
bhi	nok1

nok3:
move.b	d0,mouse
move.b	d0,d1
bra	nok2

nok1:
cmp.b	#$20,d1
bhi	nok2
cmp.b	#$c0,d0
bhi	nok3

nok2:
move.b	d0,d2
lsr.b	#4,d0
lsr.b	#4,d1
sub.b	d0,d1
beq	okirq
bmi	up

down:
move.b	d2,mouse
tst.w	prg
beq	okirq
sub.w	#1,prg
bra	okirq

up:
move.b	d2,mouse
move.w	prgtable,d1
sub.w	#1,d1
cmp.w	prg,d1
beq	okirq
add.w	#1,prg

okirq:
clr.l	d0
move.w	prg,d0
mulu	#10,d0
add.w	str,d0
bsr	setcop

move.l	#$60000,d0
bsr	scroll
tst.w	newchar
bpl	irq1
bsr	nextchr

irq1:
bsr	turntext

endirq:
movem.l	(sp)+,d0-d7/a0-a6
oldirq:
jmp	$000000


joy:
clr.l	d0
move.b	$bfe001,d2
btst	#7,d2
bne	n5
or.b	#$80,d0

n5:
rts

unpack:	add.l	#12,a0
	move.l	4(a0),d0
	add.l	d0,a0
	add.l	#8,a0
	move.l	a0,cmapchunk

iff1:	cmp.l	#$424f4459,(a0)
	beq	iff0
	add.l	#2,a0
	bra	iff1

iff0:	move.l	4(a0),d0	; Anzahl Bytes
	add.l	#1,d0
	and.l	#$fffffffe,d0

	add.l	#8,a0		; Pointer to first Byte

iff4:	clr.l	d2
	move.b	(a0)+,d2
	bmi	iff6

iff5:	move.b	(a0)+,(a1)+
	subi.l	#1,d0
	subi.b	#1,d2
	bpl	iff5
	bra	iff7
	
iff6:	neg.b	d2
	beq	iff7

iff61:	move.b	(a0),(a1)+
	subi.b	#1,d2
	bpl	iff61
	subi.l	#1,d0
	add.l	#1,a0

iff7:	subi.l	#1,d0
	bmi	iff8
	beq	iff8
	bra	iff4

iff8:	move.l	cmapchunk,a0
	move.l	cmap,a1
	add.l	#8,a0
	move.l	#8,d0

cmaploop:
	clr.l	d1
	move.b	(a0),d1
	lsl.w	#4,d1
	move.b	2(a0),d1
	lsr.b	#4,d1
	or.b	1(a0),d1
	move.w	d1,(a1)+
	add.l	#3,a0
	sub.w	#1,d0
	bne	cmaploop
	rts

cmapchunk:
	dc.l	0

cmap:	dc.l	color1

color1:	blk.w	8,0

setupcol:
lea	color1,a0
lea	copcol,a1
move.l	#$01800000,d0
move.l	#8,d1

suc1:
move.w	(a0)+,d0
move.l	d0,(a1)+
add.l	#$00020000,d0
sub.w	#1,d1
bne	suc1
rts

newchar:dc.w	24
xshft:	dc.w	1

scroll:	tst.w	xshft
	bne	scroll2
	rts

scroll2:move.w	xshft,d1
	sub.w	d1,newchar
	move.l	d0,$dff054
	add.l	#2,d0
	move.l	d0,$dff050
	move.w	#0,$dff064
	move.w	#0,$dff066
	move.l	#$ffffffff,$dff044
	move.w	#16,d1
	sub.w	xshft,d1
	lsl.w	#8,d1
	lsl.w	#4,d1
	or.w	#$09f0,d1
	move.w	d1,$dff040
	move.w	#0,$dff042
	move.w	#$1816,$dff058
	bra	clear1

newclist:
dc.w	$008e,$2c81,$0090,$0ac1,$0092,$0038,$0094,$00d0
dc.w	$0102,$0000,$0104,$001f,$0108,$0050,$010a,$0050
dc.w	$0100,$3200,$0180,$0000

adr:
dc.w	$00e0,$0005,$00e2,$30c0,$00e4,$0005,$00e6,$30e8
dc.w	$00e8,$0005,$00ea,$3110
dc.w	$120,0,$122,0,$124,0,$126,0,$128,0,$12a,0,$12c,0
dc.w	$12e,0,$130,0,$132,0,$134,0,$136,0,$138,0,$13a,0
dc.w	$13c,0,$13e,0
copcol:
blk.l	8,0
dc.w	$180,$444
dc.w	$2711,$fffe,$180,$333
dc.w	$2811,$fffe,$180,$222
dc.w	$2911,$fffe,$180,$111
dc.w	$2a11,$fffe,$180,$000
sincop:
blk.l	2*$63,0
dc.w	$8e11,$fffe,$180,$222
dc.w	$182,$999,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,$999
dc.w	$8f11,$fffe,$180,$333
dc.w	$9011,$fffe,$180,$444
chadr1:
dc.w	$b111,$fffe,$180,$225,$182,$ddd,$18e,$ddd
chadr2:
dc.w	$b211,$fffe,$180,$118
chadr3:
dc.w	$b311,$fffe,$180,$00c
chadr4:
dc.w	$bb11,$fffe,$180,$118
chadr5:
dc.w	$bc11,$fffe,$180,$225
chadr6:
dc.w	$bd11,$fffe,$180,$444,$182,$999,$18e,$999

dc.w	$dd11,$fffe,$180,$333
dc.w	$de11,$fffe,$180,$222
dc.w	$df11,$fffe,$180,$111
dc.w	$e011,$fffe,$180,0,$0100,$0200
dc.w	$e611,$fffe,$180,$111
dc.w	$e711,$fffe,$180,$221
dc.w	$e811,$fffe,$e0,$0006,$e2,$2000,$e4,$0006,$e6,$2028
dc.w	$e8,$6,$ea,$2050,$108,$50,$10a,$50,$180,$332,$182,$db8
dc.w	$184,$ea0,$186,$d90,$188,$c80,$18a,$b70,$18c,$a60
dc.w	$18e,$950
dc.w	$e911,$fffe,$180,$442
dc.w	$ea11,$fffe,$180,$553,$0100,$3200
dc.w	$ffd5,$fffe,$190,0,$190,0
dc.w	$0a11,$fffe,$180,$442
dc.w	$0b11,$fffe,$180,$332
dc.w	$0c11,$fffe,$180,$221
dc.w	$0d11,$fffe,$180,$111
dc.w	$0e11,$fffe,$180,0
dc.w	$2511,$fffe,$180,$111
dc.w	$2611,$fffe,$180,$222
dc.w	$2711,$fffe,$180,$333
dc.w	$2811,$fffe,$180,$444
dc.w	$ffff,$fffe
end:

oldclist:
dc.l	0
gfxbase:
dc.l	0
gfxname:
dc.b	"graphics.library",0
even

turntab:
dc.l	$00010203,$04050607,$08090a0b,$0c0d0e0f
dc.l	$10111213,$14151617,$18191a1b,$1c1d1e1f
dc.l	$00010203,$04050607,$08090a0b,$0c0d0e0f
dc.l	$10111213,$14151617,$18191a1b,$1c1d1e1f
dc.l	$00010203,$04050607,$08090a0b,$0c0d0e0f
dc.l	$10111213,$14151617,$18191a1b,$1c1d1e1f
dc.l	$010203ff,$04050607,$08090a0b,$0c0d0e0f
dc.l	$10111213,$14151617,$1819ff1a,$1b1c1d1e
dc.l	$01020304,$05060708,$ff090a0b,$0c0d0e0f
dc.l	$101112ff,$13141516,$1718191a,$1b1c1d1e
dc.l	$0203ff04,$05060708,$090aff0b,$0c0d0e0f
dc.l	$101112ff,$13141516,$171819ff,$1a1b1c1d
dc.l	$ff030405,$0607ff08,$090a0b0c,$ff0d0e0f
dc.l	$10ff1112,$131415ff,$16171819,$1aff1b1c
dc.l	$03040506,$ff070809,$ff0a0b0c,$ff0d0e0f
dc.l	$10ff1112,$13ff1415,$16ff1718,$191aff1b
dc.l	$040506ff,$0708ff09,$0aff0b0c,$0dff0e0f
dc.l	$ff101112,$ff1314ff,$1516ff17,$1819ff1a
dc.l	$ff06ff07,$08ff090a,$ff0bff0c,$0dff0e0f
dc.l	$ff1011ff,$12ff1314,$ff1516ff,$17ff1819
dc.l	$ff07ff08,$09ff0aff,$0bff0cff,$0dff0e0f
dc.l	$ff10ff11,$ff12ff13,$ff1415ff,$16ff1718
dc.l	$08ffff09,$ff0aff0b,$ff0cff0d,$ff0effff
dc.l	$0fff10ff,$11ff12ff,$13ff14ff,$ff15ff16
dc.l	$09ff0aff,$ff0bffff,$0cff0dff,$ff0effff
dc.l	$0fffff10,$ff11ffff,$12ffff13,$ff14ff15
dc.l	$ffff0bff,$ff0cffff,$ff0dffff,$ff0effff
dc.l	$0fffffff,$10ffffff,$11ffff12,$ffffff13
dc.l	$ff0cffff,$ffff0dff,$ffffffff,$0effffff
dc.l	$ff0fffff,$ffffff10,$ffffffff,$11ffff12
dc.l	$ffffffff,$ffffffff,$0effffff,$ffffffff
dc.l	$ff0fffff,$ffffff10,$ffffffff,$11ffff12
dc.l	$ffffffff,$ffffffff,$ffffffff,$ffff0fff
dc.l	$ffffffff,$ffffffff,$10ffffff,$ffffff11

rot:
blk.l	17*8,0

eturntab:

prgtable:
dc.w	3
dc.b	"seka assembler",0,"booter instruction",0
dc.b	"22kb bootmaker",0,"prgname",0
dc.b	"prgname",0,"prgname",0
dc.b	"prgname",0
even

text:	dc.b "\3alpha flight presents their"
	dc.b " boot control system             "
	dc.b "\4choose the shit ya wanna load"
	dc.b "             \4written by             \1danny"
	dc.b "       \3 greetings to all other members"
	dc.b " of the world ruling     \1afl    \0 ",0
even


picture:

absend = $75700
