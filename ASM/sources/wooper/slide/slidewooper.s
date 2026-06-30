;-------------------------------------------------------------------
;-                          Le slide de Wooper	                   -
;-------------------------------------------------------------------

execbase = 4
nb_plan = 6
	section	code,code_c
start:
save_all:
	move.l	execbase,a6
	move.l	#$dff000,a6
	move.w	$dff002,save_dmacon
	or.w	#$8100,save_dmacon
;	bsr	mt_init
;	clr.b	$bfde00
;	move.b	#$82,$bfd400
;	move.b	#$37,$bfd500
;	move.b	#$81,$bfdd00
;	move.b	#$11,$bfde00
;	move.l	$78,oldirq
;	move.l	#new,$78	
;installation de la 1ere liste copper
	lea	bmap(pc),a0
	move.l	#image,d0
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
	move.w	#$83d0,$96(a6)
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
;	move.l	oldirq,$78
;	bsr	mt_end
	rts
save_dmacon:dc.w 0
grname:dc.b "graphics.library",0
	even
;------------------------------------------------------------------------
menu		cmp.b	#-1,$6(a6)
		bne.S	menu

souris		btst	#6,$bfe001
		bne	souris
		rts
;------------------------------------------------------------------------
copperlist:	dc.l	$008e2c81,$00902cc1,$00920038,$009400d0
		dc.l	$01020000,$01040000,$01080000,$010a0000
bmap		dc.l	$00e00000,$00e20000,$00e40000,$00e60000
		dc.l	$00e80000,$00ea0000,$00ec0000,$00ee0000
		dc.l	$00f00000,$00f20000,$00f40000,$00f60000
		dc.l	$01006a00
coul_img:

		dc.w	$0180,$0000,$0182,$0fff,$0184,$000f,$0186,$021f
		dc.w	$0188,$041f,$018a,$052e,$018c,$073e,$018e,$083e
		dc.w	$0190,$094e,$0192,$0a5e,$0194,$0b5e,$0196,$0c6e
		dc.w	$0198,$0d6d,$019a,$0d7d,$019c,$0d7d,$019e,$0d8c
		dc.w	$01a0,$0000,$01a2,$0000,$01a4,$0000,$01a6,$0000
		dc.w	$01a8,$0000,$01aa,$0000,$01ac,$0000,$01ae,$0000
		dc.w	$01b0,$0000,$01b2,$0000,$01b4,$0000,$01b6,$0000
		dc.w	$01b8,$0000,$01ba,$0000,$01bc,$0000,$01be,$0000
		
		dc.l	-2
;------------------------------------------------------------------------
image	incbin	"salutham.raw"
	even
end

