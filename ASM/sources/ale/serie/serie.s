;essai d'une transmission serie 
 
serdat = $dff030
serper = $dff032
serdatr= $dff018
adkcon = $dff09e
adkconr= $dff010

;1200 bauds ---> 2981.95 (2982)
;3600 bauds ---> 943.31  (943)
;4800 bauds ---> 745	fnct p + 4

vitesse= 745


start:
	move.w	#vitesse,serper

	lea	text,a0
	lea	table,a1
	clr.l	d0
	clr.l	d1
	move.b	#textsize,d0

boucle:
	move.b	(a0)+,d1
	sub	#$20,d1
	mulu	#2,d1
	move.w	(a1,d1.w),serdat
	bsr	wait
	dbf	d0,boucle
	bsr	saut
	bsr	bip
	clr.l	d0
	rts

saut:
	move.w	#$8b,serdat
	bsr	wait
	move.w	#$8d,serdat
	bsr	wait
	rts
bip:
	move.w	#$87,serdat
	bsr	wait
	rts
wait:
	move.l	#0,d2
jj:
	addq	#1,d2
	cmp.l	#vitesse,d2
	bne	jj
	rts

s:
	move.w	#vitesse,serper
	move.w	#$160,d0

kk:	move.w	d0,serdat
	bsr	wait
	addq	#1,d0
	cmp.w	#$1a0,d0
	bne	kk
	bsr	saut
	rts

text:
	dc.b	"ALE OF FAME---> abcdefghijklmnopqrstuvwxyz"
fintext:
	even
textsize = fintext-text-1


;87	biiiip
;88	retour en arriere (del)
;8b	decalage en bas
;8d	retour a la ligne

table:
	dc.w	$a0	;space
	dc.w	$121	;!
	dc.w	$122	;"
	dc.w	$a3	;£
	dc.w	$124	;$
	dc.w	$a5	;%
	dc.w	$a6	;&
	dc.w	$127	;'
	dc.w	$128	;(
	dc.w	$a9	;)
	dc.w	$aa	;*
	dc.w	$12b	;+
	dc.w	$ac	;,
	dc.w	$12d	;-
	dc.w	$12e	;.
	dc.w	$af	;/

	dc.w	$130	;0
	dc.w	$b1	;1
	dc.w	$b2	;2
	dc.w	$133	;3
	dc.w	$b4	;4
	dc.w	$135	;5
	dc.w	$136	;6
	dc.w	$b7	;7
	dc.w	$b8	;8
	dc.w	$139	;9

	dc.w	$13a	;:
	dc.w	$bb	;;
	dc.w	$13c	;<
	dc.w	$bd	;=
	dc.w	$be	;>
	dc.w	$13f	;?

	dc.w	$0
	dc.w	$141	;A
	dc.w	$142	;B
	dc.w	$43	;C
	dc.w	$144	;D
	dc.w	$45	;E
	dc.w	$46	;F
	dc.w	$147	;G
	dc.w	$148	;H
	dc.w	$49	;I
	dc.w	$4a	;J
	dc.w	$14b	;K
	dc.w	$4c	;L
	dc.w	$14d	;M
	dc.w	$14e	;N
	dc.w	$4f	;O
	dc.w	$150	;P
	dc.w	$51	;Q
	dc.w	$52	;R
	dc.w	$153	;S
	dc.w	$54	;T
	dc.w	$155	;U
	dc.w	$156	;V
	dc.w	$57	;W
	dc.w	$58	;X
	dc.w	$159	;Y
	dc.w	$15a	;Z
	dc.w	0,0,0,0,0,0

	dc.w	$21	;a
	dc.w	$22	;b
	dc.w	$163	;c
	dc.w	$24	;d
	dc.w	$165	;e
	dc.w	$166	;f
	dc.w	$27	;g
	dc.w	$28	;h
	dc.w	$169	;i
	dc.w	$16a	;j
	dc.w	$2b	;k
	dc.w	$16c	;l
	dc.w	$2d	;m
	dc.w	$2e	;n
	dc.w	$16f	;o
	dc.w	$30	;p
	dc.w	$171	;q
	dc.w	$172	;r
	dc.w	$33	;s
	dc.w	$174	;t
	dc.w	$35	;u
	dc.w	$36	;v
	dc.w	$177	;w
	dc.w	$178	;x
	dc.w	$39	;y
	dc.w	$3a	;z


end
