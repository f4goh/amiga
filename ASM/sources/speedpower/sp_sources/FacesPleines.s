	********************************
;	3D FACES PLEINES 
;	RIPPED FROM ANT
;	LE MOULLEC LIONEL
;	42 RUE BLERIOT 56100 LORIENT
;	MORBIHAN
;	BRETAGNE
;	TEL: 97-83-00-01
;	********************************

_LVOForbid		=	-132
_LVOPermit		=	-138
_LVOAllocMem		=	-198
_LVOFreeMem		=	-210
_LVOCloseLibrary	=	-414
_LVOOpenLibrary		=	-552

dmaconr     EQU   $002
vposr       EQU   $004


bltcon0     EQU   $040
bltcon1     EQU   $042
bltafwm     EQU   $044
bltcpt      EQU   $048
bltapt      EQU   $050
bltdpt      EQU   $054
bltsize     EQU   $058

bltcmod     EQU   $060
bltbmod     EQU   $062
bltamod     EQU   $064
bltdmod     EQU   $066

bltadat     EQU   $074

cop1lc      EQU   $080
copjmp1     EQU   $088
diwstrt     EQU   $08E
diwstop     EQU   $090
ddfstrt     EQU   $092
ddfstop     EQU   $094
dmacon      EQU   $096


bplpt       EQU   $0E0

bplcon0     EQU   $100
bplcon1     EQU   $102
bplcon2     EQU   $104
bpl1mod     EQU   $108
bpl2mod     EQU   $10A

color       EQU   $180

; autres labels

key		=	$bfec01
custom		=	$dff000
_SysBase	=	$4
chip		=	$2
clear		=	$10000

plane_x		=	352
plane_y		=	285
bpl_depth	=	2
bpl_width	=	plane_x/8
line_width	=	bpl_width*bpl_depth
modulo		=	bpl_width*(bpl_depth-1)
bpl_size	=	bpl_width*plane_y
page_size	=	line_width*plane_y

coplist_size	=	40*4

***********
wait_blt:	macro
	btst	#14,dmaconr(a5)
loop_wait_blt\@:
	btst	#14,dmaconr(a5)
	bne.s	loop_wait_blt\@
	endm

******************************************
*************  main prg  *****************
******************************************
	bsr	main_init

main_loop:
	move.l	vposr(a5),d0
	and.l	#$1ff00,d0
	cmp.l	#$f00,d0
	bne.s	main_loop
		MOVE	#$F,$DFF180

	bsr	fill_obj
	bsr	compute_sin_cos
	bsr	coor_e_to_coor_p
	bsr	move_obj
	bsr	compute_real_line_color
	bsr	clr_obj
	bsr	draw_object
	bsr	clip_screen
		MOVE	#$0,$DFF180

	move.b	key,d0		; teste le clavier
	not	d0		;
	ror.b	#1,d0		;
	cmp.b	#$45,d0		; ESC ?
	beq	init_end	;
	bra	main_loop	; non => boucle

****** effectue le flipping de page
clip_screen:
	move.l	plane_adr(pc),a0
	move.l	bpl_log2_adr(pc),plane_adr
	move.l	bpl_log_adr(pc),bpl_log2_adr
	move.l	a0,bpl_log_adr
* swap bitplanes dans la copperlist
	move.l	coplist_adr(pc),a0
	moveq	#bpl_depth-1,d0
	move.l	plane_adr(pc),d1
	add.l	#line_width,d1
loop_modify_clist1:
	addq.l	#2,a0
	swap	d1
	move.w	d1,(a0)+
	swap	d1
	addq.l	#2,a0
	move.w	d1,(a0)+
	add.l	#bpl_width,d1	
	dbf	d0,loop_modify_clist1
	rts

****** Gère le clavier pour faire bouger l'objet
move_obj:
	move.b	key,d0
	not	d0
	ror.b	#1,d0
	and.w	#$ff,d0
	cmp.w	#$3d,d0		; 7
	bne.s	not_key_7
	addq.w	#1,inc_ang_a+2
	rts
not_key_7:
	cmp.w	#$1d,d0		; 1
	bne.s	not_key_1
	subq.w	#1,inc_ang_a+2
	rts
not_key_1:
	cmp.w	#$2d,d0		; 4
	bne.s	not_key_4
	clr.w	inc_ang_a+2
	rts
not_key_4:
	cmp.w	#$3e,d0		; 8
	bne.s	not_key_8
	addq.w	#1,inc_ang_b+2
	rts
not_key_8:
	cmp.w	#$1e,d0		; 2
	bne.s	not_key_2
	subq.w	#1,inc_ang_b+2
	rts
not_key_2:
	cmp.w	#$2e,d0		; 5
	bne.s	not_key_5
	clr.w	inc_ang_b+2
	rts
not_key_5:
	cmp.w	#$3f,d0		; 9
	bne.s	not_key_9
	addq.w	#1,inc_ang_c+2
	rts
not_key_9:
	cmp.w	#$1f,d0		; 3
	bne.s	not_key_3
	subq.w	#1,inc_ang_c+2
	rts
not_key_3:
	cmp.w	#$2f,d0		; 6
	bne.s	not_key_6
	clr.w	inc_ang_c+2
	rts
not_key_6:
	cmp.w	#$f,d0		; 0
	bne.s	not_key_0
	add.w	#10,coor_z_val+2
	rts
not_key_0:
	cmp.w	#$3c,d0		; .
	bne.s	not_key_point
	sub.w	#10,coor_z_val+2
	rts
not_key_point:
	rts

****** calcul les plans de lignes a tracer
compute_real_line_color:
	lea	tab_face(pc),a0
	lea	tab_line+4(pc),a1
	lea	coor_p(pc),a2
	move.w	(a0)+,d7
	subq.w	#1,d7
loop_line_color_each_face:
	move.w	(a0)+,d0	;\
	movem.w	(a2,d0.w),d1/d2	; > coor du pt1  (x1,y1)
	move.w	(a0)+,d0	;\
	movem.w	(a2,d0.w),d3/d4	; > coor du pt2  (x2,y2)
	move.w	(a0)+,d0	;\
	movem.w	(a2,d0.w),d5/d6	; > coor du pt3  (x3,y3)
	sub.w	d1,d3		; d3= x2-x1
	sub.w	d2,d4		; d4= y2-y1
	sub.w	d1,d5		; d5= x3-x1
	sub.w	d2,d6		; d6= y3-y1
	muls	d3,d6		; d6= (y3-y1) * (x2-x1)
	muls	d4,d5		; d5= (y2-y1) * (x3-x1) 
	sub.l	d6,d5		; d5= (y2-y1)(x3-x1)-(y3-y1)(x2-x1)
	blt.s	hiden_face	; si d5<0 then goto si_face_cachee
	move.w	(a0)+,d1
	subq.w	#1,d1
	move.w	(a0)+,d2
loop_line_color_each_line:
	move.w	(a0)+,d3
	eor.w	d2,(a1,d3.w)
	dbf	d1,loop_line_color_each_line
	dbf	d7,loop_line_color_each_face
	rts
hiden_face:
	move.w	(a0)+,d0
	add.w	d0,d0
	addq.w	#2,d0
	lea	(a0,d0.w),a0
	dbf	d7,loop_line_color_each_face
	rts

****** trace les lignes de l'objet
draw_object:
	lea	tab_line(pc),a1
	lea	coor_p(pc),a2
	move.w	nb_line(pc),count_line
loop_each_face:
loop_each_line:
	move.w	(a1)+,d0
	movem.w	(a2,d0.w),d0-d1
	move.w	(a1)+,d2
	movem.w	(a2,d2.w),d2-d3
	tst.w	(a1)
	beq.s	dont_draw_this_line
	move.w	(a1),d7
	clr.w	(a1)+
	bsr	draw_line
	subq.w	#1,count_line
	bne.s	loop_each_line
	rts
dont_draw_this_line:
	addq.l	#2,a1
	subq.w	#1,count_line
	bne.s	loop_each_line
	rts

count_face:	ds.w	1
count_line:	ds.w	1

****** tranforme les coordonnees spaciales en coordonnées planes
coor_e_to_coor_p:
	lea	coor_e(pc),a0
	lea	coor_p(pc),a1
	move.w	(a0)+,d7
	subq.w	#1,d7
loop_coor_e_to_coor_p:	
	movem.w	(a0)+,d0-d2	* d0-d2 = coor e
cos_c_val:
	move.w	#0,d4	
sin_c_val:
	move.w	#0,d5
	move.w	d0,d3
	move.w	d1,d6
	muls	d5,d0
	muls	d4,d6
	sub.l	d6,d0
	add.l	d0,d0
	swap	d0
	muls	d4,d3
	muls	d5,d1
	add.l	d3,d1
	add.l	d1,d1
	swap	d1
cos_b_val:
	move.w	#0,d4
sin_b_val:
	move.w	#0,d5
	move.w	d0,d3
	move.w	d2,d6
	muls	d5,d0
	muls	d4,d6
	sub.l	d6,d0
	add.l	d0,d0
	swap	d0
	muls	d3,d4
	muls	d5,d2
	add.l	d4,d2
	add.l	d2,d2
	swap	d2
cos_a_val:
	move.w	#0,d4
sin_a_val:
	move.w	#0,d5
	move.w	d1,d3
	move.w	d2,d6
	muls	d5,d1
	muls	d4,d6
	sub.l	d6,d1
	add.l	d1,d1
	swap	d1
	muls	d3,d4
	muls	d5,d2
	add.l	d4,d2
	add.l	d2,d2
	swap	d2
coor_z_val:
	add.w	#$3a0,d2
	ext.l	d0
	ext.l	d1
	moveq	#9,d3		* détermine le point de fuite
	asl.l	d3,d0
	asl.l	d3,d1
	tst.w	d2
	beq.s	no_zero_division
	divs	d2,d0
	divs	d2,d1
no_zero_division:
	add.w	#plane_x/2,d0
	add.w	#plane_y/2,d1
	move.w	d0,(a1)+	* > d0-d1= coor p
	move.w	d1,(a1)+	*/
	dbra	d7,loop_coor_e_to_coor_p
	rts

****** trouve les cosinus et sinus
compute_sin_cos:
inc_ang_a:
	add.w	#0,ang_a+2	* des bons angles
inc_ang_b:
	add.w	#0,ang_b+2
inc_ang_c:
	add.w	#0,ang_c+2
	lea	cos_tab(pc),a0
	move.w	#$100,d6
	move.w	#$3fe,d7
ang_c:	move.w	#0,d3		; d3= angle * 2
	and.w	d7,d3		;\
	move.w	(a0,d3.w),d4	; > d4 = cos(c)
	add.w	d6,d3		;\
	and.w	d7,d3		; > d5 = sin(c)
	move.w	(a0,d3.w),d5	;/
	move.w	d4,cos_c_val+2	; put cos in ram
	move.w	d5,sin_c_val+2	; put sin in ram
ang_b:	move.w	#0,d3		; d3= angle *2
	and.w	d7,d3		;\
	move.w	(a0,d3.w),d4	; > d4 = cos b
	add.w	d6,d3		;\			
	and.w	d7,d3		; > d5 = sin b
	move.w	(a0,d3.w),d5	;/
	move.w	d4,cos_b_val+2	; put cos in ram
	move.w	d5,sin_b_val+2	; put sin in ram
ang_a:	move.w	#0,d3		; d3= angle*2
	and.w	d7,d3		;\
	move.w	(a0,d3.w),d4	; > d4= cos a
	add.w	d6,d3		;\
	and.w	d7,d3		; > d5= sin a
	move.w	(a0,d3.w),d5	;/
	move.w	d4,cos_a_val+2	; put cos in ram
	move.w	d5,sin_a_val+2	; put sin in ram
	rts

****** clipping en Y des lignes
inter_y:
	move.w	d0,d4		*\
	add.w	d2,d4		* > milieu x
	asr.w	#1,d4		*/
	move.w	d1,d5		*\
	add.w	d3,d5		* > milieu y
	asr.w	#1,d5		*/
	cmp.w	d6,d5
	bne.s	inter_y_not_found
	rts
inter_y_not_found:
	blt.s	middle_inf_y	* \ if middle_y(d5) is greater
	move.w	d4,d2		*  > than d6
	move.w	d5,d3		* /  then modify coord and loop
	bra.s	inter_y		*/
middle_inf_y:			*\
	move.w	d4,d0		* \if middle_y(d5) is less
	move.w	d5,d1		* / than d6
	bra.s	inter_y		*/ then modify coord and loop

****** clipping en X des lignes
inter_x:
	move.w	d0,d4		*\
	add.w	d2,d4		* > milieu x
	asr.w	#1,d4		*/
	move.w	d1,d5		*\
	add.w	d3,d5		* > milieu y
	asr.w	#1,d5		*/
	cmp.w	d6,d4
	bne.s	inter_x_not_found
	rts
inter_x_not_found:
	blt.s	middle_inf_x	* \ if middle_x(d4) is greater
	move.w	d4,d2		*  > than d6
	move.w	d5,d3		* /  then modify coord and loop
	bra.s	inter_x		*/
middle_inf_x:			*\
	move.w	d4,d0		* \if middle_x(d4) is less
	move.w	d5,d1		* / than d6
	bra.s	inter_x		*/ then modify coord and loop

x1:	ds.w	2
x2:	ds.w	2
save_x:	ds.w	1

****** dessine une ligne au blitter de (D0,D1) à (D2-D3)
x_min	=	0
x_max	=	plane_x-1
y_min	=	0
y_max	=	plane_y-2

draw_line:
	cmp.w	d3,d1		* clipping de la droite
	beq	line_unvisible
	blt.s	y1_less_y2
	exg	d0,d2
	exg	d1,d3
y1_less_y2:
	movem.w	d0-d3,x1
	cmp.w	#y_max,d3
	ble.s	no_inter_y_max
	cmp.w	#y_max,d1
	bgt	line_unvisible
	move.w	#y_max,d6
	bsr	inter_y
	movem.w	d4-d5,x2
	movem.w	x1(pc),d0-d3
no_inter_y_max:
	cmp.w	#y_min,d1
	bge.s	no_inter_y_min
	cmp.w	#y_min,d3
	ble	line_unvisible
	moveq	#y_min,d6
	bsr	inter_y
	movem.w	d4-d5,x1
	movem.w	x1(pc),d0-d3
no_inter_y_min:
	cmp.w	d2,d0
	ble.s	x1_less_x2
	exg	d0,d2
	exg	d1,d3
x1_less_x2:
	movem.w	d0-d3,x1
	cmp.w	#x_min,d0
	bge.s	no_inter_x_min
	cmp.w	#x_min,d2
	ble	line_unvisible
	moveq	#x_min,d6
	bsr	inter_x	
	movem.w	d4-d5,x1
	movem.w	x1(pc),d0-d3
no_inter_x_min:
	cmp.w	#x_max,d2
	ble.s	no_inter_x_max
	cmp.w	#x_max,d0
	bgt	line_vert
inter_x_max:
	move.w	#x_max,d6
	move.w	d3,save_x
	bsr	inter_x
	movem.w	d4-d5,x2
	move.w	d5,d1
	move.w	save_x(pc),d3
	bsr	line_vert
	movem.w	x1(pc),d0-d3
no_inter_x_max:

*** la ligne est visible
line_visible:
	cmp.w	d3,d1
	ble.s	d3_sup_d1
	exg	d0,d2
	exg	d1,d3
d3_sup_d1:
	addq.w	#1,d1
	sub.w	d1,d3
	sub.w	d0,d2
	bmi.s	xneg
	cmp.w	d3,d2
	bmi.s	ygtx
	moveq	#%0011011,d5
	bra.s	lineagain
ygtx:	exg	d2,d3
	moveq	#%0000111,d5
	bra.s	lineagain
xneg:	neg.w	d2
	cmp.w	d3,d2
	bmi.s	xnygtx
	moveq	#%0011111,d5
	bra.s	lineagain
xnygtx:	exg	d2,d3
	moveq	#%0001111,d5
lineagain:
	add.w	d1,d1
	add.w	d1,d1
	lea	tab_line_adr(pc),a0
	move.l	(a0,d1.w),a0
	add.l	bpl_log_adr(pc),a0
	ror.l	#4,d0
	add.w	d0,d0
	add.w	d0,a0
	swap	d0
	or.w	#$b5a,d0
	add.w	d3,d3
	add.w	d3,d3
	add.w	d2,d2
	move.w	d2,d1
	lsl.w	#5,d1
	add.w	#$42,d1

	wait_blt

	moveq	#-line_width,d6
	move.w	d6,bltcmod(a5)	
	move.w	d6,bltdmod(a5)	
	moveq	#-1,d6
	move.l	d6,bltafwm(a5)
	move.w	d3,bltbmod(a5)
	sub.w	d2,d3
	move.w	d3,d4
	bpl.s	lineover
	or.w	#$40,d5
lineover:
	sub.w	d2,d3
	move.w	d3,bltamod(a5)
	moveq	#bpl_depth-1,d3
loop_draw_line_each_bpl:
	lsr.w	#1,d7
	bcc.s	no_line_on_this_bpl
	wait_blt
	move.w	d5,bltcon1(a5)
	move.w	d0,bltcon0(a5)
	move.w	d4,bltapt+2(a5)
	move.w	#$8000,bltadat(a5)
	move.l	a0,bltcpt(a5)
	move.l	a0,bltdpt(a5)
	move.w	d1,bltsize(a5)
no_line_on_this_bpl:
	lea	bpl_width(a0),a0
	dbf	d3,loop_draw_line_each_bpl
line_unvisible:
	rts

****** routine speciale pour tracer des droites verticales
line_vert:
	cmp.w	d3,d1
	beq.s	no_line_vert
	ble.s	d1_inf_d3
	exg	d1,d3
d1_inf_d3:
	sub.w	d1,d3
	add.w	d1,d1
	add.w	d1,d1
	lea	tab_line_adr+4(pc),a0
	move.l	(a0,d1.w),a0
	lea	bpl_width-2(a0),a0
	add.l	bpl_log_adr(pc),a0
	moveq	#line_width-2,d2
	cmp.w	#3,d7
	bne.s	line_vert_not_color_3
	add.w	d3,d3
	moveq	#bpl_width-2,d2
	bra.s	draw_line_vert
line_vert_not_color_3:
	cmp.w	#2,d7
	bne.s	draw_line_vert
	lea	bpl_width(a0),a0
draw_line_vert:
	lsl.w	#6,d3
	addq.w	#1,d3
	wait_blt
	moveq	#-1,d0			* plus rapide que
	move.l	d0,bltafwm(a5)		* 'move.l #-1,bltafwm(a5)'
	move.w	d2,bltcmod(a5)
	move.w	d2,bltdmod(a5)
	clr.w	bltcon1(a5)
	move.w	#$35a,bltcon0(a5)
	move.w	#1,bltadat(a5)
	move.l	a0,bltcpt(a5)
	move.l	a0,bltdpt(a5)
	move.w	d3,bltsize(a5)
no_line_vert:
	rts

****** efface l'ecran avec le blitter et le 68000
clr_obj:
* premier effacement au 68000
	move.l	sp,save_sp
	movem.l	empty_buffer(pc),d0-a6	* met les registres à 0
	move.l	bpl_log_adr(pc),a7
	lea	page_size(a7),a7
	move.w	#32,clr_68000_counter
loop_clr_68000:
	rept	10
	movem.l	d0-a6,-(sp)
	endr
	subq.w	#1,clr_68000_counter
	bne.s	loop_clr_68000
* effacement au blitter
	lea	custom,a5
	wait_blt
	move.l	bpl_log_adr(pc),bltdpt(a5)
	clr.w	bltdmod(a5)
	move.l	#$1000000,bltcon0(a5)
	move.w	#79*64+bpl_width/2,bltsize(a5)
	move.l	d0,a5
* second effacement au 68000
	move.w	#4,clr_68000_counter
loop1_clr_68000:
	rept	10
	movem.l	d0-a6,-(sp)
	endr
	subq.w	#1,clr_68000_counter
	bne.s	loop1_clr_68000
	move.l	d0,-(sp)

	lea	custom,a5
	move.l	save_sp(pc),sp
	rts
save_sp:		dc.l	0
clr_68000_counter:	dc.l	0
empty_buffer:		dcb.l	15,0

****** remplit la totalite des plans en une seule fois
fill_obj:
	move.l	bpl_log2_adr(pc),a0
	add.l	#page_size-2,a0
	wait_blt
	moveq	#-1,d0			* > plus rapide qu'un 
	move.l	d0,bltafwm(a5)		*/  'move.l #-1,bltafwm(a5)'
	clr.w	bltcmod(a5)
	clr.w	bltdmod(a5)
	move.l	a0,bltcpt(a5)
	move.l	a0,bltdpt(a5)
	move.w	#$03aa,bltcon0(a5)
	move.w	#$0012,bltcon1(a5)
	move.w	#plane_y*bpl_depth*64+bpl_width/2,bltsize(a5)
	rts

************************************
main_init:
	move.l	(_SysBase).w,a6
	lea	custom,a5

	jsr	_LVOForbid(a6)
	move.w	#$03e0,dmacon(a5)	; all dma off except disk

* build tab_line_adr
	lea	tab_line_adr(pc),a0
	move.w	#plane_y-1,d2
	moveq	#0,d0
loop_build_tab_line:
	move.w	d0,d1
	mulu	#line_width,d1
	move.l	d1,(a0)+
	addq.w	#1,d0
	dbf	d2,loop_build_tab_line

* initialise l'ecran
	move.w	#(bpl_depth)<<12+$200,bplcon0(a5)
	clr.w	bplcon1(a5)
	clr.w	bplcon2(a5)
	move.w	#modulo,bpl1mod(a5)
	move.w	#modulo,bpl2mod(a5)
	move.l	#$1b7136d1,diwstrt(a5)
	move.l	#$3000d8,ddfstrt(a5)

* cree la copper list
	move.l	coplist_adr(pc),a0
	moveq	#bpl_depth-1,d0
	move.l	plane_adr(pc),d1
	move.w	#bplpt,d2
loop_init_clist:
	move.w	d2,(a0)+
	addq.w	#2,d2
	swap	d1
	move.w	d1,(a0)+
	swap	d1
	move.w	d2,(a0)+
	addq.w	#2,d2
	move.w	d1,(a0)+
	add.l	#bpl_width,d1	
	dbf	d0,loop_init_clist
	move.l	#$fffffffe,(a0)+
* init cmap
	lea	cmap(pc),a0
	lea	color(a5),a1
	moveq	#2<<bpl_depth-1,d0
loop_init_cmap:
	move.w	(a0)+,(a1)+
	dbf	d0,loop_init_cmap

	move.l	coplist_adr,cop1lc(a5)
	clr.w	copjmp1(a5)

	move.w	#$83c0,dmacon(a5)	; dma sprite,copper & bpl
	rts

cmap:		dc.w	0,$ff,$cc,$aa
tab_line_adr:	ds.l	plane_y

******* init end
init_end:
	move.l	(_SysBase).w,a6
	lea	grname(pc),a1		; nom de la library ds a1
	moveq	#0,d0			; version 0 (the last)
	jsr 	_LVOOpenLibrary(a6)	; lib graphique ouverte
	move.l	d0,a1			; adr de graphicbase ds a1
	move.l	38(a1),cop1lc(a5)	; chargement de l'adr de
	clr.w	copjmp1(a5)		; l'old coplist et lancement
	jsr	_LVOCloseLibrary(a6)	; lib graphique fermée

	move.w	#$83e0,dmacon(a5)	; canaux dma necessaires
	jsr 	_LVOPermit(a6)		; multi tasking autorise


fin:	moveq	#0,d0	; flag d'erreur desactive
	rts

grname:		dc.b	"graphics.library",0
		even
plane_adr:	dc.l	space1
bpl_log_adr:	dc.l	space2
bpl_log2_adr:	dc.l	space3
coplist_adr:	dc.l	space

*******************************
cos_tab:
	dc.w		    $0000,$0192,$0324,$04B6,$0647,$07D9,$096A,$0AFB
	dc.w	$0C8B,$0E1B,$0FAB,$1139,$12C8,$1455,$15E2,$176D,$18F8,$1A82
	dc.w	$1C0B,$1D93,$1F19,$209F,$2223,$23A6,$2528,$26A8,$2826,$29A3
	dc.w	$2B1F,$2C98,$2E11,$2F87,$30FB,$326E,$33DE,$354D,$36BA,$3824
	dc.w	$398C,$3AF2,$3C56,$3DB8,$3F17,$4073,$41CE,$4325,$447A,$45CD
	dc.w	$471C,$4869,$49B4,$4AFB,$4C3F,$4D81,$4EBF,$4FFB,$5133,$5269
	dc.w	$539B,$54CA,$55F5,$571D,$5842,$5964,$5A82,$5B9D,$5CB4,$5DC7
	dc.w	$5ED7,$5FE3,$60EC,$61F1,$62F2,$63EF,$64E8,$65DD,$66CF,$67BD
	dc.w	$68A6,$698C,$6A6D,$6B4A,$6C24,$6CF9,$6DCA,$6E96,$6F5F,$7023
	dc.w	$70E2,$719E,$7255,$7307,$73B5,$745F,$7504,$75A5,$7641,$76D9
	dc.w	$776C,$77FA,$7884,$7909,$798A,$7A05,$7A7D,$7AEF,$7B5D,$7BC5
	dc.w	$7C29,$7C89,$7CE3,$7D39,$7D8A,$7DD6,$7E1D,$7E5F,$7E9D,$7ED5
	dc.w	$7F09,$7F38,$7F62,$7F87,$7FA7,$7FC2,$7FD8,$7FE9,$7FF6,$7FFD
	dc.w	$7FFF,$7FFD,$7FF6,$7FE9,$7FD8,$7FC2,$7FA7,$7F87,$7F62,$7F38
	dc.w	$7F09,$7ED5,$7E9D,$7E5F,$7E1D,$7DD6,$7D8A,$7D39,$7CE3,$7C89
	dc.w	$7C29,$7BC5,$7B5D,$7AEF,$7A7D,$7A05,$798A,$7909,$7884,$77FA
	dc.w	$776C,$76D9,$7641,$75A5,$7504,$745F,$73B5,$7307,$7255,$719E
	dc.w	$70E2,$7023,$6F5F,$6E96,$6DCA,$6CF9,$6C24,$6B4A,$6A6D,$698C
	dc.w	$68A6,$67BD,$66CF,$65DD,$64E8,$63EF,$62F2,$61F1,$60EC,$5FE3
	dc.w	$5ED7,$5DC7,$5CB4,$5B9D,$5A82,$5964,$5842,$571D,$55F5,$54CA
	dc.w	$539B,$5269,$5133,$4FFB,$4EBF,$4D81,$4C3F,$4AFB,$49B4,$4869
	dc.w	$471C,$45CD,$447A,$4325,$41CE,$4073,$3F17,$3DB8,$3C56,$3AF2
	dc.w	$398C,$3824,$36BA,$354D,$33DE,$326E,$30FB,$2F87,$2E11,$2C98
	dc.w	$2B1F,$29A3,$2826,$26A8,$2528,$23A6,$2223,$209F,$1F19,$1D93
	dc.w	$1C0B,$1A82,$18F8,$176D,$15E2,$1455,$12C8,$1139,$0FAB,$0E1B
	dc.w	$0C8B,$0AFB,$096A,$07D9,$0647,$04B6,$0324,$0192,$0000,$FE6D
	dc.w	$FCDB,$FB49,$F9B8,$F826,$F695,$F504,$F374,$F1E4,$F054,$EEC6
	dc.w	$ED37,$EBAA,$EA1D,$E892,$E707,$E57D,$E3F4,$E26C,$E0E6,$DF60
	dc.w	$DDDC,$DC59,$DAD7,$D957,$D7D9,$D65C,$D4E0,$D367,$D1EE,$D078
	dc.w	$CF04,$CD91,$CC21,$CAB2,$C945,$C7DB,$C673,$C50D,$C3A9,$C247
	dc.w	$C0E8,$BF8C,$BE31,$BCDA,$BB85,$BA32,$B8E3,$B796,$B64B,$B504
	dc.w	$B3C0,$B27E,$B140,$B004,$AECC,$AD96,$AC64,$AB35,$AA0A,$A8E2
	dc.w	$A7BD,$A69B,$A57D,$A462,$A34B,$A238,$A128,$A01C,$9F13,$9E0E
	dc.w	$9D0D,$9C10,$9B17,$9A22,$9930,$9842,$9759,$9673,$9592,$94B5
	dc.w	$93DB,$9306,$9235,$9169,$90A0,$8FDC,$8F1D,$8E61,$8DAA,$8CF8
	dc.w	$8C4A,$8BA0,$8AFB,$8A5A,$89BE,$8926,$8893,$8805,$877B,$86F6
	dc.w	$8675,$85FA,$8582,$8510,$84A2,$843A,$83D6,$8376,$831C,$82C6
	dc.w	$8275,$8229,$81E2,$81A0,$8162,$812A,$80F6,$80C7,$809D,$8078
	dc.w	$8058,$803D,$8027,$8016,$8009,$8002,$8000,$8002,$8009,$8016
	dc.w	$8027,$803D,$8058,$8078,$809D,$80C7,$80F6,$812A,$8162,$81A0
	dc.w	$81E2,$8229,$8275,$82C6,$831C,$8376,$83D6,$843A,$84A2,$8510
	dc.w	$8582,$85FA,$8675,$86F6,$877B,$8805,$8893,$8926,$89BE,$8A5A
	dc.w	$8AFB,$8BA0,$8C4A,$8CF8,$8DAA,$8E61,$8F1D,$8FDC,$90A0,$9169
	dc.w	$9235,$9306,$93DB,$94B5,$9592,$9673,$9759,$9842,$9930,$9A22
	dc.w	$9B17,$9C10,$9D0D,$9E0E,$9F13,$A01C,$A128,$A238,$A34B,$A462
	dc.w	$A57D,$A69B,$A7BD,$A8E2,$AA0A,$AB35,$AC64,$AD96,$AECC,$B004
	dc.w	$B140,$B27E,$B3C0,$B504,$B64B,$B796,$B8E3,$BA32,$BB85,$BCDA
	dc.w	$BE31,$BF8C,$C0E8,$C247,$C3A9,$C50D,$C673,$C7DB,$C945,$CAB2
	dc.w	$CC21,$CD91,$CF04,$D078,$D1EE,$D367,$D4E0,$D65C,$D7D9,$D957
	dc.w	$DAD7,$DC59,$DDDC,$DF60,$E0E6,$E26C,$E3F4,$E57D,$E707,$E892
	dc.w	$EA1D,$EBAA,$ED37,$EEC6,$F054,$F1E4,$F374,$F504,$F695,$F826
	dc.w	$F9B8,$FB49,$FCDB,$FE6D

nb_point	=	8
c		=	200

coor_e:	dc.w	nb_point	* -ceci est la structure concernant
	dc.w	c,c,c		*  les coordonnees des points dans
	dc.w	c,-c,c		*  l'espace.
	dc.w	-c,-c,c		* -le nombre de points doit etre
	dc.w	-c,c,c		*  defini par "nb_point" car
	dc.w	c,c,-c		*  je m'en sers plus haut
	dc.w	c,-c,-c		* -la 1' valeur de la liste est le
	dc.w	-c,-c,-c	*  nombre de points puis la succession
	dc.w	-c,c,-c		*  des coordonnees (x,y,z)

coor_p:	ds.l	nb_point	* ceci est le buffer ou sont memorisees
				* les coordonnees apres la projection
				*  sur l'ecran
nb_line:	dc.w	12	* indique le nombre de lignes

tab_line:
	dc.w	0,4,0		*-> chaque ligne est representee par 3
	dc.w	4,8,0		* octets. les 2 premiers sont les 
	dc.w	8,12,0		* numeros des points a relier et le
	dc.w	12,0,0		* troisiemme est utilise par le
	dc.w	16,20,0		* programme pour savoir sur quel plan
	dc.w	20,24,0		* il faut la dessinner.
	dc.w	24,28,0		*- on peut facilement remarquer que 
	dc.w	28,16,0		* les numéros des points sont tous
	dc.w	0,16,0		* multipliés par 4, ceci pour ne pas 
	dc.w	4,20,0		* avoir à les multiplier au moment
	dc.w	8,24,0		* de l'accès à la coordonnée plane
	dc.w	12,28,0

tab_face:
	dc.w	6		* le nombre de faces de l'objet
	dc.w	24,20,4		* = les 3 points d'orientation
	dc.w	4		* = le nombre de côtés du polygone
	dc.w	1		* = la couleur du polygone
	dc.w	54,6,60,30	* = les lignes du polygone
	dc.w	0,16,28		*/ autre face
	dc.w	4		*-on remarque encore que les numeros
	dc.w	1		* des points sont multipliés par 4.
	dc.w	48,42,66,18	* toujours pour les mêmes raisons.
	dc.w	28,24,8		*/ autre face
	dc.w	4		*-les numéros des lignes sont eux
	dc.w	2		* par 6 pour les mêmes raisons c-a-d
	dc.w	60,12,66,36	* pour avoir un accès plus rapide
	dc.w	20,16,0		* /autre face
	dc.w	4
	dc.w	2
	dc.w	48,24,54,0
	dc.w	16,20,24	* autre face
	dc.w	4
	dc.w	3	
	dc.w	24,30,36,42
	dc.w	8,4,0		* autre face
	dc.w	4
	dc.w	3	
	dc.w	0,6,12,18

space:		dcb.b	coplist_size,0
space1:		dcb.b	page_size,0
space2:		dcb.b	page_size,0
space3:		dcb.b	page_size,0

