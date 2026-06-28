# Répertoire d'installation de vbcc
export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

# Choisir le NDK
NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h
#NDK_INC := $(VBCC)/NDK_3.9/Include/include.h

CC := vc +kick13
CFLAGS := -I$(NDK_INC) -c99 -O2
LDFLAGS := -lamiga -lauto

EXES := playfield_ni playfield_split_ni playfield_il playfield_split_il

.PHONY: all clean

all: $(EXES)

clean:
	rm -f *.o a.out $(EXES)

playfield_ni:
	$(CC) $(CFLAGS) playfield.c tilesheet.c $(LDFLAGS)
	mv a.out $@

playfield_il:
	$(CC) $(CFLAGS) -DINTERLEAVED playfield.c tilesheet.c $(LDFLAGS)
	mv a.out $@

playfield_split_ni:
	$(CC) $(CFLAGS) -DSPLIT_SCREEN playfield.c tilesheet.c $(LDFLAGS)
	mv a.out $@

playfield_split_il:
	$(CC) $(CFLAGS) -DSPLIT_SCREEN -DINTERLEAVED playfield.c tilesheet.c $(LDFLAGS)
	mv a.out $@

