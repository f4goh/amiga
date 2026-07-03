# Répertoire d'installation de vbcc
export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

# Outils
VC := vc
VASM := $(HOME)/amiga/ASM/Linux/vasmm68k_mot

# NDK
NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h

CFLAGS := +kick13 -I$(NDK_INC)
VASMFLAGS := -m68000 -Fhunk -linedebug -devpac
LIBS := -lamiga -lauto

# Nom de l'exécutable
TARGET := example2

# Sources
CSRCS := $(wildcard *.c)
SSRCS := $(wildcard *.s)

# Objets
COBJS := $(CSRCS:.c=.o)
SOBJS := $(SSRCS:.s=.o)
OBJS := $(COBJS) $(SOBJS)

# Listings assembleur générés depuis les .c
ASMS := $(CSRCS:.c=.asm)

all: $(TARGET) $(ASMS)

# Génère le listing assembleur du C
%.asm: %.c
	$(VC) $(CFLAGS) -S $< -o $@

# Compile le C en objet
%.o: %.c
	$(VC) $(CFLAGS) -c $< -o $@

# Assemble le .s
%.o: %.s
	$(VASM) $(VASMFLAGS) -o $@ $<

# Édition de liens
$(TARGET): $(OBJS)
	$(VC) $(CFLAGS) $(OBJS) $(LIBS) -o $@

clean:
	rm -f *.o *.asm $(TARGET) a.out

rebuild: clean all

.PHONY: all clean rebuild
