# DCC - Amiga Workbench 1.3

- Copier le répertoire DICE dans la racine de dh0:

## Configuration de DICE dans s:startup-config

```console
assign dcc: dh0:dice
assign dtmp: dcc:dtmp
assign dinclude: dcc:dinclude
assign dlib: dcc:dlib
path dcc:bin add
setenv dccopts -1.3
```

- Redémarrer l'amiga

## Compiler hello.c

Pour compiler le fichier `hello.c` :

```console
dcc hello.c -o hello
```

