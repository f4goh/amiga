org $70000
load $70000

go:

move.l	$04,a6
lea	gfxname,a1
jsr	-408(a6)
move.l	d0,gfxbase
move.l	d0,a0
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
lea	rastport,a1
jsr	-48(a6)
move.l	#scrollm,zeiger

move.l	#40,d6
move.l	#sterne,a2
loop9:
jsr	rnd
and.l	#$0000ffff,d0
mulu	#330,d0
swap	d0
move.w	d0,(a2)+
jsr	rnd
and.l	#$0000ffff,d0
mulu	#190,d0
swap	d0
move.b	d0,(a2)+
jsr	rnd
and.l	#$00000003,d0
addi.l	#2,d0
move.b	d0,(a2)+
subi.l	#1,d6
bne	loop9

move.l	$6c,oldirq+2
move.l	#newirq,$6c
wait:
btst	#6,$bfe001
bne.s	wait
move.l	oldirq+2,$6c
move.l	gfxbase,a0
move.l	oldclist,50(a0)
move.l	$04,a6
move.l	gfxbase,a1
jsr	-414(a6)
rts

newirq:
movem.l	d0-d7/a0-a6,-(sp)
jmp	stern
scroll:
move.l	gfxbase,a6
lea	rastport,a1
move.l	#$01,d0
clr.l	d1
clr.l	d2
move.l	#190,d3
move.l	#336,d4
move.l	#200,d5
jsr	-396(a6)
sub.b	#$01,rows
bne.s	exit
move.b	#$08,rows
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
rts

stern:
move.l	#40,d0
move.l	#sterne,a0
move.l	#$60000,a5

loop:
clr.l	d5
clr.l	d6
move.w	(a0)+,d5
move.b	(a0)+,d6
jsr	clear
clr.l	d1
move.b	(a0)+,d1
clr.l	d2
move.w	-4(a0),d2
subi.l	d1,d2
bpl	ok2
move.w	#335,d2
ok2:
move.w	d2,-4(a0)
clr.l	d5
clr.l	d6
move.w	d2,d5
move.b	-2(a0),d6
jsr	set
subi.l	#1,d0
bne	loop
jsr	scroll
movem.l	(sp)+,d0-d7/a0-a6
oldirq:
jmp	$00000000

rechnen:
move.l	d5,d4
lsr.w	#3,d5
mulu	#42,d6
add.w	d5,d6
and.b	#$7,d4
move.b	#$7,d5
sub.b	d4,d5
rts

clear:
jsr	rechnen
bclr	d5,(a5,d6)
rts

set:
jsr	rechnen
bset	d5,(a5,d6)
rts

rnd:
move.l	zufall,d0
move.w	#7,d3
label:
move.b	d0,d1
move.b	d0,d2
lsr.b	#3,d1
lsr.b	#1,d2
eor.b	d1,d2
lsr.b	#1,d2
roxr.l	#1,d0
move.l	d0,zufall
dbra	d3,label
rts

zufall:	dc.l 523476729

sterne:
dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

newclist:
dc.w	$008e,$2c81,$0090,$f4c1,$0092,$0038,$0094,$00d0
dc.w	$0102,$0000,$0104,$0000,$0108,$0002,$010a,$0002
dc.w	$0100,$1200,$0180,$0000,$0182,$0fff
dc.w	$00e0,$0006,$00e2,$0000
dc.w	$ffff,$fffe
scrollm:
dc.b	"High Quality Crackings "
end:
even
zeiger:
dc.l	0
oldclist:
dc.l	0
gfxbase:
dc.l	0
gfxname:
dc.b	"graphics.library",0
even
bitmap:
blk.w	4,0
plane1:
blk.l	20,0
rastport:
dc.l	0
r_bitmap:
blk.l	30,0
rows:
dc.b	2
