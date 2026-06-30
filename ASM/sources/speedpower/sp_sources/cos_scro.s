;LES RIP CODE DU SPEED POWER...
;Le scrolling de SPECTRE de PROFECY.Source rippe d'un membre de mon
;groupe (c'est juste une question d'entrainement).Mon avis sur cette 
;routine :c'est la premiere routine bien programme que je rippe
;(pascal est un bon) les autres ont des choses inutiles.....
;Cette routine travaille en buffer (ou pas ...) et ne prend pas de temp 
;bref cool.....Moi j'aime bien...

;Necessite	SIN
;		COS_CHAR		 

debut		jsr	sauve_tout
		
		move	#$3fff,$dff096
		move	#$3fff,$dff09a

		move	#%0001001000000000,$dff100
		clr	$dff104
		clr	$dff108
		move	#$2981,$dff08e		
		move	#$29c1,$dff090
		move	#$0038,$dff092
		move	#$00d0,$dff094

		move	#$fff,$dff182
		
		move	#%1000001101000000,$dff096
		move	#%1000000000000000,$dff09a

w		cmp.b	#55,$dff006
		bne	w
		move	#$7,$dff180
		jsr	flippe
		jsr	cos_scroll
		jsr	affiche
		move	#$0,$dff180
		btst	#6,$bfe001
		bne	w		
	
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

cos_scroll	TST.W	compteur200
		BNE	pause
		LEA	buffer+40,A3	
		LEA	destination,A4	
		LEA	compteur16sur2,A6
		MOVEA.L	pointeur_texte,A5
		TST.W	(A6)
		BNE	no_new_let
		tst.b	(a5)		
		BNE.S	letr_ok
		lea	texte,A5
letr_ok		CLR.L	D1
		MOVE.B	(A5)+,D1
		CMPI.B	#$73,D1
		BNE	pas_arret
		MOVE.W	#$C8,compteur200
		MOVE.L	A5,pointeur_texte
		BRA	pause
pas_arret	MOVE.L	A5,pointeur_texte
		SUBI.B	#$20,D1
		LSL.W	#2,D1
		LEA	tab_adr,A2
		BSR	wait_blit
		MOVE.L	#$FFFFFFFF,$DFF044
		CLR.W	$DFF066
		MOVE.W	#$26,$DFF064
		MOVE.W	#$9F0,$DFF040
		MOVE.L	A4,$DFF054
		MOVE.L	0(A2,D1.W),$DFF050
		MOVE.W	#$601,$DFF058
		BSR	wait_blit
		MOVE.W	#$10,(A6)
no_new_let	MOVE.W	#2,D3		
		SUB.W	D3,(A6)
		MOVE.W	#$17,D1
mot_sui		CLR.W	(A3)
		MOVE.W	(A4),D0
		ANDI.W	#$C000,D0
		OR.W	D0,(A3)
		MOVE.W	(A4),D2
		LSL.W	D3,D2
		MOVE.W	D2,(A4)
		ADDQ.W	#2,A4
		ADDA.W	#$2A,A3
		DBF	D1,mot_sui	
		BSR	wait_blit
		CLR.W	$DFF066
		CLR.W	$DFF064
		MOVE.L	#$FFFFFFFF,$DFF044
		MOVE.L	#$E9F00000,$DFF040
		MOVE.L	#buffer,$DFF054
		MOVE.L	#buffer+2,$DFF050
		MOVE.W	#$615,$DFF058
		RTS
pause		SUBQ.W	#1,compteur200
		RTS

trans_sin_scr	CMPA.L	#fin_sin_scr,A2
		BNE	sin_ok
		MOVEA.L	#deb_sin_scr,A2
sin_ok		MULU	#$28,D0
		ADD.L	A1,D0
		RTS

affiche		BSR	wait_blit
		MOVE.L	#$260028,$DFF062
		MOVE.W	#$26,$DFF066
		MOVE.L	#$FFFF,$DFF042
		MOVEA.L	adr_ecran,A1
		MOVEA.L	ptr_sin_scr,A2
		LEA	buffer,A0
		MOVE.W	#$13,D5
colonne		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		BSR	wait_blit
		MOVEA.L	A0,A3
		SUBA.L	#$1A4,A3
		SUBI.L	#$190,D0
		MOVE.L	A3,$DFF050
		MOVE.L	D0,$DFF054
		MOVE.W	#$9F0,$DFF040
		MOVE.W	#$C000,$DFF046
		MOVE.W	#$B01,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	#$DFC,$DFF040
		MOVE.W	#$3000,$DFF046
		MOVE.W	#$601,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		MOVE.W	#$C00,D2
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	D2,$DFF046
		MOVE.W	#$601,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		MOVE.W	#$300,D2
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	D2,$DFF046
		MOVE.W	#$601,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		MOVE.W	#$C0,D2
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	D2,$DFF046
		MOVE.W	#$601,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		MOVE.W	#$30,D2
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	D2,$DFF046
		MOVE.W	#$601,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		MOVE.W	#$C,D2
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	D2,$DFF046
		MOVE.W	#$601,$DFF058
		CLR.L	D0
		MOVE.B	(A2)+,D0
		BSR	trans_sin_scr
		MOVE.W	#3,D2
		BSR	wait_blit
		MOVE.L	A0,$DFF050
		MOVE.L	D0,$DFF04C
		MOVE.L	D0,$DFF054
		MOVE.W	D2,$DFF046
		MOVE.W	#$601,$DFF058
		ADDQ.L	#2,A0
		ADDQ.L	#2,A1
		DBF	D5,colonne
		CMPI.L	#deb_sin_scr,ptr_sin_scr
		BNE	sinscr_deb_ok
		MOVE.L	#fin_sin_scr,ptr_sin_scr	
sinscr_deb_ok	SUBQ.L	#1,ptr_sin_scr
		RTS

wait_blit	BTST	#$E,$DFF002
		BNE.S	wait_blit
		RTS

flippe		MOVE.L	adr_ecran,D1
		MOVE.L	adr_ecran+4,adr_ecran
		MOVE.L	D1,adr_ecran+4
		move.l	d1,$dff0e0
		RTS


adr_ecran	dc.l	ecran
		dc.l	ecran+10240

ptr_sin_scr	dc.l	deb_sin_scr

compteur16sur2	dc	0
compteur200	dc	0

tab_adr		dc.l	c+1952,c+994,c+0,c+0,c+0,c+1924,c+0,c+998,c+1920,c+1922,c+1932,c+1934,c+1926,c+1928,c+1930,c+0,c+972,c+974,c+976,c+978,c+980,c+982,c+984,c+986,c+988,c+990,c+992,c+0,c+1938,c+0,c+996,c+1936
		dc.l	c+0,c+0,c+2,c+4,c+6,c+8,c+10,c+12,c+14,c+16,c+18,c+20,c+22,c+24,c+26,c+28,c+30,c+32,c+34,c+36,c+38,c+960,c+962,c+964,c+966,c+968,c+970

pointeur_texte	dc.l	texte
texte		DC.B	"    *SPEEDPOWER*    s DE >PROFECY< S'ENTRAINE AU +RIP%CODE+ SUR LE TRES BON CODE DE SPECTRE...         "
		DC.B	0
		
deb_sin_scr	incbin	"sin"
fin_sin_scr
c		incbin	"cos_char"

		even
destination	dcb.w	24,0
buffer		dcb.b	24*42,0

ecran		dcb.b	2*10240,0
