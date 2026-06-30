;LE SPEED POWER PROPOSE...
;Ma routine de degrade automatique pour le COPPER.On entre des parametres
;simples (lignes de depart,d'arrivee,couleur de depart,d'arrivee,registre)
;C'est une routine tres complexe ,je crois pas que j'arriverai a me 
;recomprendre...j'ai observe certain defauts mais j'arrive pas les reperer
;Donc pas la peine d'essayer de la modifier...
;Rq:La ligne la plus haute porte le numero 32 ,et la plus basse est 255
;Me demandez pas de compendre (et c'est pas marque dans la bible).
;La vrai routine est DEGRADE . ATT:ON n'oublie rien si on veut copier
;A propos j'ai fait COPPER.GFA ,programme totalement inutile (sauf pour
;ripper la copper list des autres ).
		section	code,code_c
		jsr	cree_cl
		move	$dff002,d6
		or	#%1000000100000000,d6

		move	#$7fff,$dff096

		move.l	#copper_list,$dff080
		tst	$dff088

		move	#%1000001010000000,$dff096

w		btst	#6,$bfe001
		bne	w

		move	#$7fff,$dff096
		move	d6,$dff096
		move.l	4,a6
		lea	glib,a1
		moveq	#0,d0
		jsr	-552(a6)
		move.l	d0,a0
		move.l	38(a0),$dff080
		clr	$dff088
		moveq	#0,d0
		rts
		even
glib		dc.b	"graphics.library",0
		even

cree_cl		lea	copper_list,a0
		move	#$0180,d0	;le registre de couleur
		move	#$f80,d1	;la teinte de depart
		move	#$000,d2	;la teinte d'arrivee
		move	#40,d3		;la ligne de depart
		move	#254,d4		;la  ''   fin (> a ligne de depart)
		bsr	degrade
		;move	#$ff03,(a0)+
		;move	#$fffe,(a0)+
		;move	#$fff3,(a0)+
		;move	#$fffe,(a0)+
		;move	#
	
		;move	#$00f,d1
		;move	#$f00,d2
		;move	#81,d3
		;move	#120,d4
		;bsr	degrade
		;move	#$f00,d1
		;move	#$0f0,d2
		;move	#121,d3
		;move	#160,d4
		;bsr	degrade
		;move	#$0f0,d1
		;move	#$faa,d2
		;move	#161,d3
		;move	#200,d4
		;bsr	degrade
		move.l	#$fffffffe,(a0)
		rts

degrade		sub	d3,d4		;boucle de n ligne=d4

		move.l	a0,a1
		move	d3,d6
		move	d4,d3
fait_wait_reg	move	d6,d7
		lsl	#8,d7
		or	#3,d7
		move	d7,(a0)+
		move	#$fffe,(a0)+
		move	d0,(a0)+
		lea	2(a0),a0
		add	#1,d6
		dbf	d3,fait_wait_reg
		move.l	a0,a2

		move	d1,d6
		lsr	#8,d6
		and	#$f,d6
		move	d2,d5
		lsr	#8,d5
		and	#$f,d5
		bsr	composante
		move	d1,d6
		lsr	#4,d6
		and	#$f,d6
		move	d2,d5
		lsr	#4,d5
		and	#$f,d5
		bsr	composante
		move	d1,d6
		and	#$f,d6
		move	d2,d5
		and	#$f,d5
		bsr	composante
		move.l	a2,a0
		rts

composante	move.l	a1,a0							
		move	d4,d3
comp_sui	move	6(a0),d7
		lsl.w	#4,d7
		move	d7,6(a0)
		lea	8(a0),a0
		dbf	d3,comp_sui
		move.l	a1,a0

		sub	d6,d5		;composante2-composante1=d5
		beq	fin
		move	d5,d3
		bge	valpos1
		neg	d3		;valeur absolue pour le test
valpos1		move	d6,d7		;composante de depart=d7
		cmp	d3,d4		;n>abs(dc)
		bge	plusdeligne1
		tst	d5
		bge	dcpos1		;dc positif ??
		neg	d5
dcpos1		move	d5,d6
		divs	d4,d6		;apres ca on a dc / n=d6
		move	d6,d3		;
		btst	#30,d6		;
		beq	lememe		;
		add	#1,d3		;
lememe		swap	d6		;
		move	d3,d6		;
		tst	d5		;est ce que dc etait negatif
		bge	unplus1		;
		neg	d6		;
		swap	d6		;
		neg	d6		;
		swap	d6		;		
unplus1		move.l	d6,d5		;les valeurs d'inc(encadre)=d5
		move	d4,d3
faitcomp1	or	d7,6(a0)	;la valeur
		swap	d5
		add	d5,d7		;on incremente (ou dec selon le choix)
		bge	n_min1
		clr	d7
n_min1		cmp	#$f,d7
		ble	n_max1
		move	#$f,d7
n_max1		lea	8(a0),a0
		dbf	d3,faitcomp1	
		rts		
plusdeligne1	moveq	#1,d6
		tst	d5
		bge	plus1
		neg	d6
		neg	d5
plus1		move	d6,valeur1+2
		move	d4,d6
		divs	d5,d6
		move	d6,d5
		clr	d6
		move	d4,d3
faitcomp1.	or	d7,6(a0)
		cmp	d5,d6
		blt	n_new_c1
		clr	d6
valeur1		add	#3,d7
n_new_c1	tst	d7
		bge	n_min1.
		clr	d7
n_min1.		cmp	#$f,d7
		ble	n_max1.
		move	#$f,d7		
n_max1.		add	#1,d6
		lea	8(a0),a0
		dbf	d3,faitcomp1.
fin		rts

copper_list	dcb.w	256*4,0

