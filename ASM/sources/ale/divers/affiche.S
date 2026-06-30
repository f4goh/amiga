;duel playing et scrolling
INTENA=$dff09A
INTREQ=$dff09C
INTREQR=$dff01E
INTENAR=$dff01C
DMACON=$dff096
COLOR00=$dff0180
VHPOSR=$dff006
;REGISTRE COPPER
COP1LC=$dff080
COP2LC=$dff084
COPJMP1=$dff088
COPJMP2=$dff08A
;REGISTRE BITPLANE
BPLCON0=$dff100
BPLCON1=$dff102
BPLCON2=$dff104
BPL1PTH=$0E0
BPL1PTL=$0E2
BPL1MOD=$dff108
BPL2MOD=$dff10A
DIWSTRT=$dff08E
DIWSTOP=$dff090
DDFSTRT=$dff092
DDFSTOP=$dff094
;registre blitter
BLTCON0=$dff040
BLTCON1=$dff042
BLTAPTH=$dff050
BLTAPTL=$dff052
BLTCPTH=$dff048
BLTCPTL=$dff04a
BLTBPTH=$dff04c
BLTBPTL=$dff04e
BLTDPTH=$dff054
BLTDPTL=$dff056
BLTSIZE=$dff058
BLTAMOD=$dff064
BLTCMOD=$dff060
BLTBMOD=$dff062
BLTDMOD=$dff066
BLTAFWM=$dff044
BLTALWM=$dff046
;CIA-A REGISTRE PORT A
CIAAPRA=$BFE001
;label
allocmen=-30-168
freemen=-30-180
execbase=4
chip=2
bplsize=40*256
clsize=9*4
start:
;allouer de la memoire pour copper
	move.l execbase,a6
	bsr save_all
	moveq #clsize,d0
	moveq #chip,d1
	jsr allocmen(a6)
	move.l d0,cladr
	beq fin
;installation de la liste copper

	moveq #4,d4
	move.l #bpl1pth,d3
	move.l #bpladr,d5
	move.l d0,a1
debut:
	move.w d3,(a1)+
	addq.w #2,d3
	swap d5
	move.w d5,(a1)+
	move.w d3,(a1)+
	addq.w #2,d3
	swap d5
	move.w d5,(a1)+
	add.l #bplsize,d5
	dbf d4,debut
	move.l #$fffffffe,(a1)+
;copper initialise
	move.w #$03e0,dmacon
	move.l cladr,COP1LC
	clr.w COPJMP1
;creation de la palette couleur
	lea palette,a0
	move.l #$dff180,a1
	move.l #31,d0
mettrecolor:
	move.w (a0)+,(a1)+
	dbra d0,mettrecolor
;bitplane initialise
	move.w #$3081,DIWSTRT
	move.w #$30C1,DIWSTOP
	move.w #$0038,DDFSTRT
	move.w #$00D0,DDFSTOP
	move.w #$5200,BPLCON0
	clr.w BPLCON1
	clr.w BPLCON2
	clr.w BPL1MOD
	clr.w BPL2MOD
;dma active
	move.w #$8380,DMACON
wait:	btst #6,CIAAPRA
	bne wait
;fin de programme
	move.l execbase,a6
	move.l cladr,a1
	moveq #clsize,d0
	jsr freemen(a6)
fin:	bsr restore_all
	clr.l d0
	rts
save_all:
	jsr -132(a6);forbid
	move.l $6c,save_vecteur_vbl
	move.w $dff01c,save_intena
	or.w #$8100,save_intena;mettre certain bits a 1 
	;pour pouvoir les replacer avec un or
	move.w $dff002,save_dmacon
	or.w #$c000,save_dmacon
	rts
restore_all:
	move.l save_vecteur_vbl,$6c
	move.w #$7fff,$dff09a;vide intena
	move.w save_intena,$dff09a;place la copie
	move.w #$7fff,$dff096;vide le dmacon
	move.w save_dmacon,$dff096;place la copie
	move.l 4,a6;base d'exec
	lea grname,a1;ouvre la library
	moveq #0,d0;vide d0
	jsr -552(a6);open-library
	move.l d0,a0;sauve handler
	move.l 38(a0),$dff080;startupcl ds cop1lc
	clr.w $dff088;copjmp1
	move.l d0,a1;adr de library
	jsr -414(a6);closelibrary
	jsr -138(a6);permit
	rts
save_intena:dc.w 0
save_dmacon:dc.w 0
save_vecteur_vbl:dc.l 0
cladr:	dc.l 0
bpladr:blk.l 5*2560,0
palette:blk.w 16,0
grname:dc.b "graphics.library",0
 even
