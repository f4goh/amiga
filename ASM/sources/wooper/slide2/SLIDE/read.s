;                           read image for slide
execbase  = 4
openlib   = -408
closelib  = -414
open      = -30
close     = -36
read      = -42
mode_old  = 1005
mode_new  = 1006

;zone equ $210000
;zone equ $c05000
;zone equ $85000
	section code,code_c

debut:
	move.l	execbase,a6
	lea	dosname,a1
	moveq	#0,d0
	jsr	openlib(a6)
	move.l	d0,dosbase
	beq	error

	move.l	#mode_old,d2
	bsr	openfile1
	move.l	zone1,d2
	bsr	readdata
	move.l	d0,d6
	bsr	closefile
wait1	btst	#6,$bfe001
	bne	wait1
	move.l	#mode_old,d2
	bsr	openfile2
	move.l	zone2,d2
	bsr	readdata
	move.l	d0,d6
	bsr	closefile

wait2	btst	#6,$bfe001
	bne	wait2

	move.l	#mode_old,d2
	bsr	openfile3
	move.l	zone3,d2
	bsr	readdata
	move.l	d0,d6
	bsr	closefile

	move.l	dosbase,a1
	move.l	execbase,a6
	jsr	closelib(a6)
error:	clr.l	d0
	rts
openfile1:
	move.l	dosbase,a6
	move.l	#filename1,d1
	jsr	open(a6)
	move.l	d0,filehd
	rts
openfile2:
	move.l	dosbase,a6
	move.l	#filename2,d1
	jsr	open(a6)
	move.l	d0,filehd
	rts
openfile3:
	move.l	dosbase,a6
	move.l	#filename3,d1
	jsr	open(a6)
	move.l	d0,filehd
	rts
closefile:
	move.l	dosbase,a6
	move.l	filehd,d1
	jsr	close(a6)
	rts
readdata:
	move.l	dosbase,a6
	move.l	filehd,d1
	move.l	#$ffffff,d3
	jsr	read(a6)
	rts
zone1	dc.l	$210000
zone2	dc.l	$210000+186760
zone3	dc.l	$210000+186760+135914

filehd:dc.l	0
dosbase:dc.l 	0
filename1:dc.b	"df0:fic.p1",0
 even
filename2:dc.b	"df0:fic.p2",0
 even
filename3:dc.b	"df0:fic.p3",0
 even
dosname:dc.b	"dos.library",0
 even

