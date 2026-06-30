;-------------------------------------------------------------------
;-            L'ULTIME DERNIER SCROLL CODE PAR ALE OF FAME  	   -
;-               Car pour moi les scrolls me font chier		   -
;-------------------------------------------------------------------

; defintion de la fenetre copper = 46 moves * 216 lignes de haut
; ce qui correspond a 46 * 27

execbase = 4
nb_plan = 1

	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon


;installation de la 1ere liste copper
	bsr	install_copper_scroll
	lea	bmap(pc),a0
	move.l	#ecran,d0
	moveq	#nb_plan-1,d1
plan_suivant	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#40*256,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
;copper initialise
	move.w	#$7fff,$96(a6)
	move.l	#copperlist,$80(a6)
	clr.w	$88(a6)
;dma active
	move.w	#$82c0,$96(a6)
	bsr	menu
	
restore_all
	move.l	execbase,a6
 	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
	lea	grname,a1
	moveq	#0,d0
	jsr	-552(a6)
	move.l	d0,a0
	move.l	38(a0),$dff080
	clr.w	$dff088
	move.l	d0,a1
	jsr	-414(a6)
fin	clr.l	d0
	rts
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even

;installation de la copper scroll
install_copper_scroll
		lea	copper_dong,a0
		move.l	#$01800000,(a0)+
		move.l	#$25,d0
inst_cop_dong	move.b	d0,(a0)+
		move.b	#$31,(a0)+
		move.w	#$fffe,(a0)+
		move.l	#46-1,d1		;46 moves
cop_moves	move.l	#$01800000,(a0)+
		dbf	d1,cop_moves						
		addq.l	#1,d0
		cmp.b	#$25+216,d0
		bne	inst_cop_dong
		move.l	#$01800000,(a0)+
		move.l	#-2,(a0)

		lea	copper_dong,a0
		add.l	#6+4,a0
		move.l	#(216/2)-1,d2		;nb_lignes/2
met_coul	lea	couls_dong1,a1
		move.l	#46-1,d1
fill_mov1	move.w	(a1)+,(a0)
		add.l	#4,a0
		dbf	d1,fill_mov1
		add.l	#4,a0
		lea	couls_dong2,a1
		move.l	#46-1,d1
fill_mov2	move.w	(a1)+,(a0)
		add.l	#4,a0
		dbf	d1,fill_mov2
		add.l	#4,a0
		dbf	d2,met_coul
		rts
;------------------------------------------------------------------------
couls_dong1:
	dc.w	$f0,$f0f,$fff,$f,$f0,$f,$ff,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f
	dc.w	$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f
	dc.w	$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$cf2,$f,$f0,$f58
couls_dong2:
	dc.w	$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0
	dc.w	$f,$f0,$f,$f0,$f,$f0,$f78,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0
	dc.w	$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0,$f,$f0

;------------------------------------------------------------------------
menu
vbl		cmp.b	#-1,$dff006
		bne	vbl
		bsr	scroll_texte				
souris		
		btst	#6,$bfe001
		bne	vbl
		rts
;---------------------------------------------------------
scroll_texte	btst	#14,$2(a6)
		bne.s	scroll_texte
		move.l	#copper_dong+10,$54(a6)
		move.l	#copper_dong+10+4,$50(a6)
		move.l	#$ffffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00080008,$64(a6)
		move.w	#216*64+(46*2),$58(a6)
		rts

ici		lea	copper_dong,a0
		add.l	#6+4,a0
		move.l	#46-1,d1	;nb colonne
next_colonne	move.l	a0,a1		;dest
		add.l	#4,a0		;source
		bsr	deplace_colonne
		dbf	d1,next_colonne
		rts

deplace_colonne
		move.l	a0,a2		;source
		move.l	a1,a3		;dest
		move.l	#216-1,d0	;lignes
scrol_colonne	move.w	(a2),(a3)
		add.l	#(47*4),a2
		add.l	#(47*4),a3
		dbf	d0,scrol_colonne			
		rts


;------------------------------ ecrit un mot dans la copper
met_mot
;		lea	mot,a3
		move.l	12(a3),a2
met_mot2	lea	copper_dong,a0
		move.w	(a2)+,d6
		add.w	(a2)+,a0
paste_lettre	move.l	(a2)+,a1
		bsr	met_lettre
		sub.l	#7504,a0	;7504 je sais pas pourquoi
		dbf	d6,paste_lettre
		rts
met_lettre			;d0 d1 d2 d3 d4 d5
		clr.l	d0
		move.l	#5-1,d1
suite_ligne	move.l	#8-1,d2
		move.w	(a1)+,d3
		move.w	(a1)+,d4
		move.w	(a1)+,d5
		lsl.w	d0,d3
		lsl.w	d0,d4
		lsl.w	d0,d5
met_ligne	or.w	d3,(a0)
		addq.l	#4,a0
		or.w	d4,(a0)
		addq.l	#4,a0
		or.w	d5,(a0)
		add.l	#45*4,a0
		dbf	d2,met_ligne
		add.w	#1,d0
		dbf	d1,suite_ligne	
		rts

;------------------------------

;------------------------------


;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000
		dc.l	$01001200
copper_dong
	dcb.w	260*46*4


;		dc.l	-2	;dans install copper
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan
	even
end



