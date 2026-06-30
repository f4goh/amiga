;-------------------------------------------------------------------
;-                    UNE INTRO REPLAY LOADING	 	   	   -
;-------------------------------------------------------------------


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
execbase=4

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

;-------------------------------
vbl1		macro
loop_vbl\@
	move.l	$4(a6),d0
	and.l	#$1ff00,d0
	cmp.l	#$11000,d0
	bne.s	loop_vbl\@
	endm
;-------------------------------

nb_plan = 1


	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$c000,save_intena


	lea	bmap(pc),a0
	move.l	#ecran,d0
	moveq	#nb_plan-1,d1
plan_suivant
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant


;copper initialise
	move.w	#$7fff,$96(a6)
	move.w	#$7fff,$9a(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
	clr.l	$144(a6)
;dma active
	move.w	#$83d0,$96(a6)
	bsr	menu
	
restore_all
	move.l	execbase,a6
 	move.w	#$7fff,$dff096
 	move.w	#$7fff,$dff09a
	move.w	save_dmacon,$dff096
	move.w	save_intena,$dff09a
	lea	grname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
fin	clr.l	d0
	rts
save_dmacon:dc.w 0
save_intena:dc.w 0
grname:dc.b "graphics.library",0
	even
;------------------------------------------------------------------------
menu
		bsr	loader
vbl		vbl1
;		move.w	#$f0,$180(a6)
;		clr.w	$180(a6)
souris		
		btst	#6,$bfe001
		bne	souris
		rts
;------------------------------------------------------------------------



;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000

		dc.l	$01001200

		dc.w	$0180,$0000
		dc.w	$0182,$0fff

		dc.l	-2
;------------------------------------------------------------------------
ecran	dcb.b	40*256
end
;------------------------------------------------------------------------
loader
	lea	VARS(pc),a5

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

.Retry	move.w	#$4000,$24(a6)		; efface DSKLEN
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

VARS	dcb.b	VARSIZE,0
	even
TRACK	dcb.b	11*512
	even
MFMBUF	dcb.w	MFMSIZE
; ************************************















