;packblock mit RI nach dem assemblieren nach Daten lesen
;ungepackt betraegt dieser block ueber 130000 Bytes und
;hatte daher nicht mehr Platz auf der Disk
;willst Du die Graphiken aendern so entpacke Dir den Block
;mit dem unpack_new Programm
;Du kannst ruhig saemtliche Routinen in Deine Programme
;einbauen solltest Du welche brauchen
;Gruss CHARLY
EXECBASE          =  4
OPENLIBRARY       = -408
CLOSELIBRARY      = -414
OPENDISKFONT      = -30
SCROLLRASTER      = -396
TEXT              = -60
MOVE              = -240
SETFONT           = -66
CLOSEFONT         = -78
FREESPRITE        = -414
FORBID            = -132
ZEIT = 1000
;-----------------------
; oberes screenbitmap = $50000
; SCREENBUFFER        = $54100
; 1 charplane = $6A938  
; 2 charplane = $6B130
; 3 charplane = $6B928
; leerplane   = $69800
;
START:
MOVEM.L D0-D7/A0-A6,-(A7)

move.l #daten,a1
move.l #datenende,a2
move.l #$7fe00,a0

decoder:
clr.l d0
clr.l d1
clr.l d2
rout:
CLR.L D0
move.l a2,A3
cmp.l A3,a1
bCC ende2 
move.b -(a2),d0
cmp.b #$db,d0
beq db
cmp.b #$da,d0
beq da
move.b d0,-(a0)
bra rout
; ------------ db machen
db:
CLR.L D0
move.b -(a2),d0
cmp.b #$01,d0
bne nullenmachen
move.b #$db,-(a0)
move.w #$0f00,$dff180
bra rout 
nullenmachen:
subq.b #1,d0
null:
move.b #00,-(a0)
move.w #$00f0,$dff180
dbra d0,null
bra rout
; --------------------
da:
clr.l d2
clr.l d0
move.b -(a2),d0
cmp.b #01,d0
bne zahlenroute 
move.b #$da,-(a0)
move.w #$0ff0,$dff180
bra rout
zahlenroute:
move.b -(a2),d2
subq.b #1,d0
xloop:
move.b d2,-(a0)
move.w #$000f,$dff180
dbra d0,xloop
bra rout
ende2:




MOVE.L EXECBASE,A6
JSR FORBID(A6)
LEA GFXNAME,A1
JSR OPENLIBRARY(A6)
MOVE.L D0,GFXBASE
MOVE.L GFXBASE,A6
MOVE.L #0,D0
JSR FREESPRITE(A6)
JSR IRQ_NEW
MOVE.L GFXBASE,A6
ADD.L #$32,A6
MOVE.L (A6),COPPERLIST_ALT
MOVE.L #COPPERLIST,(A6)
;-------------------
jsr $6d874
move.l #$50000,a0
move.l #$8200,d0
xx:
;MOVE.B #255, (a0)+
MOVE.B #0,(A0)+
dbra d0,xx


move.w #$8400,$dff096
WAIT:
CMP.B #0,STATUS ; WENN STATUSBYTE 0 TEXTSCREEN AUFGEBAUEN
BNE WEITER 
JSR BLITTSCREEN
; ------ SYNCRONISIEREN MIT RASTERSTRAHL ------
WEITER:
CMP.B #1,STATUS
BNE W1
move.l gfxbase,a6
move.l #bitmap3,a0
move.l SOURCEX2,d0    ; SOURCE X
move.l SOURCEY2,d1    ; SOURCE Y
move.l #bitmap2,a1
move.l DESTX2,d2   ; DEST X
move.l DESTY2,d3   ; DEST Y
move.l SIZEX2,d4   ; SIZE X
move.l SIZEY2,d5   ; SIZE Y
move.l #$c0,d6  
move.l #$ffff,d7
move.l #$62000,a2
jsr -30(a6)
ADD.L #1,SIZEX2
CMP.L #360,SIZEX2
BNE W1
MOVE.B #02,STATUS
MOVE.L #01,SIZEX2
w1:
move.l $dff004,d2
and.l #$0001ff00,d2
cmp.l #$0007000,d2
bne.s w1
; ---------------------------------------------
SUBQ.W #1,TIMER
CMP.W #00,TIMER
bne mousetest
move.b #0,status
MOVE.W #ZEIT,TIMER
mousetest:
;SUB.W #1,TIMER   ; ZAEHLT DIE ZEIT HERUNTER BIS NEUES BILD KOMMT
BTST #6,$BFE001
BNE WAIT
ENDE:
MOVE.L GFXBASE,A6
ADD.L #$32,A6
MOVE.L COPPERLIST_ALT,(A6)
MOVE.L GFXBASE,A6
JSR IRQ_OLD
;MOVE.W #$000F,$DFF096
MOVE.L EXECBASE,A6
JSR -138(A6)
MOVEM.L (A7)+,A0-A6/D0-D7
RTS
; ----- BLITTET GANZEN TEXTBILDSCHIRM -------
BLITTSCREEN:
CMP.L #20+[4*20],DESTY
BNE TESTZEILE
MOVE.B #01,STATUS
MOVE.L #20,DESTY
MOVE.L #2,DESTX
JMP NOTBLITT
TESTZEILE:
CMP.L #2+[14*24],DESTX
BNE ZEILE
MOVE.L #2,DESTX
ADD.L #20,DESTY
JMP NOTBLITT
ZEILE:
JSR GETCHARXY
add.l #24,destx ; SETZT DESTX POINTER AUF NAECHSTEN TAB
; ------------------------------
BLITTROUT:
move.l gfxbase,a6
move.l #bitmap1,a0
move.l SOURCEX,d0    ; SOURCE X
move.l SOURCEY,d1    ; SOURCE Y
move.l #bitmap3,a1
move.l DESTX,d2   ; DEST X
move.l DESTY,d3   ; DEST Y
move.l SIZEX,d4   ; SIZE X
move.l SIZEY,d5   ; SIZE Y
move.l #$c0,d6  
move.l #$ffff,d7
move.l #$62000,a2
jsr -30(a6)
NOTBLITT:
CMP.L #TEXTENDE,TEXTCOUNTER
BNE NOTTEXTENDE
MOVE.L #PRINTCODE,TEXTCOUNTER
NOTTEXTENDE:
RTS
; --------------------
; ---- HOLE SOURCE KOORDINATEN ----
GETCHARXY:
MOVE.L TEXTCOUNTER,A0
MOVE.L #CHARKOORDINATEN,A2
MOVE.L #CHARTABELLE,A1
CHARROUT:
MOVE.B (A0),D0
MOVE.B (A1),D1
CMP.B D0,D1
BNE NEXTCHAR
MOVE.L (A2)+,SOURCEX
MOVE.L  (A2),SOURCEY
ADD.L #1,TEXTCOUNTER
RTS
NEXTCHAR:
ADD.L #8,A2
ADD.L #1,a1
JMP CHARROUT
; -----------------------------
IRQ_NEW:
LEA OLDIRQ(PC),A0
MOVE.L $6C,2(A0)
LEA NEWIRQ(PC),A0
MOVE.L A0,$6C
RTS
; ----------------
IRQ_OLD:
LEA OLDIRQ+2(PC),A0
MOVE.L (A0),$6C
RTS
; ----------------
NEWIRQ:
MOVEM.L D0-D7/A0-A6,-(SP)
move.w $dff028,d1
btst #14,d1
beq irqend
SUB.W #92,PLANE1 ; 80
CMP.W #$7000,PLANE1
BNE R1
MOVE.W #$7000+5888,PLANE1
R1:
SUB.W #46,PLANE2
CMP.W #$7000+11776,PLANE2
BNE R2
MOVE.W #$7000+11776+5888,PLANE2
R2:
CMP.L #00,ZAEHLER
BNE R3
MOVE.L #02,ZAEHLER
SUB.W #46,PLANE3
CMP.W #$7000+11776+11776,PLANE3
BNE R3
MOVE.W #$7000+11776+11776+5888,PLANE3
R3:
SUBQ.L #1,ZAEHLER


;JMP IRQEND
SCROLLROUT:
CMP.W #15,SCROLLCOUNTER
BNE SCROLLPLUS
CMP.W #$5000,BITPLANE_4
BNE SCROLLNORMAL
MOVE.W #$5000+44,BITPLANE_4
MOVE.W #$5000+2904+44,BITPLANE_5
;MOVE.W #$5000+2904+2904+44,BITPLANE_6
SCROLLNORMAL:
MOVE.W #0,SCROLLCOUNTER
MOVE.W SCROLLCOUNTER,D0
ASL.W #4,D0
MOVE.W D0,SCROLLREGISTER
SUB.W #2,BITPLANE_4
SUB.W #2,BITPLANE_5
;SUB.W #2,BITPLANE_6
JMP IRQEND
SCROLLPLUS:
ADDQ.W #1,SCROLLCOUNTER
MOVE.W SCROLLCOUNTER,D0
ASL.W #4,D0
MOVE.W D0,SCROLLREGISTER


CMP.B #00,SPRITEZAEHLER
BNE SPRITEMOVE 
MOVE.B #4,SPRITEZAEHLER
CMP.L #SPRITEADRESSEN+[18*2],SPRITEDATENZAEHLER
BNE SPRITEZAEHLERPLUS
MOVE.L #SPRITEADRESSEN,SPRITEDATENZAEHLER
SPRITEZAEHLERPLUS:
MOVE.L SPRITEDATENZAEHLER,A0
MOVE.W (A0),SPRITEAKTUELL
ADDQ.L #4,SPRITEDATENZAEHLER
SPRITEMOVE:
SUBQ.B #1,SPRITEZAEHLER
move.l adresse,a0
MOVE.L #$70000,D1
CLR.L D0
MOVE.W SPRITEAKTUELL,D0
ADD.L D1,D0
MOVE.L D0,A1
MOVE.W SPRITEAKTUELL,SPRITEREGISTER
move.l (a0),(A1)
add.l #4,adresse
move.l #00,d0
cmp.l #$6c120+5856,adresse
beq null2
JMP IRQEND
null2:
move.l #$6C120,adresse
IRQEND:
MOVEM.L (SP)+,D0-D7/A0-A6
jmp $74cda
OLDIRQ:
JMP $000000
;---------------------
EVEN:
SOURCEX:
DC.L 0
SOURCEY:
DC.L 0
DESTX:
DC.L 2
DESTY:
DC.L 20
SIZEX:
DC.L 23
SIZEY:
DC.L 17

SOURCEX2:
DC.L 2
SOURCEY2:
DC.L 20
DESTX2:
DC.L 2
DESTY2:
DC.L 20
SIZEX2:
DC.L 1 ;365
SIZEY2:
DC.L 78
TIMER:
DC.W ZEIT
TEXTCOUNTER:
DC.L PRINTCODE
CHARKOORDINATEN:
DC.L 0,0,24,0,48,0,72,0,96,0,120,0,144,0,168,0,192,0,216,0
DC.L 240,0,264,0,288,0,0,17,24,17,48,17,72,17,96,17,120,17
DC.L 144,17,168,17,192,17,216,17,240,17,264,17,288,17
DC.L 0,34,24,34,48,34,72,34,96,34,120,34,144,34,168,34,192,34
DC.L 216,34,240,34 
STATUS:
DC.B 0
CHARTABELLE:
DC.B 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 '

PRINTCODE:
;     12345678901234
DC.B 'CHARLY OF  MFC'
DC.B '   PRESENTS   '
DC.B ' A NEW  INTRO '
DC.B ' ON THE AMIGA '

DC.B '              '
DC.B ' THIS INTRO IS'
DC.B '   COMPACTED  '
DC.B '              '

DC.B ' WHITH A NEW  '
DC.B '  COMPACKER   '
DC.B 'BY   MEGAFORCE'
DC.B ' WRITEN  1987 '

DC.B '   SPECIAL    '
DC.B '  GREETINGS   '
DC.B '     TO       '
DC.B '              '

DC.B 'PETER AND JOHN'
DC.B ' THE    KINGS '
DC.B '  OF   M F C  '
DC.B '   AUSTRIA    '

DC.B 'THATS ALL FOR '
DC.B '    NOW       '
DC.B ' SEE YOU NEXT '
DC.B '    TIME      '


DC.B '              '
DC.B '              '
DC.B '              '
DC.B '              '

TEXTENDE:
even
SPRITEADRESSEN:
DC.W $FB00,$FB50,$FBA0,$FBF0,$FC40
DC.W $FBF0,$FBA0,$FB50,$FB00,$FC90
DC.W $FCE0,$FD30,$FD80,$FD30,$FCE0
DC.W $FC90,$FB00
SPRITEZAEHLER:
DC.B 0
EVEN
SPRITEDATENZAEHLER:
DC.L SPRITEADRESSEN
SPRITEAKTUELL:
DC.W $FB00
SCROLLCOUNTER:
DC.W $F
ADRESSE:
DC.L $6C120
ZAEHLER:
DC.L 0
HELP:
DC.L 0
COPPERLIST:;5432109876543210
DC.W $0100,%0110011000000000
DC.W $0104,%0000000001000010
DC.W $008E,$1C71
DC.W $0090,$1CE1
SPRITEFARBEN:
DC.W $01A2,$0DC8
DC.W $01A4,$0976
DC.W $01A6,$0DBB
dc.w $102,0
DC.W $010A,0
dc.w $0108,1
dc.w $0120,$0007
DC.W $0122
SPRITEREGISTER:
DC.W $FB00
;dc.w $0124,$0007
;DC.W $0126,$FC00+68
;DC.W $0128,$0007
;DC.W $012A,$FC00+[68*2]
;DC.W $012C,$0007
;DC.W $012E,$FC00+[68*3]
;DC.W $0130,$0007
;DC.W $0132,$FC00+[68*4]
;DC.W $0134,$0007
;DC.W $0136,$FC00+[68*5]
;DC.W $0138,$0007
;DC.W $013A,$FC00+[68*6]
;DC.W $013C,$0007
;DC.W $013E,$FC00+[68*7]
;DC.W $0140,$0007
;DC.W $0142,$FC00+[68*8]
farben:
DC.W $0192,$0F55
DC.W $0194,$0F66
DC.W $0196,$0F88
DC.W $0198,$0Faa
DC.W $019A,$0Fcc
DC.W $019C,$0Fdd
DC.W $019E,$0Fee

DC.W $0092,$0030-8
DC.W $0094,$00D8
DC.W $00E0,$0007
DC.W $00E2
PLANE1:
DC.W $7000+5888
DC.W $00E8,$0007
DC.W $00EA
PLANE2:
DC.W $7000+11776+5888
DC.W $00F0,$0007
DC.W $00F2,
PLANE3:
DC.W $7000+11776+11776+5888

DC.W $00E4,$0005
DC.W $00E6
PLANE4:
DC.W $0000
DC.W $00EC,$0005
DC.W $00EE
PLANE5:
DC.W 5520
DC.W $00F4,$0005
DC.W $00F6,
PLANE6:
DC.W 5520+5520
farbe0:
DC.W $0180,$0000
DC.W $0182,$0AAA
DC.W $0184,$0888
DC.W $0188,$0666
;dc.w $5811,$fffe,$0102,$0000
;dc.w $5911,$fffe,$0102,$0010
;dc.w $5a11,$fffe,$0102,$0020
;dc.w $5b11,$fffe,$0102,$0030
;dc.w $5c11,$fffe,$0102,$0040
;dc.w $5d11,$fffe,$0102,$0050
;dc.w $5e11,$fffe,$0102,$0060
;dc.w $5f11,$fffe,$0102,$0070
;dc.w $6011,$fffe,$0102,$0080
;dc.w $6111,$fffe,$0102,$0090
;dc.w $6211,$fffe,$0102,$00a0
;dc.w $6311,$fffe,$0102,$00b0
;dc.w $6411,$fffe,$0102,$00c0
;dc.w $6511,$fffe,$0102,$00d0
;dc.w $6611,$fffe,$0102,$00e0
;dc.w $6711,$fffe,$0102,$00f0




DC.W $8A11,$FFFE
DC.W $0102
SCROLLREGISTER:

DC.W $0
dc.w $010a,43
DC.W $00E4,$0007
DC.W $00E6
BITPLANE_4:
DC.W $5000+44
DC.W $00EC,$0007
DC.W $00EE
BITPLANE_5:
DC.W $5000+2904+44
DC.W $00F4,$0006
DC.W $00F6,
BITPLANE_6:
DC.W $9800
DC.W $0104,%0000000001000010
DC.W $008E,$1C7B
DC.W $0090,$1CC7
DC.W $0192,$0984
DC.W $0194,$0761
DC.W $AA11,$FFFE
DC.W $0100,$0200
DC.W $0180,$0984
DC.W $AB11,$FFFE,$0180,$0A94
DC.W $AC11,$FFFE,$0180,$0BA4
DC.W $AD11,$FFFE,$0180,$0CB3
DC.W $AE11,$FFFE,$0180,$0DC2
DC.W $AF11,$FFFE,$0180,$0ED1
DC.W $B011,$FFFE,$0180,$0FF0
DC.W $B111,$FFFE,$0180,$0EE0;ED1
DC.W $B211,$FFFE,$0180,$0DD0;DC2
DC.W $B311,$FFFE,$0180,$0CC0;CB3
DC.W $B411,$FFFE,$0180,$0BB0;BA4
DC.W $B511,$FFFE,$0180,$0AA0;A94
DC.W $B611,$FFFE,$0180,$0990;984
DC.W $B711,$FFFE,$0180,$0880;984
DC.W $B811,$FFFE,$0180,$0770;984
DC.W $B911,$FFFE,$0180,$0660;984
DC.W $BA11,$FFFE,$0180,$0550;984
DC.W $BB11,$FFFE,$0180,$0440;984
DC.W $BC11,$FFFE,$0180,$0330;984
DC.W $BD11,$FFFE,$0180,$0220;984
DC.W $BE11,$FFFE,$0180,$0110;984
DC.W $BF11,$FFFE,$0180,$0000;984

DC.W $0194,$0761
DC.W $FFFF,$FFFE 
COPPERLIST_ENDE:
; ----------------------------------------
RASTPORT:
DC.L $00000000      ; rp_Layer
DC.L BITMAP2        ; rp_BitMap
DC.L $00000000      ; rp_AreaPtrn
DC.L $00000000      ; rp_TmpRas
DC.L $00000000      ; rp_AreaInfo
DC.L $00000000      ; rp_GelsInfo
DC.B $FF            ; rp_Mask
DC.B $FF            ; rp_fgPen
DC.B $00            ; rp_BgPen
DC.B $FF            ; rp_AOLPen
DC.B $01            ; rp_DrawMode
DC.B $00            ; rp_AreaPtSz
DC.B $00            ; rp_Dummy
DC.B $00            ; rp_linpatcnt
DC.W $0000          ; rp_Flags
DC.W $FFFF          ; rp_LinePtrn
DC.W $0000          ; rp_cp_x
DC.W $0000          ; rp_cp_y
DC.L $CACACACA      ; rp_minterms,8
DC.L $CACACACA      ; rp_minterms
DC.W $0000          ; rp_PenWidth
DC.W $0000          ; rp_PenHeight
FONT:
DC.L $00002390      ; rp_Font
DC.B $00            ; rp_AlgoStyle
DC.B $00            ; rp_TxFlags
DC.W $0008          ; rp_TxHeight
DC.W $0008          ; rp_TxWidth
DC.W $0006          ; rp_TxBaseline
DC.W $0000          ; rp_TxSpacing
DC.L $00000000      ; rp_User
BLK.B 30,0          ; Fuer Sonstiges

BITMAP1:
DC.W 40             ; Hoehe = 320/8= 40
DC.W 200            ; Laenge   
DC.L $FF03FFFF      ; Anzahl der BitMaps (1)
PLANES:
DC.L $6a938         ; Adresse des 1 BitMaps
DC.L $6b130
DC.L $6B928
BITMAP2:
DC.W 46             ; Hoehe = 320/8= 40
DC.W 200            ; Laenge   
DC.L $FF03FFFF      ; Anzahl der BitMaps (1)
PLANES2:
DC.L $50000         ; Adresse des 1 BitMaps
DC.L $50000+5520
DC.L $50000+5520+5520

BITMAP3:
DC.W 46             ; Hoehe = 320/8= 40
DC.W 200            ; Laenge   
DC.L $FF03FFFF      ; Anzahl der BitMaps (1)
PLANES3:
DC.L $54100         ; Adresse des 1 BitMaps
DC.L $54100+5520
DC.L $54100+5520+5520

; ----------------------------------------
GFXNAME:
DC.B 'graphics.library',0
even
GFXBASE:
DC.L 0
COPPERLIST_ALT:
DC.L 0
daten:
blk.b 45337,0
datenende:
