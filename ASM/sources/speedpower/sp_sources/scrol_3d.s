;LES RIP CODE DU SPEED POWER ....
;Le scroll 3d de COOL X .Je pensais que c'etait une bonne routine mais
;finalement , je me demande si cool x ne l'a pas aussi rippe quelque
;part .... Oui cette routine travaille en BUFFER ,prend toute la VBL
; et n'est pas constante (routine de merde) .Ce qui me  fait le plus
;chier c'est que je suis sur que l'auteur  n'arrive pas lui meme a changer
;le chemin des angles (on essai et ca plante , c'est dans la routine 
;ANGLES) , pour couronner le tout elle marche qu'avec DEVPAC (c'est bien
;ce que je disais routine de merde....)
;Moi qui voulait la passer sur ST .....(la honte...)
;Elle necessite  les fichiers TAB3D
;			      COOR_LET


debut		jsr	sauve_tout
		
		move	#$3fff,$dff096
		move	#$3fff,$dff09a

		move	#%0001001000000000,$dff100
		clr	$dff104
		clr	$dff108
		clr	$dff108
		move	#$2981,$dff08e		
		move	#$19c1,$dff090
		move	#$0038,$dff092
		move	#$00d0,$dff094

		move	#$fff,$dff182

		
		move	#%1000000001000000,$dff09a
		move	#%1000001101000000,$dff096	;ici
	
		jsr	prg_principale

		jsr	restaure_tout

		moveq	#0,d0
		rts

sauve_tout	move.b	#%10000111,$bfd100
		move.l	$6c,sauve_irq
		move	$dff01c,sauve_intena
		or	#%1100000000000000,sauve_intena
		move	$dff002,sauve_dmacon
		or	#%1000000100000000,sauve_dmacon
		rts
restaure_tout	move.l	sauve_irq,$6c
		move	#$7fff,$dff09a
		move	sauve_intena,$dff09a
		move	#$7fff,$dff096
		move	sauve_dmacon,$dff096
		move.l	4,a6
		lea	glib,a1
		moveq	#0,d0
		jsr	-552(a6)
		move.l	d0,a0
		move.l	38(a0),$dff080
		clr	$dff088
		rts

		even
sauve_intena	dc	0
		even
sauve_dmacon	dc	0
		even
sauve_irq	dc.l	0
		even
glib		dc.b	"graphics.library",0
		even

dessine		MOVEM.L	D0-d7/A0-a6,-(A7)
		MOVEA.L	adr_bitplan,A0
		SUB.W	D1,D3
		BPL.S	lbl1
		NEG.W	D3
		SUB.W	D0,D2	
		BPL.S	lbl8
		NEG.W	D2
		CMP.W	D3,D2
		BPL.S	lbl2
		MOVEQ	#$D,D4
		BRA.S	lbl6
lbl1		SUB.W	D0,D2
		BPL.S	lbl9
		NEG.W	D2
		CMP.W	D3,D2
		BPL.S	lbl3
		MOVEQ	#9,D4
		BRA.S	lbl6
lbl8		CMP.W	D3,D2
		BPL.S	lbl5
		MOVEQ	#5,D4
		BRA.S	lbl6
lbl9		CMP.W	D3,D2
		BPL.S	lbl4
		MOVEQ	#1,D4
		BRA.S	lbl6
lbl2		MOVEQ	#$1D,D4
		BRA.S	lbl7
lbl3		MOVEQ	#$15,D4
		BRA.S	lbl7
lbl4		MOVEQ	#$11,D4
		BRA.S	lbl7
lbl5		MOVEQ	#$19,D4
		BRA.S	lbl7
lbl6		EXG	D2,D3
lbl7		MOVE.W	D2,D5
		ADDQ.W	#1,D5
		ASL.W	#6,D5
		ADDQ.W	#2,D5
		MOVE.W	D0,D6
		LSR.W	#3,D0
		MULU	#$28,D1
		ADD.W	D1,D0
		ADDA.W	D0,A0
		ADD.W	D3,D3
		MOVE.W	D3,D7
		CMP.W	D2,D7
		BPL.S	lbl10
		BSET	#6,D4
		SUB.W	D2,D7
		SUB.W	D2,D7
		BSR.S	trace
		MOVE.W	D7,$DFF052
		ADD.W	D7,D7
		MOVE.W	D7,$DFF064
		BRA.S	lbl11
lbl10		BSR.S	trace
		MOVE.W	D7,$DFF052
		SUB.W	D2,D7
		SUB.W	D2,D7
		ADD.W	D7,D7
		MOVE.W	D7,$DFF064
lbl11		ADD.W	D3,D3
		MOVE.W	D3,$DFF062
		ROR.W	#4,D6
		ANDI.W	#$F000,D6
		ORI.W	#$BFA,D6
		MOVE.W	#$28,$DFF060
		MOVE.L	#$FFFFFFFF,$DFF044
		MOVE.W	#$8000,$DFF074
		MOVE.W	D6,$DFF040
		MOVE.W	D4,$DFF042
		MOVE.L	A0,$DFF048
		MOVE.L	A0,$DFF054
		MOVE.W	D5,$DFF058
		MOVEM.L	(A7)+,D0-d7/A0-a6
		RTS


trace		MOVE.W	#$8400,$DFF096
wb1		BTST	#$E,$DFF002
		BNE.S	wb1
		MOVE.W	#$400,$DFF096
		RTS

wb2		BTST	#$E,$DFF002
		BNE.S	wb2
		RTS

efface		BTST	#$E,$DFF002
		BNE.S	efface
		MOVE.L	adr_bitplan,$DFF054
		MOVE.L	#$1000000,$DFF040
		MOVE.L	#0,$DFF044
		MOVE.W	#0,$DFF066
		MOVE.W	#$4014,$DFF058
		RTS

flippe		MOVE.L	adr_bitplan,D0
		MOVE.L	adr_bitplan+4,adr_bitplan
		move.l	d0,adr_bitplan+4
		move.l	d0,$dff0e0	;j'ai change
		RTS

prg_principale	MOVE.L	$DFF004,D2
		ANDI.L	#$1FF00,D2
		CMPI.L	#$100,D2
		BNE.S	prg_principale
		move	#$f,$dff180
		BSR.S	flippe
		BSR	efface
		BSR.S	angles
		BSR.S	transforme
		BSR	scrolling
		move	#$0,$dff180
		BSR	wb2
		BTST	#6,$BFE001
		BNE.S	prg_principale
		RTS

angles		LEA	ptr_angles,A0
		add	#6,(a0)+
		add	#6,(a0)+
		add	#0,(a0)
		RTS

transforme	LEA	table1,A0	
		LEA	table2,A1
		LEA	ptr_angles,A2
		MOVEM.W	(A2)+,D0-d3
		AND.W	D3,D0
		AND.W	D3,D1
		AND.W	D3,D2
		ADD.L	D0,D0
		ADD.L	D1,D1
		ADD.L	D2,D2
		MOVE.W	0(A0,D0.W),valeur1+2
		MOVE.W	0(A0,D1.W),valeur2+2
		MOVE.W	0(A0,D2.W),valeur3+2
		MOVE.W	0(A1,D0.W),valur1+2
		MOVE.W	0(A1,D1.W),valur2+2
		MOVE.W	0(A1,D2.W),valur3+2
		RTS

calcul		MOVEM.L	D0-d7/A0-a6,-(A7)
		LEA	big_buf,A0		
		MOVE.W	(A2),(A0)+
		MOVEQ	#0,D7
		MOVE.W	(A2)+,D7
bcl1		MOVE.W	(A2)+,(A0)
		SUB.W	D1,(A0)+
		MOVE.W	(A2)+,(A0)+
		MOVE.W	(A2)+,(A0)+
		DBF	D7,bcl1
		MOVEQ	#0,D7
		MOVE.W	(A2),(A0)+
		MOVE.W	(A2)+,D7	
bcl2		MOVE.W	(A2)+,(A0)+
		MOVE.W	(A2)+,(A0)+
		DBF	D7,bcl2
		LEA	big_buf,A0		
		LEA	buf_res,A1
		MOVE.W	(A0)+,D7
bcl3		MOVEM.W	(A0)+,D0-d2
		ADDI.W	#$C8,D0
		MOVE.W	D0,D3
		MOVE.W	D1,D4
valeur1		MOVE.W	#0,D6
valur1		MOVE.W	#0,D5
		MULS	D5,D0
		MULS	D6,D1
		SUB.L	D1,D0
		ADD.L	D0,D0
		SWAP	D0
		MULS	D5,D4
		MULS	D6,D3
		ADD.L	D4,D3
		ADD.L	D3,D3
		SWAP	D3
		MOVE.W	D3,D1
		MOVE.W	D2,D4
valeur2		MOVE.W	#0,D6
valur2		MOVE.W	#0,D5
		MULS	D5,D1
		MULS	D6,D2
		SUB.L	D2,D1
		ADD.L	D1,D1
		SWAP	D1
		MULS	D6,D3
		MULS	D5,D4
		ADD.L	D4,D3
		ADD.L	D3,D3
		SWAP	D3
		MOVE.W	D3,D2
		MOVE.W	D0,D4
valeur3		MOVE.W	#0,D6
valur3		MOVE.W	#0,D5
		MULS	D5,D2
		MULS	D6,D4
		SUB.L	D4,D2
		ADD.L	D2,D2
		SWAP	D2
		MULS	D5,D0
		MULS	D6,D3
		ADD.L	D3,D0
		ADD.L	D0,D0
		SWAP	D0
		ADDI.W	#$2C6,D2
		MULS	#$BE,D0
		MULS	#$BE,D1
		DIVS	D2,D0
		DIVS	D2,D1
		ADDI.W	#$A0,D0
		ADDI.W	#$64,D1
		MOVE.W	D0,(A1)+
		MOVE.W	D1,(A1)+
		DBF	D7,bcl3
		MOVEQ	#0,D7
		MOVEQ	#0,D6
		MOVE.W	(A0)+,D7
		MOVEA.L	adr_bitplan,A5
		LEA	buf_res,A1
lbl12		MOVE.W	(A0)+,D6
		MOVE.W	(A0)+,D5
		LSL.W	#2,D6
		LSL.W	#2,D5
		MOVE.W	0(A1,D6.L),D0
		MOVE.W	2(A1,D6.L),D1
		MOVE.W	0(A1,D5.L),D2
		MOVE.W	2(A1,D5.L),D3
		BSR	dessine
		SUBI.W	#1,D7
		CMPI.W	#$FFFF,D7
		BNE.S	lbl12		
		MOVEM.L	(A7)+,D0-d7/A0-a6
		RTS

scrolling	SUBI.W	#1,compteur50
		BEQ.S	lbl13
		ADDI.W	#2,compteur830
		BRA.S	lbl14
lbl13		MOVE.W	#$33E,compteur830
		MOVE.W	#$32,compteur50
		ADDI.L	#1,pointeur_texte
		MOVEA.L	pointeur_texte,A0
		TST.B	(A0)	
		BEQ.S	lbl15
		BRA.S	lbl14
lbl15		MOVE.L	texte,pointeur_texte
		NOP
lbl14		MOVEA.L	pointeur_texte,A4
		MOVEQ	#0,D0
		MOVE.B	#9,D0
		LEA	tab_adr,A1
		MOVE.W	compteur830,D1
bcl4		MOVEQ	#0,D2
		MOVE.B	(A4)+,D2
		CMPI.B	#0,D2
		BEQ.S	lbl16
		CMPI.B	#$20,D2
		BEQ.S	lbl17
		SUBI.B	#$41,D2
		LSL.L	#2,D2
		MOVEA.L	0(A1,D2.L),A2
		BSR	calcul
lbl17		SUBI.W	#$64,D1
		DBF	D0,bcl4
		RTS
lbl16		MOVE.L	#texte,pointeur_texte
		RTS

ptr_angles	dc	0
		dc	0
		dc	0
		dc	$7ff		

		even
adr_bitplan	dc.l	ecran
		dc.l	ecran+10240
		even
compteur830	dc	830
compteur50	dc	50

pointeur_texte	dc.l	texte
		EVEN			;rq  [ = -
texte		dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ[ "
		DC.B	0
		EVEN

		even	;a    b     c    d     e      f     g     h      i      j     k       l      m     n      o       p      q      r      s      t      u      v       w      x      y      z	
tab_adr		dc.l	c+0,c+$22,c+$58,c+$76,c+$a2,c+$ca,c+$f2,c+$124,c+$158,c+$16c,c+$19a,c+$1c8,c+$1e6,c+$218,c+$240,c+$26c,c+$294,c+$2d0,c+$302,c+$32a,c+$34e,c+$376,c+$394,c+$3cc,c+$3f0,c+$414,c+$43c	
		even																	  

table1		incbin	"df0:tab3d"
		even
table2=table1+8192

		even
c		incbin	"df0:coor_let"
		even

		even
big_buf		dcb.b	1000,0		
buf_res		dcb.b	1000,0		

ecran		dcb.b	10240*2,0
