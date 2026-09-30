# A500HDD — SYNTHÈSE D'INSTALLATION WD800 / WORKBENCH 1.3

Interface IDE pour Amiga 500

A500HDD est une [interface IDE](http://nuclear.mutantstargoat.com/hw/amiga/a500hdd) non autobootable pour Amiga 500.

Le système démarre depuis la disquette bootstrap, initialise le pilote IDE, monte DH0:, effectue les assignations système, puis exécute le Startup-Sequence de Workbench 1.3 présent sur le disque dur.


---

## 1. MATÉRIEL

- U1 : connecteur ATA IDE 40 broches — mâle 2×20, pas 2,54 mm
- U3 : 74HCT04 — inverseur hexadécimal, SOIC-14
- U4 : voir note ci-dessous
- U5 : 74HCT00 — quadruple NAND, SOIC-14
- U6, U7 : 74HCT08 — quadruple AND, SOIC-14
- D1 : LED rouge 0805
- C1 à C4 : condensateurs 100 nF / 0,1 µF, 0805
- R1 à R16 : résistances 68 Ω, 0805
- R17 : résistance 330 Ω, 0805

# Amiga HDD — Décodage d'adresse

## Adresse

Le décodage d'adresse utilise les lignes d'adresse A23 à A16.

| Ligne | A23 | A22 | A21 | A20 | A19 | A18 | A17 | A16 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| $DAxxxx | 1 | 1 | 0 | 1 | 1 | 0 | 1 | 0 |


### Note concernant U4

Le footprint U4 est prévu pour un connecteur mâle à angle droit de 86 broches (2×43).

Ce connecteur permet de remplacer le connecteur de bord du port d'extension de l'Amiga 500, difficile à trouver dans la bonne dimension.

Il est également possible de fabriquer un connecteur de bord personnalisé à partir de connecteurs ISA.

Pour souder directement un connecteur de bord sur le circuit :

1. Plier la rangée inférieure de broches.
2. Souder cette rangée directement sur la rangée extérieure de pastilles.
3. Faire passer une barrette simple rangée dans la rangée arrière de pastilles.
4. Cette barrette rejoint la rangée supérieure de broches droites.

---

## 2. CONFIGURATION DU DISQUE DUR

Configuration utilisée pour le WD800 :

    dh0: Device = ide.device
       /* pour Kickstart 2.04 et supérieur, supprimer la ligne suivante */
       FileSystem = L:FastFileSystem
       Unit = 0
       Flags = 0
       Surfaces = 16
       BlocksPerTrack = 63
       Reserved = 2
       Interleave = 0
       LowCyl = 1024
       HighCyl = 2047
       Buffers = 20
       GlobVec = -1
       BufMemType = 1
       DosType = 0x444F5301
       Mount = 1
    #

### Paramètres

- `Surfaces = 16` → 16 têtes
- `BlocksPerTrack = 63` → 63 secteurs par piste
- `LowCyl = 1024` → premier cylindre utilisé
- `HighCyl = 2047` → dernier cylindre utilisé
- `Unit = 0` → premier périphérique IDE
- `DosType = 0x444F5301` → système de fichiers DOS/FFS

La zone utilisée représente environ 504 Mo.

---

## 3. DÉMARRAGE SUR LA DISQUETTE BOOTSTRAP

Le système A500HDD est une interface disque dur non autobootable.

La disquette bootstrap reste donc nécessaire pour démarrer l'Amiga.

### Procédure

1. Insérer la disquette A500HDD dans `DF0:`.
2. Brancher le disque dur sur l'interface IDE.
3. Régler le cavalier du disque dur sur `MASTER`.
4. Démarrer l'Amiga 500.

Le Kickstart démarre sur DF0:, puis exécute le `Startup-Sequence` de la disquette.

---

## 4. CONTENU DE LA DISQUETTE BOOTSTRAP

La disquette doit contenir au minimum :

    DF0:
    ├── DEVS/
    │   └── ide.device
    ├── L/
    │   └── FastFileSystem
    ├── S/
    │   └── Startup-Sequence
    └── ide.ml

### Kickstart 1.3

FastFileSystem doit être présent dans :

    L:FastFileSystem

La ligne suivante doit rester dans `ide.ml` :

    FileSystem = L:FastFileSystem

### Kickstart 2.04 et supérieur

FastFileSystem est disponible en ROM dans la configuration prévue ici.

Supprimer ou commenter :

    FileSystem = L:FastFileSystem

---

## 5. MONTAGE DU DISQUE DUR

Démarrer sur la disquette bootstrap et ouvrir le CLI.

Exécuter :

    mount dh0: from ide.ml

Puis vérifier :

    info

`DH0:` doit apparaître dans la liste des volumes.

---

## 6. FORMATAGE DU DISQUE DUR

**ATTENTION : cette opération efface la zone définie dans `ide.ml`.**

Exécuter :

    cd system
    format DRIVE dh0: NAME root FFS QUICK

Configuration :

    Surfaces = 16
    BlocksPerTrack = 63
    LowCyl = 1024
    HighCyl = 2047

Capacité utilisée :

    Environ 504 Mo

---

## 7. INSTALLATION DE WORKBENCH 1.3.2

Après le formatage :

    copy df0: to dh0: all clone

Cette commande copie le contenu de la disquette vers DH0: en conservant la structure et les attributs des fichiers.

---

## 8. CORRECTION DU STARTUP-SEQUENCE SUR DH0:

Après la copie, vérifier :

    DH0:S/

On doit retrouver :

    Startup-Sequence
    Startup-Sequence.f

`Startup-Sequence.f` correspond au Startup-Sequence normal de Workbench.

Le `Startup-Sequence` sans extension correspond au script spécial utilisé pour le démarrage HDD.

### Supprimer le Startup-Sequence spécial de DH0:

    delete dh0:s/startup-sequence

### Restaurer le Startup-Sequence normal

    rename dh0:s/startup-sequence.f dh0:s/startup-sequence

---

## 9. VÉRIFICATION DU STARTUP-SEQUENCE DE DH0:

Exécuter :

    type dh0:s/startup-sequence

Il doit s'agir du Startup-Sequence normal de Workbench 1.3.2.

On doit notamment retrouver des commandes telles que :

    c:SetPatch >NIL:
    Addbuffers df0: 10
    cd c:
    ...
    LoadWB delay
    endcli >NIL:

---

## 10. STARTUP-SEQUENCE DE LA DISQUETTE DF0:

Sur la disquette bootstrap, conserver le Startup-Sequence spécial HDD.

Il doit notamment contenir :

    mount dh0: from ide.ml

Puis :

    assign sys: dh0:
    assign c: SYS:c
    assign L: SYS:l
    assign FONTS: SYS:fonts
    assign S: SYS:s
    assign DEVS: SYS:devs
    assign LIBS: SYS:libs

Et finalement :

    execute s:Startup-Sequence

Le système passe ainsi la main au Startup-Sequence présent sur DH0:.

---

## 11. FONCTIONNEMENT AU DÉMARRAGE

    Allumage de l'Amiga
            |
            v
        Kickstart 1.3
            |
            v
          DF0:
            |
            v
    DF0:S/Startup-Sequence
            |
            v
    mount dh0: from ide.ml
            |
            v
        DH0: monté
            |
            v
    assign SYS: DH0:
            |
            v
    assign C: SYS:c
    assign L: SYS:l
    assign FONTS: SYS:fonts
    assign S: SYS:s
    assign DEVS: SYS:devs
    assign LIBS: SYS:libs
            |
            v
    execute s:Startup-Sequence
            |
            v
    DH0:S/Startup-Sequence
            |
            v
      Workbench 1.3.2

---

## 12. RÔLE DES DEUX STARTUP-SEQUENCE

### Startup-Sequence de DF0:

Il sert à :

1. Initialiser le système IDE.
2. Monter DH0:.
3. Faire les assignations système.
4. Exécuter le Startup-Sequence de DH0:.

Commande principale :

    mount dh0: from ide.ml

Puis :

    execute s:Startup-Sequence

### Startup-Sequence de DH0:

Il s'agit du Startup-Sequence normal de Workbench 1.3.2.

Il poursuit le démarrage normal du système et lance Workbench.

---

## 13. DÉPANNAGE

### DH0: n'apparaît pas avec `info`

Vérifier :

- Le disque dur est correctement connecté à l'interface IDE.
- Le disque est configuré en `MASTER`.
- Le câble IDE est correctement branché.
- `ide.device` est présent dans `DF0:DEVS/`.
- Le fichier `ide.ml` contient les bons paramètres.
- Le disque est correctement détecté par l'interface.

### Erreur avec `mount`

Vérifier :

    mount dh0: from ide.ml

Puis contrôler :

    Unit = 0
    Surfaces = 16
    BlocksPerTrack = 63
    LowCyl = 1024
    HighCyl = 2047

### Workbench ne démarre pas

Vérifier :

    type dh0:s/startup-sequence

Le fichier doit être le Startup-Sequence normal de Workbench 1.3.2.

Il ne doit pas contenir le Startup-Sequence spécial qui effectue :

    mount dh0: from ide.ml

Le montage doit être effectué depuis DF0:.

---

## 14. LA DISQUETTE BOOTSTRAP RESTE NÉCESSAIRE

Ce système n'utilise pas un autoboot classique du disque dur.

La séquence est :

    DF0: Bootstrap
          |
          v
    Montage de DH0:
          |
          v
    assign SYS: DH0:
          |
          v
    execute s:Startup-Sequence
          |
          v
    Startup-Sequence de DH0:
          |
          v
    Workbench 1.3.2

La disquette bootstrap doit donc rester disponible pour démarrer le système.

---

## 15. TEMPS DE DÉMARRAGE

Le démarrage peut prendre plusieurs secondes.

L'Amiga peut rester un moment sans afficher beaucoup de choses pendant :

    Initialisation IDE
           |
           v
    Détection du disque
           |
           v
    Montage de DH0:
           |
           v
    Chargement du système
           |
           v
    Démarrage de Workbench

Cela ne signifie pas forcément que l'Amiga est bloqué.

**Ne pas couper immédiatement l'alimentation pendant cette phase.**

---

## 16. RÉSUMÉ DES COMMANDES

### Monter le disque

    mount dh0: from ide.ml

### Vérifier les volumes

    info

### Formater

    format DRIVE dh0: NAME root FFS QUICK

### Copier Workbench

    copy df0: to dh0: all clone

### Supprimer le Startup-Sequence HDD de DH0:

    delete dh0:s/startup-sequence

### Restaurer le Startup-Sequence normal

    rename dh0:s/startup-sequence.f dh0:s/startup-sequence

### Vérifier le Startup-Sequence

    type dh0:s/startup-sequence

---

## 17. CONFIGURATION FINALE

    AMIGA 500
       |
       | Port d'extension
       v
    A500HDD
       |
       | IDE
       v
    DISQUE DUR WD800
       |
       | MASTER
       v
    DH0:
       |
       +-- Workbench 1.3.2
       +-- S/Startup-Sequence
       +-- C/
       +-- DEVS/
       +-- L/
       +-- LIBS/
       +-- FONTS/
       +-- etc.

    DF0:
       |
       +-- ide.device
       +-- ide.ml
       +-- L/FastFileSystem
       +-- S/Startup-Sequence

---

## 18. IDE.ML FINAL — WD800 / WORKBENCH 1.3

    dh0: Device = ide.device
       FileSystem = L:FastFileSystem
       Unit = 0
       Flags = 0
       Surfaces = 16
       BlocksPerTrack = 63
       Reserved = 2
       Interleave = 0
       LowCyl = 1024
       HighCyl = 2047
       Buffers = 20
       GlobVec = -1
       BufMemType = 1
       DosType = 0x444F5301
       Mount = 1
    #

### Pour Kickstart 2.04 ou supérieur

Supprimer la ligne :

    FileSystem = L:FastFileSystem

---

## FIN



