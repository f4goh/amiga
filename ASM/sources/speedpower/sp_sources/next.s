;rip caractere vagues
;termine le 17/09/91
;les effets sont sympas,mais je vais sans doute les changer
;ainsi que le prg qui je pense peux etre plus simple
;on a 4 plans,mais en fait on met l'image dans les 2 derniers plans
;et a la fin de l'affichage,on change on met 2 plans actifs
;afin de pouvoir avoir une image que l'on pourra reduire
;----------------------
	section	spectre,code_c
s	move.l	4,a6
	move.l	$9c(a6),a1
	move.l	$26(a1),oldcopper
	move.l	sp,pile
	move.l	4,a6
	jsr	-$84(a6)
	lea	table(pc),a0
	moveq	#0,d0
	move.w	#160-1,d7
clear
	move.w	d0,(a0)+
	addq.w	#6,d0
	dbra	d7,clear

	move.l	#$dff000,a6
	move.w	2(a6),old_dma
	add.w	#$8000,old_dma
	move.w	#$a0,$96(a6)
	move.l	#copperlist,$80(a6)
	move.w	#$8480,$96(a6)
	jsr	initialise(pc)
vbl	cmp.b	#$10,6(a6)
	bne.s	vbl
	jsr	effacescreen(pc)
	jsr	affiche(pc)
	jsr	end_aff(pc)
	btst	#10,$16(a6)	;bouton droit
	beq.s	souris
	cmp.w	#2,test_aff
	bne.s	souris
	subq.w	#1,pause
	bne.s	souris
	move.w	#1,test_aff
souris
	btst	#6,$bfe001
	bne.s	vbl
	jmp	restore_all(pc)

affiche	cmp.w	#0,test_aff
	beq.s	vas_y
	rts

vas_y	cmp.w	#0,compt_effet
	bgt.s	pas_fini
	addq.w	#1,vitesse
pas_fini
	cmp.w	#160,compt_effet
	bne.s	aff_dessin
	move.w	#2,test_aff
	rts

aff_dessin
	move.l	#$ffff0000,$44(a6)
	move.l	#$24005a,$62(a6)
	move.w	#$24,$66(a6)
	lea	inconnu(pc),a4
	lea	inconnu2(pc),a5
	lea	table(pc),a2
	move.l	table_aff(pc),a3
	move.w	vitesse(pc),d7
	cmp.w	#$ffff,vitesse	;fin?
	beq	restore_all
deb_effet	
	cmp.b	#$ff,(a3)	;test fin effet
	bne.s	pas_fin_effet
	subq.w	#1,vitesse
	jmp	sw_plan(pc)

pas_fin_effet
	moveq	#0,d2
	moveq	#0,d6
	or.b	(a3),d6
	rol.w	#1,d6
	move.w	0(a2,d6.w),d6
	move.w	0(a5,d6.l),d0
	addq.l	#2,d6
	move.w	0(a5,d6.l),d1
	addq.l	#2,d6
	move.w	0(a5,d6.l),d2
	cmp.w	#128,d2
	ble	aff_let
	subq.w	#8,0(a5,d6.l)
	muls	#$100,d0
	divs	d2,d0
	and.l	#$ffff,d0
	muls	#$100,d1
	divs	d2,d1
	and.l	#$ffff,d1
	jsr	calcul_pos(pc)
effet_suit
	dbra	d7,deb_effet
sw_plan
	jsr	swap_plan(pc)
	rts
table
	dcb.w	160,0
calcul_pos
	sub.w	-4(a5,d6.l),d0
	sub.w	-2(a5,d6.l),d1
	add.w	#160,d0
	add.w	#64,d1
	move.l	destp(pc),a0
	mulu	#40,d1
	divu	#16,d0
	swap	d0
	moveq	#0,d4
	move.w	d0,d4
	clr.w	d0
	swap	d0
	rol.l	#1,d0
	add.l	d0,a0
	add.l	d1,a0
	jsr	affiche_dessin(pc)
	rts

affiche_dessin
	sub.w	#$80,d2
	lsr.w	#3,d2
	mulu	#1410,d2
	moveq	#0,d6
	move.b	(a3)+,d6
	rol.l	#3,d6
	add.l	0(a4,d6.l),d2
	cmp.l	#0,0(a4,d6.l)
	beq.s	espace2
	ror.l	#4,d4
	or.l	#$dfc0000,d4
	move.l	a0,$4c(a6)	;1er plan
	move.l	d2,$50(a6)
	move.l	a0,$54(a6)
	move.l	d4,$40(a6)
	move.w	#15*64+2,$58(a6)
	add.l	#5120,a0	;prochain plan
	add.l	#42300,d2	;et 2nd plan lettre
	move.l	a0,$4c(a6)
	move.l	d2,$50(a6)
	move.l	a0,$54(a6)
	move.l	d4,$40(a6)
	move.w	#15*64+2,$58(a6)
espace2
	rts

aff_let
	addq.l	#1,table_aff
	moveq	#0,d6
	move.b	(a3)+,d6
	rol.l	#3,d6
	move.l	0(a4,d6.w),d0
	beq.s	espace
	addq.l	#4,d6
	move.l	0(a4,d6.w),d1
	move.l	#$5c0026,$64(a6)
	or.l	#$ffffffff,$44(a6)
	move.l	d1,$54(a6)
	move.l	d0,$50(a6)
	move.l	#$9f00000,$40(a6)
	move.w	#15*64+1,$58(a6)
	add.l	#5120,d1	;2plan lettre
	add.l	#42300,d0
	move.l	d0,$50(a6)
	move.l	d1,$54(a6)
	move.w	#15*64+1,$58(a6)
	move.l	#$ffff0000,$44(a6)
	move.l	#$24005a,$62(a6)
	move.w	#$24,$66(a6)
espace
	addq.w	#1,compt_effet
	jmp	effet_suit(pc)

initialise
	clr.w	test_aff
	move.w	#$ffff,vitesse
	clr.w	compt_effet
	move.w	#250,pause
	move.w	#32,tourne
	move.l	#degr,p_degr
	move.w	#$4600,pointx
	move.w	#$fff,col1	;on remet les couls init
	move.w	#$ccc,col2
	move.w	#$888,col3
	jsr	init_p_ecran(pc)
	clr.w	$66(a6)		;efface les plans
	move.l	#ecran3,$54(a6)
	move.l	#$9000000,$40(a6)
	move.w	#256*64+20,$58(a6)
	move.w	#160-1,d7
	lea	inconnu,a0
	lea	inconnu2,a1
	move.l	p_lettre,a2
	moveq	#0,d1
	moveq	#0,d2
prepa_table			;on prepare ds une table l'add des lettres
	moveq	#0,d0		;et l'add dest ainsi que la pos de depart
	move.b	(a2)+,d0
	sub.b	#" ",d0
	rol.l	#2,d0		;*4 pour avoir l'add en mots longs
	add.l	#table_add,d0
	move.l	d0,a5
	move.l	(a5),(a0)+
	move.l	d1,d3
	add.l	d2,d3
	add.l	#ecran3,d3
	move.l	d3,(a0)+	;add ecran
	move.w	d1,d3
	rol.w	#3,d3		;tous les 8 octets
	add.w	#-160,d3	;centrex
	addq.w	#1,d3
	move.w	d3,(a1)+
	moveq	#0,d3
	move.w	d2,d3
	divu	#40,d3
	add.w	#-64,d3		;centrey
	move.w	d3,(a1)+
	move.w	#256,(a1)+	;sert a diviser par 256
	addq.w	#2,d1
	cmp.w	#40,d1
	bne.s	no_new_let
	moveq	#0,d1
	add.w	#640,d2		;long ligne dessin
no_new_let
	dbra	d7,prepa_table

	move.l	#table_orient,table_aff
	moveq	#0,d0
	move.b	(a2)+,d0	;caractere special
	mulu	#161,d0		;multiplie par largeur effet
	add.l	d0,table_aff
	add.l	#161,p_lettre	;texte suivant
	cmp.b	#0,(a2)
	bne.s	pas_fin_txt
	move.l	#texte,p_lettre
pas_fin_txt
	rts

end_aff	cmp.w	#1,test_aff
	beq.s	vas_y2
	rts

vas_y2
	cmp.w	#512,tourne
	blt.s	va_plier
	jsr	initialise(pc)
	rts

va_plier
	move.w	#128-1,d7	;hauteur d'un plan
	move.w	tourne,d6
	lea	courb1,a0
	move.w	0(a0,d6.w),d6
	move.w	#-64,d0		;centrey
	move.l	#ecran3,d5
	move.l	#$9f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	clr.l	$64(a6)
	move.l	destp,d2	;ecran1
	add.l	#2560,d2	;+moitie ecran
plie_ecran
	move.w	d0,d1
	muls	d6,d1
	divs	#$7fff,d1
	muls	#40,d1		;largeur de l'ecran
	add.l	d2,d1
	move.l	d5,$50(a6)	;copie ecran3
	move.l	d1,$54(a6)
	move.w	#64*1+20,$58(a6);une ligne
	add.l	#5120,d5	;plan suivant
	add.l	#5120,d1
	move.l	d5,$50(a6)
	move.l	d1,$54(a6)
	move.w	#64*1+20,$58(a6)
	sub.l	#5080,d5	;- une ligne
	addq.w	#1,d0
	dbra	d7,plie_ecran

	move.w	#$2200,pointx	;2 plans
	add.w	#24,tourne
	move.l	p_degr,a0	;gris pour le plie
	move.w	(a0)+,col1
	move.w	(a0)+,col2
	move.w	(a0),col3
	addq.l	#6,p_degr
	jsr	swap_plan2(pc)
	rts

effacescreen
	clr.l	$64(a6)
	move.l	destp,$54(a6)
	move.l	#$9000000,$40(a6)
	move.w	#256*64+20,$58(a6)	; 2 ecrans
	rts

buffer	cmp.l	#ecran1,destp
	bne.s	change_ecran
	move.l	#ecran6,destp
	rts

change_ecran
	move.l	#ecran1,destp
	rts

swap_plan
	move.l	destp(pc),d0
	lea	pointeur1(pc),a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	add.l	#5120,d0		;plan suivant
	lea	pointeur3(pc),a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	jsr	buffer
	rts

swap_plan2
	move.l	destp(pc),d0
	lea	pointeur1(pc),a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	add.l	#5120,d0	;plan suivant
	lea	pointeur2(pc),a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	jsr	buffer
	rts

init_p_ecran
	move.l	#ecran1,d0
	lea	pointeur1(pc),a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	move.l	#ecran3,d0
	addq.l	#8,a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	move.l	#ecran2,d0
	addq.l	#8,a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	move.l	#ecran4,d0
	addq.l	#8,a0
	swap	d0
	move.w	d0,(a0)
	swap	d0
	move.w	d0,4(a0)
	rts

restore_all
	move.w	old_dma,$96(a6)
	move.l	oldcopper,$80(a6)
	move.l	4,a6
	jsr	-$8a(a6)
	move.l	pile,sp
	clr.l	d0
	rts
copperlist	dc.w	$8e,$2c81,$90,$2cc1,$92,$38,$94,$d0
		dc.w	$108,0,$10a,0,$102,0,$104,$40
		dc.w	$100,0,$180,$0,$e0
pointeur1	dc.w	4,$e2,$3800,$e4
pointeur2	dc.w	4,$e6,$3800,$e8
pointeur3	dc.w	4,$ea,$3800,$ec
		dc.w	4,$ee,$3800,$182
col1	dc.w	$fff,$184
col2	dc.w	$ccc,$186
col3	dc.w	$888,$192,$fff,$194,$ccc
	dc.w	$196,$888,$8c0f,$fffe,$180,$804,$8d0f,$fffe
	dc.w	$180,$f08,$8e0f,$fffe,$180,$804,$8f0f,$fffe
	dc.w	$180,$402,$900f,$fffe,$180,$000,$910f,$fffe
	dc.w	$180,3,$100
pointx	dc.w	$4600,$ffdf,$fffe,$110f,$fffe
	dc.w	$100,0
	dc.w	$120f,$fffe,$180,$804,$130f,$fffe,$180,$f08
	dc.w	$140f,$fffe,$180,$804,$150f,$fffe,$180,$402
	dc.w	$160f,$fffe,$180,0,$ffff,$fffe
oldcopper	dc.l	0
pile		dc.l	0
destp		dc.l	ecran1
old_dma		dc.w	0
p_lettre	dc.l	texte
texte	
	dc.b	'@@@@@@@@@@@@@@@@@@@@'
	dc.b	'@                  @'
	dc.b	'@                  @'
	dc.b	'@ A PROFECY  INTRO @'
	dc.b	'@  MADE BY SPECTRE @'
	dc.b	'@                  @'
	dc.b	'@                  @'
	dc.b	'@@@@@@@@@@@@@@@@@@@@'
	dc.b	14
	dc.b	'@@@@@@@@@@@@@@@@@@@@'
	dc.b	'@     HI  TO       @'
	dc.b	'@   ALL MENBERS    @'
	dc.b	'@       OF         @'
	dc.b	'@    PROFECY       @'
	dc.b	'@    17-09-91      @'
	dc.b	'@                  @'
	dc.b	'@@@@@@@@@@@@@@@@@@@@'
	dc.b	10
	dc.b	0
	dc.b	0
	even
table_aff	dc.l	table_orient
table_orient	incbin	"table_orient"
	even
vitesse		dc.w	-1
compt_effet	dc.w	0
pause		dc.w	0
tourne		dc.w	0
test_aff	dc.w	0
p_degr	dc.l	degr
degr	dc.w	$EEE,$BBB,$777,$EEE,$BBB,$777,$DDD,$BBB
	dc.w	$777,$DDD,$AAA,$777,$DDD,$AAA,$666,$CCC,$AAA,$666
	dc.w	$CCC,$999,$666,$BBB,$999,$666,$BBB,$999,$555,$BBB
	dc.w	$888,$555,$AAA,$888,$555,$AAA,$888,$555,$999,$777
	dc.w	$444,$999,$777,$444,$999,$777,$444,$888,$666,$444
	dc.w	$888,$666,$333,$888,$666,$333,$777,$555,$333,$777
	dc.w	$555,$333,$777,$555,$222,$666,$444,$222,$666,$444
	dc.w	$222,$666,$333,$222,$444,$333,$111,$444,$222,$111
	dc.w	$333,$222,$111,$222,$111,$111,$222,$111,0
table_add
	dc.l	0
	dc.l	dessin+78,dessin,dessin,dessin,dessin
	dc.l	dessin,dessin+76,dessin+82,dessin+84,dessin
	dc.l	dessin+90,dessin+74,dessin+92,dessin+72
	dc.l	dessin+88,dessin+52,dessin+54,dessin+56,dessin+58
	dc.l	dessin+60,dessin+62,dessin+64,dessin+66,dessin+68
	dc.l	dessin+70,dessin,dessin,dessin,dessin
	dc.l	dessin,dessin+80,dessin+86,dessin,dessin+2
	dc.l	dessin+4,dessin+6,dessin+8,dessin+10,dessin+12
	dc.l	dessin+14,dessin+16,dessin+18,dessin+20,dessin+22
	dc.l	dessin+24,dessin+26,dessin+28,dessin+30,dessin+32
	dc.l	dessin+34,dessin+36,dessin+38,dessin+40,dessin+42
	dc.l	dessin+44,dessin+46,dessin+48,dessin+50
	dc.w	0,$C9,$192,$25B,$324
	dc.w	$3ED,$4B6,$57E,$647,$710,$7D9,$8A1,$96A,$A32,$AFB
	dc.w	$BC3,$C8B,$D53,$E1B,$EE3,$FAB,$1072,$1139,$1200
	dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833
	dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56
	dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467
	dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61
	dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041
	dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603
	dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4
	dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120
	dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674
	dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D
	dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097
	dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F
	dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3
	dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F
	dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
	dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
	dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
	dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
	dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
	dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
	dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
	dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
	dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
	dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
	dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
	dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
	dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
	dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
	dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE
courb1	dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0
	dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74
	dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9
	dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0
	dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59
	dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5
	dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6
	dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D
	dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A
	dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140
	dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30
	dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB
	dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745
	dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370
	dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D
	dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F
	dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689
	dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE
	dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0
	dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3
	dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279
	dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07
	dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F
	dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4
	dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB
	dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7
	dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC
	dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD
	dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E
	dc.w	$12C7,$1200,$1139,$1072,$FAB,$EE3,$E1B,$D53,$C8B
	dc.w	$BC3,$AFB,$A32,$96A,$8A1,$7D9,$710,$647,$57E,$4B6
	dc.w	$3ED,$324,$25B,$192,$C9,0,$FF37,$FE6E,$FDA5,$FCDC
	dc.w	$FC13,$FB4A,$FA82,$F9B9,$F8F0,$F827,$F75F,$F696
	dc.w	$F5CE,$F505,$F43D,$F375,$F2AD,$F1E5,$F11D,$F055
	dc.w	$EF8E,$EEC7,$EE00,$ED39,$EC72,$EBAB,$EAE5,$EA1F
	dc.w	$E959,$E893,$E7CD,$E708,$E643,$E57E,$E4BA,$E3F5
	dc.w	$E331,$E26D,$E1AA,$E0E7,$E024,$DF61,$DE9F,$DDDD
	dc.w	$DD1C,$DC5A,$DB99,$DAD9,$DA19,$D959,$D899,$D7DA
	dc.w	$D71B,$D65D,$D59F,$D4E2,$D425,$D368,$D2AC,$D1F0
	dc.w	$D134,$D07A,$CFBF,$CF05,$CE4C,$CD93,$CCDA,$CC22
	dc.w	$CB6A,$CAB3,$C9FD,$C947,$C891,$C7DC,$C728,$C674
	dc.w	$C5C1,$C50E,$C45C,$C3AA,$C2F9,$C249,$C199,$C0EA
	dc.w	$C03B,$BF8D,$BEE0,$BE33,$BD87,$BCDB,$BC30,$BB86
	dc.w	$BADD,$BA34,$B98C,$B8E4,$B83D,$B797,$B6F2,$B64D
	dc.w	$B5A9,$B506,$B463,$B3C1,$B320,$B280,$B1E0,$B141
	dc.w	$B0A3,$B006,$AF69,$AECD,$AE32,$AD98,$ACFF,$AC66
	dc.w	$ABCE,$AB37,$AAA1,$AA0C,$A977,$A8E3,$A850,$A7BE
	dc.w	$A72D,$A69D,$A60D,$A57F,$A4F1,$A464,$A3D8,$A34D
	dc.w	$A2C3,$A23A,$A1B1,$A12A,$A0A3,$A01E,$9F99,$9F15
	dc.w	$9E92,$9E10,$9D8F,$9D0F,$9C90,$9C12,$9B95,$9B19
	dc.w	$9A9E,$9A23,$99AA,$9932,$98BB,$9844,$97CF,$975B
	dc.w	$96E7,$9675,$9604,$9594,$9525,$94B6,$9449,$93DD
	dc.w	$9372,$9308,$929F,$9237,$91D0,$916B,$9106,$90A2
	dc.w	$9040,$8FDE,$8F7E,$8F1F,$8EC0,$8E63,$8E07,$8DAC
	dc.w	$8D52,$8CFA,$8CA2,$8C4B,$8BF6,$8BA2,$8B4F,$8AFD
	dc.w	$8AAC,$8A5C,$8A0D,$89C0,$8973,$8928,$88DE,$8895
	dc.w	$884D,$8807,$87C1,$877D,$873A,$86F8,$86B7,$8677
	dc.w	$8639,$85FC,$85BF,$8584,$854B,$8512,$84DB,$84A4
	dc.w	$846F,$843C,$8409,$83D7,$83A7,$8378,$834A,$831E
	dc.w	$82F2,$82C8,$829F,$8277,$8250,$822B,$8207,$81E4
	dc.w	$81C2,$81A2,$8182,$8164,$8147,$812C,$8111,$80F8
	dc.w	$80E0,$80C9,$80B4,$809F,$808C,$807A,$806A,$805A
	dc.w	$804C,$803F,$8033,$8029,$8020,$8018,$8011,$800B
	dc.w	$8007,$8004,$8002,$8001,$8002,$8004,$8007,$800B
	dc.w	$8011,$8018,$8020,$8029,$8033,$803F,$804C,$805A
	dc.w	$806A,$807A,$808C,$809F,$80B4,$80C9,$80E0,$80F8
	dc.w	$8111,$812C,$8147,$8164,$8182,$81A2,$81C2,$81E4
	dc.w	$8207,$822B,$8250,$8277,$829F,$82C8,$82F2,$831E
	dc.w	$834A,$8378,$83A7,$83D7,$8409,$843C,$846F,$84A4
	dc.w	$84DB,$8512,$854B,$8584,$85BF,$85FC,$8639,$8677
	dc.w	$86B7,$86F8,$873A,$877D,$87C1,$8807,$884D,$8895
	dc.w	$88DE,$8928,$8973,$89C0,$8A0D,$8A5C,$8AAC,$8AFD
	dc.w	$8B4F,$8BA2,$8BF6,$8C4B,$8CA2,$8CFA,$8D52,$8DAC
	dc.w	$8E07,$8E63,$8EC0,$8F1F,$8F7E,$8FDE,$9040,$90A2
	dc.w	$9106,$916B,$91D0,$9237,$929F,$9308,$9372,$93DD
	dc.w	$9449,$94B6,$9525,$9594,$9604,$9675,$96E7,$975B
	dc.w	$97CF,$9844,$98BB,$9932,$99AA,$9A23,$9A9E,$9B19
	dc.w	$9B95,$9C12,$9C90,$9D0F,$9D8F,$9E10,$9E92,$9F15
	dc.w	$9F99,$A01E,$A0A3,$A12A,$A1B1,$A23A,$A2C3,$A34D
	dc.w	$A3D8,$A464,$A4F1,$A57F,$A60D,$A69D,$A72D,$A7BE
	dc.w	$A850,$A8E3,$A977,$AA0C,$AAA1,$AB37,$ABCE,$AC66
	dc.w	$ACFF,$AD98,$AE32,$AECD,$AF69,$B006,$B0A3,$B141
	dc.w	$B1E0,$B280,$B320,$B3C1,$B463,$B506,$B5A9,$B64D
	dc.w	$B6F2,$B797,$B83D,$B8E4,$B98C,$BA34,$BADD,$BB86
	dc.w	$BC30,$BCDB,$BD87,$BE33,$BEE0,$BF8D,$C03B,$C0EA
	dc.w	$C199,$C249,$C2F9,$C3AA,$C45C,$C50E,$C5C1,$C674
	dc.w	$C728,$C7DC,$C891,$C947,$C9FD,$CAB3,$CB6A,$CC22
	dc.w	$CCDA,$CD93,$CE4C,$CF05,$CFBF,$D07A,$D134,$D1F0
	dc.w	$D2AC,$D368,$D425,$D4E2,$D59F,$D65D,$D71B,$D7DA
	dc.w	$D899,$D959,$DA19,$DAD9,$DB99,$DC5A,$DD1C,$DDDD
	dc.w	$DE9F,$DF61,$E024,$E0E7,$E1AA,$E26D,$E331,$E3F5
	dc.w	$E4BA,$E57E,$E643,$E708,$E7CD,$E893,$E959,$EA1F
	dc.w	$EAE5,$EBAB,$EC72,$ED39,$EE00,$EEC7,$EF8E,$F055
	dc.w	$F11D,$F1E5,$F2AD,$F375,$F43D,$F505,$F5CE,$F696
	dc.w	$F75F,$F827,$F8F0,$F9B9,$FA82,$FB4A,$FC13,$FCDC
	dc.w	$FDA5,$FE6E,$FF37,0,$C9,$192,$25B,$324,$3ED,$4B6
	dc.w	$57E,$647,$710,$7D9,$8A1,$96A,$A32,$AFB,$BC3,$C8B
	dc.w	$D53,$E1B,$EE3,$FAB,$1072,$1139,$1200,$12C7,$138E
	dc.w	$1455,$151B,$15E1,$16A7,$176D,$1833,$18F8,$19BD
	dc.w	$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56,$1F19,$1FDC
	dc.w	$209F,$2161,$2223,$22E4,$23A6,$2467,$2527,$25E7
	dc.w	$26A7,$2767,$2826,$28E5,$29A3,$2A61,$2B1E,$2BDB
	dc.w	$2C98,$2D54,$2E10,$2ECC,$2F86,$3041,$30FB,$31B4
	dc.w	$326D,$3326,$33DE,$3496,$354D,$3603,$36B9,$376F
	dc.w	$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4,$3C56,$3D07
	dc.w	$3DB7,$3E67,$3F16,$3FC5,$4073,$4120,$41CD,$4279
	dc.w	$4325,$43D0,$447A,$4523,$45CC,$4674,$471C,$47C3
	dc.w	$4869,$490E,$49B3,$4A57,$4AFA,$4B9D,$4C3F,$4CE0
	dc.w	$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097,$5133,$51CE
	dc.w	$5268,$5301,$539A,$5432,$54C9,$555F,$55F4,$5689
	dc.w	$571D,$57B0,$5842,$58D3,$5963,$59F3,$5A81,$5B0F
	dc.w	$5B9C,$5C28,$5CB3,$5CB3,$5D3D,$5DC6,$5E4F
	dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271
	dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656
	dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC
	dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61
	dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082
	dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E
	dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3
	dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F
	dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41
	dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7
	dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61
	dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E
	dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C
	dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD
	dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE,$7FFF
inconnu		dcb.b	1280
inconnu2	dcb.b	960
ecran1	dcb.b	5120
ecran2	dcb.b	5120
ecran6	dcb.b	10240
ecran3	dcb.b	5120
ecran4	dcb.b	5120
dessin	incbin	dessin
