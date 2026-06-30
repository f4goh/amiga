;LE SPEED POWER PROPOSE ...
;Routine de scrolling sinusoidale .Assez bien programme .en buffer ou pas
;On peut mettre des charsets multiple de 26.Il faut alors changer la
;routine d'affichage a partir de SIN_OK ainsi que la vitesse SIN_OK_DEP
;car il faut mettre apres le sinus une identification de colonne
;necessite le fichier CHAR_SIN pour l 'exemple.Pour creer le sinus 
;on utilise COS.LST
hauteur_let=32
mot_let=2
plan_let=1
nbr_lig=255
pas_scroll=2
vitesse_sin=1  
nbr_let=49
debut		jsr	prepa_let

		jsr	sauve_tout
		
		move	#$3fff,$dff096
		move	#$3fff,$dff09a

		move	#%0001001000000000,$dff100
		clr	$dff104
		clr	$dff108
		move	#$3081,$dff08e		
		move	#$30c1,$dff090
		move	#$0038,$dff092
		move	#$00d0,$dff094

		move	#$fff,$dff182

		move	#%1100000000000000,$dff09a
		move	#%1000001100000000,$dff096
	
w		cmp.b	#20,$dff006
		bne	w
		move.l	#ecran,$dff0e0
		bsr	sinus_scroll
		btst	#6,$bfe001
		bne	w

		jsr	restaure_tout

		moveq	#0,d0
		rts

sinus_scroll	lea	buffer_scroll,a1
		lea	buffer_scroll+4*pas_scroll,a0
		move	#nbr_lig+hauteur_let-pas_scroll-1,d0
scroll_buff	move.l	(a0)+,(a1)+	
		dbra	d0,scroll_buff
		sub	#pas_scroll,compteur_vert
		bge	no_new_let
		move	#hauteur_let,compteur_vert
		move.l	pointeur_vert,a0
		tst.b	(a0)
		bne	let_vert_ok
		lea	texte_vert,a0
let_vert_ok	moveq	#0,d0
		move.b	(a0)+,d0
		move.l	a0,pointeur_vert
		add	d0,d0
		add	d0,d0
		lea	table_graph_let,a0
		move.l	(a0,d0),a0
		lea	buffer_scroll+nbr_lig*4,a1
		moveq	#hauteur_let-1,d0
in_buf		move.l	a0,(a1)+
		lea	2*mot_let*plan_let(a0),a0
		dbra	d0,in_buf
no_new_let	move.l	pointeur_sin,a1
		tst	(a1)
		bge	sin_ok_dep
		lea	sinus,a1
sin_ok_dep	lea	4*vitesse_sin(a1),a1
		move.l	a1,pointeur_sin
		lea	ecran,a6
		lea	buffer_scroll,a0
		move	#nbr_lig-1,d0
affiche_scroll	tst	(a1)
		bge	sin_ok
		lea	sinus,a1
sin_ok		move	(a1)+,d1
		move.l	(a0)+,a2
		move.l	(a2,d1),d2
		tst	(a1)+
		beq	pair
		swap	d2
		move.l	d2,d3
		move.l	d2,d4
		move.l	d2,d5
		move.l	d2,d6
		move.l	d2,d7
		move.l	d2,a2
		move.l	d2,a3
		move.l	d2,a4
		move.l	d2,a5
		movem.l	d2-d7/a2-a5,(a6)
		lea	40(a6),a6
		dbra	d0,affiche_scroll
		rts
pair		move.l	d2,d3
		move.l	d2,d4
		move.l	d2,d5
		move.l	d2,d6
		move.l	d2,d7
		move.l	d2,a2
		move.l	d2,a3
		move.l	d2,a4
		move.l	d2,a5
		movem.l	d2-d7/a2-a5,(a6)
		lea	40(a6),a6
		dbra	d0,affiche_scroll
		rts

prepa_let	lea	table_graph_let,a2
		lea	buf_let,a1
		moveq	#96,d0
lettre_sui	move.l	(a2)+,a0
		cmp.l	#0,a0
		beq	pas_graph
		move.l	a1,-4(a2)
		move	#hauteur_let-1,d1
init_let	move	#mot_let*plan_let-1,d2
long_let	move	(a0)+,(a1)+
		dbf	d2,long_let
		lea	plan_let*40-plan_let*mot_let*2(a0),a0
		dbf	d1,init_let
		move	#15-1,d1
decal_let	lea	-hauteur_let*mot_let*plan_let*2(a1),a0
		move	#hauteur_let*mot_let*plan_let-1,d2
copy_let	move	(a0)+,(a1)+
		dbf	d2,copy_let
		move	#hauteur_let-1,d2
decal_lig_let	move	#plan_let-1,d3
decal_plan_let	move	#mot_let-1,d4
mot_decal	roxr	(a0)
		lea	plan_let*2(a0),a0
		dbf	d4,mot_decal
		move	sr,d5
		btst	#0,d5
		beq	vide		
		bset	#7,-mot_let*plan_let*2(a0)
vide		lea	2-mot_let*plan_let*2(a0),a0
		dbf	d3,decal_plan_let
		lea	mot_let*plan_let*2-plan_let*2(a0),a0
		dbf	d2,decal_lig_let
		dbf	d1,decal_let
pas_graph	dbf	d0,lettre_sui
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

table_graph_let	
		dcb.l	32,0
		dc.l	c+5152,c+3040,c+3064,c+3068,0,0,0,c+3060,c+2584,c+2588,0,0,c+2596,c+3048,c+2592,0,c+3072,c+3076,c+5120,c+5124,c+5128,c+5132,c+5136,c+5140,c+5144,c+5148,c+3052,c+3056,0,0,0,c+3044,0,c,c+4
		dc.l	c+8,c+12,c+16,c+20,c+24,c+28,c+32,c+36,c+1280,c+1284,c+1288,c+1292,c+1296,c+1300,c+1304,c+1308,c+1312,c+1316,c+2560,c+2564,c+2568,c+2572,c+2576,c+2580,0,0,0,0,0,0

		even
compteur_vert	dc	hauteur_let
		even
pointeur_vert	dc.l	texte_vert
		even
texte_vert	DC.B	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		DC.B	0
		even
buffer_scroll	rept	nbr_lig+2*hauteur_let
		dc.l	buf_let
		endr

pointeur_sin	dc.l	sinus
sinus		dc	0*hauteur_let*mot_let*plan_let*2,0
		dc	1*hauteur_let*mot_let*plan_let*2,0
		dc	2*hauteur_let*mot_let*plan_let*2,0
		dc	3*hauteur_let*mot_let*plan_let*2,0
		dc	4*hauteur_let*mot_let*plan_let*2,0
		dc	5*hauteur_let*mot_let*plan_let*2,0
		dc	6*hauteur_let*mot_let*plan_let*2,0
		dc	7*hauteur_let*mot_let*plan_let*2,0
		dc	8*hauteur_let*mot_let*plan_let*2,0
		dc	9*hauteur_let*mot_let*plan_let*2,0
		dc	10*hauteur_let*mot_let*plan_let*2,0
		dc	11*hauteur_let*mot_let*plan_let*2,0
		dc	12*hauteur_let*mot_let*plan_let*2,0
		dc	13*hauteur_let*mot_let*plan_let*2,0
		dc	14*hauteur_let*mot_let*plan_let*2,0
		dc	15*hauteur_let*mot_let*plan_let*2,0
		dc	0*hauteur_let*mot_let*plan_let*2,1
		dc	1*hauteur_let*mot_let*plan_let*2,1
		dc	2*hauteur_let*mot_let*plan_let*2,1
		dc	3*hauteur_let*mot_let*plan_let*2,1
		dc	4*hauteur_let*mot_let*plan_let*2,1
		dc	5*hauteur_let*mot_let*plan_let*2,1
		dc	6*hauteur_let*mot_let*plan_let*2,1
		dc	7*hauteur_let*mot_let*plan_let*2,1
		dc	8*hauteur_let*mot_let*plan_let*2,1
		dc	9*hauteur_let*mot_let*plan_let*2,1
		dc	10*hauteur_let*mot_let*plan_let*2,1
		dc	11*hauteur_let*mot_let*plan_let*2,1
		dc	12*hauteur_let*mot_let*plan_let*2,1
		dc	13*hauteur_let*mot_let*plan_let*2,1
		dc	14*hauteur_let*mot_let*plan_let*2,1
		dc	15*hauteur_let*mot_let*plan_let*2,1
		dc	-1
		dc	-1
		dc	-1
		dc	-1

		even
sauve_intena	dc	0
		even
sauve_dmacon	dc	0
		even
sauve_irq	dc.l	0
		even
glib		dc.b	"graphics.library",0
		even

c		dcb.l	1,0
		incbin	"df0:char_sin"
buf_let		dcb.b	nbr_let*16*2*mot_let*plan_let*hauteur_let

ecran		dcb.b	10240,0
