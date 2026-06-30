;LE SPEED POWER PROPOSE....
;Une routine amusante .elle dessine .On fait les dessins avec COURBE.GFA
;Et ca dessine tout seul.A poser lors des presentation d'auteurs....
;Le graph du crayon est en bas.Necessite SP pour l'exemple....

long_ecr=40
long_cray=1
haut_cray=14
		section	code,code_c
		move	$dff002,d6
		or	#%1000000100000000,d6
		move	$dff01c,d7
		or	#%1100000000000000,d7
		
		move	#$7fff,$dff096
		move	#%0001001000000000,$dff100
		clr	$dff108
		move	#$2981,$dff08e
		move	#$29c1,$dff090
		move	#$0038,$dff092
		move	#$00d0,$dff094
		
		move	#%1000011101000000,$dff096

w		cmp.b	#1,$dff006
		bne	w
		move.l	#ecran,$dff0e0
		move	#10,$dff180
		tst	d0
		bmi	a_oter	
		bsr	dessine
a_oter		move	#0,$dff180
		btst	#6,$bfe001
		bne	w

		move	#$7fff,$dff096
		move	d6,$dff096
		move	#$7fff,$dff09a
		move	d7,$dff09a
		moveq	#0,d0
		rts

dessine		move.l	pos_cray,a0
		tst	(a0)
		bmi	fin_dessin		
		move	(a0)+,d0
		move	(a0)+,d1
		move.l	a0,pos_cray
		mulu	#long_ecr,d1
		move	d0,d2
		lsr	#4,d2
		lsl	d2
		add	d2,d1
		add.l	#ecran,d1
		lsl	#8,d0
		lsl	#4,d0
		or	#%0000110111111100,d0
		lea	$dff000,a0
		move.l	#crayon,$50(a0)
		move.l	d1,$4c(a0)
		move.l	d1,$54(a0)
		move	#0,$64(a0)
		move	#long_ecr-(long_cray+1)*2,$62(a0)
		move	#long_ecr-(long_cray+1)*2,$66(a0)
		move	d0,$40(a0)
		move	#haut_cray<<6+long_cray+1,$58(a0)
		move	#0,d0
		rts
fin_dessin	move	#-1,d0
		rts
		
pos_cray	dc.l	dessin

dessin		incbin	"df0:sp"
		dc	-1

crayon		dc	%0000000110000000,0			
		dc	%0000011111100000,0
		dc	%0000011111100000,0
		dc	%0011111111111100,0
		dc	%0011111111111100,0
		dc	%0111111111111110,0
		dc	%0111111111111110,0
		dc	%0111111111111110,0
		dc	%0111111111111110,0
		dc	%0011111111111100,0
		dc	%0011111111111100,0
		dc	%0000011111100000,0
		dc	%0000011111100000,0
		dc	%0000000110000000,0

		even	
ecran		dcb.b	256*long_ecr
