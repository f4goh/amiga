
;  ** Danny's Demo No. 1 **

move.w  #$80,$dff096   ; Bildschirm schwarz ...
move.w  #0,$dff180
move.w  #0,$dff100

move.l	$04,a6
lea	gfxname,a1
jsr	-408(a6)
move.l	d0,gfxbase

lea     dosname,a1
jsr     -408(a6)
move.l  d0,dosbase

move.l  #$70000,a0
move.l  #$80000,a1
loop:
clr.l   (a0)
adda.l  #4,a0
cmp.l   a0,a1
bne loop

move.l	#picname,d1
move.l  #$71000,buffer
jsr	load

move.l	#picname2,d1
move.l	#$72000,buffer
jsr 	load

move.l	#eyename,d1
move.l  #$7a000,buffer
jsr load
jsr change

move.l	#musicname,d1
move.l	#$60000,buffer
jsr load

move.l  #$c500e100,$78000
move.l  #$c500e180,$79000

move.l  dosbase,a6
move.l  #$b0,d1
jsr     -198(a6)

move.l	gfxbase,a6        ; Laufschrift-Bitmap erzeugen
lea	bitmap,a0
move.l	#$01,d0
move.l	#336,d1
move.l	#10,d2
jsr	-390(a6)
move.l	#$70000,plane1
lea	rastport,a1
jsr	-198(a6)
move.l	#bitmap,r_bitmap
lea	rastport,a1
jsr	-48(a6)
move.l	#scrollm,zeiger

lea	bitmap2,a0              ; Bitmap 2 erzeugen
move.l	#$01,d0
move.l  #320,d1
move.l  #80,d2
jsr 	-390(a6)
move.l  #$71000,plane2
lea	rast2,a1
jsr 	-198(a6)
move.l  #bitmap2,r_bitmap2

move.l  $4,a6
jsr     -132(a6)

initirq:
move.w  #$4000,$dff09a          ; IRQ einschalten
move.l	$6c,oldirq+2
move.l	#newirq,$6c
move.w  #$c010,$dff09a

move.l  gfxbase,a0              ; neue Copperliste
move.l  50(a0),oldclist
move.l  #newclist,50(a0)
move.w  #$8080,$dff096

move.l	#$60000,$dff0a0
move.l	#$60000,$dff0b0
move.w	#$68d8,$dff0a4
move.w	#$68d8,$dff0b4
move.w	#$0200,$dff0a6
move.w	#$0200,$dff0b6
move.w	#64,$dff0a8
move.w	#64,$dff0b8
move.w	#$8003,$dff096

wait:
and.b   #$40,$bfe001            ; Wartet auf Maustaste
bne	wait

move.w	#$0003,$dff096
clr.w	$dff0a8
clr.w	$dff0b8

move.w  #$80,$dff096            ; Normale Copperliste
move.l	gfxbase,a0
move.l	oldclist,50(a0)
move.w	#$8080,$dff096

move.w  #$4010,$dff09a
move.l	oldirq+2,$6c            ; Normaler Interrupt
move.w  #$c000,$dff09a

move.l	$04,a6
jsr     -138(a6)
move.l	gfxbase,a1
jsr	-414(a6)
move.l  dosbase,a1
jsr     -414(a6)

illegal                         ; auf zum Seka 

newirq:
movem.l	d0-d7/a0-a6,-(sp)       ; Register retten

move.w  $dff01e,d0              ; Irq-Requester
dc.w $0800,$0005                ; BTST.L #5,d0
bne     irq1
dc.w $0800,$0004                ; BTST.L #4,d0
bne     irq2

endirq:
movem.l (sp)+,d0-d7/a0-a6
oldirq:
jmp $00000000

irq1:
move.l	gfxbase,a6              ; Laufschrift-IRQ
lea	rastport,a1
move.l	#$01,d0
clr.l	d1
clr.l	d2
move.l	#0,d3
move.l	#336,d4
move.l	#10,d5
jsr	-396(a6)                ; Soft nach links scrollen

sub.b	#$01,rows               ; Schon 8 Pixel gescrollt
bne.s	exit
move.b	#$08,rows               ; wenn ja neues Zeichen ausgeben
lea	rastport,a1
move.l	#320,d0
move.l	#8,d1
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
jsr schieb
jmp endirq                         ; Fertig

irq2:
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
move.l  d0,handle
move.l  d0,d1
move.l  buffer,d2
move.l  length,d3
jsr     -42(a6)
move.l  handle,d1
jsr     -36(a6)
rts

change:
move.l	#$78004,a0
move.l	#$79004,a1
move.l	#$7a000,a2
move.l	#17,d0
ch1:
move.l	(a2)+,(a0)+
move.l  (a2)+,(a1)+
subi.l	#1,d0
bne ch1
rts

schieb:
clr.l	d0
cmp.b	#0,mod		
bne sch1
addi.b	#1,xk
cmp.b	#$d8,xk
bne sch2
move.b	#1,mod
jmp sch2

sch1:
subi.b	#1,xk
cmp.b	#$40,xk
bne	sch2
move.b	#0,mod

sch2:
move.b	xk,$78001
move.b	xk,$79001
clr.l	d0
move.w	yk,d0
move.l	counter,a0	
move.w	(a0),d1
addi.w	d1,d0
move.w	d0,yk
move.b	d0,$78000
move.b	d0,$79000
lsr.w	#6,d0
clr.l	d1
move.w	yk,d1
addi.w	#$11,d1
move.b	d1,$78002
move.b	d1,$79002
lsr.w	#7,d1
ori.b	d0,d1
move.b	d1,$78003
ori.b	#$80,d1
move.b	d1,$79003
addi.l	#2,counter
cmp.l	#endsin3,counter
bne 	sch3
move.l	#sinus3,counter
sch3:
rts

; Daten fuer Programm

counter:
dc.l	sinus3

yk:
dc.w	$c8

xk:
dc.b 0

mod:
dc.b 0 

even

picname:
dc.b "df0:pics/Danny1.AFL.pic",0

even

picname2:
dc.b "df0:pics/Danny1.pic",0

even

eyename:
dc.b "df0:pics/Danny1.eye",0

even

newclist:
dc.w    $0120,$7,$0122,$8000,$0124,$7,$0126,$9000,$0128,0
dc.w	$012a,0,$012c,0,$012e,0,$0130,0,$0132,0
dc.w	$0134,0,$0136,0,$0138,0,$013a,0,$013c,0,$013e,0
dc.w	$008e,$2581,$0090,$32c1,$0092,$0038,$0094,$00d0
dc.w	$0102,$0000,$0104,$0000,$0108,$0000,$010a,$0000
dc.w	$0100,$1200,$00e0,$0007,$00e2,$1000

dc.w	$0180,$0000,$0182,$074      ;ALPHA
dc.w    $2601,$fffe,$0182,$095
dc.w	$2701,$fffe,$0182,$0b6
dc.w    $2801,$fffe,$0182,$0d7
dc.w    $2901,$fffe,$0182,$0f8
dc.w    $4101,$fffe,$0182,$0d7
dc.w	$4201,$fffe,$0182,$0b6
dc.w    $4301,$fffe,$0182,$095
dc.w    $4401,$fffe,$0182,$074

dc.w    $4701,$fffe,$0182,$0a05      ;FLIGHT
dc.w    $4801,$fffe,$0182,$0b06
dc.w    $4901,$fffe,$0182,$0d07
dc.w    $4a01,$fffe,$0182,$0e07
dc.w    $4b01,$fffe,$0182,$0f08
dc.w    $6201,$fffe,$0182,$0e07
dc.w    $6301,$fffe,$0182,$0d07
dc.w    $6401,$fffe,$0182,$0b06
dc.w    $6501,$fffe,$0182,$0a05
dc.w	$7001,$fffe,$009c,$8010
dc.w    $0102,$0000,$0104,$0000,$0108,$0002,$010a,$0002
dc.w    $0100,$1200
dc.w	$00e0,$0007,$00e2,$0000,$0180,$0000,$0182,$0fff

dc.w    $8001,$fffe,$0108,$00a0,$010a,$00a0,$0100,$5200
dc.w	$00e0,$0007,$00e2,$2000,$00e4,$0007,$00e6,$2028
dc.w	$00e8,$0007,$00ea,$2050,$00ec,$0007,$00ee,$2078
dc.w	$00f0,$0007,$00f2,$20a0,$0182,$0c48,$0184,$0d2d
dc.w	$0186,$0c0e,$0188,$0c48,$018a,$0fe0,$018c,$08f0
dc.w	$018e,$05d5,$0190,$00b6,$0192,$00d9,$0194,$00af
dc.w	$0196,$007c,$0198,$0fca,$019a,$070f,$019c,$0c0e
dc.w	$019e,$0c48,$01a0,$0620,$01a2,$0e52,$01a4,$0b33
dc.w	$01a6,$000f,$01a8,$0343,$01aa,$0454,$01ac,$0565
dc.w	$01ae,$0676,$01b0,$0787,$01b2,$0898,$01b4,$09a9
dc.w	$01b6,$0aba,$01b8,$0bcb,$01ba,$0cdc,$01bc,$0ded
dc.w	$01be,$0efe
dc.w	$c201,$fffe,$01be,$26a,$01bc,$fff,$01ba,$bbe
dc.w	$01b8,$29b,$01b6,$d67,$01b4,$ddd,$01b2,$555
dc.w	$01b0,$777,$01ae,$999,$01ac,$000
dc.w	$f001,$fffe,$0102,$0000,$0104,$0000,$0108,$0000
dc.w    $010a,$0000,$0100,$1200,$00e0,$0007,$00e2,$1000

dc.w    $0180,$0000,$0182,$0a05
dc.w	$f101,$fffe,$0182,$0b06
dc.w	$f201,$fffe,$0182,$0d07
dc.w	$f301,$fffe,$0182,$0e07
dc.w	$f401,$fffe,$0182,$0f08
dc.w	$ffc1,$fffe,$0182,$0f08,$0182,$0f08,$0182,$0f08
dc.w	$0182,$0f08,$0182,$0f08,$0182,$0f08,$0182,$0f08
dc.w    $0b01,$fffe,$0182,$0f08
dc.w	$0c01,$fffe,$0182,$0e07
dc.w	$0d01,$fffe,$0182,$0d07
dc.w	$0e01,$fffe,$0182,$0b06
dc.w	$0f01,$fffe,$0182,$0a05

dc.w	$1201,$fffe,$0182,$074
dc.w	$1301,$fffe,$0182,$095
dc.w	$1401,$fffe,$0182,$0b6
dc.w	$1501,$fffe,$0182,$0d7
dc.w	$1601,$fffe,$0182,$0f8
dc.w	$2d01,$fffe,$0182,$0d7
dc.w	$2e01,$fffe,$0182,$0b6
dc.w	$2f01,$fffe,$0182,$095
dc.w	$3001,$fffe,$0182,$074

dc.w	$ffff,$fffe

even

scrollm:
dc.b	"                 The Ghostdance Inc. presents POP-EYE  ..."
dc.b    "    Written in 4 days by Danny on Franky's Amiga 1000     "
dc.b	" Graphix was also painted by Franky.  Scroll-Text written "
dc.b	"by Crime and Danny.      Greetings to:DNS-HQC-GSC-MOVERS-"
dc.b	"HOTLINE-1001 CREW-ICI-DSC-TTF-RSI-TSK-TDF-SAP-DEF JAM-SKAR-"
dc.b	"RELAX-TIP-INTERFOX-RWE-FSW-TLC-TOC-I.K-SF-TRIAD-YF-YAZOO-"
dc.b	"FL-MTY-FRANKY-TBW-TRIANON-BENCOR BROTHERS-USA TEAM-DG-..."
dc.b	"      The members are:THE GHOSTDANCE INC.-FDT-TDS AND UCS.."
dc.b 	"  Contact the [AFL]'70 at:02204 / 81914 (Crime=Frank!)...."
dc.b 	" Coming soon:New Stuff,Old Stuff?,First Game and some more"
dc.b	" World Ruling Demos & Intros of the great Alpha Flight "
dc.b 	" Productions 1970 !! See you at our copy meeting in Ddorf."
dc.b	"             " 
dc.b	"  (C) by The Alpha Flight/Ghostdance Inc.                 "
blk.b	15,$20

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

dosbase:
dc.l    0
dosname:
dc.b    "dos.library",0

even

bitmap2:
blk.w 4,0
plane2:
blk.l 20,0
rast2:
dc.l 0
r_bitmap2:
blk.l 30,0

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

even

sinus:
dc.w 0,0,0,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-2
dc.w -3,-3,-3,-3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
dc.w -4,-5,-5,-5,-5,-5,-5,-5,-5,-5,-6,-6,-6,-6,-6,
dc.w 6,6,6,6,6,5,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,4
dc.w 4,4,3,3,3,3,3,2,2,2,2,2,2,2,1,1,1,1,1,1,0,0,0
endsin:

even

sinus2:
dc.w -6,-6,-6,-6,-6,-5,-5,-5,-5,-5,-5,-5,-5,-5,-4
dc.w -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3,-3,-3,-3,-3
dc.w -2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,0,0,0
dc.w 0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,4,4
dc.w 4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,6,6,6,6,6
endsin2:

even

sinus3:
dc.w 0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,4,4
dc.w 4,4,4,4,4,4,4,4,4,5,5
dc.w -5,-5,-4,-4,-4,-4,-4,-4,-4,-4,-4
dc.w -4,-4,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-2,-2
dc.w -1,-1,-1,-1,-1,-1,0,0,0
endsin3:

x1:
dc.l sinus

x2:
dc.l sinus2

col1:
dc.l startcol1

ccol1:
dc.w 1

startcol1:
dc.w $0022,$0033,$0044,$0055,$0066,$0077,$0088,$0099
dc.w $02aa,$04bb,$06cc,$08dd,$0bee,$0fff,$0fed,$0edc,$0dcb,$0cba
dc.w $0b98,$0a87,$0976,$0854,$0743,$0632,$0521,$0410,$0211,$0121
endcol1:

musicname:
dc.b	"df0:sfx/Danny1.music",0

even

