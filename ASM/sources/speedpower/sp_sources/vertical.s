;LE SPEED POWER PROPOSE.....
;Une routine de raster vertical completement nul a chier.C'est programme
;comme un porc ,c'est lent , ca plante .... J'ai fait ca hyper mega speed
;chez Wooper . Pour la reparer , il faudrait mettre un ptr sur chaque barre
;(comme pour les sprites ) .Pour que ca fasse bien il faut le faire en ham
;mettre une ondulation ou un decalage et puis aussi faire du precalcul ect.
;de toute facon , j'aime pas ce genre de trucs.......
;necessite pour l'exemple SINV fait avec SINV.LST
;Autre chose , ca peut se passer sur le st (mais ca prend du temp).

taillecran=40*256
nbecran=2

dep_lignev=40
nb_barrev=10
n_planv=3
long_ecr=40
v_barv=1
nb_ligv=199
espv=4

	section debut,code_c
start:
;******* debut ******
save_all:
	move.l	4,a6
	jsr	-132(a6)
	move.w	$dff002,save_dmacon
	or.w	#$c000,save_dmacon

	move.l	#$dff000,a6

;****** installation copper *****
		lea	copper_list,a0
		move.l	#$1005200,(a0)+
		move.l	#ecran,d0
		move	#$00e0,d1
		move	#$00e2,d2
		move	#nbecran-1,d3
plan_sui	move	d1,(a0)+
		swap	d0
		move	d0,(a0)+
		move	d2,(a0)+
		swap	d0
		move	d0,(a0)+
		add.l	#taillecran,d0
		add	#4,d1
		add	#4,d2
		dbf	d3,plan_sui
		
		move.l	#lignev,d0
		move	#dep_lignev,d1
		move	#nb_ligv-1,d2
ligne_sui	move	d1,d3
		addq	#1,d1	
		lsl	#8,d3
		or 	#1,d3
		move	d3,(a0)+
		move	#$fffe,(a0)+		;le wait
		move	#$00e0+nbecran*4,d4
		move	#$00e0+nbecran*4+2,d5
		move.l	d0,d6
		rept 	n_planv
		move	d4,(a0)+
		swap	d6
		move	d6,(a0)+
		move	d5,(a0)+
		swap	d6
		move	d6,(a0)+
		add.l	#long_ecr,d6
		add	#4,d4
		add	#4,d5
		endr
		dbf	d2,ligne_sui
		move.l	#$1000200,(a0)+
		move.l	#$fffffffe,(a0)+

		lea	coulv,a0
		lea	$dff180,a1
		move	#8-1,d0
put_coulv	move.w	(a0)+,(a1)
		addq.l	#8,a1
		dbf	d0,put_coulv	
				
		
		move.w	#$7fff,$96(a6)
		move.l	#copper_list,$80(a6)
		clr.w	$88(a6)
;****** creation palette couleur ******
	move.w	#$2981,$8e(a6)
	move.w	#$29C1,$90(a6)
	move.w	#$0038,$92(a6)
	move.w	#$00D0,$94(a6)
	move.w	#%0101001000000000,$100(a6)	;1 plan
	clr.w	$102(a6)
	clr.w	$104(a6)
	clr.w	$108(a6)
	clr.w 	$10a(a6)
	clr.w	$42(a6)
;****** dma active ******
	move.w	#$8380,$96(a6)		;copper,bitplane et blitter

w		cmp.b	#20,$dff006
		bne	w
		bsr	raster
		btst	#6,$bfe001
		bne	w

;***** fin de programme *****

restore_all:
	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
	move.l	4,a6
	lea	grname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
	jsr	-138(a6)
fin:	clr.l	d0
	rts

raster		lea	lignev,a0
		moveq	#0,d1
		move	#15-1,d0
clrv		move.l	d1,(a0)+
		move.l	d1,(a0)+
		dbra	d0,clrv		
				
		move.l	ptr_sinv,a0
		cmp.l	#fin_sinv,a0
		blt	sin_dep_ok
		lea	sinusv,a0
sin_dep_ok	move.l	a0,a1
		lea	2*v_barv(a0),a0
		move.l	a0,ptr_sinv
		move.l	a1,a0
		lea	masquev,a1	;le masque des barres
		move	#nb_barrev-1,d0
bar_suiv	cmp.l	#fin_sinv,a0
		blt	sin_ok
		lea	sinusv,a0
sin_ok		move	(a0),d1
		lea	espv*2(a0),a0
		move	d1,d2
		and	#$f,d1
		lsr	#4,d2
		add	d2,d2
		lea	barrev,a2
		lea	lignev,a3
		lea	(a3,d2),a3

		move.l	(a1),d5
		lsr.l	d1,d5		;on decale le masque
		not.l	d5

		rept	n_planv
		move.l	(a2)+,d3	;le graph
		lsr.l	d1,d3		;decalage pt pres	
		move.l	(a3),d4		;le fond
		and.l	d5,d4		;on eteint la ou il va y avoir la bar	
		or.l	d3,d4					
		move.l	d4,(a3)
		lea	long_ecr(a3),a3
		endr

		dbra	d0,bar_suiv
		rts

		section	data,data_c
		
save_dmacon	dc	0
grname		dc.b	"graphics.library",0
		even

coulv		dc	$0,$905,$505,$d05,$305,$b05,$705,$f05
lignev		dcb.b	long_ecr*n_planv,0
ptr_sinv	dc.l	sinusv
sinusv		incbin	sinv
fin_sinv
masquev		dc.l	%11111111111111110000000000000000
barrev		
		dc.l	%00001111111100000000000000000000	
		dc.l	%00110011110011000000000000000000
		dc.l	%01010101101010100000000000000000

copper_list	dcb.b	(8+8+8)*256+4
		section	bss,bss_c
ecran:		dcb.w	taillecran*nbecran/2,$00ff	;octets

