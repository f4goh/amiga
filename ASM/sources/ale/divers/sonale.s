;    routine de son 
AudLoc0=$DFF0A0	
AudLen0=$DFF0A4
AudPer0=$DFF0A6
AudVol0=$DFF0A8
SoundLength=47270
SampleFreq=24000
IntEnaW=$DFF09A
DmaConW=$DFF096
drb1=$BFE101  
ddrb1=$BFE301
touche=$BFE001

start:	jsr play
	rts
play:
	MOVE.L	 #buffer,AudLoc0	
	MOVE.L 	#buffer,AudLoc0+16	
	MOVE 	#SoundLength,D0	
	LSR 	#1,D0		
	MOVE 	d0,AudLen0	
	MOVE 	d0,AudLen0+16	
	MOVE 	#64,AudVol0	
	MOVE 	#64,AudVol0+16
	BSR 	convertir	
	MULU 	#10,D0 
	MOVE 	d0,AudPer0
	MOVE 	d0,AudPer0+16
	MOVE 	#$8203,DmaConW	
wait:	BTST 	#6,touche	
	BNE.S 	wait
	MOVE 	#3,DmaConW
	RTS

convertir:
	MOVE.L 	#SampleFreq,D0
	MOVE.L 	#715909,D3	
	DIVU 	D0,D3		
	LSR 	#1,D3		
	CLR.L 	D0		
	ADDX 	D3,D0		
	RTS
		
buffer:	incbin"df0:effet2"

END
