# Répertoire d'installation de vbcc
export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

# Choisir le NDK
NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h
#NDK_INC := $(VBCC)/NDK_3.9/Include/include.h

CC := vc +kick13
CFLAGS := -I$(NDK_INC) -c99 -O2 -I../include
LDFLAGS := -lamiga -lauto

EXES := example_00 example_01 example_02 example_03 \
         example_04 example_05 example_06 example_07

.PHONY: all clean

all: $(EXES)

clean:
	rm -f *.o a.out $(EXES)

example_00:
	$(CC) $(CFLAGS) example_00.c tilesheet.c $(LDFLAGS)
	mv a.out $@

example_01:
	$(CC) $(CFLAGS) example_01.c tilesheet.c $(LDFLAGS)
	mv a.out $@

example_02:
	$(CC) $(CFLAGS) example_02.c tilesheet.c $(LDFLAGS)
	mv a.out $@

example_03:
	$(CC) $(CFLAGS) example_03.c tilesheet.c $(LDFLAGS)
	mv a.out $@

example_04:
	$(CC) $(CFLAGS) example_04.c tilesheet.c sprites.c $(LDFLAGS)
	mv a.out $@

example_05:
	$(CC) $(CFLAGS) example_05.c tilesheet.c sprites.c $(LDFLAGS)
	mv a.out $@

example_06:
	$(CC) $(CFLAGS) example_06.c tilesheet.c sprites.c $(LDFLAGS)
	mv a.out $@

example_07:
	$(CC) $(CFLAGS) example_07.c tilesheet.c sprites.c $(LDFLAGS)
	mv a.out $@
