; essai d'une comparaison entre 2 données 
; et test si l'une est plus grande que l'autre

start:
	clr	d1
	move.b	nombre,d1
	cmp	#$20,d1
	blt	fin1		;saut si d1<$20
	cmp	#$39,d1
	bgt	fin2		;saut si d1>$39
	move.b	#$ff,d2
	rts
fin1:
	move.b	#$1,d2
	rts
fin2:
	move.b	#$2,d2
	rts

nombre:
	dc.b	$ff
	even


;	l'instruction cmp
;	N	positionné si le résultat est négatif
;	Z	positionné si le résultat est zero
;	V	Positionné si il y a débordement
;	C	Positionné si il y a retenue

;	l'instruction cmp
;	BCC	retenue à zero		C = 0
;	BCS	retenue à un		C = 1
;	BEQ	égal			Z = 1
;	BNE	pas égal		Z = 0
;	BGE	supérieur ou égal	N @ V = 0
;	BGT	supérieur		Z + (N @ V) =0
;	BHI	supérieur		C + Z =0
;	BLE	inférieur ou égal	Z + (N @ V) =1
;	BLS	inférieur ou égal	C + Z = 1
;	BLT	inférieur		N @ V = 1
;	BMI	négatif			N = 1
;	BPL	positif			N = 0
;	BVC	dépassement à zero	V = 0
;	BVS	dépassement à un	V = 1
;	BT	vrai(true)		1
;	BF	faux(false)		0

;	Remarque:	@ correspond à un plus (entouré)

