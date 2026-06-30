;----------------------------------
;ri  generateur  dans generateur
;ri  mod.flasher501 dans data
;----------------------------------
 
jmp j
Exec=4			
OpenLibrary=-408	
CloseLibrary=-414
forbid=-132
permit=-138
even

j:
	jsr initialisercopper	
	jsr setcopper
	jsr rout
	jsr effacerecran
	jsr affa
	jsr affbm
	jsr affg
	jsr start_muzak
	jsr changerirq

lea tadresse,a0
move.l #generateur,a2
move.w #1,d0
carl1:
move.w #19,d1
 move.l a2,a1
  carl:
   move.l a1,(a0)+
    add.l #2,a1
  dbf d1,carl
add.l #960,a2
dbf d0,carl1

;---- bob1 = greting    50*100 ----
move.w #300,bx1
move.w #80,by1
;------------------------
move.l #generateur,gret
move.w #0,cgret
move.w #16,sgret
clr.w ptext
clr.w ccappe
move.w #-1,pcappe
clr.w flirq
clr.w cptc
move.w #800,ve
move.w #40,by2
move.w #1,bdy2
move.w #20,cbdy2
lea michel,a0
move.l a0,pmichel
clr.w cpmichel
clr.w ctlaser
move.w #$d9,alx
move.w #$d9,lx
;-------------------------
lea palh+2,a0
lea palette,a1
couleurs:
move.w cptc,d0
move.w (a1)+,d1
bsr boucle

lea $4(a0),a0
add.w #4,cptc

cmp.w #128,cptc
bne couleurs
bra ok

boucle:
ll:
add.w #$0001,(a0)
move.w #50,d2
ll2:
dbra d2,ll2
dbf d1,ll
sub.w #1,(a0)
rts

ok:
bsr effgene
move.w #1,flirq

wait:
cmp.b #200,$dff006
bne wait

move.w ve,d0
beq vitesse
sub.w #1,ve
bra fin

vitesse:
add.w #1,cpte
cmp.w #3,cpte
bne fin
clr.w cpte
bsr etoiles
bsr laser

fin:
andi.b	#64,$bfe001	;bouton de gauche ?
bne wait

tstfin:btst #14,$dff002 ;oui & attendre deniere op blitter
       bne tstfin

end:	
jsr stop_muzak
jsr remetreirq
jsr effacerecran

attendr:
cmp.b #200,$dff006
bne attendr
clr.l $dff146
clr.l $dff14e
clr.l $dff156
clr.l $dff15e
clr.l $dff166
clr.l $dff16e
clr.l $dff176
clr.l $dff17e
move.w #$0020,$dff096
move.l #$ffffffff,$dff044
move.l #$00180040,$dff064
move.l #generateur+9122,a1	;source laser
move.l #bitplane1+4014,a2
moveq #3,d5			;4 bitplanes
alaser2:
move.l a2,a0
move.l a0,$dff054	;d destination bitplane
move.l a1,$dff050	;a mask
move.w #$09f0,$dff040
move.w #$0588,$dff058
bsr waitb
lea $2800(a1),a1
lea $2800(a2),a2
dbf d5,alaser2

move.w #60,d0
finl1:
move.w #60000,d1
finl2:
dbra d1,finl2
dbra d0,finl1

move.w #$8020,$dff096
move.l exec,a6
jsr permit(a6)
move.l gfxbase,a0
lea $32(a0),a0
move.l (a0),$dff080
clr.w $dff088

	move.l exec,a6
	move.l	GfxBase,a1	
	jsr	CloseLibrary(a6)
	move.l dos_base,a1
	jsr closelibrary(a6)
clr.l d0
rts			
;------------------------------
effgene:
move.l #generateur+2000,a0
move.w #131,d0
effgl:
move.l #$ffffffff,(a0)
move.l #$ffffffff,4(a0)
add.l #40,a0
dbf d0,effgl
rts

effacerecran:
move.l #bitplane1,a0
move.w #12799,d0
eff:
move.l #$0,(a0)+
dbf d0,eff
rts

cappe:		;<------ scrolling dand la cappe
bsr scrc
add.w #1,ccappe
cmp.w #10,ccappe
bne fingret
clr.w  ccappe
add.w #1,pcappe
cmp.w #10,pcappe;<----- nb de lignes pour le scrolling cappe
bne contc
clr.w pcappe
contc:
move.l #greting,a0
move.w pcappe,d1
mulu #9,d1
add.w d1,a0
move.l #generateur+2000,a2
move.w #0,d0
move.w #15,d2
bsr bbgret
fingret:
rts

scrc:
move.l #$ffffffff,$dff044
clr.w $dff042
move.w #$09f0,$dff040
move.l #$00200020,$dff064
move.l #generateur+2000,$dff054
move.l #generateur+2040,$dff050
move.w #130,d0
asl #6,d0
ori.w #4,d0
move.w d0,$dff058
bsr waitb

move.l #$ffffffff,$dff044
move.l #$00200020,$dff064
move.l #generateur+2000,a1	;source laser
move.l #bitplane3+2800,a0
clr.l d1
clr.l d0
move.w #208,d0
divu #16,d0
move.w d0,d1
mulu #2,d1
add.l d1,a0
move.l a0,$dff054	;d destination bitplane
move.l a1,$dff050	;a mask
swap d0
ror.w #4,d0
ori #$09f0,d0
move.w d0,$dff040
move.w #90,d0
asl #6,d0
ori.w #4,d0
move.w d0,$dff058

bsr waitb
rts
ccappe:dc.w 0
pcappe:dc.w 0


bbgret:
move.l a2,a1
add.w d0,a1
mulu #320,d2
add.w d2,a1
move.l a1,a3
bbaratin:
clr.l d1
move.b (a0)+,d1
cmp.b #0,d1
beq finsb2
lea $fc90f4,a2
sub.b #32,d1
add.l d1,a2
move.w #7,d5
print2:
move.b (a2),d3
eor.b #$ff,d3
move.b d3,(a1)
add.l #$c0,a2
add.l #40,a1
dbf d5,print2
move.l a3,a1
addq #1,a1
move.l a1,a3
bra bbaratin
finsb2:rts


;----------------------------
laser:
bsr scrg
add.w #1,cptg
cmp.w #10,cptg
bne finsb
clr.w cptg
bsr agret
add.l #16,pmichel
add.w #1,cpmichel
cmp.w #10,cpmichel;<---- nb de lignes pour le scrolling hublot
bne sortir
lea michel,a0
move.l a0,pmichel
clr.w cpmichel
sortir:
rts

agret:
move.l pmichel,a0
move.l #bitplane5,a2
move.w #24,d0
move.w #25,d2
aagret:
move.l a2,a1
add.w d0,a1
mulu #320,d2
add.w d2,a1
move.l a1,a3
sbaratin:
clr.l d1
move.b (a0)+,d1
cmp.b #0,d1
beq finsb
lea $fc90f4,a2
sub.b #32,d1
add.l d1,a2
move.w #7,d5
print:
move.b (a2),(a1)
add.l #$c0,a2
add.l #40,a1
dbf d5,print
move.l a3,a1
addq #1,a1
move.l a1,a3
bra sbaratin
finsb:rts

;-------------------------
michel:
dc.b '     laser     ',$00
dc.b '    the best   ',$00
dc.b '      way      ',$00
dc.b '  for swapping ',$00
dc.b '               ',$00
dc.b '    laser      ',$00
dc.b '   the best    ',$00
dc.b '     way       ',$00
dc.b '  for swapping ',$00
dc.b '               ',$00
;-------------------------
greting:
dc.b '  laser ',$00
dc.b '   the  ',$00
dc.b '   best ',$00
dc.b '        ',$00
dc.b ' c      ',$00
dc.b '  o     ',$00
dc.b '   d    ',$00
dc.b '    i   ',$00
dc.b '     n  ',$00
dc.b '      g ',$00
;------------------------
even
pmichel:dc.l 0
cpmichel:dc.w 0
cptg:dc.w 0

scrg:
move.l #$ffffffff,$dff044
clr.w $dff042
move.w #$0df0,$dff040
move.l #$00400018,$dff064
move.l #bitplane1+2808,$dff054
move.l #bitplane5+384,$dff050
move.w #$1408,$dff058;80*8
bsr waitb

move.l #$ffffffff,$dff044
clr.w $dff042
move.w #$09f0,$dff040
move.l #$00180018,$dff064
move.l #bitplane5+6344,$dff054
move.l #bitplane5+6384,$dff050
;move.w #50,d0
;asl #6,d0
;ori.w #8,d0
move.w #$0c88,$dff058;50*8
bsr waitb

;move.l #$ffffffff,$dff044
;clr.w $dff042
move.w #$09f0,$dff040
move.l #$00180018,$dff064
move.l #bitplane5+4344,$dff054
move.l #bitplane5+4424,$dff050
;move.w #50,d0
;asl #6,d0
;ori.w #8,d0
move.w #$0c88,$dff058;50*8
bsr waitb

;move.l #$ffffffff,$dff044
;clr.w $dff042
move.w #$09f0,$dff040
move.l #$00180018,$dff064
move.l #bitplane5+2344,$dff054
move.l #bitplane5+2464,$dff050
;move.w #50,d0
;asl #6,d0
;ori.w #8,d0
move.w #$0c88,$dff058
bsr waitb

;move.l #$ffffffff,$dff044
;clr.w $dff042
move.w #$09f0,$dff040
move.l #$00180018,$dff064
move.l #bitplane5+1144,$dff054
move.l #bitplane5+1224,$dff050
;move.w #30,d0
;asl #6,d0
;ori.w #8,d0
move.w #$0788,$dff058;30*8
bsr waitb


;move.l #$ffffffff,$dff044
;clr.w $dff042
move.w #$09f0,$dff040
move.l #$00180018,$dff064
move.l #bitplane5+304,$dff054
move.l #bitplane5+344,$dff050
;move.w #30,d0
;asl #6,d0
;ori.w #8,d0
move.w #$0788,$dff058;30*8
bsr waitb
rts


trap:
move.w #$2700,sr
rte
;-----------------------
afflaser:
movem.l d0-d2/a0-a3,-(sp)
move.w lx,alx
clr.l d0
laserl:
add.w #2,ctlaser
move.w ctlaser,d0
lea sinlaser,a0
add.w d0,a0
move.w (a0),lx	;d0:position x
cmp.w #0,lx
bne affl
clr.w ctlaser
bra laserl

affl:
move.l #$ffffffff,$dff044
move.l #$00180018,$dff064
move.l #generateur+9122,a1	;source laser
move.l #bitplane1,a2
clr.l d1
moveq #3,d5			;4 bitplanes
alaser:
move.l a2,a0
clr.l d0
move.w lx,d0
divu #16,d0
move.w d0,d1
mulu #2,d1
add.l d1,a0
move.l a0,$dff054	;d destination bitplane
move.l a1,$dff050	;a mask
swap d0
ror.w #4,d0
ori #$09f0,d0
move.w d0,$dff040
move.w #$0588,$dff058
bsr waitb
lea $2800(a1),a1
lea $2800(a2),a2
dbf d5,alaser
movem.l (sp)+,d0-d2/a0-a3
rts

efflaser:
movem.l d0-d2/a0-a3,-(sp)
move.l #$ffffffff,$dff044
move.l #$00180018,$dff064
move.l #generateur+9218,a1	;source laser
move.l #bitplane1,a2
clr.l d1
moveq #3,d5			;4 bitplanes
elaser:
move.l a2,a0
clr.l d0
move.w alx,d0
divu #16,d0
move.w d0,d1
mulu #2,d1
add.l d1,a0
move.l a0,$dff054	;d destination bitplane
move.l a1,$dff050	;a mask
swap d0
ror.w #4,d0
ori #$09f0,d0
move.w d0,$dff040
move.w #$0588,$dff058
bsr waitb
lea $2800(a1),a1
lea $2800(a2),a2
dbf d5,elaser
movem.l (sp)+,d0-d2/a0-a3
rts
lx:dc.w 0
alx:dc.w 0


;------------------------
affbm:
movem.l d0-d2/a0-a2,-(sp)
move.l #$ffffffff,$dff044
move.l #$00200020,$dff064
move.l #generateur+9462,a1	;logo
moveq #3,d5			;4 bitplanes
lea bitplane1+7800,a2
bm2:
move.l a2,a0
move.l a0,$dff054	;d destination bitplane
move.l a1,$dff050	;a mask
move.w #$09f0,$dff040
move.w #13,d0
asl #6,d0
ori #4,d0
move.w d0,$dff058
bsr waitb
lea $2800(a1),a1
lea $2800(a2),a2
dbf d5,bm2
movem.l (sp)+,d0-d2/a0-a2
rts

affa:
move.l #$ffffffff,$dff044
move.l #$00000000,$dff064
clr $dff042
move.l #generateur,a1
add.l #1960,a1	;albator
move.l #bitplane1,a0
add.l #1000,a0
moveq #3,d5			;4 bitplanes
al2:
move.l a0,$dff054	;d destination bitplane
move.l a1,$dff050	;a mask
move.w #$09f0,$dff040
move.w #179,d0
asl #6,d0
ori #20,d0
move.w d0,$dff058
bsr waitb
add.l #$2800,a1
add.l #$2800,a0
dbf d5,al2
rts
;----

bob2:
movem.l d0-d2/a0-a2,-(sp)
move.w by2,d0
move.w bdy2,d1
add.b d1,d0
move.w d0,by2

sub.w #1,cbdy2
bne afb2
eor.w #$fe,bdy2
move.w #60,cbdy2

afb2:
move.l #$ffffffff,$dff044
move.l #$00180018,$dff064
move.l #bitplane5+324,a0
move.w by2,d0
mulu #40,d0
add.w d0,a0
bobl2:
move.l #bitplane4+2088,$dff054	;d destination bitplane
move.l a0,$dff050	;a sources
move.w #$09f0,$dff040
move.w #120,d0
asl #6,d0
ori #8,d0
move.w d0,$dff058
bsr waitb
movem.l (sp)+,d0-d2/a0-a2
rts
;-----
rout:
lea palh,a0
move.w #32,d0
move.w #$0180,d1
pall:
move.w d1,(a0)+
move.w #$0,(a0)+
add.w #$0002,d1
sub.w #1,d0
bne pall


rts

changerirq:
move.w #$8000,$dff09a
move.l $6c,oldirq
move.l #newirq,$6c
move.w #$8030,$dff09a
rts

remetreirq:
move.w #$4000,$dff09a
move.l oldirq,$6c
move.w #$c000,$dff09a
rts

newirq:
movem.l d0-d7/a0-a6,-(a7)
move.w sr,-(sp)
move.w $dff01e,d0
btst #5,d0
beq irqfin
move.w flirq,d0
beq irqsortie


bsr vague
bsr efflaser
bsr afflaser


cirq:
bsr replay_muzak
bsr baratin
bsr bob2

add.w #1,comptc
cmp.w #2,comptc
bne irqsortie
clr.w comptc
bsr cappe

irqsortie:
move.w (sp)+,sr
movem.l (sp)+,d0-d7/a0-a6
move.w #$0020,$dff09c
rte
irqfin:
move.w (sp)+,sr
movem.l (sp)+,d0-d7/a0-a6
move.w #$0fdf,$dff09c
rte
oldirq: DC.L $0000
;-------------------------------
comptc:dc.w 0
flirq:dc.w 0

vague:
lea sin,a0
add.w s0,a0
cmp.w #0,(a0)
bne cont0
clr.w  s0
cont0:
add.w #2,s0
lea ispr0,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s1,a0
cmp.w #0,(a0)
bne cont1
clr.w s1
cont1:
add.w #2,s1
lea ispr1,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s2,a0
cmp.w #0,(a0)
bne cont2
clr.w s2
cont2:
add.w #2,s2
lea ispr2,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s3,a0
cmp.w #0,(a0)
bne cont3
clr.w s3
cont3:
add.w #2,s3
lea ispr3,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s4,a0
cmp.w #0,(a0)
bne cont4
clr.w s4
cont4:
add.w #2,s4
lea ispr4,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s5,a0
cmp.w #0,(a0)
bne cont5
clr.w s5
cont5:
add.w #2,s5
lea ispr5,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s6,a0
cmp.w #0,(a0)
bne cont6
clr.w s6
cont6:
add.w #2,s6
lea ispr6,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
;
lea sin,a0
add.w s7,a0
cmp.w #0,(a0)
bne cont7
clr.w s7
cont7:
add.w #2,s7
lea ispr7,a1
move.w (a0),(a1)
move.b (a0),d0
add.b #16,d0
move.b d0,2(a1)
rts

loupe:
rts


baratin:
move.w fls,d0
bne pasdescroll
bsr scroll
sub.w #1,sgret
move.w sgret,d0
bne encor
move.w #8,sgret
bsr affg
encor:
rts

pasdescroll:
add.w #1,cfls
cmp.w #100,cfls
bne pasencore
clr.w fls
pasencore:
rts

;----- scrolling greting du bas [3 bitplanes] ---------
scroll:
move.l #$ffffffff,$dff044
clr.w $dff042
move.l #$00000000,$dff064
move.w #$e9f0,$dff040
lea bitplane1+8964,a0
lea bitplane1+8962,a1
moveq #2,d1
scrl:
move.l a0,$dff050
move.l a1,$dff054
move #24,d0
asl #6,d0
ori #23,d0
move d0,$dff058
bsr waitb
lea $2800(a0),a0
lea $2800(a1),a1
dbf d1,scrl
rts

affg:
move.l #text,a0
move.w ptext,d0
add.w d0,a0
move.b (a0),d1	;d1=caractere a afficher
cmp.b #'&',d1
beq attendre
cmp.b #$00,d1
bne pasfini
clr.w ptext
bra affg
pasfini:
move.w #-1,d0
move.l #scheck,a1
rl:
add.w #1,d0
cmp.b (a1)+,d1
bne rl
 
mulu #4,d0
move.l #tadresse,a0
add.l d0,a0
move.l (a0),adresse
add.w #1,ptext

aff:
move.l #$ffffffff,$dff044
clr.w $dff042
move.l #$0026002c,$dff064
move.w #$09f0,$dff040
move.l adresse,a0
lea bitplane1+9008,a1
moveq #2,d1
agl:
move.l a0,$dff050
move.l a1,$dff054
move #23,d0
asl#6,d0
ori #1,d0
move d0,$dff058
bsr waitb
lea $2800(a0),a0
lea $2800(a1),a1
dbf d1,agl
rts

attendre:
add.w #1,ptext
move.w #$1,fls
clr.w cfls
rts

;-------------------------------

initialisercopper:
	move.l exec,a6
	jsr forbid(a6)
	lea Dosname,a1
	jsr Openlibrary(a6)
	move.l d0,dos_base
	lea	GrName,a1	
	jsr	OpenLibrary(a6)	
	move.l	d0,GfxBase	

lea spr0,a0
move.l #ispr0,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
lea spr1,a0
move.l #ispr1,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
lea spr2,a0
move.l #ispr2,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
lea spr3,a0
move.l #ispr3,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)

lea spr4,a0
move.l #ispr4,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
lea spr5,a0
move.l #ispr5,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
lea spr6,a0
move.l #ispr6,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
lea spr7,a0
move.l #ispr7,d0
move.w d0,6(a0)
swap d0
move.w d0,2(a0)
rts

setcopper:
	move.l	copptr,a0	
	move.l	(a0),oldcop	
	move.l	#Copper,$dff080	
move.w #$85e0,$dff096	
clr $dff088
rts

copper:
palh:blk.l 32
	DC.W	$00e0
hi1:	DC.W	$0005
	DC.W	$00e2
lo1:	DC.W	$0000
	DC.W	$00e4
hi2:	DC.W	$0005
	DC.W	$00e6
lo2:	DC.W	$2800
	DC.W	$00e8
hi3:	DC.W	$0005
	DC.W	$00ea
lo3:	DC.W	$5000
	DC.W	$00ec
hi4:	DC.W	$0005
	DC.W	$00ee
lo4:	DC.W	$7800

        DC.W	$0100,$4000
	DC.W	$0102,$0000
	DC.W	$0104,$0000
	DC.W	$0108,$0000
	DC.W	$010a,$0000
	DC.W	$0092,$0038
	DC.W	$0094,$00d0
	DC.W	$008e,$2c81
	DC.W	$0090,$22d1

spr0:	dc.w $0120,$0000
	dc.w $0122,$0000
spr1:	dc.w $0124,$0000
	dc.w $0126,$0000
spr2:	dc.w $0128,$0000
	dc.w $012a,$0000
spr3:	dc.w $012c,$0000
	dc.w $012e,$0000
spr4:	dc.w $0130,$0000
	dc.w $0132,$0000
spr5:	dc.w $0134,$0000
	dc.w $0136,$0000
spr6:	dc.w $0138,$0000
	dc.w $013a,$0000
spr7:	dc.w $013c,$0000
	dc.w $013e,$0000

dc.w $fc01,$ff00
dc.w $0092,$0028
dc.w $0094,$00d8
dc.w $0180,$015
dc.w $0182,$fcc
dc.w $0184,$f99
dc.w $0186,$015
dc.w $0188,$f44
dc.w $018a,$c22
dc.w $018c,$a11
dc.w $018e,$700
dc.w $0102,$00ff
dc.w $ffff,$fffe

waitb:
btst #14,$dff002
bne waitb
rts

even
GrName:		DC.B 'graphics.library',0
even
Dosname:	DC.B 'dos.library',0
copptr:		blk.l 1,0
oldcop:		blk.l 1,0
GfxBase:	blk.l 1,0
Dos_base:	blk.l 1,0
savesp:dc.l 0

bitplane1=$50000
bitplane2=bitplane1+10240
bitplane3=bitplane2+10240
bitplane4=bitplane3+10240
bitplane5=bitplane4+10240

palette:
dc.w $015,$03d,$039,$015,$000,$500,$900,$d00,$f76,$ebb
dc.w $eee,$771,$740,$77e,$d85,$777

dc.w $000,$55f,$00f,$aaf,$000,$55f,$00f,$aaf
dc.w $000,$55f,$00f,$aaf,$000,$55f,$00f,$aaf

bx1:dc.w 0
by1:dc.w 0
abx1:dc.w 0
aby1:dc.w 0

bx2:dc.w 0
by2:dc.w 0
abx2:dc.w 0
aby2:dc.w 0

bx3:dc.w 0
by3:dc.w 0
abx3:dc.w 0
aby3:dc.w 0

bx4:dc.w 0
by4:dc.w 0
abx4:dc.w 0
aby4:dc.w 0

gret:dc.l 0
adresse:dc.l 0
cgret:dc.w 0
sgret:dc.w 0
ptext:dc.w 0

tadresse:blk.l 40,$00050000

bbob1:blk.b 1920,00
bbob2:blk.b 1920,00
bbob3:blk.b 1920,00
bbob4:blk.b 1920,00


text:
dc.b '                                           '
dc.b ' jean claude &  voici notre superbe demo'
dc.b $00	;fin du greting

scheck:
dc.b 'abcdefghijklmnopqrstuvwxyz '
even

ispr0:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000

ispr1:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000
ispr2:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000
ispr3:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000
ispr4:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000
ispr5:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000
ispr6:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000
ispr7:
dc.w $80b0,$8500
dc.l %00000000000000000000001111000000
dc.l %00000000000000000000111111110000
dc.l %00000000111000000001111100011000
dc.l %00000000111100000011111101101100
dc.l %00000000111110000111111100110110
dc.l %00000000011111000111111110011010
dc.l %00000000001111001111111111001011
dc.l %00000000000111001111111111100011
dc.l %00000000000000001111111111111111
dc.l %00000000000000001111111111111111
dc.l %00000000000000000111111111111110
dc.l %00000000000000000111111111111110
dc.l %00000000000000000011111111111100
dc.l %00000000000000000001111111111000
dc.l %00000000000000000000111111110000
dc.l %00000000000000000000001111000000
dc.w $0000,$0000



sin:
dc.w $c37E,$c280,$c082,$bC84,$b786,$b188,$a98A,$a28C
dc.w $aA8E,$928F,$8A91,$8393,$8E95,$7996,$7598,$7399
dc.w $739B,$749C,$779D,$7B9F,$81A0,$87A1,$8FA2,$97A3
dc.w $9EA3,$a6A4,$aEA5,$b4A5,$bAA5,$bEA6,$c1A6,$c3A6

dc.w $c3A6,$c1A6,$bEA6,$b9A5,$b3A5,$aDA4,$a5A4,$9DA3
dc.w $95A2,$8DA1,$86A1,$809F,$7B9E,$779D,$749C,$739A
dc.w $7499,$7698,$7996,$7E94,$8593,$8C91,$938F,$9B8D
dc.w $a38B,$aB89,$b288,$b886,$bD84,$c082,$c280,$c37E

dc.w $c27C,$bF7A,$bB78,$b676,$aF74,$a872,$a070,$986E
dc.w $916C,$896B,$8269,$7D67,$7866,$7564,$7362,$7361
dc.w $7560,$785E,$7C5D,$825C,$895B,$905A,$9859,$a059
dc.w $a858,$aF57,$b557,$bB57,$bF56,$c256,$c356,$c356
dc.w $c156,$bD56,$b857,$b257,$aB58,$a458,$9C59,$945A
dc.w $8C5B,$855C,$7F5D,$7A5E,$765F,$7460,$7362,$7463
dc.w $7665,$7A66,$7F68,$866A,$8D6B,$956D,$9D6F,$a471

dc.w $aC73,$b375,$b977,$bD79,$c17B,$c37D,$c37E,$c382
dc.w $c386,$c38A,$c28E,$c291,$c195,$c198,$c09B,$bF9D
dc.w $bEA0,$bDA2,$bCA3,$bBA5,$bAA5,$b8A6,$b7A6,$b5A6

dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6
dc.w $b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6,$b5a6

dc.w $b4A5,$b2A4,$b1A2,$aFA1,$aD9E,$aB9C,$a999,$a896
dc.w $a693,$a48F,$a28B,$a088,$9E84,$9C80,$9A7C,$9878
dc.w $9674,$9470,$926C,$9069,$8E66,$8C62,$8A60,$895D
dc.w $875B,$8559,$8358,$8257,$8056,$7F56,$7E56,$7C57
dc.w $7B58,$7A59,$795B,$785D,$775F,$7662,$7565,$7568
dc.w $746B,$746F,$7373,$7377,$737B,$737F,$7383,$7387
dc.w $748A,$748E,$7492,$7595,$7698,$769B,$779E,$78A0
dc.w $79A2,$7AA4,$7BA5,$7DA6,$7EA6,$7FA6,$81A6,$82A5

dc.w $84A4,$86A2,$87A0,$899E,$8B9B,$8D99,$8F95,$9192
dc.w $938E,$958B,$9787,$9983,$9B7F,$9D7B,$9E77,$a073
dc.w $a26F,$a46C,$a668,$a865,$aA62,$aC5F,$aE5D,$aF5B
dc.w $b159,$b358,$b457,$b656,$b756,$b956,$bA57,$bB58
dc.w $bC59,$bD5B,$bE5D,$bF60,$c062,$c165,$c169,$c26C
dc.w $c270,$c373,$c377,$c37B
dc.w $0000
;---------------------------------------------------
sinlaser:
dc.w $D9,$CD,$C3,$B9,$B1
dc.w $AB,$A6,$A2,$A0,$A0,$A1,$A4,$A9,$AF,$B6,$BF,$C9,$D2
dc.w $D5,$CD,$C3,$B9,$B1,$AB,$A6,$A2,$A0,$A0
dc.w $9F,$9D,$99,$93,$8C,$84,$7A,$6F,$63,$56,$49,$3A,$2B
dc.w $1B,$B,$1
dc.w $10,$20,$2F,$3E,$4D,$5A,$67,$73,$7D,$87,$8F,$95,$9A,$9E,$A0
dc.w $9F,$9C,$97,$91,$8A,$81,$77,$6C,$60,$52,$44,$36,$26,$17,$7
dc.w $10,$20,$2f,$3e,$4d,$5a,$67,$73,$7d,$87,$8f,$95,$9e
dc.w $a6,$ab,$b1,$ba,$c3,$cd,$d5
dc.w $00

ctlaser:dc.w 0

s7:dc.w 0
s6:dc.w 50
s5:dc.w 100
s4:dc.w 150
s3:dc.w 200
s2:dc.w 250
s1:dc.w 300
s0:dc.w 350
cptc:dc.w 0
fls:dc.w 0
cfls:dc.w 0

;------------------------------------------
etoiles:	movem.l	d0-d7/a0-a6,-(a7)
neco:		lea	skorsx,a0
		lea	skorsy,a1
		lea	speed1,a2
		lea	speed2,a3
		clr.l	d7
stopo:		move	(a0),d0
		move	(a1),d1
		move	(a2)+,d2
		move	(a3)+,d3
		move	d0,d4
		move	d1,d5
		sub	d2,d0
		sub	d3,d1
		cmp	#184,d0
		ble	nomaxx
		move	#100,d0
		move	#128,d1
		jmp	nominy
nomaxx:		cmp	#9,d0
		bge	nominx
		move	#100,d0
		move	#128,d1
		jmp	nominy
nominx:		cmp	#256,d1
		ble	nomaxy
		move	#100,d0
		move	#128,d1
		jmp	nominy
nomaxy:		cmp	#9,d1
		bge	nominy
		move	#100,d0
		move	#128,d1
nominy:		move.w	d0,(a0)
		move.w	d1,(a1)+
;
		mulu	#40,d5
		lsr.w	#3,d4
		move.l	#bitplane5,a5
		add	d4,a5
		add	d5,a5
		move.b  #$00,(a5)
;
		move.l	#bitplane5,a5
		lsr.w	#3,d0
		mulu	#40,d1
		add	d0,a5
		add	d1,a5
;
		move.w	(a0)+,d0
		and.w	#$7,d0
		move.l	#128,d1
		lsr.l	d0,d1
		move.b	d1,(a5)
;
		add.w	#1,d7
		cmp.w	#60,d7
		bne	stopo
		movem.l (a7)+,d0-d7/a0-a6
		rts
skorsx:
dc.w 1,2,3,4,5,6,7,8,9,10
dc.w 5,1,1,3,4,2,8,7,3,1
dc.w 1,2,3,4,5,6,7,8,9,10
dc.w 1,2,3,4,5,6,7,8,9,10
dc.w 1,2,3,4,5,6,7,8,9,10
dc.w 2,8,6,1,1,2,8,4,6,9
skorsy:
dc.w 10,9,8,7,6,5,4,3,2,1
dc.w 10,9,8,7,6,5,4,3,2,1
dc.w 5,4,2,1,1,9,8,5,2,3
dc.w 10,9,8,7,6,5,4,3,2,1
dc.w 10,9,8,7,6,5,4,3,2,1
dc.w 2,4,1,1,3,5,6,2,1,7
speed1:
dc.w 1,2,3,4,3,2,1,2,3,4
dc.w -1,-2,-3,-4,-3,-2,-1,-2,-3,-4
dc.w 1,2,3,4,3,2,1,2,3,4
dc.w -1,-2,-3,-4,-3,-2,-1,-2,-3,-4
dc.w -1,2,4,-3,4,-3,-1,2,1,3
dc.w 1,5,-5,4,-1,3,-1,2,-3,4
speed2:
dc.w 1,2,3,4,5,4,3,2,1,2
dc.w 1,2,3,4,5,4,3,2,1,2
dc.w -1,-2,-3,-4,-5,-4,-3,-2,-1,-2
dc.w -1,-2,-3,-4,-5,-4,-3,-2,-1,-2
dc.w 1,5,-3,-1,4,-2,2,-3,4,1
dc.w 1,6,3,-4,-2,1,-5,-4,2,-3
cpte:dc.w 0
ve:dc.w 0
bdy2:dc.w 0
cbdy2:dc.w 0

even:
;-------------------------------

start_muzak:
	move.l	#data,muzakoffset	;** get offset
init0:	move.l	muzakoffset,a0		;** get highest used pattern
	add.l	#472,a0
	move.l	#$80,d0
	clr.l	d1
init1:	move.l	d1,d2
	subq.w	#1,d0
init2:	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	init1
	dbf	d0,init2
	addq.b	#1,d2

init3:	move.l	muzakoffset,a0		;** calc samplepointers
	lea	pointers(pc),a1
	lsl.l	#8,d2
	lsl.l	#2,d2
	add.l	#600,d2
	add.l	a0,d2
	moveq	#14,d0
init4:	move.l	d2,(a1)+
	clr.l	d1
	move.w	42(a0),d1
	lsl.l	#1,d1
	add.l	d1,d2
	add.l	#30,a0
	dbf	d0,init4

init5:	clr.w	$dff0a8			;** clear used values
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.w	timpos
	clr.l	trkpos
	clr.l	patpos

init6:	move.l	muzakoffset,a0		;** initialize timer irq
	move.b	470(a0),numpat+1	;number of patterns
	rts

stop_muzak:
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts


replay_muzak:
	movem.l	d0-d7/a0-a6,-(a7)
	addq.w	#1,timpos
speed:	cmp.w	#6,timpos
	beq.L	replaystep

chaneleffects:				;** seek effects
	lea	datach0(pc),a6
	tst.b	3(a6)
	beq.s	ceff1
	lea	$dff0a0,a5
	bsr.s	ceff5
ceff1:	lea	datach1(pc),a6
	tst.b	3(a6)
	beq.s	ceff2
	lea	$dff0b0,a5
	bsr.s	ceff5
ceff2:	lea	datach2(pc),a6
	tst.b	3(a6)
	beq.s	ceff3
	lea	$dff0c0,a5
	bsr.s	ceff5
ceff3:	lea	datach3(pc),a6
	tst.b	3(a6)
	beq.s	ceff4
	lea	$dff0d0,a5
	bsr.s	ceff5
ceff4:	movem.l	(a7)+,d0-d7/a0-a6
	rts

ceff5:	move.b	2(a6),d0		;room for some more
	and.b	#$f,d0			;implementations below
	tst.b	d0
	beq.s	arpreggiato
	cmp.b	#1,d0
	beq.L	pitchup
	cmp.b	#2,d0
	beq.L	pitchdown
	cmp.b	#12,d0
	beq.L	setvol
	cmp.b	#14,d0
	beq.L	setfilt
	cmp.b	#15,d0
	beq.L	setspeed
	rts

arpreggiato:				;** spread by time
	cmp.w	#1,timpos
	beq.s	arp1
	cmp.w	#2,timpos
	beq.s	arp2
	cmp.w	#3,timpos
	beq.s	arp3
	cmp.w	#4,timpos
	beq.s	arp1
	cmp.w	#5,timpos
	beq.s	arp2
	rts

arp1:	clr.l	d0			;** get higher note-values
	move.b	3(a6),d0		;   or play original
	lsr.b	#4,d0
	bra.s	arp4
arp2:	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	bra.s	arp4
arp3:	move.w	16(a6),d2
	bra.s	arp6
arp4:	lsl.w	#1,d0
	clr.l	d1
	move.w	16(a6),d1
	lea	notetable,a0
arp5:	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	beq.s	arp6
	addq.l	#2,a0
	bra.s	arp5
arp6:	move.w	d2,6(a5)
	rts

pitchdown:
	bsr.s	newrou
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	add.w	d0,(a4)
	cmp.w	#$358,(a4)
	bmi.s	ok1
	move.w	#$358,(a4)
ok1:	move.w	(a4),6(a5)
	rts

pitchup:bsr.s	newrou
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	sub.w	d0,(a4)
	cmp.w	#$71,(a4)
	bpl.s	ok2
	move.w	#$71,(a4)
ok2:	move.w	(a4),6(a5)
	rts

setvol:	move.b	3(a6),8(a5)
	rts

setfilt:move.b	3(a6),d0
	and.b	#1,d0
	lsl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

setspeed:
	clr.l	d0
	move.b	3(a6),d0
	and.b	#$f,d0
	move.w	d0,speed+2
	rts

newrou:	cmp.l	#datach0,a6
	bne.s	next1
	lea	voi1(pc),a4
	rts
next1:	cmp.l	#datach1,a6
	bne.s	next2
	lea	voi2(pc),a4
	rts
next2:	cmp.l	#datach2,a6
	bne.s	next3
	lea	voi3(pc),a4
	rts
next3:	lea	voi4(pc),a4
	rts

replaystep:				;** work next pattern-step
	clr.w	timpos
	move.l	muzakoffset,a0
	move.l	a0,a3
	add.l	#12,a3			;ptr to soundprefs
	move.l	a0,a2
	add.l	#472,a2			;ptr to pattern-table
	add.l	#600,a0			;ptr to first pattern
	clr.l	d1
	move.l	trkpos,d0		;get ptr to current pattern
	move.b	(a2,d0),d1
	lsl.l	#8,d1
	lsl.l	#2,d1
	add.l	patpos,d1		;get ptr to current step
	clr.w	enbits
	lea	$dff0a0,a5		;chanel 0
	lea	datach0(pc),a6
	bsr.L	chanelhandler
	lea	$dff0b0,a5		;chanel 1
	lea	datach1(pc),a6
	bsr.L	chanelhandler
	lea	$dff0c0,a5		;chanel 2
	lea	datach2(pc),a6
	bsr.L	chanelhandler
	lea	$dff0d0,a5		;chanel 3
	lea	datach3(pc),a6
	bsr.L	chanelhandler
	move.w	#400,d0			;** wait a while and set len
rep1:	dbf	d0,rep1			;   of oneshot to 1 word
	move.w	#$8000,d0
	or.w	enbits,d0
	move.w	d0,$dff096
	cmp.w	#1,datach0+14
	bne.s	rep2
	clr.w	datach0+14
	move.w	#1,$dff0a4
rep2:	cmp.w	#1,datach1+14
	bne.s	rep3
	clr.w	datach1+14
	move.w	#1,$dff0b4
rep3:	cmp.w	#1,datach2+14
	bne.s	rep4
	clr.w	datach2+14
	move.w	#1,$dff0c4
rep4:	cmp.w	#1,datach3+14
	bne.s	rep5
	clr.w	datach3+14
	move.w	#1,$dff0d4

rep5:	add.l	#16,patpos		;next step
	cmp.l	#64*16,patpos		;pattern finished ?
	bne.s	rep6
	clr.l	patpos
	addq.l	#1,trkpos		;next pattern in table
	clr.l	d0
	move.w	numpat,d0
	cmp.l	trkpos,d0		;song finished ?
	bne.s	rep6
	clr.l	trkpos
rep6:	movem.l	(a7)+,d0-d7/a0-a6
	rts

chanelhandler:
	move.l	(a0,d1.l),(a6)		;get period & action-word
	addq.l	#4,d1			;point to next chanel
	clr.l	d2
	move.b	2(a6),d2		;get nibble for soundnumber
	lsr.b	#4,d2
	beq.s	chan2			;no soundchange !
	move.l	d2,d4			;** calc ptr to sample
	lsl.l	#2,d2
	mulu	#30,d4
	lea	pointers-4(pc),a1
	move.l	(a1,d2.l),4(a6)		;store sample-address
	move.w	(a3,d4.l),8(a6)		;store sample-len in words
	move.w	2(a3,d4.l),18(a6)	;store sample-volume

	move.l	d0,-(a7)
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#$c,d0
	bne.s	ok3
	move.b	3(a6),8(a5)
	bra.s	ok4
ok3:	move.w	2(a3,d4.l),8(a5)	;change chanel-volume
ok4:	move.l	(a7)+,d0

	clr.l	d3
	move.w	4(a3,d4),d3		;** calc repeatstart
	add.l	4(a6),d3
	move.l	d3,10(a6)		;store repeatstart
	move.w	6(a3,d4),14(a6)		;store repeatlength
	cmp.w	#1,14(a6)
	beq.s	chan2			;no sustainsound !
	move.l	10(a6),4(a6)		;repstart  = sndstart
	move.w	6(a3,d4),8(a6)		;replength = sndlength
chan2:	tst.w	(a6)
	beq.s	chan4			;no new note set !
	move.w	22(a6),$dff096		;clear dma
	tst.w	14(a6)
	bne.s	chan3			;no oneshot-sample
	move.w	#1,14(a6)		;allow resume (later)
chan3:	bsr.L	newrou
	move.w	(a6),(a4)
	move.w	(a6),16(a6)		;save note for effect
	move.l	4(a6),0(a5)		;set samplestart
	move.w	8(a6),4(a5)		;set samplelength
	move.w	(a6),6(a5)		;set period
	move.w	22(a6),d0
	or.w	d0,enbits		;store dma-bit
	move.w	18(a6),20(a6)		;volume trigger
chan4:	rts

datach0:	blk.w	11,0
		dc.w	1
datach1:	blk.w	11,0
		dc.w	2
datach2:	blk.w	11,0
		dc.w	4
datach3:	blk.w	11,0
		dc.w	8
voi1:		dc.w	0
voi2:		dc.w	0
voi3:		dc.w	0
voi4:		dc.w	0
pointers:	blk.l	15,0
notetable:	dc.w	856,808,762,720,678,640,604,570
		dc.w	538,508,480,453,428,404,381,360
		dc.w	339,320,302,285,269,254,240,226  
		dc.w	214,202,190,180,170,160,151,143
		dc.w	135,127,120,113,000
muzakoffset:	dc.l	0
trkpos:		dc.l	0
patpos:		dc.l	0
numpat:		dc.w	0
enbits:		dc.w	0
timpos:		dc.w	0
data:		blk.b	38192,0
generateur:	blk.b 40960,0
fini:
