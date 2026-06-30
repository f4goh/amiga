;                          Debbug 68000 sur Minitel (version commentaires)
;                          ------------------------

;Realise par ALE OF FAME of PROFECY

;il suffit de loger cette routine dans n'importe quelle source asm,
;de faire un bsr debbug pour avoir un dumping des registres du 68000,
;ainsi que des bloc mémoires determines.
;il suffit de configurer la structure de debbug 68000.
;Cette structure est decrite a la fin de cette source (apres la table)

;Pour utiliser debbug, il faut configurer le Minitel en 80 colonnes
;(Fnct T+F) et la vitesse de transmission a 4800 bauds (Fnct P+4)


;registres de l'UART (port serie) 
serdat = $dff030
serper = $dff032
serdatr= $dff018
adkcon = $dff09e
adkconr= $dff010

;1200 bauds ---> 2982
;3600 bauds ---> 943
;4800 bauds ---> 745

vitesse= 745


start:
	move.w	#vitesse,serper

	clr.l	d0
	clr.l	d1
	lea	texta,a0
	lea	table,a1
	move.b	#textasize,d0
	bsr	affiche
	lea	textb,a0
	lea	table,a1
	clr.l	d0
	move.b	#textbsize,d0
	bsr	affiche
	lea	textc,a0
	lea	table,a1
	clr.l	d0
	move.b	#textcsize,d0
	bsr	affiche

	clr.l	d0
	rts

affiche:
	move.b	(a0)+,d1
	sub	#$20,d1
	mulu	#2,d1
	move.w	(a1,d1.w),serdat
	bsr	wait
	dbf	d0,affiche
	bsr	saut
	rts

saut:
	move.w	#$8b,serdat
	bsr	wait
	move.w	#$8d,serdat
	bsr	wait
	rts
bip:
	move.w	#$87,serdat
	bsr	wait
	rts

wait:
	move.l	#0,d2
jj:
	addq	#1,d2
	cmp.l	#vitesse,d2
	bne	jj
	rts

texta:
	dc.b	"                          Debbug 68000 sur Minitel"
fintexta:
	even
textasize = fintexta-texta-1

textb:
	dc.b	"                          ------------------------"
fintextb:
	even
textbsize = fintextb-textb-1

textc:
	dc.b	"                                       "
	dc.b	"                  Realise par ALE OF FAME"
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

;Les accents ne sont pas inclus, alors attention !


end

