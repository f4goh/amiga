;                          Send messages sur  Minitel 
;                          --------------------------

; Salut a toi D2-R2 je suis actuellement en train de finir la 1 ere
;version de sendmess.


;Realise par ALE OF FAME of PROFECY


;Ceci est une première version de send messages,l'appuye d'une touche 
;de F1 à F10 provoque l'envoi d'un message. Il faudrait prévoir les codes
;de controle minitel : envoie sommaire suite etc.... pour que le programme
;soit absolument sublime.




;Les accents ne sont pas inclus, alors attention au gourou !


;registres de l'UART (port serie) 
serdat = $dff030
serper = $dff032
serdatr= $dff018
adkcon = $dff09e
adkconr= $dff010

;1200 bauds ---> 2982	;ici c'est la vitesse du minitel
;3600 bauds ---> 943
;4800 bauds ---> 745

vitesse= 2982


start:
	move.w	#vitesse,serper	;init du registre de contrôle série

	clr.l	d0
	clr.l	d1


souris:	move.w	#0,d0
	move.b	$bfec01,d0	;code touche dand D0
	not.b	d0
	ror.b	#1,d0		;petit calcul rapide

	cmp.b	#$59,d0		;f10
	beq	sendmess1
	cmp.b	#$58,d0		;f9
	beq	sendmess2
	cmp.b	#$57,d0
	beq	sendmess3	;f8
	
retour:	btst 	#6,$bfe001	;test de la souris
	bne.s 	souris

stop:	clr.l	d0		;clr du registre D0 dans tout les
	rts			;programmes: c'est spectre qui a dit
				; ceci est le RTS de fin de programme

sendmess1:
	lea	texta,a0	;adresse du texte à envoyer
	lea	table,a1	;adresse de la table code lettre
	clr	d0
	move.b	#textasize,d0	;longueur du texte à envoyer
	bsr	affiche
	bra	retour

sendmess2:
	lea	textb,a0
	lea	table,a1
	clr.l	d0
	move.b	#textbsize,d0
	bsr	affiche
	bra	retour

sendmess3:
	lea	textc,a0
	lea	table,a1
	clr.l	d0
	move.b	#textcsize,d0
	bsr	affiche
	bra	retour

affiche:
	move.b	(a0)+,d1
	sub	#$20,d1
	mulu	#2,d1
	move.w	(a1,d1.w),serdat
	bsr	wait
	dbf	d0,affiche
;	bsr	saut		;saut de ligne (valable en 80 colonnes)
	rts

saut:
	move.w	#$8b,serdat
	bsr	wait
	move.w	#$8d,serdat
	bsr	wait
	rts
bip:
	move.w	#$87,serdat	;provoque un bip sur le minitel cool
	bsr	wait
	rts

wait:				;attente pour que la phrase soit transmise
	move.l	#0,d2
jj:
	addq	#1,d2
	cmp.l	#vitesse,d2
	bne	jj
	rts

;************************************************************************
;*                         Ici commence le baratin			*
;************************************************************************

;les dc.b sont définis pour 40 colones (guillmets à 58)
;et surtout je le redis PAS D'ACCENTS


texta:
	dc.b	"    Bonjour je m'appelle ALE of FAME    "
fintexta:
	even
textasize = fintexta-texta-1



textb:
	dc.b	"je viens juste de mettre au point l'en- "
	dc.b	"voi rapide de texte sur le minitel      "
	dc.b	"j'espere que ca marche bien             "
fintextb:
	even
textbsize = fintextb-textb-1



textc:
	dc.b	"         Profecy do it for fun          "
fintextc:
	even
textcsize = fintextc-textc-1



;$88	(del) code non utilise, mais on ne sait jamais !! 


table:
	dc.w	$a0,$121,$122,$a3,$124,$a5,$a6,$127	;Carac. speciaux
	dc.w	$128,$a9,$aa,$12b,$ac,$12d,$12e,$af
	dc.w	$130,$b1,$b2,$133,$b4,$135,$136,$b7	;Chiffres + divers
	dc.w	$b8,$139,$13a,$bb,$13c,$bd,$be,$13f
	dc.w	$0
	dc.w	$141,$142,$43,$144,$45,$46,$147,$148	;Majuscules
	dc.w	$49,$4a,$14b,$4c,$14d,$14e,$4f,$150
	dc.w	$51,$52,$153,$54,$155,$156,$57,$58
	dc.w	$159,$15a,0,0,0,0,0,0
	dc.w	$21,$22,$163,$24,$165,$166,$27,$28,$169	;Minuscules
	dc.w	$16a,$2b,$16c,$2d,$2e,$16f,$30,$171,$172
	dc.w	$33,$174,$35,$36,$177,$178,$39,$3a,0


end


