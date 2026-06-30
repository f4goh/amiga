;-------------------------------------------------------------------
;-                 Un petit essai de Blitter : segments            -
;-------------------------------------------------------------------

; Ceci utilise une copie A + B -> D

execbase = 4
nb_plan = 2
csize =2*24*2
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
	move.w	$dff01c,save_intena
	or.w	#$8000,save_intena 
	move.w 	#$3fff,$9a(a6)

;installation de la 1ere liste copper
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
	clr.l	$144(a6)
;dma active
	move.w	#$83c0,$96(a6)
	bsr	menu
	
restore_all
	move.l	execbase,a6
 	move.w	#$7fff,$dff096
	move.w	save_dmacon,$dff096
	move.w	save_intena,$dff09a
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
save_intena:dc.w 0
grname:dc.b "graphics.library",0
	even

;------------------------------------------ Menu
menu		move.l	#$dff000,a6
		bsr	install_lcd
vbl		move.l	$4(a6),d4
		and.l	#$1ff00,d4
		cmp.l	#$0ff00,d4
		bne	vbl
		bsr	scroll_lcd
		bsr	effacescroll
		bsr	compte
souris		
		btst	#6,$bfe001
		bne	souris
		rts

;------------------------------------install_lcd
install_lcd	move.w	#$888,coul2
		move.w	#$eee,coul4
		move.w	#$eee,coul6
w_inst_lcd1	btst	#14,$2(a6)
		bne.s	w_inst_lcd1
		move.l	#ecran,$54(a6)
		move.l	#lcd_barre,$50(a6)
		move.l	#$0fffffff,$44(a6)
		move.l	#$09f00000,$40(a6)
		move.l	#$00000000,$64(a6)
		move.w	#24*64+20,$58(a6)
w_inst_lcd2	btst	#14,$2(a6)
		bne.s	w_inst_lcd2
		move.l	#ecran+(40*50),$54(a6)
		move.l	#lcd_barre,$50(a6)
		move.w	#24*64+20,$58(a6)
		rts
scroll_lcd:
		lea	tablechars,a0
		lea	scrolltext1,a1
		moveq	#0,d0
		move.b	(a1),d0
next_text	bsr	movchars
		bsr	pause1
		bsr	pause1
		dbf	d0,next_text		
		rts
movchars	moveq	#0,d3
		move.b	-(a1),d3
		cmp.b	#"!",d3
		beq	scrollfin
		cmp.b	#" ",d3
		bne	scrollchar
		lea	lcdchars+26*csize,a4
		lea	lcdchars+(26*csize)+2*24,a5
		bsr	paste_char
		bra	movchars
scrollchar	sub.b	#"A",d3
		add.w	d3,d3
		move.w	(a0,d3),a4
		add.l	#lcdchars,a4
		move.l	a4,a5
		add.w	#24*2,a5
		bsr	paste_char
		bra	movchars
scrollfin	rts
paste_char	lea	ecran,a2
		lea	ecran+(40*256),a3
		move.l	a4,d4		;save ptr char
		move.l	a5,d5
		move.l	#24-1,d3
copiechar1	move.w	(a4)+,d1
		move.w	(a5)+,d2
		and.w	#$3c,d1	
		and.w	#$3c,d2
		lsl.w	#2,d1
		lsl.w	#2,d2
		or.b	d1,(a2)
		or.b	d2,(a3)
		add.l	#40,a2
		add.l	#40,a3
		dbf	d3,copiechar1
		bsr	move_scr_lcd1
		bsr	pause2
		lea	ecran,a2
		lea	ecran+(40*256),a3
		move.l	d4,a4
		move.l	d5,a5
		move.l	#24-1,d3
copiechar2	move.w	(a4)+,d1
		move.w	(a5)+,d2
		and.w	#$780,d1	
		and.w	#$780,d2
		lsr.w	#3,d1
		lsr.w	#3,d2
		or.b	d1,(a2)
		or.b	d2,(a3)
		add.l	#40,a2
		add.l	#40,a3
		dbf	d3,copiechar2
		bsr	move_scr_lcd1
		bsr	pause2
		lea	ecran,a2
		lea	ecran+(40*256),a3
		move.l	d4,a4
		move.l	d5,a5
		move.l	#24-1,d3
copiechar3	move.b	(a4),d1
		move.b	(a5),d2
		add.w	#2,a4
		add.w	#2,a5
		and.b	#$f0,d1	
		and.b	#$f0,d2
		or.b	d1,(a2)
		or.b	d2,(a3)
		add.l	#40,a2
		add.l	#40,a3
		dbf	d3,copiechar3
		bsr	move_scr_lcd1
		bsr	pause2
		lea	ecran,a2
		lea	ecran+(40*256),a3
		lea	lcdchars+26*csize,a4
		lea	lcdchars+(26*csize)+2*24,a5
		move.l	#24-1,d3
copiechar4	move.b	(a4),d1
		move.b	(a5),d2
		add.w	#2,a4
		add.w	#2,a5
		and.b	#$f0,d1	
		and.b	#$f0,d2
		or.b	d1,(a2)
		or.b	d2,(a3)
		add.l	#40,a2
		add.l	#40,a3
		dbf	d3,copiechar4
		bsr	move_scr_lcd1
		bsr	pause2
		rts								
;---------------------------------- deplace le scroll vers la droite
move_scr_lcd1	btst	#14,$2(a6)
		bne.s	move_scr_lcd1
		move.l	#ecran,$54(a6) 		;dest ecran
		move.l	#ecran,$50(a6)		;source 
		move.l	#$ffffffe0,$44(a6)		;masque
		move.l	#$59f00000,$40(a6)		;mode0 ror5
		move.l	#$00000000,$64(a6)		;pas masque
		move.w	#24*64+20,$58(a6)
move_scr_lcd2	btst	#14,$2(a6)
		bne.s	move_scr_lcd2
		move.l	#ecran+(40*256),$54(a6) 	;dest ecran
		move.l	#ecran+(40*256),$50(a6)		;source 
		move.w	#24*64+20,$58(a6)
		rts
;---------------------------------- effacescroll
effacescroll	btst	#14,$2(a6)
		bne.s	effacescroll
		move.l	#ecran,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0000,$66(a6)
		move.w	#256*2*64+20,$58(a6)
		rts		
;---------------------------------- table de chars
tablechars	dc.w	0,csize,2*csize,3*csize,4*csize,5*csize,6*csize
		dc.w	7*csize,8*csize,9*csize,10*csize,11*csize,12*csize
		dc.w	13*csize,14*csize,15*csize,16*csize,17*csize,18*csize,19*csize
		dc.w	20*csize,21*csize,22*csize,23*csize,24*csize,25*csize,26*csize
;---------------------------------- scrolltexts
		dc.b	"!  ALE OF FAME  "
		dc.b	"!    SPECTRE    "
		dc.b	"!    WOOPER     "
		dc.b	"!  SPEED POWER  "
		dc.b	"!    LOOPING    "
		dc.b	"!    GRETZKY    "
		dc.b	"!     FURIO     "
		dc.b	"!     MERY      "
scrolltext1	dc.b	8-1
		even
;*************************************** Compte
compte:
		move.w	#$b00,coul2
		clr.w	coul4
		moveq	#10-1,d0		;nb de numeros
		lea	chiffres,a0
next_num	move.l	(a0)+,a1
		bsr	effaceseg
		bsr	numero
		bsr	pause1
		dbf	d0,next_num		
		rts
numero		move.l	(a1)+,d1	;nb de segments ON
next_seg	move.l	(a1),a2
		jsr	(a2)
		addq	#4,a1
		dbf	d1,next_seg
		rts
asegf		lea	ecran+10,a4
		lea	segnum+(4*4*128)+(20*24),a5
		bsr	copieh
		rts
asegg		lea	ecran+(116*40)+10,a4
		lea	segnum+(4*4*128)+(2*20*24),a5
		bsr	copieh
		rts
asegc		lea	ecran+(232*40)+10,a4
		lea	segnum+(2*4*128),a5
		bsr	copieh
		rts
asega		lea	ecran+26,a4
		lea	segnum,a5
		bsr	copiev
		rts
asegb		lea	ecran+(128*40)+26,a4
		lea	segnum+(4*128),a5
		bsr	copiev
		rts
asegd		lea	ecran+(128*40)+10,a4
		lea	segnum+(2*4*128)+(20*24),a5
		bsr	copiev
		rts
asege		lea	ecran+10,a4
		lea	segnum+(3*4*128)+(20*24),a5
		bsr	copiev
		rts
copiev		btst	#14,$2(a6)
		bne.s	copiev
		move.l	a4,$54(a6) 			;dest ecran
		move.l	a4,$4c(a6)			;b
		move.l	a5,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$0dfc0000,$40(a6)
		move.l	#$00000024,$64(a6)
		move.w	#$0024,$62(a6)
		move.w	#128*64+2,$58(a6)
		rts
copieh		btst	#14,$2(a6)
		bne.s	copieh
		move.l	a4,$54(a6) 			;dest ecran
		move.l	a4,$4c(a6)			;b
		move.l	a5,$50(a6)			;source smx
		move.l	#$ffffffff,$44(a6)		;masque
		move.l	#$0dfc0000,$40(a6)
		move.l	#$00000014,$64(a6)
		move.w	#$0014,$62(a6)
		move.w	#24*64+10,$58(a6)
		rts
;---------------------------------- effaceseg
effaceseg	btst	#14,$2(a6)
		bne.s	effaceseg
		move.l	#ecran+10,$54(a6)
		move.l	#$ffffffff,$44(a6)	;masque
		move.l	#$01000000,$40(a6)	;bltcon0 et 1
		move.w	#$0014,$66(a6)
		move.w	#256*64+10,$58(a6)
		rts		
;---------------------------------- datas
;chiffres	dc.l	zero,un,deux,trois,quatre,cinq
;		dc.l	six,sept,huit,neuf
chiffres	dc.l	neuf,huit,sept,six,cinq,quatre
		dc.l	trois,deux,un,zero

zero		dc.l	6-1,asega,asegb,asegc,asegd,asege,asegf
un		dc.l	2-1,asega,asegb
deux		dc.l	5-1,asegf,asega,asegg,asegd,asegc
trois		dc.l	5-1,asegf,asega,asegg,asegb,asegc
quatre		dc.l	4-1,asege,asegg,asega,asegb
cinq		dc.l	5-1,asegf,asege,asegg,asegb,asegc
six		dc.l	5-1,asege,asegg,asegd,asegb,asegc
sept		dc.l	3-1,asegf,asega,asegb
huit		dc.l	7-1,asega,asegb,asegc,asegd,asege,asegf,asegg
neuf		dc.l	5-1,asegf,asege,asega,asegg,asegb

;---------------------------------- pause
pause1		move.l	#100,d6
w_vbl1		move.l	$4(a6),d7
		and.l	#$1ff00,d7
		cmp.l	#$12000,d7
		bne	w_vbl1
		dbf	d6,w_vbl1
		rts
pause2		move.l	#10,d7
w_vbl2		cmp.b	#-1,$6(a6)
		bne	w_vbl2
		dbf	d7,w_vbl2
		rts
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
;		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
;		dc.l	$00f00000,$00f20000
		dc.l	$01002200
		dc.w	$180,$000
		dc.w	$182
coul2		dc.w	$000
		dc.w	$184
coul4		dc.w	$000
		dc.w	$186
coul6		dc.w	$000
		
		dc.l	-2	;dans install copper
;------------------------------------------------------------------------
segnum:		incbin	df0:segnum.raw
lcdchars:	incbin	df0:lcdchars.raw
lcd_barre:	incbin	df0:lcdscrol.raw
;------------------------------------------------------------------------
ecran	dcb.b	40*256*nb_plan
	even
end

