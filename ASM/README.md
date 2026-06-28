## Amiga ASM with Linux

- asm must be executable

```console
chmod +x ~/amiga/ASM/Linux/asm
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
cd ~/amiga/C/Sources/disk01

asm nomfic.s
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

