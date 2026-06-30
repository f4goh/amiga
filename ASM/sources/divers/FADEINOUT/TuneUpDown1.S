**********************************************************************
*                                                                    *
*                    IMAGE COMPRESSION ROUTINES                      *
*                                                                    *
*                                                                    *
*          Written on 20/7 1988 By AntiAction of TETRAGON            *
*                                                                    *
*                                                                    *
**********************************************************************

Test:
move.l	#copl,$dff080

lea	$70000,a0
moveq	#9,d0
Fill:
move.l	#$ffffffff,(a0)+
dbf	d0,Fill

WaitMouse3:
btst	#6,$bfe001
bne.s	WaitMouse3

move.l	4.w,a6
moveq	#0,d0
lea	GraphName,a1
jsr	-552(a6)
move.l	d0,a0
move.l	$26(a0),$dff080
rts

copl:
dc.l	$01001200,$00e00007,$00e21000,$00920038,$009400d0
dc.l	$008e2c81,$0090f4c1
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

tocol:
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000
dc.w	$0ac0,$0fff,$0000,$0000,$0000,$000,$000,$000

GraphName:
dc	"graphics.library",0
even

TuneUp:
subq.w	#1,Dly
bne.s	Return
move.w	#2,Dly			; Delay factor
lea	Imgs+2,a0
lea	Tocol,a1
moveq	#$1f,d7			; Numofcols
tracols:
move.w	(a1)+,(a0)
addq.l	#4,a0
dbf	d7,tracols		; Copy colors
moveq	#$f,d5
sub.w	Count,d5
bsr	UpDown
return:
rts

TuneDown:
subq.w	#1,Dly
bne.s	Return
move.w	#2,Dly
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
seq	DownFlag
ret2:
rts

Count:dc.w	0
UpFlag:dc.w	0
DownFlag:dc.w	0
Dly:dc.w	1
