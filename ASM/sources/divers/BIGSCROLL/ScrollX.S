gfxb=$7ff00
count=$7ff04
baba=$7ff08
charp=$7ff0c
oldcop=$7ff10
intrpt=$7ff14
count2=$7ff18

rastport=$7fe00
bitmap=$7fea0

org $40000
load $40000

beg:
movem.l a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0,-(A7)
move.l #scrolly,charp			; Where scrolly resides
move.l $000004,a6
lea    glib,a1
jsr    -408(a6)
move.l d0,a6
move.l a6,gfxbase

lea	bitmap,a0
moveq	#1,d0
moveq	#8,d1
moveq	#8,d2
jsr	-390(a6)			; InitBitmap

lea	bitmap,a0
move.l	#work,8(a0)

lea	rastport,a1
jsr	-198(a6)			; InitRastPort

lea	bitmap,a0
move.l	a0,rastport+4			; struct BitMap *bitmap

move.b #1,count2
move.b #$08,count
lea    $48000,a0
moveq  #$7f,d0
clrmem:
clr.l  (a0)+
dbf    d0,clrmem
move.w #$8380,$dff096
move.w #$0020,$dff096
move.w #$4000,$dff09a
chkbtn:
btst   #6,$bfe001
beq    pressed
cmpi.b #228,$dff006
bne.s  chkbtn
move.w #$00f,$dff180
move.l #copl,$dff080
lea    $dff000,a0
clr.l  $120(a0)
clr.w  $102(a0)
move.l #$c9f00000,$40(a0)
move.l #$ffffffff,$44(a0)
move.l #$00048000,$50(a0)
move.l #$00047ffe,$54(a0)
clr.l  $64(a0)
move.w #$1018,$58(a0)
wtbl:
btst   #$e,$dff002
bne.s  wtbl
move.l #$c9f00000,$40(a0)
move.l #$ffffffff,$44(a0)
move.l #$00049000,$50(a0)
move.l #$00048ffe,$54(a0)
clr.l  $64(a0)
move.w #$1018,$58(a0)
wtbl2:
btst   #$e,$dff002
bne.s  wtbl2
subq.b #$04,count
bne.L  endint
move.b #$08,count
scroll:
subq.b #$01,count2
bne.s  nonewchar
move.w #$00f0,$dff180
lea	rastport,a1
moveq	#8,d0
moveq	#6,d1
jsr	-240(a6)			; Move (0,0)
move.l charp,a0
moveq  #1,d0
lea    rastport,a1
move.l gfxbase,a6
jsr	-60(a6)				; Fix char into workarea
addq.l	#1,charp
move.l	charp,a0
tst.b	(a0)
bne.s	noend
move.l	#scrolly,charp
noend:
move.b #8,count2
move.b #8,count
nonewchar:
move.w	#$0f00,$dff180
lea	work,a0
lea	$48000+47,a1
lea	$49000+47,a2
moveq	#7,d5
loop1:
roxl.b	#1,(a0)
bcc.s	clearit

lea	char,a3				; A Set point
lea	char+8,a4
moveq	#7,d4
clp:
move.b	(a3)+,(a1)
move.b	(a4)+,(a2)
add.l	#48,a1
add.l	#48,a2
dbf	d4,clp
bra.s	skipit

clearit:

moveq	#7,d4
cllp:
clr.b	(a1)
clr.b	(a2)
add.l	#48,a1
add.l	#48,a2
dbf	d4,cllp

skipit:
addq.l	#2,a0
dbf	d5,loop1

endint:
move.w	#$000,$dff180

lea	wave+2,a2
lea	wave+10,a4
move.w	(a2),d6
moveq	#30,d5
tlp:
move.w	(a4),(a2)
addq.l	#8,a2
addq.l	#8,a4
dbf	d5,tlp
move.w	d6,(a2)

bra    chkbtn
pressed:
move.w #$8020,$dff096
move.w #$c000,$dff09a
move.l	gfxbase,a6
move.l $26(a6),$dff080
movem.l (a7)+,a6/a5/a4/a3/a2/a1/a0/d7/d6/d5/d4/d3/d2/d1/d0
rts

gfxbase:dc.l 0
copl:
dc.w $008e,$6080,$0090,$9fe0
dc.w $0092,$0028,$00e0,$0004,$00e2,$8000
dc.w $00e4,$0004,$00e6,$9000,$010a,$0002
dc.w $0182,$000a,$0184,$055e,$0186,$0fff
dc.w $0094,$00d8,$0108,$0002
dc.w $0104,$0010,$0100,$2200
dc.w $6001,$ff00
wave:
dc.w $0102,$0011,$6201,$ff00
dc.w $0102,$0022,$6401,$ff00
dc.w $0102,$0033,$6601,$ff00
dc.w $0102,$0044,$6801,$ff00
dc.w $0102,$0055,$6a01,$ff00
dc.w $0102,$0066,$6c01,$ff00
dc.w $0102,$0077,$6e01,$ff00
dc.w $0102,$0088,$7001,$ff00
dc.w $0102,$0099,$7201,$ff00
dc.w $0102,$00:
move.l  #10,d0
move.l	col1,a0
l0:
move.w	(a0)+,$dff182
cmp.l	#endcol1,a0
bne     l1
move.l	#startcol1,a0
l1:
move.w	$dff006,d1
lsr.w	#8,d1
l2:
move.w	$dff006,d2
lsr.w	#8,d2
cmp.w	d1,d2
beq l2
subi.l  #1,d0
bne l0
subi.w  #1,ccol1
bne l3
move.w  #3,ccol1
adda.l  #2,col1
cmp.l   #endcol1,col1
bne l3
move.l  #startcol1,col1

l3:
move.l  gfxbase,a6
lea     rast2,a1                   ; Sinus-Schwingung
move.l  x1,a0
clr.l   d0
clr.l   d1
move.w  (a0),d0
cmp.l   #0,d0
beq exit3
move.l  #0,d2
move.l  #0,d3
move.l  #319,d4
move.l  #33,d5
jsr -396(a6)                  ; scrollen

exit3:
addi.l #2,x1
cmp.l #endsin,x1
bne next
move.l #sinus,x1

next:
move.l  gfxbase,a6
lea     rast2,a1
move.l  x2,a0
clr.l   d0
clr.l   d1
move.w  (a0),d0
cmp.w   #0,d0
beq next2
move.l	#0,d2
move.l  #33,d3
move.l  #319,d4
move.l  #66,d5
jsr	-396(a6)

next2:
addi.l  #2,x2
cmp.l   #endsin2,x2
bne     endirq2
move.l  #sinus2,x2

endirq2:
move.w #16,$dff09c
movem.l (sp)+,d0-d7/a0-a6
rte

handle:
dc.l  0
buffer:
dc.l  0
length:
dc.l  $10000

load:
move.l  dosbase,a6
move.l  #$03ed,d2
jsr	-30(a6)
move.l  d0,