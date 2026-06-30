;Salut c'est ALE OF FAME,voici quelques petits essai avec le copper

;registre copper.
cop1lc  = $80
cop2lc  = $84
copjmp1 = $88
copjmp2 = $8a

dmacon  = $96
color00 = $180


;cia a bouton souris

ciaapra =$bfe001
execbase = 4
chip = 2

openlib =-552
forbid  =-132
permit  =-138
allocmem=-198
freemem =-210

startlist = 38

;initialisation

start:
	bsr	init
	beq.s	fin		;au cas ou toute la chip serai full
	bsr	transfer
	jsr	forbid(a6)	;on supprime le multitache he he !
	bsr	charge
	move.w	#$8280,dmacon(a5)	;dma active les bandes
wait:					;sont affichées
	btst	#6,ciaapra	;on attends pour le test de la souris
	bne.s	wait
	bsr	active
	jsr	permit(a6)	;on reactive le multitache ouf !
	bsr	freem
fin:
	clr.l	d0
	rts			;c'est le rts de la fin



init:
	move.l	execbase,a6	
	moveq	#clsize,d0
	moveq	#chip,d1
	jsr	allocmem(a6)	;on demande l'adresse de la chip ram libre
				;pour recopier la copper liste en chip
	move.l	d0,cladr	;sinon ca marche pas na !
	rts
freem:
	move.l	cladr,a1	;on libère la mémoire chip prise pour
	moveq	#clsize,d0	;notre copper liste
	jsr	freemem(a6)
	rts


transfer:
	lea	clstart,a0	;on recopie la copper liste en chip ram
	move.l	cladr,a1
	moveq	#clsize-1,d0
clcopy:
	move.b	(a0)+,(a1)+
	dbf	d0,clcopy
	rts

charge:
	move.l	#$dff000,a5	;adresse des registre de base dans a5
	move.w	#$0380,dmacon(a5)	;on bloque le dma
	move.l	cladr,cop1lc(a5);adresse de la copper liste dans 1ere list
	clr.w	copjmp1(a5)	;raz de l'adresse de la 1er liste (jmp)
	rts

active:
	move.l	#grname,a1	;on charge une copper liste toute faite
	clr.l	d0		;qui se trouve deja en mémoire pour 
	jsr	openlib(a6)	;la fin du programme sinon....
	move.l	d0,a4		;on touve cette liste grace à la
	move.l	startlist(a4),cop1lc(a5); graphics library
	clr.w	copjmp1(a5)
	move.w	#$83e0,dmacon(a5)
	rts

;************** donnes diverses

cladr:	dc.l	0

grname:	dc.b	"graphics.library",0
	even

;copper liste...

clstart:
	dc.w	color00,$000f
	dc.w	$580f,$fffe
	dc.w	color00,$0008
	dc.w	$970f,$fffe

;	dc.w	$b00f,$ffff	;essai d'un skip
;	dc.w	color00,$00f0
;	dc.w	$d00f,$fffe


;	dc.w	color00,$000d
;	dc.w	$4a0f,$fffe

;	dc.w	color00,$000c
;	dc.w	$580f,$fffe
;	dc.w	color00,$000b
;	dc.w	$660f,$fffe
;	dc.w	color00,$000a
;	dc.w	$740f,$fffe
;	dc.w	color00,$0009
;	dc.w	$820f,$fffe
;	dc.w	color00,$0008
;	dc.w	$900f,$fffe
;	dc.w	color00,$0007
;	dc.w	$9e0f,$fffe
;	dc.w	color00,$0006
;	dc.w	$ac0f,$fffe
;	dc.w	color00,$0005
;	dc.w	$ba0f,$fffe
;	dc.w	color00,$0004
;	dc.w	$c80f,$fffe
;	dc.w	color00,$0003
;	dc.w	$d60f,$fffe
;	dc.w	color00,$0002
;	dc.w	$e40f,$fffe
;	dc.w	color00,$0001
;	dc.w	$f20f,$fffe

	dc.w	color00,$0000
	dc.w	$ffff,$fffe
clend:

clsize=clend-clstart

end

;message to spectre:

;j'ai des problèmes de d'allocation de chip si clsize > $ff
;j'ai essayé de bidouiller ça,mais je n'y arrive pas


