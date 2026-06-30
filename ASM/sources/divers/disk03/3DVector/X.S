res=320
wpl=res/16
color=0
Botline=$c0

*************************************************************
*                                                           *
*        3D GRAPHICS DRIVER, CONVERTED BY ANTIACTION        *
*                      OF TETRAGON                          *
*                                                           *
*                                                           *
*************************************************************

s:
bsr	Start				; Init screen stuff
bsr	Main				; Do main stuff
bsr	Reset				; Reset screen stuff
rts

****************************
* Pass upper screen to VDC *
*  while drawing the other *
****************************

pageup:
move.l	d0,-(a7)
move.l	#$70000,DrawPlane		; Rastport structure
move.l	#$78000,d0			; BitMap pointer
move.w	d0,LowBMPtr
swap	d0
move.w	d0,HiBMPtr			; Copper fixes the rest
bsr	WaitBot
move.l	(a7)+,d0
rts

****************************
* Pass lower screen to VDC *
*  while drawing the other *
****************************

pagedown:
move.l	d0,-(a7)
move.l	#$78000,DrawPlane			; Rastport structure
move.l	#$70000,d0			; BitMap pointer
move.w	d0,LowBMPtr
swap	d0
move.w	d0,HiBMPtr			; Copper fixes the rest
bsr	Waitbot
move.l	(a7)+,d0
rts

WaitBot:
move.w	#$222,color
cmp.b	#BotLine,$dff006
bne.s	WaitBot
move.w	#$000,color
rts

********************
* Clear the screen *
********************

clwork:
btst	#14,$dff002
bne.s	ClWork

move.l	DrawPlane,$dff054
move.l	#$01000000,$dff040
move.w	#0,$dff066
move.w	#200*64+wpl,$dff058

move.w	#$0f0,color
rts

****************************
* Initialize stuff routine *
****************************

Start:
move.l	4.w,a6
jsr	-132(a6)

lea	GfxName,a1
moveq	#0,d0
jsr	-552(a6)			; Open Gfx Library
move.l	d0,GfxBase

move.l	d0,a6

move.l	$32(a6),OldCop
move.l	#Coplist,$32(a6)		; Set coplist pointer
rts

Reset:
move.l	GfxBase,a6
move.l	OldCop,$32(a6)
move.l	4.w,a6
jsr	-138(a6)
rts

*******************************************************************
* Draw-line routine, The points are passed in D2,D3 (start point) *
* and A2, A3 (end point)                                          *
*******************************************************************

Drawl:
movem.l	d0-d3/a0-a1,-(a7)

move.l	d2,d0
move.l	d3,d1				; X,y start
move.l	a2,d2
move.l	a3,d3				; X,y end
bsr	Draw

movem.l	(a7)+,d0-d3/a0-a1
rts

****************
* Blitter Line *
****************

Draw:
movem.l	d2-d7/a2-a3,-(a7)
moveq	#$f,d4
and.w	d2,d4				; low 4 bits
sub.w	d3,d1				; Height
mulu	#res/8,d3			; Start address
sub.w	d2,d0				; Width
blt.s	No1
tst.w	d1
blt.s	No2
cmp.w	d0,d1
bge.s	No3
moveq	#$11,d7
bra.s	OctSel				; Octant #
No3:
moveq	#1,d7
exg	d1,d0
OctSel:
bra.s	No4
No2:
neg.w	d1
cmp.w	d0,d1
bge.s	Skip
moveq	#$19,d7
bra.s	No4
Skip:
moveq	#5,d7
exg	d1,d0
No4:
bra.s	OctsSel
No1:
neg.w	d0
tst.w	d1
blt.s	No11

cmp.w	d0,d1
bge.s	No12
moveq	#$15,d7
bra.s	OctSel2

No12:
moveq	#9,d7
exg	d1,d0
OctSel2:
bra.s	OctsSel

No11:
neg.w	d1
cmp.w	d0,d1
bge.s	No13
moveq	#$1d,d7
bra.s	OctsSel
No13:
moveq	#$d,d7
exg	d1,d0
OctsSel:
add.w	d1,d1
asr.w	#3,d2
ext.l	d2
add.l	d2,d3				; Total offset
move.w	d1,d2
sub.w	d0,d2
bge.s	NoMinus
ori.w	#$40,d7				; Sign = -
NoMinus:
lea	$dff000,a0
move.w	d2,a3
move.w	#$ffff,d6			; LinePtrn
WaitBl:
btst	#6,2(a0)
bne.s	WaitBl
move.w	d1,$62(a0)			; 4Y
move.w	d2,d1
sub.w	d0,d1
move.w	d1,$64(a0)			; 4Y-4X
moveq	#-1,d1
move.l	d1,$44(a0)			; AFWM+ALWM
move.w	#res/8,$60(a0)			; BitMap Width in bytes
move.w	d7,d5
addq.w	#1,d0
asl.w	#6,d0
addq.w	#2,d0				; Blitsize
move.w	d4,d2
swap	d4
asr.l	#4,d4				; First pixelpos
ori.w	#$b00,d4			; Use ABD
move.w	#$8000,$74(a0)			; Index
clr.w	d1
NoSpesh:
move.l	DrawPlane,d7			; Pointer
swap	d5
move.w	d4,d5
move.b	#$ca,d5			; MinTerms
swap	d5
add.l	d3,d7
WtBl2:
btst	#6,2(a0)
bne.s	WtBl2
move.l	d5,$40(a0)			; BltCon0 & 1
move.w	a3,$52(a0)			; 2Y-X
move.l	d7,$48(a0)
move.l	d7,$54(a0)			; Start address of line
move.w	d6,$72(a0)			; Pattern
move.w	d0,$58(a0)			; Size
movem.l	(a7)+,d2-d7/a2-a3
rts

*****************************************************
* Sine and cosine function, angle is passed in D0   *
* and the sine and cosine are returned in D1 and D2 *
*****************************************************

sincos:
tst.w	d0				; Angle neg. add 360°
bpl.s	NoAddi
add.w	#360,d0
noaddi:
move.l	#sintab,a1			; Beginning ad. of sinetable
move.l	d0,d2				; Angle in d0 and d2
lsl.w	#1,d0				; Angle times 2 as index
move.w	0(a1,d0.w),d1			; Sine to D1
cmp.w	#270,d2				; Calc cosine through
blt.s	plus9				; displacement of sine value
sub.w	#270,d2				; by 90 degrees
bra	sendsin
plus9:
add.w	#90,d2
sendsin:
lsl.w	#1,d2
move.w	(a1,d2.w),d2			; Cosine to D2

rts					; And return

*****************************************************
* Sine function					    *
* Angle is passed in d0 and the sine returned in D1 *
*****************************************************

sin:
move.l	#sintab,a1
tst.w	d0
bpl.s	sin1
add.w	#360,d0
sin1:
lsl.w	#1,d0
move.w	(a1,d0.w),d1
rts

*************************************************************
* Init the main diagonal of the result matrix with          *
* ones which were multiplied by 2^14. This subroutine must  *
* be called at least once before the call by rotate, or the *
* result matrix will only consist of zeros.                 *
*************************************************************

matinit:
moveq	#0,d1
move.w	#16384,d2			; The initial value for
move.w	d2,Matrix11			; the main diagonal of
move.w	d1,Matrix12			; the result matrix
move.w	d1,Matrix13			; all other elements 
move.w	d1,Matrix21			; at zero.
move.w	d2,Matrix22
move.w	d1,Matrix23
move.w	d1,Matrix31
move.w	d1,Matrix32
move.w	d2,Matrix33
rts

***************************************************************
* Multiplication of the rotation matrix by the rotation       *
* matrix for rotation about the X-Axis                        *
***************************************************************

xrotate:
move.w	XAngle,d0		; Multiply matrix11-matrix33
jsr	SinCos			; with the rotation matrix
move.w	d1,sinx			; for a rotation about the X-Axis
move.w	d2,cosx
move.w	d1,d3
move.w	d2,d4
move.w	Matrix11,Rotx11		; The first column of the matrix
move.w	Matrix21,Rotx21		; Does not change with X rotation
move.w	Matrix31,Rotx31
muls	Matrix12,d2
muls	Matrix13,d1
sub.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx12
move.w	d3,d1
move.w	d4,d2
muls	Matrix22,d2
muls	Matrix23,d1
sub.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,rotx22
move.w	d3,d1
move.w	d4,d2
muls	Matrix32,d2
muls	Matrix33,d1
sub.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx32
move.w	d3,d1
move.w	d4,d2
muls	Matrix12,d1
muls	Matrix13,d2
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx13
move.w	d3,d1
move.w	d4,d2
muls	Matrix22,d1
muls	Matrix23,d2
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx23
muls	Matrix32,d3
muls	Matrix33,d4
add.l	d3,d4
lsl.l	#2,d4
swap	d4
move.w	d4,Rotx33
move.l	#Rotx11,a1
move.l	#Matrix11,a2
moveq	#8,d7			; Number of matrix elements

roxlop1:
move.w	(a1)+,(a2)+		; Copy result matrix, which
dbra	d7,roxlop1		; is still in ROTXnn, to MATRIXnn
rts

***********************************************************
* Multiply the general rotation matrix by the Y-axis	  *
* rotation matrix. Results are stored in the general	  *
* rotation matrix					  *
***********************************************************

yrotate:
move.w	YAngle,d0		; Angle around which rotation is made
jsr	SinCos
move.w	d1,siny
move.w	d2,cosy
move.w	d1,d3			; Sine of Y-Angle
move.w	d2,d4			; Cosine of Y-angle

muls	Matrix11,d2
muls	Matrix13,d1
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx11
move.w	d3,d1
move.w	d4,d2

muls	Matrix21,d2
muls	Matrix23,d1
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx21
move.w	d3,d1
move.w	d4,d2

muls	Matrix31,d2
muls	Matrix33,d1
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx31
neg.w	d3
move.w	d3,d1				; -siny in the rotation mat.
move.w	d4,d2

move.w	Matrix12,Rotx12
move.w	Matrix22,Rotx22			; The second column
move.w	Matrix32,Rotx32			; of the starting matrix
					; does not change.
muls	Matrix11,d1
muls	Matrix13,d2
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx13
move.w	d3,d1
move.w	d4,d2

muls	Matrix21,d1
muls	Matrix23,d2
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx23

muls	Matrix31,d3
muls	Matrix33,d4
add.l	d3,d4
lsl.l	#2,d4
swap	d4
move.w	d4,Rotx33

moveq	#8,d7

move.l	#Rotx11,a1			; Address of result matrix
move.l	#Matrix11,a2			; Address of original matrix

yrotlop1:
move.w	(a1)+,(a2)+			; Copy result matrix
dbra	d7,yrotlop1			; to original matrix
rts

********************************************
* Z-axis - Rotation matrix multiplications *
********************************************

zrotate:
move.w	ZAngle,d0
jsr	SinCos
move.w	d1,SinZ
move.w	d2,CosZ
move.w	d1,d3
move.w	d2,d4

muls	Matrix11,d2
muls	Matrix12,d1
sub.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx11
move.w	d3,d1
move.w	d4,d2

muls	Matrix21,d2
muls	Matrix22,d1
sub.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx21
move.w	d3,d1
move.w	d4,d2

muls	Matrix31,d2
muls	Matrix32,d1
sub.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx31
move.w	d3,d1
move.w	d4,d2

muls	Matrix11,d1
muls	Matrix12,d2
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx12
move.w	d3,d1
move.w	d4,d2

muls	Matrix21,d1
muls	Matrix22,d2
add.l	d1,d2
lsl.l	#2,d2
swap	d2
move.w	d2,Rotx22

muls	Matrix31,d3
muls	Matrix32,d4
add.l	d3,d4
lsl.l	#2,d4
swap	d4
move.w	d4,Rotx32

move.w	Matrix13,Rotx13			; The third column remains
move.w	Matrix23,Rotx23			; Unchanged
move.w	Matrix33,Rotx33

moveq	#8,d7
move.l	#Rotx11,a1
move.l	#Matrix11,a2

zrotlop1:
move.w	(a1)+,(a2)+			; Copy to general
dbra	d7,zrotlop1			; rotation matrix
rts

**************************************************************
* Multiply every point whose Array address is in datx etc.   *
* by previous translation of the coordinate source to        *
* point [offx,offy,offz], with the general rotation matrix.  *
* The coordinate source of the result coordinates is then    *
* moved to point [xoffs,yoffs,zoffs]                         *
**************************************************************

rotate:
move.w	NumMark,d0			; Number of points to be
ext.l	d0				; transformed as counter
subq.l	#1,d0

move.l	datx,a1
move.l	daty,a2
move.l	datz,a3

move.l	pointx,a4
move.l	pointy,a5
move.l	pointz,a6

rotate1:
move.w	(a1)+,d1			; X-Coordinate
add.w	Offx,d1
move.w	d1,d4

move.w	(a2)+,d2			; Y-Coordinate
add.w	Offy,d2			; Translation to point[offx,offy,offz]
move.w	d2,d5

move.w	(a3)+,d3			; Z-Coordinate
add.w	offz,d3
move.w	d3,d6

muls	Matrix11,d1
muls	Matrix21,d2
muls	Matrix31,d3

add.l	d1,d2
add.l	d2,d3
lsl.l	#2,d3
swap	d3
add.w	xoffs,d3
move.w	d3,(a4)+			; Rotated X-Coordinate

move.w	d4,d1
move.w	d5,d2
move.w	d6,d3

muls	Matrix12,d1
muls	Matrix22,d2
muls	Matrix32,d3
add.l	d1,d2
add.l	d2,d3
lsl.l	#2,d3
swap	d3
add.w	yoffs,d3
move.w	d3,(a5)+		; Rotated Y-Coordinate

muls	Matrix13,d4
muls	Matrix23,d5
muls	Matrix33,d6
add.l	d4,d5
add.l	d5,d6
lsl.l	#2,d6
swap	d6
add.w	Zoffs,d6
move.w	d6,(a6)+		; Rotated Z-Coordinate

dbra	d0,rotate1
rts

*********************************************************************
* Perspective, calculated from the transformed points in the arrays *
* pointx, pointy and pointz the screen coordinates, which           *
* are then stored in the arrays xplot and yplot.                    *
*********************************************************************

pers:
move.l	pointx,a1		; Beginning address of point arrays
move.l	pointy,a2
move.l	pointz,a3

move.l	xplot,a4		; Start address of display coordinate
move.l	yplot,a5		; array.

move.w	NumMark,d0		; Number of points to be transformed
ext.l	d0
subq.l	#1,d0

perlop:
move.w	(a3)+,d5		; Z-coordinate of object
move.w	d5,d6
move.w	Dist,d4			; Enlargement factor
sub.w	d5,d4			; Dist minus Z-coordinate of obj.coord
ext.l	d4
lsl.l	#8,d4			; Times 256 for value fitting
move.w	Zobs,d3			; Projection center Z-coordinates
ext.l	d3

sub.l	d6,d3			; Minus z-coordinate of object
bne.s	pers1

moveq	#0,d1			; Catch division by zero
addq.l	#2,a1
addq.l	#2,a2
move.w	d1,(a4)+
move.w	d1,(a5)+
bra.s	perend1

pers1:
divs	d3,d4
move.w	d4,d3
move.w	(a1)+,d1		; X-Coordinate of object
move.w	d1,d2
neg.w	d1
muls	d1,d3			; Multiplied by perspective factor
lsr.l	#8,d3			; /256 save value fitting

add.w	d3,d2			; Add to x-coordinate
add.w	x0,d2			; Add screen offset (center point)
move.w	d2,(a4)+		; Display X-coordinate

move.w	(a2)+,d1		; Y-Coordinate of object
move.w	d1,d2
neg.w	d1
muls	d1,d4
lsr.l	#8,d4			; /256

add.w	d4,d2
neg.w	d2			; Display offset, mirror of Y-Axis
add.w	y0,d2			; Source at [X0,Y0]
move.w	d2,(a5)+		; Display Y-Coordinate
perend1:
dbra	d0,perlop		; Until all points transformed

move.w	#$ff0,color
rts

*******************************************************
* Draw number of lines from array from lines in linxy *
*******************************************************

drawn1:
move.l	XPlot,a4		; Display X-Coordinate
move.l	YPlot,a5		; Display Y-Coordinate
move.w	numline,d0		; Number of lines
ext.l	d0
subq.l	#1,d0			; As counter
move.l	linxy,a6		; Address of line array

drlop:
move.l	(a6)+,d1		; First line (P1,P2)
subq.w	#1,d1			; Fit to list structure
lsl.w	#1,d1			; Times list element length (2)
move.w	(a4,d1.w),d2		; X-Coordinate of 2nd point
move.w	(a5,d1.w),d3		; Y-Coordinate of second point
swap	d1
subq.w	#1,d1
lsl.w	#1,d1
move.w	(a4,d1.w),a2		; X-Coordinate of first point
move.w	(a5,d1.w),a3		; Y-Coordinate of first point
bsr	Drawl			; Draw line from P1 to P2
dbra	d0,drlop		; Until all lines drawn
rts

************************
* Simple counting loop *
************************

wait1:
dbra	d0,wait1		; Delay loop
rts

***********************************
* Variables for the basic program *
***********************************

* Sine table starts here

sintab:
dc.w	0,286,572,857,1143,1428,1713,1997,2280
dc.w	2563,2845,3126,3406,3686,3964,4240,4516
dc.w	4790,5063,5334,5604,5872,6138,6402,6664
dc.w	6924,7182,7438,7692,7943,8192,8438,8682
dc.w	8923,9162,9397,9630,9860,10087,10311,10531
dc.w	10749,10963,11174,11381,11585,11786,11982,12176
dc.w	12365,12551,12733,12911,13085,13255,13421,13583
dc.w	13741,13894,14044,14189,14330,14466,14598,14726
dc.w	14849,14962,15082,15191,15296,15396,15491,15582
dc.w	15668,15749,15826,15897,15964,16026,16083,16135
dc.w	16182,16225,16262,16294,16322,16344,16362,16374
dc.w	16382,16383

dc.w	16382,16374,16362,16344,16322,16294,16262,16225
dc.w	16182
dc.w	16135,16083,16026,15964,15897,15826,15749,15668
dc.w	15582,15491,15396,15296,15191,15082,14962,14849
dc.w	14726,14598,14466,14330,14189,14044,13894,13741
dc.w	13583,13421,13255,13085,12911,12733,12551,12365
dc.w	12176,11982,11786,11585,11381,11174,10963,10749
dc.w	10531,10311,10087,9860,9630,9397,9162,8923
dc.w	8682,8438,8192,7943,7692,7438,7182,6924
dc.w	6664,6402,6138,5872,5604,5334,5063,4790
dc.w	4516,4240,3964,3686,3406,3126,2845,2563
dc.w	2280,1997,1713,1428,1143,857,572,286,0

dc.w	-286,-572,-857,-1143,-1428,-1713,-1997,-2280
dc.w	-2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
dc.w	-4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
dc.w	-6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
dc.w	-8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
dc.w	-10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
dc.w	-12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
dc.w	-13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
dc.w	-14849,-14962,-15082,-15191,-15296,-15396,-15491,-15582
dc.w	-15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
dc.w	-16382,-16383

dc.w	-16382,-16374,-16362,-16344,-16322,-16294,-16262,-16225
dc.w	-16182
dc.w	-16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668
dc.w	-15582,-15491,-15396,-15296,-15191,-15082,-14962,-14849
dc.w	-14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741
dc.w	-13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
dc.w	-12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
dc.w	-10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
dc.w	-8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
dc.w	-6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
dc.w	-4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
dc.w	-2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

x0:dc.w	0
y0:dc.w	0
z0:dc.w	0
z1:dc.w	0

linxy:dc.l	0		; Address of line array

nummark:dc.w	0		; Number of points
numline:dc.w	0		; Number of lines

pointx:dc.l	0		; Variables of point arrays for world,
pointy:dc.l	0		; view, and screen coordinates
pointz:dc.l	0

xplot:dc.l	0
yplot:dc.l	0

datx:dc.l	0
daty:dc.l	0
datz:dc.l	0

sinx:dc.w	0		; Temporary storage for sin & cos
siny:dc.w	0		; values
sinz:dc.w	0

cosx:dc.w	0
cosy:dc.w	0
cosz:dc.w	0

var1:dc.w	0		; General variables
var2:dc.w	0
var3:dc.w	0

xangle:dc.w	0		; Variables for passing angles
yangle:dc.w	0		; to the rotation subroutine
zangle:dc.w	0

leftx:dc.w	0
lefty:dc.w	0
rightx:dc.w	0
righty:dc.w	0

dist:dc.w	0
zobs:dc.w	1500

rotx11:dc.w	16384		; Space here for the result matrix
rotx12:dc.w	0		; of matrix multiplication
rotx13:dc.w	0
rotx21:dc.w	0
rotx22:dc.w	16384
rotx23:dc.w	0
rotx31:dc.w	0
rotx32:dc.w	0
rotx33:dc.w	16384

matrix11:dc.w	0		; Space here for the general rotation
matrix12:dc.w	0		; matrix
matrix13:dc.w	0
matrix21:dc.w	0
matrix22:dc.w	0
matrix23:dc.w	0
matrix31:dc.w	0
matrix32:dc.w	0
matrix33:dc.w	0

DrawPlane:dc.l	0

CopList:
dc.w	$0180,$0000,$0182,$fff
dc.w	$0100,res/321*32768+$1200,$00e0
hibmptr:
dc.w	$0007,$00e2
lowbmptr:
dc.w	$0000,$0092,$0038,$0094,$00d0
dc.w	$008e,$2c81,$0090,$f4c1
dc.w	$0120
sp1h:dc.w 0,$0122
sp1l:dc.w 0,$0124
sp2h:dc.w 0,$0126
sp2l:dc.w 0,$0128
sp3h:dc.w 0,$012a
sp3l:dc.w 0,$012c,0,$012e,0,$0130,0,$0132,0,$0134,0
dc.w $0136,0,$0138,0,$013a,0,$013c,0,$013e,0

dc.w	$2c01,$fffe,$0180,$0fff
dc.w	$2d01,$fffe,$0180,$008f
dc.w	$3201,$fffe,$0180,$000d
dc.w	$3301,$fffe,$0180,$0000

dc.w	$b001,$fffe,$0180,$0fff
dc.w	$b101,$fffe,$0180,$008f
dc.w	$b601,$fffe,$0180,$000d
dc.w	$b701,$fffe,$0180,$0000

dc.w	$ffff,$fffe

GfxName:
dc	"graphics.library",0
even

GfxBase:dc.l	0

OldCop:dc.l	0

Main:
bsr	GetReso

bsr	MakeWrld		; Create the world system
bsr	WorldSet		; Pass the world parameters
bsr	SpritesBuild

bsr	SetRotDp		; Init obs.ref.point
bsr	PageUp
bsr	ClWork
bsr	PageDown
bsr	ClWork			; Init both pages

bsr	inp_chan		; Input and change parameters
move.w	#2047,dist

mainlop1:
bsr	PointRot
bsr	Pers			; Do Perspective
bsr	DrawN1			; Draw It
bsr	PageUp			; Display It

bsr	Inp_Chan		; Input new parameters
bsr	ClWork
bsr	PointRot		; Rotate
bsr	Pers			; Perspective
bsr	DrawN1			; Drawit
bsr	PageDown
bsr	Inp_Chan		; Input Parameters
bsr	ClWork
btst	#6,$bfe001
bne.s	mainlop1

mainend:
bsr	PageUp
rts

inp_chan:
addq.w	#1,Hyangle
addq.w	#1,Hzangle
cmp.w	#360,Hyangle
blt.s	Nosub
sub.w	#360,Hyangle
NosuB:
cmp.w	#360,hzangle
blt.s	Nosubz
sub.w	#360,Hzangle
NosuBz:
sub.w	#10,Dist
cmp.w	#-1000,Dist
bgt.s	NoClr
move.w	#-1000,Dist
NoClr:
move.w	#$00f,color
rts

************************************************
* Init the rotation reference point to [0,0,0] *
************************************************

setrotdp:
moveq	#0,d1
move.w	d1,rotdpx
move.w	d1,rotdpy
move.w	d1,rotdpz
move.w	#0,hyangle		; Start rotation angle
move.w	#0,hxangle
move.w	#0,hzangle
rts

***********************************************************
* Rotation around one point, the rotation reference point *
***********************************************************

pointrot:
move.w	Hxangle,xangle	; Rotate the world around the angle
move.w	hyangle,yangle	; hxangle, hyangle, hzangle about the
move.w	hzangle,zangle
move.w	rotdpx,d0	; Rotation reference point
move.w	rotdpy,d1
move.w	rotdpz,d2
move.w	d0,xoffs
move.w	d1,yoffs
move.w	d2,zoffs	; Add for back transformation
neg.w	d0
neg.w	d1
neg.w	d2
move.w	d0,offx		; Subtract for transformation
move.w	d1,offy
move.w	d2,offz
bsr	Matinit
bsr	zrotate
bsr	yrotate
bsr	xrotate
bsr	rotate
move.w	#$f00,color
rts

*****************************************************
* Creation of the world system from the object data *
*****************************************************

Makewrld:
move.l	#housdatx,a1		; Create the world system by
move.l	#housdaty,a2
move.l	#housdatz,a3
move.l	#worldx,a4
move.l	#worldy,a5
move.l	#worldz,a6
move.w	hnummark,d0
ext.l	d0
subq.l	#1,d0
makewl1:
move.w	(a1)+,(a4)+		; Copying the house data into the
move.w	(a2)+,(a5)+		; world data
move.w	(a3)+,(a6)+
dbra	d0,makewl1
move.w	hnumline,d0
ext.l	d0
subq.l	#1,d0
move.l	#houslin,a1
move.l	#wlinxy,a2
makewl2:
move.l	(a1)+,(a2)+
dbra	d0,makewl2
rts

***********************************************
* Pass the world parameters to base variables *
***********************************************

worldset:
move.l	#Worldx,datx		; Pass variables for rotation routine
move.l	#worldy,daty
move.l	#Worldz,datz
move.l	#viewx,pointx
move.l	#viewy,pointy
move.l	#viewz,pointz
move.l	#wlinxy,linxy
move.w	PictureX,x0
move.w	Picturey,Y0
move.w	proz,zobs
move.w	r1z1,dist
move.l	#screenx,xplot
move.l	#screeny,yplot
move.w	hnumline,numline
move.w	hnummark,nummark
rts

getReso:
move.w	#res/2,PictureX
move.w	#68,pictureY
rts

spritesbuild:
movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(a7)

lea	spritedata,a0			; Sprite table
move.l	a0,d0
move.w	d0,sp1l				; Setup copper pointers
swap	d0
move.w	d0,sp1h				; --- || ---

lea	hposdata2,a1			; Horiz.pos'n data
move.w	#28,d7				; No.of stars
move.w	#$8200,d0			; Starting pos'n
lp:
clr.l	d1
move.w	(a1)+,d2			; Get horizontal position
move.w	d0,d1				; Copy
clr.b	d1				; Clear lower part
asr.w	#1,d2				; Only 8 MSBits
bcc.s	noset				; LSB set?
bset	#0,d1				; Yes, set bit in sprcon
noset:
move.b	d2,d0				; Copy byte part
move.w	d0,(a0)+			; Sprite DMA instructions
add.w	#$0100,d1			; End line
move.w	d1,(a0)+			; SPDMAINS
move.w	#$8000,(a0)+			; IMAGE DATA
move.w	#$8000,(a0)+
add.w	#$0200,d0			; Next line = Current + 2
dbf	d7,lp				; Until all done
clr.w	(a0)+
clr.w	(a0)+

lea	spritedata2,a0
move.l	a0,d0
move.w	d0,sp2l
swap	d0
move.w	d0,sp2h				; Sprite 2 stuff

lea	hposdata1,a1
move.w	#28,d7
move.w	#$8300,d0
lp2:
clr.l	d1
move.w	(a1)+,d2
move.w	d0,d1
clr.b	d1
asr.w	#1,d2
bcc.s	noset2
bset	#0,d1
noset2:
move.b	d2,d0
move.w	d0,(a0)+
add.w	#$0100,d1
move.w	d1,(a0)+
move.w	#$8000,(a0)+
move.w	#$0000,(a0)+
add.w	#$0200,d0
dbf	d7,lp2
clr.l	(a0)+

lea	spritedata3,a0
move.l	a0,d0
move.w	d0,sp3l
swap	d0
move.w	d0,sp3h				; Sprite 2 stuff

move.w	#28,d7
move.w	#$8200,d0
lp3:
clr.l	d1
move.w	(a1)+,d2
move.w	d0,d1
clr.b	d1
asr.w	#1,d2
bcc.s	noset3
bset	#0,d1
noset3:
move.b	d2,d0
move.w	d0,(a0)+
add.w	#$0100,d1
move.w	d1,(a0)+
move.w	#$8000,(a0)+
move.w	#$8000,(a0)+
add.w	#$0200,d0
dbf	d7,lp3
clr.l	(a0)+

movem.l	(a7)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6
rts

movestars:				; Do star movement
lea	spritedata,a0
moveq	#3,d0				; Speed
bsr	dostarsman1
lea	spritedata2,a0
moveq	#2,d0				; Speed
bsr	dostarsman1
lea	spritedata3,a0
moveq	#1,d0
dostarsman1:
moveq	#28,d2

dostarsman:
move.w	(a0)+,d7
beq.s	itsend				; Zero?
clr.w	d6
move.b	d7,d6
move.w	(a0)+,d5
asr.w	#1,d5				; Odd horz position?
roxl.w	#1,d6

add.w	d0,d6
cmp.w	#448,d6				; Over edge?
blt.s	notover
sub.w	#448,d6				; Beginning
notover:
move.w	d6,d5
asr.w	#1,d5
bcs.s	IsSet
bclr	#0,-1(a0)
bra.L	NotSet
IsSet:
bset	#0,-1(a0)
NotSet:
move.b	d5,-3(a0)			; MSBits

add.w	#4,a0
dbf	d2,dostarsman

itsend:
rts

hposdata1:
dc.w 384,324,312,056,143,099,376,278,100,110,067
dc.w 065,323,089,143,063,378,290,044,416,064,238
dc.w 445,061,072,252,409,265,053,344,293,219,125
dc.w 079,123,384,437,076,278,174,436,323,263,139
dc.w 427,424,012,056,243,099,176,278,400,110,067
dc.w 355,023,089,143,163,188,290,344,216,164,138
dc.w 045,461,172,332,309,265,053,378,293,219,225
dc.w 329,123,354,037,076,081,174,352,423,263,139
dc.w 127,324,412,256,243,199,276,345,400,410,067

hposdata2:
dc.w 450,18,314,213,344,219,422,357,72,373,298,160
dc.w 418,410,371,163,139,295,454,252,444,42,211,147
dc.w 20,92,265,215,306,311,66,170,342,211,52,104,93
dc.w 77,114,90,81,347,122,452,257,373,228,195,161,199
dc.w 76,370,33,353,143,11,339,328,435,226,47,13,113,377
dc.w 350,241,350,202,362,312,323,6,186,79,49,67,205,279
dc.w 238,239,254,176,126,404,287,29,374,103,58,191,59,378
dc.w 225,303,36,159,321,79,378,102

spritedata:
blk.w 6*50+6,0
spritedata2:
blk.w 6*50+6,0
spritedata3:
blk.w 6*50+6,0

*****************
* variable data *
*****************

********************
* House definition *
********************

housdatx:
dc.w	0,40,0,-40,-15,0,15,0,-15,15
dc.w	0,35,0,-35

housdaty:
dc.w	40,0,-40,0,15,15,15,-25,10,10
dc.w	35,0,-35,0

housdatz:
dc.w	0,0,0,0,10,10,10,10,10,10
dc.w	20,20,20,20

houslin:
dc.w	1,2, 2,3, 3,4, 4,1, 5,7, 6,8, 5,9, 7,10
dc.w	11,12, 12,13, 13,14, 14,11, 1,11, 2,12
dc.w	3,13,4,14

hnummark:dc.w	14	; Number of corner points of the house
hnumline:dc.w	16	; Number of lines in the house

hxangle:dc.w	0	; Rotation angle of the house around X axis
hyangle:dc.w	0
hzangle:dc.w	0

xwplus:dc.w	0	; Angle increment around x axis
ywplus:dc.w	0
zwplus:dc.w	0

picturex:dc.w	res
picturey:dc.w	100	; Origin location on screen

rotdpx:dc.w	0
rotdpy:dc.w	0
rotdpz:dc.w	0	; Rotation datum point

r1z1:dc.w	0
normz:dc.w	1500

plusrot:dc.l	0
first:dc.l	0
second:dc.w	0
delta1:dc.w	0

flag:dc.b	1
even

diffz:dc.w	0
dx:dc.w		0
dy:dc.w		0
dz:dc.w		0

worldx:blk.w	1600,0	; World coordinate array
worldy:blk.w	1600,0
worldz:blk.w	1600,0

viewx:blk.w	1600,0	; View coordinate array
viewy:blk.w	1600,0
viewz:blk.w	1600,0

screenx:blk.w	1600,0	; Display coordinate array
screeny:blk.w	1600,0

wlinxy:blk.l	3200,0	; Line array

prox:dc.w	0	; Coordinates of the projection center
proy:dc.w	0	; on the positive Z-axis
proz:dc.w	2000

offx:dc.w	0
offy:dc.w	0
offz:dc.w	0
xoffs:dc.w	0
yoffs:dc.w	0
zoffs:dc.w	0

loopc:dc.l	0

end:
