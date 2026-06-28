./vasmm68k_mot -m68000 -Fhunk -linedebug -devpac -o kitt.o kitt.s
./vlink -bamigahunk -Bstatic -o kitt kitt.o

./vasmm68k_mot -m68000 -Fhunk -linedebug -devpac -o dessine2.o dessine2.s
./vlink -bamigahunk -Bstatic -o dessine2 dessine2.o

./vasmm68k_mot -m68000 -Fhunk -linedebug -devpac -o display.o display.s
./vlink -bamigahunk -Bstatic -o display display.o



