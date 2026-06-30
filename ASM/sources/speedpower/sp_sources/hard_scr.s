;LE SPEED POWER PROPOSE...
;Ma routine de hard scroll .C'est la premiere routine que je fait sur cette
;machine (putain c'est dur).On peut mettre de 1 a trois plans ou alors les 6
;il faut alors changer les initialisations et les ; sont a otes dans la rout
;hard_scroll
; on fait les courbe avec le prg COURBE.GFA
;c'est un big ecran de 640*512 (10240*4*n_plan)
longueur_lig=640
big_bitplane=80*512
nbr_bpl=3

debut		jsr	sauve_tout
		
		move	#$7fff,$dff096
		move	#$7fff,$dff09a

		move	#%0110011000000000,$dff100	;trois bit plann +dual play field
		;bset	#6,$dff104		;texte-scrolling sur le bpl 2
		move	#$2981,$dff08e		
		move	#$29b1,$dff090
		move	#$0030,$dff092			;pour cacher le decalage
		move	#$00c8,$dff094
		move	#$444,$dff182
		move	#$666,$dff184
		move	#$888,$dff186
		move	#$333,$dff188
		move	#$f8f,$dff18a		;les huit couleurs
		move	#$0ff,$dff18c
		move	#$fff,$dff18e
		
		move	#40,$dff108	;longueur_lig/8-320/8,$dff108	;modulo
		clr	$dff10a
		move.l	#irq,$6c
		
		move	#%1100000000100000,$dff09a
		move	#%1000001100000000,$dff096
	
w		;cmp.b	#0,$dff006
		;bne	w
		;bsr	hard_scroll
		;move.l	#10000,d0
zob		;dbf	d0,zob
		btst	#6,$bfe001
		bne	w

		jsr	restaure_tout

		moveq	#0,d0
		rts

irq		movem.l	d0-d7/a0-a6,-(sp)
		bsr	hard_scroll
		move	#%0000000000100000,$dff09c
		movem.l	(sp)+,d0-d7/a0-a6
		rte

hard_scroll	move.l	ptr_hard_scroll,a0
		tst	(a0)
		bge	adr_ok
		lea	courbe,a0
adr_ok		move	(a0)+,d0
		move	(a0)+,d1
		move.l	a0,ptr_hard_scroll
		move	d0,d2
		and	#%0000000000001111,d2
		lsr	#4,d0
		lsl	#1,d0
		mulu	#longueur_lig/8,d1
		add.l	d1,d0
		add.l	#big_ecr,d0
		move.l	d0,$dff0e0	
		add.l	#big_bitplane,d0
		move.l	d0,$dff0e8	 	;les deux autres plans impair
		add.l	#big_bitplane,d0
		move.l	d0,$dff0f0
		not	d2
		move	d2,$dff102		;con1 1,3,5 eme plan
		move.l	#$16000,$dff0e4
		move.l	#$16000,$dff0ec		;l'autre play field
		move.l	#$16000,$dff0f4
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

ptr_hard_scroll	dc.l	courbe

courbe		incbin	"df0:courbe"	
		dc.l	-1

		even
big_ecr		incbin	"df0:char_sin"	;dcb.b	nbr_bpl*big_bitplane,0	
