nb_plan=5
hauteurimage=256

		INCLUDE	"../Include/BareMetal.i"

;-----------------------------------------------------------

		SECTION	Code,CODE_C		

		INCLUDE	"../Include/SafeStart.i"

Main:	
        move.l	#$dff000,a6	;Ouais...
        bsr	installPlans	;installation pour un ecran 5 plans
	    bsr	active_copper	;Bon...

.WaitLoop:
        cmp.b	#-1,VHPOSR(a6)
	    bne.s	.WaitLoop
	    ;move.w	#$fff,COLOR0(a6)	;test tps machine
	    ;clr.w	COLOR0(a6)	;test tps machine 2, le retour
	
        BTST	#6,CIAAPRA		; Check for left mouse click
		BNE.B	.WaitLoop		; No click, keep testing
		RTS

installPlans
	;installation de la 1ere liste copper
	lea	bmap,a0
	move.l	#image,d0
	moveq	#nb_plan-1,d1
plan_suivant
	move.w	d0,6(a0)  ;LSB
	swap	d0
	move.w	d0,2(a0)  ;MSB
	swap	d0
	add.l	#40*hauteurimage,d0
	addq.l	#8,a0
	dbf	d1,plan_suivant
	rts

active_copper
	;copper initialise
	move.w	#$7fff,DMACON(a6)
	move.l	#copper,COP1LC(a6)
	clr.w	COPJMP1(a6)
	;dma active
	move.w	#%1000001111000000,DMACON(a6)
	rts

;********************************************************



	section		data,data_c

copper:
		dc.w	$100,$0

		dc.l	$008e2c81,$00902cc1,$00920038,$009400d0 ;DIWSTRT DIWSTOP DDFSTRT DDFSTOP
		dc.l	$01020000,$01040000,$01080000,$010a0000 ;BPLCON1 BPLCON2 BPL1MOD BPL2MOD
bmap	dc.l	$00e00000,$00e20000 ;BPL1PTH	BPL1PTL
		dc.l	$00e40000,$00e60000 ;BPL2PTH	BPL2PTL
		dc.l	$00e80000,$00ea0000 ;BPL3PTH	BPL3PTL
		dc.l	$00ec0000,$00ee0000 ;BPL4PTH	BPL4PTL
		dc.l	$00f00000,$00f20000 ;BPL5PTH	BPL5PTL
		dc.w	$2e01,$fffe
		dc.w	$0100,$5200
	    dc.w    $0180,$0000
        dc.w    $0182,$0FFF
        dc.w    $0184,$0ACD
        dc.w    $0186,$0121
        dc.w    $0188,$0120
        dc.w    $018A,$0789
        dc.w    $018C,$08AA
        dc.w    $018E,$0478
        dc.w    $0190,$0444
        dc.w    $0192,$0469
        dc.w    $0194,$0456
        dc.w    $0196,$069B
        dc.w    $0198,$0146
        dc.w    $019A,$0684
        dc.w    $019C,$047A
        dc.w    $019E,$0365

        dc.w    $01A0,$0774
        dc.w    $01A2,$0351
        dc.w    $01A4,$0135
        dc.w    $01A6,$0445
        dc.w    $01A8,$0662
        dc.w    $01AA,$09A5
        dc.w    $01AC,$0772
        dc.w    $01AE,$08A6

        dc.w    $01B0,$0167
        dc.w    $01B2,$0322
        dc.w    $01B4,$0A99
        dc.w    $01B6,$0042
        dc.w    $01B8,$0874
        dc.w    $01BA,$0474
        dc.w    $01BC,$0797
        dc.w    $01BE,$0434

		dc.l	-2
;------------------------------------------------------------------------
	even
image
	;ds.b	40*hauteurimage*nb_plan
    incbin "montagne.raw"
	even
end
