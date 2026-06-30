# Tools
ASM_DIR := $(HOME)/amiga/ASM/Linux
VASM := $(ASM_DIR)/vasmm68k_mot
VLINK := $(ASM_DIR)/vlink

# Target
EXE := kitt
SRC := kitt.s
OBJ := kitt.o

.PHONY: all clean

all: $(EXE)

# -------------------
# ASM compile
# -------------------
$(OBJ): $(SRC)
	$(VASM) -m68000 -Fhunk -linedebug -devpac -o $(OBJ) $(SRC)

# -------------------
# LINK
# -------------------
$(EXE): $(OBJ)
	$(VLINK) -bamigahunk -Bstatic -o $(EXE) $(OBJ)

# -------------------
# CLEAN
# -------------------
clean:
	rm -f $(OBJ) $(EXE)
