# Tools
ASM_DIR := $(HOME)/amiga/ASM/Linux
VASM := $(ASM_DIR)/vasmm68k_mot
VLINK := $(ASM_DIR)/vlink

# Target
EXE := main

# Sources
SRCS := takeover.s copperlist.s playfield.s bob.s tilemap.s map.s scroll_bgnd.s plship.s enemies.s enemies_model.s shots.s collisions.s fonts.s hud.s game_state.s playing_state.s gameover_state.s
OBJS := $(SRCS:.s=.o)

.PHONY: all clean

all: $(EXE)

# Assemble .s -> .o
%.o: %.s
	$(VASM) -m68000 -Fhunk -linedebug -devpac -o $@ $<

# Link
$(EXE): $(OBJS)
	$(VLINK) -bamigahunk -Bstatic -o $@ $(OBJS)

# Clean
clean:
	rm -f $(OBJS) $(EXE)
