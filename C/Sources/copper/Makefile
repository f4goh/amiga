# Répertoire d'installation de vbcc
export VBCC := $(HOME)/amiga/C/Linux/vbcc
export PATH := $(VBCC)/bin:$(PATH)

VC := vc

# Choisir le NDK
NDK_INC := $(VBCC)/NDK_1.3/Includes1.3/include.h
#NDK_INC := $(VBCC)/NDK_3.9/Include/include.h

# Nom de l'exécutable
TARGET := copper

# Tous les fichiers .c du projet
SRCS := $(wildcard *.c)

# Options du compilateur
CFLAGS := +kick13 -I$(NDK_INC)
LIBS := -lamiga -lauto

all: $(TARGET)

$(TARGET): $(SRCS)
	$(VC) $(CFLAGS) $(SRCS) $(LIBS)
	mv a.out $(TARGET)

clean:
	rm -f $(TARGET) a.out

rebuild: clean all

.PHONY: all clean rebuild
