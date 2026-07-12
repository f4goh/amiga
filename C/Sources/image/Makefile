# -------------------------------------------------
# vbcc Amiga
# -------------------------------------------------

export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

CC := vc

# NDK
NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h

# Projet
TARGET := image

# Sources
SRCS := $(wildcard *.c)
OBJS := $(SRCS:.c=.o)

# Répertoires include
INCLUDES := -I$(NDK_INC) \
            -I../include

# Options compilation
CFLAGS := +kick13 \
          $(INCLUDES) \
          -c99 \
          -O2

# Link
LDFLAGS := -lamiga -lauto

# Génération map
MAPFILE := $(TARGET).map

# -------------------------------------------------

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) +kick13 $(OBJS) $(LDFLAGS) -o $@ -k -m$(MAPFILE)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS) $(MAPFILE)

rebuild: clean all

.PHONY: all clean rebuild
