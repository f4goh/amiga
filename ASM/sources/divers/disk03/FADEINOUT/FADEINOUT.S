Speed=1				; Tune speed

Test:
move.l	#copl,$dff080

WaitMouse3:
cmp.b	#$c0,$dff006
bne.s	WaitMouse3
Wt1:
cmp.b	#$c1,$dff006
bne.s	Wt1

tst.w	UpFlag
bne.s	NoUp				; Still left?
bsr	TuneUp				; Yeah, tune up.
NoUp:
btst	#6,$bfe001
bne.s	WaitMouse3			; If no mouse

sf	DownFlag			; Now, tune down.
Wait4:
cmp.b	#$c0,$dff006
bne.s	Wait4
Wt2:
cmp.b	#$c1,$dff006
bne.s	Wt2

tst.w	DownFlag
bne.s	NoDown				; Entirely black?
bsr	TuneDown
bra.s	Wait4

NoDown:
move.l	4.w,a6
moveq	#0,d0
lea	GraphName,a1
jsr	-552(a6)			; Restore coppers
move.l	d0,a0
move.l	$26(a0),$dff080
rts

copl:
dc.l	$01001200,$00e00007,$00e21000,$00920038,$009400d0
dc.l	$008e2c81,$0090f4c1

**************** WHERE COLORS ARE STORED: *****************
**************** MUST BE LIKE THIS!!!!!!! *****************
imgs:
dc.w	$0180,$0000,$0182,$0000,$0184,$0000,$0186,$0000
dc.w	$0188,$0000,$018a,$0000,$018c,$0000,$018e,$0000
dc.w	$0190,$0000,$0192,$0000,$0194,$0000,$0196,$0000
dc.w	$0198,$0000,$019a,$0000,$019c,$0000,$019e,$0000
dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000

dc.w	$ffff,$fffe

***************** THE COLORS TO TUNE UP TO *****************

tocol:
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000

GraphName:
dc	"graphics.library",0
even

********************* Call this to tune up colors ****************
;   ********************* Once every frame ********************


TuneUp:
subq.w	#1,Dly
bne.s	Return
move.w	#Speed,Dly			; Delay factor
lea	Imgs+2,a0
lea	Tocol,a1
moveq	#$1f,d7				; Numofcolors
tracols:
move.w	(a1)+,(a0)
addq.l	#4,a0
dbf	d7,tracols			; Copy colors
moveq	#$f,d5
sub.w	Count,d5
bsr	UpDown
return:
rts

**************** CALL THIS TO TUNE DOWN IN SAME WAY AS TUNEUP *******

TuneDown:
subq.w	#1,Dly
bne.s	Return
move.w	#Speed,Dly
moveq	#1,d5

UpDown:
lea	Imgs+2,a0
moveq	#$1f,d7
DoCols:
moveq	#2,d6
moveq	#$f,d3
move.w	d5,d4
DoDis:
move.w	(a0),d0
and.w	d3,d0
cmp.w	d4,d0
bcs.s	Skip1
sub.w	d4,(a0)
bra.s	Skip2
Skip1:
not.w	d3
and.w	d3,(a0)
not.w	d3
Skip2:
asl.w	#4,d4
asl.w	#4,d3
dbf	d6,DoDis
addq.l	#4,a0
dbf	d7,DoCols
addq.w	#1,Count
cmpi.w	#$10,Count
bne.s	Ret2
clr.w	Count
seq	UpFlag
seq	DownFlag				; Clear up&downflags
ret2:
rts

Count:dc.w	0
UpFlag:dc.w	0
DownFlag:dc.w	0
Dly:dc.w	1
