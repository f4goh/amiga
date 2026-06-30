;
;
;
;	      TETRAGON INTRO #1, WRITTEN ON 9/5 '88
;
;		       © 1988 By AntiAction
;
;

beg:					; As usual...
movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(a7)
move.l	a7,InitialSP			; Just to be on the safe side
jsr	$40056
bsr	SwitchOSout			; Switch out Operating System
bsr	Initchips			; Setup Custom chip pointers
bsr	Initint				; Setup Interrupts.
bsr	InitOther			; Init the other stuff
bsr	Wait				; Handle input stuff
bsr	Resetint			; Reset interrupts
bsr	Resetchips			; Reset custom chips
bsr	SwitchOSin			; Switch in Operating System.
move.l	InitialSP,a7			; Restore Stack Frame Pointer
movem.l	(a7)+,a0/a1/a2/a3/a4/a5/a6/d0/d1/d2/d3/d4/d5/d6/d7
rts

InitialSP:dc.l 0			; Hold initial SP

SwitchOSout:				; Switch out disturbing stuff.
move.l	$4,a6				; System Base
lea	gfxlib,a1
clr.l	d0
jsr	-552(a6)			; _LVOOpenLibrary
move.l	d0,gfxbase			; Save Graphics_lib base
jsr	-$84(a6)			; _LVOForbid
jsr	-$96(a6)			; _LVOSuperState
move.l	d0,systack			; System stack
rts

systack:dc.l 0
gfxlib:dc "graphics.library",0,0
gfxbase:dc.l 0

Initchips:				; Initialize custom chips
move.w	$dff01c,intesave
move.w	$dff01e,intrsave
move.w	$dff002,dmasave
move.w	$dff010,adksave
move.w	#%0111111111111111,$dff096	; DMACONW
move.w	#%1000001111100000,$dff096	; Disable disk access.
move.w	#%0111111111111111,$dff09a	; INTENA
move.w	#%1100000000110100,$dff09a	; Enable desired IRQ's
move.l	#copl,$dff080
rts

intesave:dc.w	0
intrsave:dc.w	0
dmasave:dc.w	0
adksave:dc.w	0

InitInt:				; Initialize interrupts
move.l	$6c,level3save			; Save level 3 vector
move.l	$6c,af3+2
move.l	$68,level2save			; Save level 2 vector
move.l	$68,af2+2
move.l	#level2irq,$68			; Set new interrupt vector 2
move.l	#level3irq,$6c			; Set new interrupt vector 3
rts

level2save:dc.l 0
level3save:dc.l 0

ResetInt:				; Reset Interrupts
move.l	level3save,$6c			; Restore level 3 vector
move.l	level2save,$68			; Restore level 2 vector
rts

Resetchips:				; Reset custom chips
move.w	intesave,d7
bset	#$f,d7
move.w	d7,$dff09a			; Reset Interrupts
move.w	intrsave,d7
bset	#$f,d7
move.w	d7,$dff09c			; Reset interrupt request
move.w	dmasave,d7
bset	#$f,d7
move.w	d7,$dff096			; Reset DMAConw
move.w	adksave,d7
bset	#$f,d7
move.w	d7,$dff09e			; Reset ADK
move.l	gfxbase,a0
move.l	$26(a0),$dff080
rts

SwitchOSIn:				; Allow OS to operate again.
move.l	4,a6				; System Base
jsr	-$8a(a6)			; _LVOPermit
move.l	systack,d0			; Systemstack
jsr	-$9c(a6)			; _LVOUserState
rts

level2irq:
af2:jmp 0

level3irq:
movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(a7)
;move.w	#$000f,$dff180
movem.l	(a7)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6
af3:jmp 0

rotdly:dc.w 250
rotdirection:dc.w 0
rotate:dc.w 0

dorotation:
tst.w	rotate
bne.s	rotatin

subq.w	#1,rotdly
bne.s	norot

move.w	#150,rotate

rotatin:
subq.w	#1,rotate
beq.s	norot3

tst.w	rotdirection
bne.s	other

lea	dire,a0
moveq	#99,d6
slp:
move.w	(a0),d0
addq.w	#2,d0
cmpi.w	#720,d0
blt.s	nomore
subi.w	#720,d0
nomore:
move.w	d0,(a0)+
dbf	d6,slp
bra.s	norot2

other:
lea	dire,a0
moveq	#99,d6
slp2:
move.w	(a0),d0
subq.w	#2,d0
cmpi.w	#0,d0
bge.s	nomore2
addi.w	#720,d0
nomore2:
move.w	d0,(a0)+
dbf	d6,slp2
bra.s	norot2

norot3:
not.w	rotdirection
move.w	#250,rotdly
norot2:

norot:
rts

initother:
lea	$60000,a0
move.w	#$3000,d0
clp:
clr.l	(a0)+
dbf	d0,clp
rts

Wait:					; Wait.
wtl:
cmp.b	#255,$dff006
bne.s	wtl
;move.w	#$fff,$dff180
bsr	dostars
;move.w	#$003,$dff180
bsr	dorotation
;move.w	#$002,$dff180
jsr	$4015c
;move.w	#$000,$dff180
btst	#6,$bfe001
bne.s	wait
rts

delay180:dc.w 200

dostars:
moveq	#99,d2
lea	$60000,a0			; Bpl 1
lea	$64000,a1			; Bpl 2
lea	sine,a6				; Sine table
lea	posx,a5				; X pos table
lea	posy,a4				; Y pos table
lea	dire,a3				; Direction table

thelot:
move.w	(a5),d0				; Xpos * 100
move.w	(a4),d1				; Ypos * 100
move.w	(a3)+,d7			; Direction (angle * 2)
move.w	d7,d6
add.w	#180,d6				; Y direction
cmpi.w	#720,d6
blt.s	notnow
subi.w	#720,d6				; cos(360)=cos(0)
notnow:

movem.l	d0/d1/d3/a1,-(a7)
lsr.w	#7,d0
lsr.w	#1,d1
and.w	#$ffc0,d1			; YPos/128 * 64 = Row offset
move.w	d0,d3
lsr.w	#3,d3				; Byte offset
not.b	d0				; DELETE OLD STAR
andi.b	#7,d0
add.w	d3,d1
bclr	d0,0(a0,d1)
bclr	d0,0(a1,d1)
add.w	#$4000,a1
bclr	d0,0(a1,d1)
movem.l	(a7)+,d0/d1/d3/a1

move.w	(a6,d7.w),d5			; Get sine value
move.w	(a6,d6.w),d4			; Get cosine value
move.w	198(a3),d7			; Distance
muls	d7,d4
muls	d7,d5

asr.w	#5,d4
asr.w	#5,d5

add.w	d5,d0				; Xpos
add.w	d4,d1				; Ypos
move.w	d0,(a5)+			; Xpos save
move.w	d1,(a4)+			; YPos save
lsr.l	#7,d0				; Xpos = Xpos/128 = Xpos
lsr.l	#7,d1				; Ypos = Ypos/128 = Ypos
cmpi.w	#352,d0
bge.s	res
cmp.w	#256,d1
blt.s	nores
res:
move.w	#176,d0
move.w	#22528,-2(a5)			; Save the pos'n
moveq	#127,d1
move.w	#16256,-2(a4)
clr.w	198(a3)				; Clear nummoves
moveq	#0,d7
nores:

addq.w	#1,198(a3)			; One step further
					; SETDOT
lsl.w	#6,d1				; * 64
move.w	d0,d3
lsr.w	#3,d3				; Divide by 8 = byte offset
add.w	d3,d1
not.b	d0
andi.b	#7,d0

lsr.w	#4,d7
beq.s	Nopl3
addq.b	#1,d7				; Color is dependent upon dist
cmpi.b	#7,d7
ble.s	nofix
moveq	#7,d7
nofix:
lsr.b	#1,d7
bcc.s	nopl1
setp1:
bset	d0,0(a0,d1)			; Set point
nopl1:
lsr.b	#1,d7
bcc.s	nopl2
setp2:
bset	d0,0(a1,d1)
nopl2:
lsr.b	#1,d7
bcc.s	nopl3
add.w	#$4000,a1
bset	d0,(a1,d1)
sub.w	#$4000,a1
nopl3:

dbf	d2,thelot
rts

dire:
dc.w 468,624,524,574,52,352,326,76,684,506
dc.w 382,698,230,688,672,384,406,482,504,532
dc.w 480,326,240,112,530,390,306,38,552,368
dc.w 406,532,476,166,334,92,348,38,260,410
dc.w 712,208,472,676,272,640,574,680,232,296
dc.w 304,526,156,158,548,490,514,672,188,372
dc.w 340,98,348,438,126,236,176,410,584,88
dc.w 6,52,120,512,378,670,440,398,516,312
dc.w 72,246,600,656,326,138,590,412,610,82
dc.w 706,418,442,500,612,274,164,48,254,200
dc.w 420,74,124,192,370,630,298,76,394,256

nummoves:
blk.w	100,0

copl:
dc.w $0100,$3200
dc.w $00e0,$0006,$00e2,$0000
dc.w $00e4,$0006,$00e6,$4000
dc.w $00e8,$0006,$00ea,$8000
dc.w $0102,$0000,$0104,$0030,$008e,$2480
dc.w $0090,$24e0,$0092,$0030,$0094,$00d8
dc.w $010a,$0014,$0108,$0014,$0120,$0000
dc.w $0122,$0000
dc.w $0182,$0111,$0184,$0222,$0186,$0444,$0188,$0777
dc.w $018a,$0aaa,$018c,$0bbb,$018e,$0ccc
dc.w $0124,$0000,$0126,$0000,$0128,$0000,$012a,$0000
dc.w $012c,$0000,$012e,$0000,$0130,$0000,$0132,$0000
dc.w $0134,$0000,$0136,$0000,$0138,$0000,$013a,$0000
dc.w $013c,$0000,$013e,$0000
dc.w $0180,$0000
dc.w $ffff,$fffe

posx:
dc.w 29440,39296,33024,36096,3328,22144,20480,4736,43008,31872,
dc.w 24064,43904,14464,43264,42240,24192,25472,30336,31744,33536,
dc.w 30208,20480,15104,7040,33280,24576,19200,2432,34688,23168,
dc.w 25472,33536,29952,10368,20992,5760,21888,2432,16384,25856,
dc.w 44800,13056,29696,42496,17152,40320,36096,42880,14592,18688,
dc.w 19200,33152,9856,9856,34560,30848,32384,42240,11776,23296,
dc.w 21376,6144,21888,27520,7936,14848,11008,25728,36736,5632,
dc.w 384,3200,7552,32256,23680,42240,27648,25088,32512,19584,
dc.w 4608,15488,37760,41216,20480,8704,37120,25984,38400,5120,
dc.w 44416,26240,27776,31488,38528,17280,10240,2944,15872,12544,
dc.w 26368,4608,7808,12032,23296,39680,18688,4864,24832,16128,

posy:
dc.w 15616,21376,30464,11904,6784,14208,29312,25472,9344,15872,
dc.w 5376,32256,28160,13184,23680,19328,14592,23296,27648,11392,
dc.w 2176,13440,10880,13056,20736,26496,1920,22528,19840,20224,
dc.w 23424,22912,28032,8576,27648,12672,27264,15232,2816,12544,
dc.w 30848,2432,22784,15232,6144,4736,11136,7680,1792,8576,
dc.w 2048,2944,22016,4096,19328,13568,6016,11776,27392,1920,
dc.w 12672,20480,21504,32512,20864,29952,28544,10368,32384,4992,
dc.w 17920,13696,18688,0,15744,14720,7808,31360,32256,1024,
dc.w 14976,22400,29824,6144,14720,18688,29184,18432,19328,18816,
dc.w 28672,28928,1024,9344,29184,21120,19712,8960,1664,1920,
dc.w 31360,21376,26752,9216,31232,29952,17664,27776,9728,128,

sine:
dc.w 0, 4, 8, 12
dc.w 16, 22, 26, 30, 34, 40, 44, 48, 52, 56, 60, 66, 70
dc.w 74, 78, 82, 86, 90, 94, 100, 104, 108, 112, 116, 120, 124, 128
dc.w 130, 134, 138, 142, 146, 150, 154, 156, 160, 164, 166, 170 
dc.w 174, 176, 180, 184, 186, 190, 192, 196, 198, 200, 204, 206
dc.w 208, 212, 214, 216, 218, 220, 222, 226, 228, 230, 232, 232
dc.w 234, 236, 238, 240, 242, 242, 244, 246, 246, 248, 248, 250, 250
dc.w 252, 252, 252, 254, 254, 254, 254, 254, 254, 254, 256, 254
dc.w 254, 254, 254, 254, 254, 254, 252, 252, 252, 250, 250, 248, 248
dc.w 246, 246, 244, 242, 242, 240, 238, 236, 234, 232, 232, 230, 228
dc.w 226,222,220,218,216,214,212,208,206,204,200,198,196
dc.w 192,190,186,184,180,176,174,170,166,164,160,156,154,150
dc.w 146, 142, 138, 134, 130, 126, 124, 120, 116, 112, 108, 104
dc.w 100, 94, 90, 86, 82, 78, 74, 70, 66, 60, 56, 52, 48, 44, 40
dc.w 34, 30, 26, 22, 16, 12, 8, 4,-2,-6,-10,-14,-18,-24,-28,-32,-36
dc.w -42,-46,-50,-54,-58,-62,-68,-72,-76,-80,-84,-88,-92,-96,-102
dc.w -106,-110,-114
dc.w -118,-122,-126,-130,-132,-136,-140,-144,-148,-152,-156,-158,-162
dc.w -166,-168,-172,-176,-178,-182,-186,-188,-192,-194,-198,-200,-202
dc.w -206,-208,-210,-214,-216,-218,-220,-222,-224,-228,-230,-232,-234
dc.w -234,-236,-238,-240,-242,-244,-244,-246,-248,-248,-250,-250,-252
dc.w -252,-254,-254,-254,-256,-256,-256,-256,-256,-256,-256,-256,-256
dc.w -256,-256,-256,-256,-256,-256,-254,-254,-254,-252,-252,-250,-250
dc.w -248,-248,-246,-244,-244,-242,-240,-238,-236,-234,-234,-232,-230
dc.w -228,-224,-222,-220,-218,-216,-214,-210,-208,-206,-202,-200,-198
dc.w -194,-192,-188,-186,-182,-178,-176,-172,-168,-166,-162,-158,-156
dc.w -152,-148,-144,-140,-136,-132,-128,-126,-122,-118,-114,-110,-106
dc.w -102,-96,-92,-88,-84,-80,-76,-72,-68,-62,-58,-54,-50,-46,-42,-36
dc.w -32,-28,-24,-18,-14,-10,-6
end:
