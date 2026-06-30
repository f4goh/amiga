execbase=4
openlib=-408
closelib=-414
openscreen=-198
closescreen=-66
movescreen=-162
joy2=$dff00c
feu=$bfe001

run:
	bsr openint
	bsr scr_open
	move joy2,d6
	bra loop
fin:
	bsr scr_close
	bsr closeint
	rts

;*** BOUCLE TEST JOY ***
loop:
	tst.b feu
	bpl fin
	move joy2,d0
	sub d6,d0
	cmp #$0100,d0
	bne noup
	move.l #-1,d1
	bsr scr_move
	bra loop
noup:
	cmp #$1,d0
	bne loop
	move.l #1,d1
	bsr scr_move
	bra loop

;*** DEPLACEMENT ECRAN ***
scr_move:
	move.l intbase,a6
	move.l screenhandle,a0
	clr.l d0
	jsr movescreen(a6)
	rts

;*** DEFINITION ECRAN ***
screen_defs:
	xpos:	dc.w 0
	ypos:	dc.w 0
	width:	dc.w 640
	height:	dc.w 200
	depth:	dc.w 2
	detailpen:	dc.b 0
	blockpen:	dc.b 1
	viewmodes:	dc.w $8002
	screentype:	dc.w 15
	font:	dc.l 0
	title:	dc.l titre
	gadgets:	dc.l 0
	bitmap:	dc.l 0
	titre:	dc.b "Ecran Intuition",0

;*** OUVRIR ECRAN ***
scr_open:
	move.l intbase,a6
	lea screen_defs,a0
	jsr openscreen(a6)
	move.l d0,screenhandle
	rts
screenhandle:
	dc.l 0


;*** FERMER ECRAN ***
scr_close:
	move.l intbase,a6
	move.l screenhandle,a0
	jsr closescreen(a6)
	rts


;*** OUVRIR INTUITION.LIBRARY ***
openint:
	move.l execbase,a6
	lea intname,a1
	jsr openlib(a6)
        move.l d0,intbase
	rts
intname:
	dc.b "intuition.library",0
	even
intbase:
	dc.l 0


;*** FERMER INTUITION.LIBRARY ***
closeint: 
	move.l execbase,a6
	move.l intbase,a1
	jsr closelib(a6)
	rts
