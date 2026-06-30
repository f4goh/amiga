	opt	o+,ow-

;------------------
DSKRDY	=5		; bits utiles du CIAA-PRA
DSKTRK0	=4
DSKPROT	=3
DSKCHNG	=2

DSKMTR	=7		; bits utiles du CIAB-PRB
DSKSEL3	=6
DSKSEL2	=5
DSKSEL1	=4
DSKSEL0	=3
DSKSIDE	=2
DSKDIR	=1
DSKSTEP	=0

MFMSIZE	=512*12+256	; taille du buffer MFM

Custom	=$dff000

SysCop1	=$26
SysCop2	=$32
execbase=4
oldopenlibrary=-408
closelibrary=-414
RawDoFmt=-522
WIDTH	=40		; Largeur de l'écran (octets)
HEIGHT	=40		; Hauteur de l'écran (lignes)
BPLSIZE	=WIDTH*HEIGHT	; Taille du bitplan

; ************************************
	rsreset
olddma	rs.w	1
oldint	rs.w	1
oldcop1	rs.l	1
oldcop2	rs.l	1
VARSIZE	rs.w	0

	rsreset
head	rs.w	1		; tête de lecture (0-1)
track	rs.w	1		; piste (0-79)
essais	rs.w	1		; essais en cas d'erreur (max 4)
DVARSIZE rs.w	0

; ************************************
	section	READTRACK,CODE

Start	movea.l	execbase,a6
	lea	VARS(pc),a5

	lea	gfxname(pc),a1	; Ouvre la graphics.library
	moveq	#0,d0		; pour y puiser les adresses
	jsr	oldopenlibrary(a6)	; des 2 CopperLists système
	movea.l	d0,a1
	move.l	SysCop1(a1),oldcop1(a5)
	move.l	SysCop2(a1),oldcop2(a5)
	jsr	closelibrary(a6)	; Il faut la refermer !

	lea	Custom,a6	; c'est
	move.w	$2(a6),d0
	ori.w	#$8200,d0
	move.w	d0,olddma(a5)

	move.w	$1c(a6),d0
	ori.w	#$c000,d0
	move.w	d0,oldint(a5)

	move.w	#$7fff,d0
	move.w	d0,$96(a6)
	move.w	d0,$9a(a6)
	move.w	d0,$9c(a6)

	lea	NewCop,a0	; Construit notre CopperList
	move.l	#Screen,d0	; (adresse du bitplan)
	move.w	d0,CLPlan-NewCop+6(a0)
	swap	d0
	move.w	d0,CLPlan-NewCop+2(a0)
	move.l	a0,$80(a6)	; et l'active
	move.w	d0,$88(a6)

	move.w	#$8390,$96(a6)
	move.w	#$1002,$9a(a6)

	bsr.s	StartDrive	; démarre le moteur de DF0:

	moveq	#0,d1
	move.w	#$0F00,d2	; couleur des 2 lignes si erreur
ReadAllDisk:
	btst	#6,$bfe001
	beq.s	Exit
	move.w	d1,d0		; numéro de piste dans d0
	lea	TRACK(pc),a0	; adresse de lecture dans a0
	bsr	ReadThisTrack	; lecture !
	bne.s	Error		; ça n'a pas marché...
	addq.w	#1,d1
	cmpi.w	#159,d1
	bls.s	ReadAllDisk	; boucle pour toutes les pistes

Exit	moveq	#$000F,d2	; couleur des 2 lignes si OK
	btst	#6,$bfe001
	beq.s	Exit

Error	bsr	StopDrive	; arrête le moteur de DF0:

	lea	NewCop,a0	; change la couleur des 2 lignes
	move.w	d2,CLCol1-NewCop+6(a0)
	move.w	d2,CLCol2-NewCop+6(a0)

WaitLMB	btst	#6,$bfe001
	bne.s	WaitLMB		; attend Mickey

	move.w	#$7fff,d0	; remet le système dans
	move.w	d0,$96(a6)	; son état normal
	move.w	d0,$9a(a6)
	move.l	oldcop1(a5),$80(a6)
	move.l	oldcop2(a5),$84(a6)
	move.w	d0,$88(a6)
	move.w	olddma(a5),$96(a6)
	move.w	oldint(a5),$9a(a6)

	moveq	#0,d0		; Retour au CLI sans code d'erreur
	rts

; ************************************
; Démarre le drive DF0: et place les têtes
; au dessus de la piste 0, face 0
StartDrive:
	bset	#DSKSEL0,$bfd100	; unselect drive 0
	bclr	#DSKMTR,$bfd100		; motor on
	bclr	#DSKSEL0,$bfd100	; select drive 0

.Wait	btst	#DSKRDY,$bfe001		; teste DSKRDY
	bne.s	.Wait			; faut encore attendre

	bset	#DSKDIR,$bfd100		; dir = -> piste 0
	bset	#DSKSIDE,$bfd100	; face = lower (0)
.Seek0	btst	#DSKTRK0,$bfe001	; piste 0 atteinte ?
	beq.s	.Track0			; oui
	bsr	MoveHeads		; sinon déplace les têtes
	bra.s	.Seek0			; et boucle
.Track0	rts

; ************************************
; Arrêtre le drive DF0: (la LED s'éteint)
StopDrive:
	bset	#DSKSEL0,$bfd100	; unselect drive 0
	bset	#DSKMTR,$bfd100		; motor off
	bset	#DSKMTR,$bfd100		; motor off
	bclr	#DSKSEL0,$bfd100	; select drive 0
	rts

; ************************************
; Lecture de la piste D0 dans le buffer pointé par A0.
; Cette routine recherche la bonne piste (Seek), la lit
; et décode les données MFM.
ReadThisTrack:
	movem.l	a0-a6/d1-d5,-(sp)
	lea	DskVars(pc),a5		; a5 = variables "locales"
	clr.w	essais(a5)

	bsr	SeekThisTrack		; recherche la piste à lire

.Retry	bsr	PrintStatus		; affiche les infos
	move.w	#$4000,$24(a6)		; efface DSKLEN
	move.l	#MFMBUF,$20(a6)		; Adresse de lecture
	move.w	#$4489,$7e(a6)		; Synchro MFM standard
	move.w	#$7f00,$9e(a6)		; Efface ADKCON
	move.w	#$9500,$9e(a6)		; Valeur correcte dans ADKCON
	move.w	#$8000|MFMSIZE,$24(a6)	; Longueur de lecture (mots)
	move.w	#$8000|MFMSIZE,$24(a6)	; écrite 2 fois
.Wait	move.w	$1e(a6),d0		; Lecture terminée ?
	andi.w	#$2,d0
	beq.s	.Wait			; Pas encore
	move.w	#$2,$9c(a6)
	move.w	#$4000,$24(a6)		; Efface DSKLEN

	bsr.s	MFMUncode		; Décodage des données MFM
	beq.s	.ReadOk

.Error	addq.w	#1,essais(a5)
	andi.w	#3,essais(a5)
	bne.s	.Retry
	moveq	#-1,d0			; erreur de lecture !

.ReadOk	movem.l	(sp)+,a0-a6/d1-d5
	rts

DskVars	dcb.b	DVARSIZE

; ************************************
; Cette routine décode les données MFM de MFMBUF (1 piste)
; dans le buffer pointé par A0.
; Retourne 0 si OK, -1 si erreur
MFMUncode:
	lea	MFMBUF,a1	; données MFM
	move.l	#$55555555,d2	; masque bits impairs
	moveq	#10,d5		; 11 secteurs à décoder
.GAP	cmpi.w	#$4489,(a1)+	; cherche le début du secteur
	bne.s	.GAP
	cmpi.w	#$4489,(a1)
	beq.s	.GAP

	move.l	(a1)+,d0
	and.l	d2,d0
	lsl.l	#1,d0
	move.l	(a1)+,d1
	and.l	d2,d1
	or.l	d1,d0		; d0=format,track,sector,count

	add.w	d0,d0
	andi.w	#$1E00,d0
	lea	0(a0,d0.w),a2	; a2=secteur dans le track-buffer

	lea	36(a1),a1	; saute les infos DOS et le header checksum
	move.l	(a1)+,d0	; d0=data checksum. a1=données
	moveq	#9,d3		; 10 mots longs à vérifier
	lea	-48(a1),a3	; a3 pointe le header (OS recovery info)
.Check	move.l	(a3)+,d1
	eor.l	d1,d0
	dbra	d3,.Check
	and.l	d2,d0
	bne.s	.ReadError

	addq.l	#4,a1
	move.l	(a1)+,d3	; d3=data area checksum
	lea	512(a1),a4	; a1=oddbits, a4=evenbits
	moveq	#127,d4		; 128 mots de données à décoder
.UncodeSector:
	move.l	(a1)+,d0
	eor.l	d0,d3
	and.l	d2,d0
	lsl.l	#1,d0

	move.l	(a4)+,d1
	eor.l	d1,d3
	and.l	d2,d1

	or.l	d1,d0
	move.l	d0,(a2)+
	dbra	d4,.UncodeSector
	and.l	d2,d3
	bne.s	.ReadError
	dbra	d5,.GAP
	moveq	#0,d0
	rts

.ReadError:
	moveq	#-1,d0
	rts

; ************************************
; Positionne les têtes de lecture/écriture au dessus
; de la piste désignée par D0.
SeekThisTrack:
	moveq	#1,d2
	bset	#DSKSIDE,$bfd100	; face 0
	clr.w	head(a5)
	lsr.w	#1,d0
	bcc.s	.LowerSide
	bclr	#DSKSIDE,$bfd100	; face 1
	addq.w	#1,head(a5)

.LowerSide:
	move.w	d0,d1
	sub.w	track(a5),d0	; Dans quelle direction aller ?
	beq.s	.SeekOk		; Ben.. Nulle part, on y est déjà !
	bpl.s	.SeekForward	; Vers le sillon 79 (centre)

.SeekBackward:
	bset	#DSKDIR,$bfd100	; Vers le sillon 0 (extérieur)
	neg.w	d2
	bra.s	.SeekIt

.SeekForward:
	bclr	#DSKDIR,$bfd100

.SeekIt	bsr.s	MoveHeads	; Déplace les têtes d'1 piste
	add.w	d2,track(a5)	; Inc/Dec le compteur de pistes
	cmp.w	track(a5),d1	; Piste demandée atteinte ?
	bne.s	.SeekIt		; pas encore...

.SeekOk	rts

; ************************************
; Fournit l'impulsion STEP au drive
; suivie du nécessaire délai (soft... argh !)
MoveHeads:
	bset	#DSKSTEP,$bfd100	; step = high
	nop
	nop
	nop
	bclr	#DSKSTEP,$bfd100	; step = low
	nop
	nop
	nop
	bset	#DSKSTEP,$bfd100	; step = high

; ************************************
; Délai logiciel... !!!! ABSOLUMENT INTERDIT !!!!
SoftDelay:
	move.w	#4000,d0
	dbra	d0,*
	rts

; ************************************
; Affiche le numéro de la piste
; en cours de lecture.
PrintStatus:
	movem.l	a0-a3/a6/d1,-(sp)
	lea	.fmt(pc),a0
	lea	DskVars(pc),a1
	lea	.putch(pc),a2
	lea	.buf(pc),a3
	movea.l	execbase,a6
	jsr	RawDoFmt(a6)
	moveq	#0,d1
	lea	Screen,a1	; pointeur sur le bitplan
.loop	lea	Numbers(pc),a0	; données des chiffres
	move.b	(a3)+,d1
	beq.s	.ret
	subi.b	#" ",d1
	beq.s	.space
	subi.b	#"0"-" ",d1
	lsl.b	#3,d1
	lea	8(a0,d1.w),a0
.space	move.b	(a0)+,HEIGHT*0(a1)
	move.b	(a0)+,HEIGHT*1(a1)
	move.b	(a0)+,HEIGHT*2(a1)
	move.b	(a0)+,HEIGHT*3(a1)
	move.b	(a0)+,HEIGHT*4(a1)
	move.b	(a0)+,HEIGHT*5(a1)
	move.b	(a0)+,HEIGHT*6(a1)
	move.b	(a0)+,HEIGHT*7(a1)
	addq.l	#1,a1
	bra.s	.loop
.ret	movem.l	(sp)+,a0-a3/a6/d1
	rts

.putch	move.b	d0,(a3)+
	rts

.fmt	dc.b	"%d:%d ;%d<  ",0
.buf	dc.l	0,0,0,0
.var	dc.w	0

; ************************************
Numbers	DC.B	$00,$00,$00,$00,$00,$00,$00,$00	; espace
	DC.B	$7C,$C6,$CE,$D6,$E6,$C6,$7C,$00	; 0
	DC.B	$18,$38,$18,$18,$18,$18,$7E,$00	; 1
	DC.B	$3C,$66,$06,$3C,$60,$66,$7E,$00	; 2
	DC.B	$3C,$66,$06,$1C,$06,$66,$3C,$00	; 3
	DC.B	$1C,$3C,$6C,$CC,$FE,$0C,$1E,$00	; 4
	DC.B	$7E,$62,$60,$7C,$06,$66,$3C,$00	; 5
	DC.B	$3C,$66,$60,$7C,$66,$66,$3C,$00	; 6
	DC.B	$7E,$66,$06,$0C,$18,$18,$18,$00	; 7
	DC.B	$3C,$66,$66,$3C,$66,$66,$3C,$00	; 8
	DC.B	$3C,$66,$66,$3E,$06,$66,$3C,$00	; 9
	DC.B	$06,$0C,$18,$30,$60,$C0,$80,$00	; /
	DC.B	$0C,$18,$30,$30,$30,$18,$0C,$00	; (
	DC.B	$30,$18,$0C,$0C,$0C,$18,$30,$00	; )

; ************************************
VARS	dcb.b	VARSIZE,0
gfxname	dc.b	"graphics.library",0
	even

; ************************************
TRACK	dcb.b	11*512

; ************************************
	section	CHIP,DATA_C

NewCop	dc.w	$8e,$2c81,$90,$2cc1
	dc.w	$92,$0038,$94,$00d0
	dc.w	$100,$1200
	dc.w	$102,$0000,$104,$0000
	dc.w	$108,$0000,$10a,$0000
CLPlan	dc.w	$e0,$0000,$e2,$0000
CLCol1	dc.w	$2a0f,$fffe,$180,$00F0
	dc.w	$2b0f,$fffe,$180,$0000
CLCol2	dc.w	$530f,$fffe,$180,$00F0,$100,$0000
	dc.w	$540f,$fffe,$180,$0000
	dc.l	-2

; ************************************
Screen	dcb.b	BPLSIZE
MFMBUF	dcb.w	MFMSIZE

; ************************************
	END

