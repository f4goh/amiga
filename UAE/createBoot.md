# Création d'une disquette AmigaOS 1.3 bootable minimale

add writable_floppy_images = 1 in fs-uae file configuration
in documents/FS-UAE/Configurations

[fs-uae]
chip_memory = 1024
floppy_drive_0 = Workbench v1.3.3 rev 34.34.adf
floppy_drive_1 = $HOME/amiga/UAE/boot_prog.adf
floppy_drive_2 = $HOME/amiga/UAE/Blank-Empty.adf
floppy_drive_speed = 0
hard_drive_0 = /home/ale/amiga/C/Sources
hard_drive_1 = /home/ale/amiga/ASM/sources
keyboard_layout = fr
kickstart_file = Kickstart 1.3.rom
slow_memory = 1024
writable_floppy_images = 1

## Configuration

- DF0: = Workbench 1.3
- DF1: = Disquette vide

Ouvrir un CLI.

---

## 1. Formater la disquette

FORMAT DRIVE DF1: NAME TestBoot

Installer le bootblock :

INSTALL DF1:

---

## 2. Créer l'arborescence

MAKEDIR DF1:C
MAKEDIR DF1:S

---

## 3. Copier les commandes nécessaires

COPY C:ASSIGN  DF1:C
COPY C:ECHO    DF1:C
COPY C:EXECUTE DF1:C
COPY C:LIST DF1:C
COPY C:DIR  DF1:C
COPY C:TYPE DF1:C
COPY C:CD DF1:C

---

## 4. Créer le Startup-Sequence

ED DF1:S/Startup-Sequence

Contenu :

ASSIGN C: SYS:C
ASSIGN S: SYS:S

ECHO "Test Amiga OK"

Enregistrer et quitter :

Esc
x

---

## 5. Vérifier le fichier

TYPE DF1:S/Startup-Sequence

---

## 6. Copier le programme

Exemple :

COPY DH0:MonProg DF1:

ou

COPY DF0:MonProg DF1:

---

## 7. Démarrage automatique du programme

Modifier Startup-Sequence :

ED DF1:S/Startup-Sequence

Contenu :

ASSIGN C: SYS:C
ASSIGN S: SYS:S


MonProg

Enregistrer :

Esc
x

---

## 8. Tester

- Retirer la disquette Workbench.
- Mettre cette disquette en DF0:.
- Redémarrer.

Le programme MonProg sera exécuté automatiquement.

---

## Commandes utiles

Afficher le contenu d'un fichier :

TYPE fichier

Lister les fichiers :

LIST

Renommer un volume :

RELABEL DH1: NouveauNom

Informations sur les volumes :

INFO

A trier
https://fsck.technology/software/Commodore/Amiga/
https://cloud.amigacafe.nl/s/qrS1m7tWuKzKtz2/nl/files/

