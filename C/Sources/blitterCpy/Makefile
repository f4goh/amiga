# Répertoire d'installation de vbcc
export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

# Choisir le NDK
NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h
#NDK_INC := $(VBCC)/NDK_3.9/Include/include.h

CC := vc +kick13
CFLAGS := -I$(NDK_INC) -c99 -O2 -I../include
LDFLAGS := -lamiga -lauto

EXES := example_00 example_01

.PHONY: all clean

all: $(EXES)

clean:
	rm -f *.o a.out $(EXES)

example_00:
	$(CC) $(CFLAGS) example_00.c $(LDFLAGS)
	mv a.out $@

example_01:
	$(CC) $(CFLAGS) example_01.c tilesheet.c $(LDFLAGS)
	mv a.out $@
