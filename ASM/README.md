## Amiga ASM with Linux

- asm must be executable

```console
chmod +x ~/amiga/ASM/Linux/asm
chmod +x ~/amiga/ASM/Linux/vasmm68k_mot
chmod +x ~/amiga/ASM/Linux/vlink
```

- add PATH directory

```console
nano ~/.bashrc
```

- add ligne
```console
export PATH=~/amiga/ASM/Linux:$PATH
```

- Save ctrl+o , ctrl+x

- reload 
```console
source ~/.bashrc
```

- go into any asm source directory

```console
cd ~/amiga/ASM/sources/kitt
ls
kitt.s
asm kitt.s 
vasm 1.8k (c) in 2002-2021 Volker Barthelmann
vasm M68k/CPU32/ColdFire cpu backend 2.3o (c) 2002-2021 Frank Wille
vasm motorola syntax module 3.15a (c) 2002-2021 Frank Wille
vasm hunk format output module 2.13 (c) 2002-2020 Frank Wille

code(acrx2):	       34554 bytes
Compilation réussie : kitt.o et kitt générés.
```

## Amiga ASM with Windows

into cmd windows add path

```console
C:\Users\admin>setx PATH "C:\amiga\ASM\Windows;%PATH%"
C:\Users\admin>set PATH=C:\amiga\ASM\Windows;%PATH%

```

```console
cd C:\Users\<VotreNom>\amiga\ASM\Source\disk01
asm nomfic.s
```

This will generate the filename.o and exectuable filename


# Recall

[lien YT](https://www.stashofcode.fr/coder-une-cracktro-sur-amiga-2/)

# ASM avec ASM-ONE Tutorial

https://www.youtube.com/watch?v=p83QUZ1-P10

