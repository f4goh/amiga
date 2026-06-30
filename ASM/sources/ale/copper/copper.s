;registre copper.....
cop1lc  = $80
cop2lc  = $84
copjmp1 = $88
copjmp2 = $8a

;registre dmacon (Direct memory access du copper), on ne passe pas par
;le micro 68000 lors de l'affichage des bandes R V B,on initialise des
; paramètres dans les registres de fat agnus, on lance l'accès
; écran<>mémoire avec le dma, puis après l'action de la souris, on remet
;la liste du copper comme elle était avant...et oui..c'est tout.

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
	dbf	d0,clcopy	;dbf teste,decrémente d0 et saute à
	rts			;clcopy si false d'ou le f de db(f)

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

;copper liste... et la voila cette liste... c'est tout......ben oui !
;				ya seulement 3 bandes R V B
clstart:
	dc.w	color00,$000f
	dc.w	$780f,$fffe

	dc.w	color00,$00f0
	dc.w	$d70f,$fffe

	dc.w	color00,$0f00
	dc.w	$ffff,$fffe
clend:

clsize=clend-clstart

end
;**********************  Commentaires de l'exemple copper  **************

;j'ai mis des bsr dans la boucle principale pour séparer les différentes
;phases de l'affichage des bandes R V B horizontales.

;j'était présent quand Spectre a fait pour la 1 ere fois ce programme
;et même que c'était avec arnaud, il y a a peu prés 1 an...déja....
;et maintenant,Spectre est rendu très loin maintenant, oh la la oui !!
;il est vrai que, il y a un an, je ne comprenais rien à cette copper liste
;mais depuis que je m'y suis mis,il y a 1 semaine et 1 jour,ça va mieux...



;d'abord sur le DMACON adresse dff000+96,puisque adressage indirect oblige

;-----------------------------------DMACON------------------------------|
;Bit n°	15	14	13	12	11	10	9	8	|
;    set/clr  bbusy   bzero      non used    bltpri  dmaen    bpeln	|
;									|
;	7	6	5	4	3	2	1	0	|
;     copen   blten   spren   dsken  aud3en  aud2en  aud1en  aud0en	|
;-----------------------------------------------------------------------|
;bit	15	1--> bits de ctrl allumés suivant la suite		|
;		0--> bits de ctrl eteints et remis a zero (les boules)	|
;									|
;	9	interrupteur général des canaux dma (1:on/0:off)	|
;									|
;	8	dma 	bitplane					|
;	7	dma 	copper ----> c'est lui qui nous interesse ici	|
;	6	dma 	blitter						|
;	5	dma	sprite						|
;	4	dma	dmadisquette					|
;	3-0	dma	audio						|
;------------------------------------------------------------------------
;dans notre programme on n'a:						|
;	$03a0	: 0000	0011	1010	0000				|
;		bits 9,8,7,5 allumés,tiens c'est bizarre pour le 5	|
;	$8280	: 1000	0010	1000	0000				|
;		bits 15,9,7 allumés ok pas de problème,c'est ok		|
;	$83e0	: 1000	0011	1110	0000				|
;		bits 15,9,8,7,6,5 allumés, tout les dma graph quoi !	|
;-----------------------------------------------------------------------|

; et maintenant voyons un peu cette fameuse....
;			....... COPPER LISTE...

;Mes frères, il est dit que, dans la Bible que le copper est en fait
;un petit microprocesseur qui ne connait que les instructions
;MOVE,WAIT et SKIP (non pas la lessive...... c'est nul je sais)
;Ces instructions sont toujours caractérisés dans la copper liste
;de 2 mots (16 bits)

;clstart:
;	dc.w	color00,$000f	;instruction MOVE
;	dc.w	$780f,$fffe	;instruction WAIT

;	dc.w	color00,$00f0	;même chose
;	dc.w	$d70f,$fffe

;	dc.w	color00,$0f00	;pareil
;	dc.w	$ffff,$fffe
;clend:
;REM	:l'instruction SKIP n'est pas défini dans cette Copper liste

;-------------------------- étude d'un MOVE ----------------------------

;		mot1	mot2

;bit	15	x	dw15	x:non used
;	14	x	dw14	ra:registre d'adresse
;	13	x	dw13	dw:données (mot,donc de 16 bits)
;	12	x	dw12
;	11	x	dw11
;	10	x	dw10
;	9	x	dw9
;	8	ra8	dw8
;	7	ra7	dw7
;	6	ra6	dw6
;	5	ra5	dw5
;	4	ra4	dw4
;	3	ra3	dw3
;	2	ra2	dw2
;	1	ra1	dw1
;	0	0	dw0

;mot1:	dans l'exemple le mot1 est en fait un registre de fat agnus
;	c'est le registre color00
;	le bit 0 est à 0 pour que le copper reconnaisse que c'est une
;	instruction MOVE
;mot2:	ce mot est la la couleur qui va être transférée dans color00 par
;	le copper, une fois que le DMA sera activé par le 68000.


;	dc.w		color00	   ,	$000f
;ce qui fait:	0000 0001 1000 0000,0000 0000 0000 1111
;					  R     V    B
;la sélection des couleurs se fait comme dans delux-paint avec les
;reglages de la palette des couleurs.
;par exemple:   RVB
;	 	00f:bleu
;		ff0:jaune
;		888:gris

;-------------Bon maintenant passons a l'instruction WAIT ---------------

;bit	15	vp7	bfd	vp:position verticale du faisceau
;	14	vp6	vm6	vm:bit masque vertical
;	13	vp5	vm5	hp:position horiz du faisceau
;	12	vp4	vm4	hm:bit masque horiz
;	11	vp3	vm3	bfd:blitter finish disable
;	10	vp2	vm2
;	9	vp1	vm1
;	8	vp0	vm0

;	7	hp8	hm8
;	6	hp7	hm7
;	5	hp6	hm6
;	4	hp5	hm5
;	3	hp4	hm4
;	2	hp3	hm3
;	1	hp2	hm2
;	0	1	0
;même chose pour SKIP,mais le bit 0 change:
;	0	1	1	pour l'instruction SKIP


;exemple:

;	dc.w	$780f,$fffe	0111 1000 0000 1111,1111 1111 1111 1110
;				$78=120 ème ligne
;	dc.w	$d70f,$fffe	$d7=215 ème ligne

;	dc.w	$ffff,$fffe	$ff=255 ème ligne

;pour cette instruction il y a la possibilité de masquer la position
;verticale et horizontale, actuellement on prend $fffe (pas de masque)
;De plus étant donné que le registre Vp et Hp est codé sur 8 et 7 bits
;on ne peut pas positionner les couleurs ou on veut....
;Dans la Bible ils s'expliquent comme des pieds, alors.....
;J'ai du relire leur texte plusieurs fois, c'est nul leur baratin,
;j'espère que la suite c'est plus explicite......on verra bien.
;pour l'instruction SKIP,c'est la même chose que WAIT,mais skip permet
;de tester si la position du faisceau est >= à celle se trouvant dans le 
;terme de l'instruction. (mot1)  ouf! (une comparaison en fait)
;cette instruction est caractérisée par les bits 0 des 2 mots à 1 


