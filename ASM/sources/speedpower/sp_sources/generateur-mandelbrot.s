
;  **********************************************
;  ****  nom:     Generateur de mandelbrot   ****
;  ****  auteur:  CODY of DEFCON4            ****
;  ****  version: V1.00                      ****
;  ****  date:    15-07-91                   ****
;  ****  asm:     Asm-one V1.01 (the only!)  ****
;  **********************************************


ZOOM 	= 64
AJUSTX	=-$4000
AJUSTY	= $2600

main:
	bsr	sauve
	bsr	inits
	bsr	fractale
	bsr	waitclick
	bsr	restore
	moveq	#0,d0
	rts

; **********************************************************
; ****    fractale: genere la fractale (Mandelbrot)    *****
; **********************************************************

fractale:
	MOVE.L	BITPLANE1_PTR,A0
	MOVE.L	BITPLANE2_PTR,A1
	MOVE.L	BITPLANE3_PTR,A2
	MOVE.L	BITPLANE4_PTR,A3
	MOVE.L	BITPLANE5_PTR,A4

	SUB.L	A6,A6		; J
	clr.w	cordy
LOOP1:
	SUB.L	A5,A5		; I
	CLR.W	CORDx
LOOP2:
	MOVE.W	CORDy,D1
	SUB.L	#AJUSTY,D1	; ajustement y (+grand=affiche vers haut) 

	MOVE.W	CORDx,D0
	add.L	#AJUSTX,D0	; ajustement x (+grand=affiche vers droite)

	MOVE.W	#30,D7		; Facteur de recursivite = 31

	MOVE.L	D0,D4		; D4 = position Y
	MOVE.L	D1,D5		; D5 = position X

	MOVE.W	D0,D2		; D2 = position Y = i
	MULS	D2,D2		; D2 = i^2
	MOVE.W	D1,D3		; D3 = POSITION X = r
	MULS	D3,D3		; D3 = r^2
LOOP3:
	SUB.L	D3,D2		; D2=r^2-i^2

	ASR.L	#8,D2
	asr.l	#5,d2
	ADD.W	D4,D2		; D2=X

	MOVE.W	D1,D3
	MULS	D0,D3		; D3=r*2*i
	ASR.L	#7,D3
	asr.l	#5,d3

	ADD.W	D5,D3		; D3=Y

	MOVE.W	D2,D0
	MOVE.W	D3,D1

	MULS	D2,D2
	MULS	D3,D3
	MOVE.L	D2,D6
	add.L	D3,D6		; D6=X^2+Y^2

	CMP.L	#$cf40000,D6	; indice K
	BHI.S	NOTDRAW
	DBF	D7,LOOP3
NOTDRAW:

;*****  PLOT  *****

	MOVE.L	A5,D2
	MOVE.W	D2,D3
	NOT.W	D3
	LSR.W	#3,D2
	ADD.W	A6,D2

	ADD.W	D7,D7
	ADD.W	JUMP_TABEL(PC,D7.W),D7
	JMP	JUMP_TABEL(PC,D7.W)

	DR.W	PIXEL_00000
JUMP_TABEL:
	DR.W	PIXEL_11111
	DR.W	PIXEL_11110
	DR.W	PIXEL_11101
	DR.W	PIXEL_11100
	DR.W	PIXEL_11011
	DR.W	PIXEL_11010
	DR.W	PIXEL_11001
	DR.W	PIXEL_11000
	DR.W	PIXEL_10111
	DR.W	PIXEL_10110
	DR.W	PIXEL_10101
	DR.W	PIXEL_10100
	DR.W	PIXEL_10011
	DR.W	PIXEL_10010
	DR.W	PIXEL_10001
	DR.W	PIXEL_10000

	DR.W	PIXEL_01111
	DR.W	PIXEL_01110
	DR.W	PIXEL_01101
	DR.W	PIXEL_01100
	DR.W	PIXEL_01011
	DR.W	PIXEL_01010
	DR.W	PIXEL_01001
	DR.W	PIXEL_01000
	DR.W	PIXEL_00111
	DR.W	PIXEL_00110
	DR.W	PIXEL_00101
	DR.W	PIXEL_00100
	DR.W	PIXEL_00011
	DR.W	PIXEL_00010
	DR.W	PIXEL_00001

DOTSET:	MACRO
PIXEL_\1:
	IF	[%\1>>0]&1
	BSET	D3,(A0,D2.W)
	ENDC
	IF	[%\1>>1]&1
	BSET	D3,(A1,D2.W)
	ENDC
	IF	[%\1>>2]&1
	BSET	D3,(A2,D2.W)
	ENDC
	IF	[%\1>>3]&1
	BSET	D3,(A3,D2.W)
	ENDC
	IF	[%\1>>4]&1
	BSET	D3,(A4,D2.W)
	ENDC
	BRA	MAIN_LOOP
	ENDM

	DOTSET	00000
	DOTSET	00001
	DOTSET	00010
	DOTSET	00011
	DOTSET	00100
	DOTSET	00101
	DOTSET	00110
	DOTSET	00111
	DOTSET	01000
	DOTSET	01001
	DOTSET	01010
	DOTSET	01011
	DOTSET	01100
	DOTSET	01101
	DOTSET	01110
	DOTSET	01111

	DOTSET	10000
	DOTSET	10001
	DOTSET	10010
	DOTSET	10011
	DOTSET	10100
	DOTSET	10101
	DOTSET	10110
	DOTSET	10111
	DOTSET	11000
	DOTSET	11001
	DOTSET	11010
	DOTSET	11011
	DOTSET	11100
	DOTSET	11101
	DOTSET	11110
	DOTSET	11111

;*** MAIN LOOP ***

MAIN_LOOP:
	ADDQ.W	#1,A5
	ADD.W	#ZOOM,CORDX
	CMP.W	#320,A5		; 320
 	BNE.L	LOOP2
	ADD.W	#ZOOM,CORDY
	ADD.W	#40,A6
	btst	#6,$bfe001
	beq	end
	CMP.W	#256*40,A6	; 189
	BNE.L	LOOP1
END:
	RTS

CORDX:	DC.W	0
CORDY:	DC.W	0
	rts

; *******************************************************
; ****  inits: efface l'ecran                        ****
; ****         met en place la nouvelle copper-list  ****
; *******************************************************
inits:
	lea	planeadr,a0
	move.w	#$31ff,d0	; on vide 5 bitplans 
cls:	
	clr.l	(a0)+
	dbra	d0,cls
	
	move.l	#planeadr,d0
	lea	copper_plane,a1
	move.w	#4,d1		; 5 bitplans
	move.w	#$e0,d2

init_bitplane:

	move.w	d2,(a1)+
	add.w	#2,d2
	swap	d0
	move.w	d0,(a1)+
	move.w	d2,(a1)+
	add.w	#2,d2
	swap	d0
	move.w	d0,(a1)+
	add.l	#10240,d0

	dbf	d1,init_bitplane

	lea	copperlist,a0
	move.l	a0,$dff080
	clr.w	$dff088
	move.w	#$8380,$dff096	; (copper et bitplans)
	rts

; *********************************************************
; ****  waitclick: test le bouton gauche de la souris  ****
; *********************************************************
waitclick:
	btst	#6,$bfe001
	bne	waitclick
	rts

; **********************************************************
; ****  sauve: le multitask ca se respecte (oui! oui!)  ****
; **********************************************************
sauve:
	move.l	$6c.w,oldirq
	lea	$dff000,a5
	move.w	2(a5),olddma
	move.w	$1c(a5),oldint	; (sauve intena)
	move.w	#$7fff,$96(a5)
	move.w	#$7fff,$9c(a5)	; (vide intena)
	move.l	$4.w,a6
	jsr	-132(a6)	; (forbid)
	rts

; ************************************************************
; ****  restore: le multitask ca se respecte (encore!)  ******
; ************************************************************
restore:
	move.w	#$7fff,$dff09a
	move.w	#$7fff,$dff096
	move.l	oldirq,$6c.w
	lea	$dff000,a5
	move.w	olddma,d0
	or.w	#$8000,d0
	move.w	d0,$96(a5)
	move.w	oldint,d0
	or.w	#$8000,d0
	move.w	d0,$9a(a5)
	move.l	$4.w,a6
	jsr	-138(a6)

	move.l	4,a6
	lea	gfxname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
	rts

planeadr:	blk.b	10240*5,0

bitplane1_ptr:	dc.l	planeadr
bitplane2_ptr:	dc.l	planeadr+(10240*1)
bitplane3_ptr:	dc.l	planeadr+(10240*2)
bitplane4_ptr:	dc.l	planeadr+(10240*3)
bitplane5_ptr:	dc.l	planeadr+(10240*4)
oldirq:		dc.l	0
olddma:		dc.w	0
oldint:		dc.w	0

copperlist:	dc.w	$8e,$2c81,$90,$2cc1,$92,$38,$94,$d0
		dc.w	$100,$5200,$102,$0,$108,$0
copper_plane:
		blk.w	20,0
		dc.w	$180,$000,$182,$100,$184,$200,$186,$300,$188,$400
		dc.w	$18a,$500,$18c,$600,$18e,$700,$190,$800,$192,$900
		dc.w	$194,$a00,$196,$b00,$198,$c00,$19a,$d00,$19c,$e00
		dc.w	$19e,$f00,$1a0,$f11,$1a2,$f22,$1a4,$f33,$1a6,$f44
		dc.w	$1a8,$f55,$1aa,$f66,$1ac,$f77,$1ae,$f88,$1b0,$f99
		dc.w	$1b2,$faa,$1b4,$fbb,$1b6,$fcc,$1b8,$fdd,$1ba,$fee
		dc.w	$1bc,$fff,$1be,$000
		dc.l	$fffffffe


gfxname:	dc.b	"graphics.library",0
