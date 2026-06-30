
; ** Marty´s Demo No. 1 **

mty:
move.l	$04,a6
lea	gfxname,a1
jsr	-408(a6)
move.l	d0,gfxbase
lea	dfname,a1
jsr	-408(a6)
move.l	d0,dfbase
move.l	dfbase,a6
lea	chardevs,a0
jsr	-30(a6)
move.l	d0,fontbase
move.l	gfxbase,a0
move.l	50(a0),oldclist
move.l	#newclist,50(a0)
move.l	gfxbase,a6
lea	bitmap,a0
move.l	#$01,d0
move.l	#336,d1
move.l	#200,d2
jsr	-390(a6)
move.l	#$60000,plane1
lea	rastport,a1
jsr	-198(a6)
move.l	#bitmap,r_bitmap
move.l	fontbase,a0
lea	rastport,a1
jsr	-66(a6)
lea	rastport,a1
jsr	-48(a6)
move.l	gfxbase,a6
move.l	#130,d0
move.l	#50,d1
lea	rastport,a1
jsr	-240(a6)
lea	tx,a0
move.l	#5,d0
jsr	-60(a6)
move.l	#120,d0
move.l	#80,d1
lea	rastport,a1
jsr	-240(a6)
lea	tx2,a0
move.l	#9,d0
jsr	-60(a6)
move.l	#105,d0
move.l	#100,d1
lea	rastport,a1
jsr	-240(a6)
lea	tx3,a0
move.l	#11,d0
jsr	-60(a6)
	
lea	sprt1,a0
move.l	#$65000,a1
lea	sprt2,a2
move.l	#$65100,a3
lea	sprt3,a4
move.l	#$65200,a5

lo:	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	move.l	(a4)+,(a5)+
	cmpa.l	#e1,a0
	bne	lo
	
lea	sprt4,a0
move.l	#$65300,a1
lea	sprt5,a2
move.l	#$65400,a3

lo2:	move.l	(a0)+,(a1)+
	move.l	(a2)+,(a3)+
	cmpa.l	#e4,a0
	bne 	lo2

lea	col,a0
move.l	#$0000,d0
lo4:	move.w	d0,(a0)+
	addi.w	#$0111,d0
	cmp	#$0fff,d0
	bne lo4
lo5:	move.w	d0,(a0)+
	subi.w	#$0111,d0
	cmp	#$0000,d0
	bne	lo5


move.l	#scrollm,zeiger
move.l	$6c,oldirq+2
move.l	#newirq,$6c
move.l	#tab,pt
move.w	#$83a0,$dff096
move.l	#0,$66000
wait:
btst	#6,$bfe001
bne.s	wait
move.l	oldirq+2,$6c
move.l	gfxbase,a0
move.l	oldclist,50(a0)
move.l	$04,a6
move.l	gfxbase,a1
jsr	-414(a6)
move.l	dfbase,a1
jsr	-414(a6)
rts

newirq:
movem.l	d0-d7/a0-a6,-(sp)
move.l	gfxbase,a6
lea	rastport,a1
move.l	#$01,d0
clr.l	d1
clr.l	d2
move.l	#180,d3
move.l	#336,d4
move.l	#200,d5
jsr	-396(a6)
lea	rastport,a1
clr.l	d0
move.l	pt,a0
move.l	(a0),d1
move.l	#100,d2
clr.l	d3
move.l	#200,d4
move.l	#70,d5
jsr	-396(a6)
addi.l	#4,pt
cmp.l	#ed,pt
bne	ll
move.l	#tab,pt
ll:
subi.l	#1,count
tst.l	count
bne	l2
move.l	#3,count
move.b	s+6,d0
lea	s,a0
l1:
move.b	18(a0),6(a0)
adda.l	#12,a0
cmp.l	#d,a0
bne	l1
move.b	d0,d+6
lea	s1,a0
lo6:
move.w	14(a0),6(a0)
adda.l	#4,a0
cmp.l	#en,a0
bne	lo6
move.l	colpnt,a0
lea	col,a1
cmp.l	#colend-col,a0
bne	lo7
move.l	#0,colpnt
move.l	#0,a0
lo7:
move.w	(a0,a1),en+6
addi.l	#2,colpnt
l2:
lea	mem,a0
move.b	4(a0),$65101
move.b	5(a0),d0
move.b	d0,$65100
addi.b	#15,d0
move.b	d0,$65102
move.b	10(a0),$65201
move.b	11(a0),d0
move.b	d0,$65200
addi.b	#15,d0
move.b	d0,$65202
move.b	16(a0),$65301
move.b	17(a0),d0
move.b	d0,$65300
addi.b	#15,d0
move.b	d0,$65302
move.b	22(a0),$65401
move.b	23(a0),d0
move.b	d0,$65400
addi.b	#15,d0
move.b	d0,$65402
bsr	mov
move.l	#50,d1
move.l	pnt1,d0
jsr	trig
move.b	d7,$65001
move.b	d7,mem
move.l	pnt2,d0
jsr 	trig
move.b	d7,$65000
move.b	d7,mem+1
addi.b	#15,d7
move.b	d7,$65002
addi.l	#3,pnt1
addi.l	#5,pnt2
l3:
sub.b	#$01,rows
bne.s	exit
move.b	#$0c,rows
lea	rastport,a1
move.l	#320,d0
move.l	#198,d1
jsr	-240(a6)
lea	rastport,a1
move.l	zeiger,a0
move.l	#$01,d0
jsr	-60(a6)
addq.l	#$01,zeiger
cmp.l	#end,zeiger
blt.s	exit
move.l	#scrollm,zeiger
exit:
movem.l	(sp)+,d0-d7/a0-a6
oldirq:
jmp	$00000000

trig:

divs   #360,d0
swap   d0
move.w d0,a0
clr.l  d7
lea    SinTab,a1
move.b (a1,a0),d7
addi.b #100,d7
muls   d1,d7
divs   #100,d7
addi.l #100,d7
rts


mov:

lea	memend-2,a0
move.l	#memend,a1

lo3:	move.w	-(a0),-(a1)
	cmpa.l	#mem-2,a0
	bne lo3
rts


newclist:
dc.w	$008e,$2c81,$0090,$f4c1,$0092,$0038,$0094,$00d0
dc.w	$0102,$0000,$0104,$0000,$0108,$0002,$010a,$0002
dc.w	$0100,$1200,$0180,$0000,$0182,$0fff

dc.w	$0120,$0006,$0122,$5000
dc.w	$0124,$0006,$0126,$5100
dc.w	$0128,$0006,$012a,$5200
dc.w	$012c,$0006,$012e,$5300
dc.w	$0130,$0006,$0132,$5400
dc.w	$0134,$0006,$0136,$6000
dc.w	$0138,$0006,$013a,$6000
dc.w	$012c,$0006,$013e,$6000

dc.w	$01a2,$044f,$01a4,$077f,$01a6,$0aaf
dc.w	$01aa,$044f,$01ac,$077f,$01ae,$0aaf
dc.w	$01b2,$044f,$01b4,$077f,$01b6,$0aaf

dc.w	$00e0,$0006,$00e2,$0000

dc.w	$3201,$ff00,$180,$0110
dc.w	$3301,$ff00,$180,$0330
dc.w	$3401,$ff00,$180,$0550
dc.w	$3501,$ff00,$180,$0770
dc.w	$3601,$ff00,$180,$0990
dc.w	$3701,$ff00,$180,$0bb0
dc.w	$3801,$ff00,$180,$0dd0
dc.w	$3901,$ff00,$180,$0ff1
dc.w	$3a01,$ff00,$180,$0dd3
dc.w	$3b01,$ff00,$180,$0bb5
dc.w	$3c01,$ff00,$180,$0997
dc.w	$3d01,$ff00,$180,$0779
dc.w	$3e01,$ff00,$180,$055b
dc.w	$3f01,$ff00,$180,$033d
dc.w	$4001,$ff00,$180,$011f
dc.w	$4101,$ff00,$180,$000d
dc.w	$4201,$ff00,$180,$000b
dc.w	$4301,$ff00,$180,$0009
dc.w	$4401,$ff00,$180,$0007
dc.w	$4501,$ff00,$180,$0005
dc.w	$4601,$ff00,$180,$0003
dc.w	$4701,$ff00,$180,$0001
dc.w	$4801,$ff00,$180,$0000

dc.w	$5501,$ff00,$182,$0f00
dc.w	$5601,$ff00,$182,$0e01
dc.w	$5701,$ff00,$182,$0d02
dc.w	$5801,$ff00,$182,$0c03
dc.w	$5901,$ff00,$182,$0b04
dc.w	$5a01,$ff00,$182,$0a05
dc.w	$5b01,$ff00,$182,$0906
dc.w	$5c01,$ff00,$182,$0807
dc.w	$5d01,$ff00,$182,$0708
dc.w	$5e01,$ff00,$182,$0608
dc.w	$5f01,$ff00,$182,$050a
dc.w	$6001,$ff00,$182,$040b
dc.w	$6101,$ff00,$182,$030c
dc.w	$6201,$ff00,$182,$020d
dc.w	$6301,$ff00,$182,$010e
dc.w	$6401,$ff00,$182,$000f
dc.w	$6501,$ff00,$182,$001e
dc.w	$6601,$ff00,$182,$002d
dc.w	$6701,$ff00,$182,$003c
dc.w	$6801,$ff00,$182,$004b
dc.w	$6901,$ff00,$182,$005a
dc.w	$6a01,$ff00,$182,$0069
dc.w	$6b01,$ff00,$182,$0078
dc.w	$6c01,$ff00,$182,$0087
dc.w	$6d01,$ff00,$182,$0096
dc.w	$6e01,$ff00,$182,$005d

dc.w	$7301,$ff00,$182,$00ff
dc.w	$7401,$ff00,$182,$01ee
dc.w	$7501,$ff00,$182,$02dd
dc.w	$7601,$ff00,$182,$03cc
dc.w	$7701,$ff00,$182,$04bb
dc.w	$7801,$ff00,$182,$05aa
dc.w	$7901,$ff00,$182,$0699
dc.w	$7a01,$ff00,$182,$0788
dc.w	$7b01,$ff00,$182,$0877
dc.w	$7c01,$ff00,$182,$0866
dc.w	$7d01,$ff00,$182,$0955
dc.w	$7e01,$ff00,$182,$0a44
dc.w	$7f01,$ff00,$182,$0b33

s1:
dc.w	$8701,$ff00,$182,$0000
dc.w	$8801,$ff00,$182,$0000
dc.w	$8901,$ff00,$182,$0000
dc.w	$8a01,$ff00,$182,$0000
dc.w	$8b01,$ff00,$182,$0000
dc.w	$8c01,$ff00,$182,$0000
dc.w	$8d01,$ff00,$182,$0000
dc.w	$8e01,$ff00,$182,$0000
dc.w	$8f01,$ff00,$182,$0000
en:
dc.w	$9001,$ff00,$182,$0000

dc.w	$e601,$ff00,$180,$0660
s: dc.w	$e801,$ff00,$182,$0400,$180,$022f
dc.w 	$e901,$ff00,$182,$0600,$180,$044c
dc.w	$ea01,$ff00,$182,$0800,$180,$066a
dc.w	$eb01,$ff00,$182,$0a00,$180,$0888
dc.w	$ec01,$ff00,$182,$0c00,$180,$0aa6
dc.w	$ed01,$ff00,$182,$0e00,$180,$0ee1
dc.w	$ee01,$ff00,$182,$0e00,$180,$0ee1
dc.w	$ef01,$ff00,$182,$0c00,$180,$0aa6
dc.w	$f001,$ff00,$182,$0a00,$180,$0888
dc.w	$f101,$ff00,$182,$0800,$180,$066a
dc.w	$f201,$ff00,$182,$0600,$180,$044c
dc.w	$f301,$ff00,$182,$0400,$180,$022f
d: dc.w	$f401,$ff00,$182,$0000,$180,$000f
dc.w	$f501,$ff00,$180,$0660,$f701,$ff00,$180,$0000


dc.w	$ffff,$fffe

sprt1:

dc.w	$6d60,$7d00
dc.w	%0000000000000000,%0000000000000000
dc.w	%0001000000001000,%0000000000000000
dc.w	%0010100000010100,%0001000000001000
dc.w	%0101010000101010,%0011100000011100
dc.w	%1011101001011101,%0111110000111110
dc.w	%1011110110111101,%0111111001111110
dc.w	%1011111001111101,%0111111111111110
dc.w	%1011111111111101,%0111111111111110
dc.w	%1011011111101101,%0111111111111110
dc.w	%1010101111010101,%0111011111101110
dc.w 	%1010110110110101,%0111001111001110
dc.w	%1010101001010101,%0111000110001110
dc.w	%0100100110010010,%0011000000001100
dc.w	%0110100000010110,%0001000000001000
dc.w	%0011100000011100,%0000000000000000
dc.w	%0000100000010000,%0000000000000000
dc.w	0,0
e1:

sprt2:

dc.w	$9d60,$ad00
dc.w	%0000111111110000,%0000000000000000
dc.w	%0001000000001000,%0000111111110000
dc.w	%0010100000010100,%0001111111111000
dc.w	%0101011111101010,%0011100000011100
dc.w	%1010100000010101,%0111000000001110
dc.w	%1010100000010101,%0111000000001110
dc.w	%1010100000010101,%0111000000001110
dc.w	%1011011111101101,%0111100000011110
dc.w	%1011100000011101,%0111111111111110
dc.w	%1011011111101101,%0111100000011110
dc.w	%1010100000010101,%0111000000001110
dc.w	%1010100000010101,%0111000000001110
dc.w	%0100100000010010,%0011000000001100
dc.w	%0010100000010100,%0001000000001000
dc.w	%0001100000011000,%0000000000000000
dc.w	0,0
e2:

sprt3:

dc.w	$9d80,$ad00
dc.w	%0000111111110000,%0000000000000000
dc.w	%0001000000001000,%0000111111110000
dc.w	%0010101111010100,%0001110000111000
dc.w	%0101010000101010,%0011100000011100
dc.w	%1010100000010101,%0111000000001110
dc.w	%1001000000001001,%0110000000000110
dc.w	%1001111111111001,%0110000000000110
dc.w	%1010000000000101,%0111111111111110
dc.w	%1010011111111001,%0111111111111110
dc.w	%1001101111110111,%0110011111111000
dc.w	%1001010011101000,%0110001111110000
dc.w	%1001001101101000,%0110000011110000
dc.w	%0101000010010110,%0010000001111000
dc.w	%0011000001100100,%0000000000011000
dc.w	%0011000000011000,%0000000000000000
dc.w	0,0
e3:			

sprt4:

dc.w	$7d90,$8d00
dc.w	%0000111111110000,%0000000000000000
dc.w	%0001000000001000,%0000111111110000
dc.w	%0010111111110100,%0001111111111000
dc.w	%0101111111111010,%0011111111111100
dc.w	%1000011111100001,%0111111111111110
dc.w	%1111100110011111,%0000011111100000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000011001100000,%0000000110000000
dc.w	%0000001111000000,%0000000000000000
dc.w	0,0
e4:

sprt5:

dc.w	$7d50,$8c00
dc.w	%1111100000011111,%0000000000000000
dc.w	%1000100000010001,%0111000000001110
dc.w	%0101010000101010,%0011100000011100
dc.w	%0101010000101010,%0011100000011100
dc.w	%0010101001010100,%0001110000111000
dc.w	%0010101001010100,%0001110000111000
dc.w	%0010001111000100,%0001110000111000
dc.w	%0001010000101000,%0000111111110000
dc.w	%0000100110010000,%0000011111100000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000010110100000,%0000001111000000
dc.w	%0000011001100000,%0000000110000000
dc.w	%0000001111000000,%0000000000000000
dc.w	0,0
e5:


scrollm:
dc.b	"HI ! Who got hisself a sound digitizer ? I gotta get some"
dc.b	" sounds digitized an' the guy who said he'd get a digitizer "
dc.b	"chickened out in the last minute [no offense]. ## I kinda "
dc.b 	"like the AMIGA 'cause you gotta be nutty as hell to make "
dc.b	"any kinda sense outa it. 'Specially 'C' is a language that"
dc.b	" can get the key-punch bloody well in dire straits. And "
dc.b	"then the feckin' long wait for compilation !! It certainly "
dc.b	"won't blow ma mind. Write a program in cool assembler an' "
dc.b	"everything's clear 's mud while when ye write it in 'C' ye "
dc.b	"need an expert to explain what yer own prog's s'posed to do."
dc.b	"Na, 'C' is nuffn good fer I. ## I say, I'll give yer a piece"
dc.b	" of ma min'. The feckin' Jacks at Commodore kinda must have "
dc.b	"flipped their lid. They don' even deliver a DOS Manunal "
dc.b	"with the AMIGA 500. Stark mad ! ## Now the obligatory "
dc.b	"greetings to the following guys: Danny (gimme back my book),"
dc.b	" Firelord (whatabout the INTUITION Reference Manual -or what"
dc.b	" ever the feckin' name is- ? Got one ?), Keyboard Kid, MCS, "
dc.b	"Frank, FDT, Tom"
dc.b	"AJA, Druid and HQC of HQC. Special thanks to HQC for handing"
dc.b	" out a few sourcecodes that showed me how to write this demo"
dc.b	" !!!      --- To get the hell outa here hit left Mouse "
dc.b	"Button. ---                  "
end:
even
colpnt:
dc.l	0
zeiger:
dc.l	0
oldclist:
dc.l	0
gfxbase:
dc.l	0
dfbase:
dc.l	0
fontbase:
dc.l	0
pt:
dc.l  	0
pnt1:
dc.l	0
pnt2:
dc.l	0
count:
dc.l	3
dfname:
dc.b	"diskfont.library",0
even
gfxname:
dc.b	"graphics.library",0
even
bitmap:
blk.w	4,0
plane1:
blk.l	30,0
rastport:
dc.l	0
r_bitmap:
blk.l	30,0
rows:
dc.b	1
even
chardevs:
dc.l	fontname
dc.w	14
dc.w	0

fontname:	dc.b "opal.font",0
even
tx:		dc.b "MARTY"
even
tx2:		dc.b "presents:"
even
tx3:		dc.b "A mini DEMO"
even
tab:
dc.l	-1,-1,-1,-1,-1,-2,-2,-2,-2,-3,1,2,2,2,2,2,1,1,1,1,1
ed:
even

SinTab:               ; Einheit: 100*sin(x)

dc.b 0,1,3,5,6,8,10,12,13,15,17,19,20,22,24,25,27,29,30,32,34,35,37,39
dc.b 40,42,43,45,46,48,49,51,52,54,55,57,58,60,61,62,64,65,66,68,69,70
dc.b 71,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,89,90,91,92
dc.b 92,93,93,94,95,95,96,96,97,97,97,98,98,98,99,99,99,99,99,99,99,99
dc.b 99,99,99,99,99,99,99,99,99,98,98,98,97,97,97,96,96,95,95,94,93,93
dc.b 92,92,91,90,89,89,88,87,86,85,84,83,82,81,80,79,78,77,76,75,74,73
dc.b 72,71,70,69,68,66,65,64,62,61,60,58,57,55,54,52,51,50,48,46,45,43
dc.b 42,40,39,37,35,34,32,30,29,27,25,24,22,20,19,17,15,13,12,10,8,6,5
dc.b 3,1,0,-2,-4,-6,-7,-9,-11,-13,-14,-16,-18,-20,-21,-23,-25,-26,-28
dc.b -30,-31,-33,-35,-36,-38,-40,-41,-43,-44,-46,-47,-49,-50,-52,-53
dc.b -55,-56,-58,-59,-61,-62,-63,-65,-66,-67,-69,-70,-71,-72,-74,-75
dc.b -76,-77,-78,-79,-80,-81,-82,-83,-84,-85,-86,-87,-88,-89,-90,-90
dc.b -91,-92,-93,-93,-94,-94,-95,-96,-96,-97,-97,-98,-98,-98,-99,-99
dc.b -99,-100,-100,-100,-100,-100,-100,-100,-100,-100,-100,-100,-100
dc.b -100,-100,-100,-100,-100,-99,-99,-99,-98,-98,-98,-97,-97,-96,-96
dc.b -95,-94,-94,-93,-93,-92,-91,-90,-90,-89,-88,-87,-86,-85,-84,-83
dc.b -82,-81,-80,-79,-78,-77,-76,-75,-74,-72,-71,-70,-69,-67,-66,-65
dc.b -63,-62,-61,-59,-58,-56,-55,-53,-52,-51,-49,-47,-46,-44,-43,-41
dc.b -40,-38,-36,-35,-33,-31,-30,-28,-26,-25,-23,-21,-20,-18,-16,-14
dc.b -13,-11,-9,-7,-6,-4,-2
even

mem:	blk.b	24,0
memend:
col:	blk.w	30,0
colend:
