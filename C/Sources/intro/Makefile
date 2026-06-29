# Répertoire d'installation de vbcc
export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h

CC := vc +kick13
CFLAGS := -I$(NDK_INC) -c99 -O2
LDFLAGS := -lamiga -lauto

EXES := waitmouse moveline

.PHONY: all clean

all: $(EXES)

clean:
	rm -f *.o a.out $(EXES)

waitmouse: waitmouse.c
	$(CC) $(CFLAGS) waitmouse.c $(LDFLAGS)
	mv a.out $@

moveline: moveline.c
	$(CC) $(CFLAGS) moveline.c $(LDFLAGS)
	mv a.out $@
