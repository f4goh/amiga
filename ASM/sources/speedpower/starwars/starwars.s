;LES RIP'S CODE DU SPEED POWER......
;La routine de scrolling a la STARWARS de KEFRENS.C'est chouette et ca peut 
;se transferer sur ST (ya que TCB qu'il l'a fait...).On peut modifier la 
;vitesse du scroll,les charsets (KEF_CHAR),le retrecissement(rout RETRECIT)
;le plus dur ,c'est la copper list a modifier mais ca se fait (r CALC_PTR)
;necessite les fichiers KEF_AST,KEF_CHAR,KEF_MATH pour l'exemple.
;A noter la technique de retrecissemnt au BLITTER...
;
;IMPORTANT :ELLE NE MARCHE PAS 2 FOIS DE SUITE ..( FAIT CHIER DE CHERCHER)


		section	code,code_c

		jsr	calc_ptr
		jsr	protege_texte
		move.l	#scr_car,d0	;on oublie rien.....
		move	d0,copper_list+6
		swap	d0
		move	d0,copper_list+2

		jsr	 sauve_tout

		move.w	#$7FFF,$DFF09A
		move.w	#$7FFF,$DFF096
		move	#%0001001000000000,$dff100
		move	#$2981,$dff08e
		move	#$29c1,$dff090
		move	#$0038,$dff092
		move	#$00d0,$dff094
		move.l	#copper_list,$DFF080
		move.w	#0,$DFF088
		move.w	#%1000001111000000,$DFF096
		move.w	#%1000000000000000,$DFF09A

w		cmp.b	#20,$dff006
		bne	w	
		bsr	scr_gen
		bsr	generique
		bsr	transforme
		btst	#6,$BFE001
		bne.s	w

		jsr	restaure_tout

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

generique	sub.w	#1,compteur16
		beq	new_ligne
		rts
new_ligne	clr.w	d6
		move.w	#$10,compteur16
		move.l	#$13,d7
boucle_lettre	clr.l	d0
		move.l	adr_lettre,a0
		move.w	(a0)+,d0
		cmp.w	#$FFFF,d0
		bne	pas_fin_texte
		lea	texte_adr,a0
		move.w	(a0)+,d0
pas_fin_texte	move.l	a0,adr_lettre
		add.l	#c,d0
		clr.l	d1
		move.w	d6,d1
		add.l	#scr_car+256*40,d1
		bsr	wb
		move.w	#$9F0,$DFF040
		move.w	#0,$DFF042
		move.l	#$FFFFFFFF,$DFF044
		move.l	d0,$DFF050
		move.l	d1,$DFF054
		move.w	#$26,$DFF064
		move.w	#$26,$DFF066
		move.w	#$3C1,$DFF058		;16*16
		add.w	#2,d6
		dbra	d7,boucle_lettre
		rts

wb		btst	#14,$DFF002
		bne.s	wb
		rts

scr_gen		bsr	wb
		move.w	#$9F0,$DFF040
		move.w	#0,$DFF042
		move.l	#$FFFFFFFF,$DFF044
		move.l	#scr_car+21*40,$DFF050
		move.l	#scr_car+20*40,$DFF054
		move.w	#0,$DFF064
		move.w	#0,$DFF066
		move.w	#$3E94,$DFF058
		rts

transforme	move.l	#$F6,d0
		clr.l	d1
		clr.l	d2
chaque_ligne	add.w	pas,d1	;ca c'est un pas mais ????(16)
		cmp.w	#$1000,d1	;4096 pour y aller tous les 16
		blt	pas_bon_bloc
		bsr	retrecit
		sub.w	#$1000,d1	; pour le remettre a zero
pas_bon_bloc	dbra	d0,chaque_ligne
		rts


retrecit	clr.l	d5
		move.w	compteur9,d5
		lea	retrec,a0	;c'est ca qu'est important
		asl.w	#2,d5
		move.l	0(a0,d5.w),d4	;modulo variable (ligne se retrecit)
		move.l	d0,d7		;chaque ligne
		mulu	#$28,d7
		add.l	#scr_car,d7
		bsr	wb
		move.w	#$19F0,$DFF040	;elle est decale d '1
		move.w	#0,$DFF042
		move.l	#$FFFFFFFF,$DFF044
		move.l	d7,$DFF050	;la ligne reste au meme endroit
		move.l	d7,$DFF054
		move.w	d4,$DFF064
		move.w	d4,$DFF066	;meme modulo
		swap	d4
		move.w	d4,$DFF058	;taille dubloc
		add.w	#$26,d7		;plus 38 on se met a droite de la ligne
		bsr	wb
		move.w	#2,$DFF042	;decroissant
		move.l	d7,$DFF050
		move.l	d7,$DFF054
		move.w	d4,$DFF058	;on recommence mais a droite
		add.w	#1,compteur9
		cmp.w	#9,compteur9	;il y a 10 retrecissement possible
		ble	lbC002B8A
		clr.w	compteur9
lbC002B8A	rts			;J'AI COMPRIS.....
			;little fichier (le truc important)

protege_texte	lea	texte,a0
		lea	texte_adr,a1
		move.l	a1,$47580		;sert a rien
lbl2		clr.l	d0
		move.b	(a0)+,d0
		cmp.b	#$FF,d0
		beq	lbC0001DC
		cmp.b	#$20,d0
		bne	lbC0001B4
		move.w	#$5B,d0
lbC0001B4	sub.b	#$41,d0
		clr.w	d1
lbl1		cmp.b	#$14,d0
		blt	lbC0001D0
		sub.b	#$14,d0
		add.w	#$258,d1
		jmp	lbl1
lbC0001D0	asl.w	#1,d0
		add.w	d1,d0
		move.w	d0,(a1)+
		jmp	lbl2
lbC0001DC	move.w	#$FFFF,(a1)+
		rts

calc_ptr	lea	ptr_plancher,a0
		move.w	#$ABE1,d7	;wait de la ligne du depart
		move.w	#$100,d6
		move.l	#$FF,d1
lbC002BCE	move.l	d6,d3
		and.l	#$1FF,d3
		move.w	d7,(a0)+
		move.w	#$FFFE,(a0)+	;le wait
		move.l	d3,d0		;
		bsr	lbC002C1E	;
		move.w	d0,d5		;
		move.w	#$182,(a0)+	;
		move.w	d0,d5		;
		asr.w	#4,d5		;
		move.w	d5,(a0)		;la couleur bleu
		and.w	#15,(a0)+	;
		mulu	#$28,d0		;
		add.l	#scr_car,d0	;j'ai rajoute ca
		move.w	#$E0,(a0)+	;le pointeur haut
		swap	d0
		move.w	d0,(a0)+	;l'adresse
		move	#$e2,(a0)+	;le ptr bas
		swap	d0
		move	d0,(a0)+	;l'adresse

		add.w	#$100,d7	
		cmp.w	#$A5,d6
		beq	lbC002C0C
		dbra	d6,lbC002BCE
lbC002C0C	;move.w	#$100,(a0)+
		;move.w	#$200,(a0)+
		move.w	#$FFFF,(a0)+
		move.w	#$FFFE,(a0)+
		rts

lbC002C1E	lea	table_calc,a1
		rol.l	#1,d0
		add.l	d0,a1
		move.w	(a1),d0
		muls	d1,d0
		divs	#$7530,d0
		rts

		section	data,data_c

copper_list	dc.w	$00e0,0,$00e2,0
ptr_plancher	dcb.w	260*(2+2+2+2),0	;wait + move couleur +2 move ptr

pas		dc	2048		;????????
compteur16	dc	16
compteur9	dc	9		;fantastiq j'ai meme les compteurs

adr_lettre	dc.l	texte_adr

texte		dc.b	" IL Y A LONGTEMPS DE"
		dc.b	"  CELA   DANS   UNE "
		dc.b	" GALAXIE  TRES  TRES"
		dc.b	"      LOINTAINE     "
		dc.b	"                    "
		dc.b	"         LE         "
		dc.b	"     SPEED POWER    "
		dc.b	"                    "
		dc.b	"   DE     PROFECY   "
		dc.b	" RIPPA LA ROUTINE DE"
		dc.b	"        KEFRENS     "
		dc.b	"                    "
fin_texte	dc.b	-1

c		incbin	"kef_char"

retrec		incbin	"kef_ast"

table_calc	incbin	"kef_math"

texte_adr	dcb.w	fin_texte-texte,0	
scr_car		dcb.b	10240,0

