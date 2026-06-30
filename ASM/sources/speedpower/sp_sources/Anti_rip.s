;done by Spectre:1992
;----------------------------------------------------------------
;routine qui empeche les possesseur de cartes Action Replay	|
;et Nordic Power de freezer le prg pendant son execution	|
;Cette routine a ete ripper de celle faite par Hornet/Alcatraz	|
;----------------------------------------------------------------
;mettre la routine qui doit etre appele lors de l'appui sur la carte
;a l'adresse No_rip...
install	clr.l	$60
	move.l	#nordic_power,$7c
	move.l	#$130373,$dff084
	lea	action_replay,a0
	lea	$8,a1
	move.w	#10-1,d0
action	move.l	a0,(a1)+
	dbf	d0,action
	move.l	$6c,save_vbl
	move.l	#toto,$6c
souris	btst	#6,$bfe001
	bne.s	souris
fin	move.l	save_vbl,$6c
	rts
save_vbl	dc.l	0
toto	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	(sp)+,d0-d7/a0-a6
	rte
sauve_sp	dc.l	0
sauve_intena	dc.w	0
action_replay
	move.w	#$2700,sr
	move.w	#$7fff,$dff09a
	move.w	#$2000,sr
	move.l	sp,sauve_sp
	lea	$80000,sp
	movem.l	d0-d7/a0-a6,-(sp)
	;bsr	No_rip
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	sauve_sp,sp
	move.l	$f80004,a0
	jmp	-2(a0)
bidon	rte
	dc.w	0
nordic_power
	move.l	#bidon,$7c
compare	cmp.l	#bidon,2(a7)
	bne.s	suite_nordic_power
	addq.l	#6,a7
	bra	compare
suite_nordic_power
	move.w	$1c(a6),sauve_intena
	or.w	#$8000,sauve_intena
	move.w	#$7fff,$dff09a
	move	#$2000,sr
	move.l	sp,sauve_sp
	lea	$80000,sp
	movem.l	d0-d7/a0-a6,-(sp)
	;bsr	No_rip
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	sauve_sp,sp
	move	#$2700,sr
	move.w	sauve_intena,$dff09a
	move.l	$f80004,a0
	jmp	-2(a0)
	
