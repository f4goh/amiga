# Copper

# COLORxx — Palette Amiga 500 (OCS/ECS)

## 📍 Adresse

| Plage | Registres | Description |
|------|-----------|-------------|
|$DFF180–$DFF1BE|COLOR00 à COLOR31|Palette couleur (32 registres actifs) |

---

## 🎨 Description générale

Le chipset Amiga dispose de **32 registres de couleurs directs** (`COLOR00` à `COLOR31`).

Ces registres définissent une palette matérielle utilisée par :
- bitplanes (graphismes classiques),
- sprites,
- Copper (modification dynamique possible ligne par ligne).

---

## 🧠 Sélection de banque (LOCT)

Il existe **deux formats de palette** contrôlés par le bit **LOCT** :

| LOCT | Fonction |
|------|----------|
|0|Mode compatibilité (4 bits → étendus en 8 bits)|
|1|Mode pleine résolution palette (8 bits LSB indépendants)|

---

## 🎚️ Format du registre COLORxx

### LOCT = 0 (mode compatibilité)

| Bit | Fonction |
|----:|----------|
|15|T (Transparency / ZD pin)|
|14–12|0|
|11–8|Rouge (R7–R4)|
|7–4|Vert (G7–G4)|
|3–0|Bleu (B7–B4)|

➡️ Chaque composante est sur **4 bits (MSB)**  
➡️ Les bits LSB sont automatiquement dupliqués pour compatibilité

---

### LOCT = 1 (mode pleine résolution)

| Bit | Fonction |
|----:|----------|
|15–12|0|
|11–8|Rouge (R3–R0)|
|7–4|Vert (G3–G0)|
|3–0|Bleu (B3–B0)|

➡️ Ici chaque couleur est définie sur **4 bits indépendants**

---

## 🧪 Signification du bit T (Transparency)

- Bit **15** uniquement en mode LOCT = 0
- Contrôle la sortie du signal **ZD (genlock transparency)**
- Utilisé pour :
  - genlock vidéo
  - overlay vidéo externe

| T | Effet |
|--:|------|
|0|Opaque|
|1|Transparent (signal vidéo externe visible)|

---

## 🧩 Structure couleur

```
Rouge = R
Vert  = G
Bleu  = B
```

### Mode LOCT = 0

```
T RRRR GGGG BBBB
```

### Mode LOCT = 1

```
0000 RRRR GGGG BBBB
```

---

## ⚡ Points importants

- 32 couleurs simultanées en OCS/ECS (hors HAM)
- Palette modifiable en temps réel via Copper
- Le registre COLOR00 est souvent utilisé pour le fond (background)
- Le bit T n’existe que dans le mode LOCT = 0

---

## 🎯 Résumé

| Élément | Valeur |
|--------|--------|
|Nombre de couleurs | 32 |
|Profondeur | 12 bits effectifs |
|Modes | LOCT 0 / LOCT 1 |
|Bit spécial | T (transparence / genlock) |

---
# BPLCON0 ($100)

Registre de contrôle du mode d’affichage

## Vue d’ensemble

| Bit | Nom / Fonction | Description |
|-----|----------------|-------------|
| 15  | HR (High Resolution) | Active le mode haute résolution (640 points horizontaux) : 0 = désactivé, 1 = activé |
| 14–12 | Nombre de bitplanes | Définit le nombre de plans d’affichage (1 à 6, avec possibilité théorique jusqu’à 7) |
| 11  | HAM | Active le mode HAM (Hold-And-Modify, 4096 couleurs) |
| 10  | Dual Playfield | Active le mode double champ de jeu |
| 9   | Mode couleur | Active le mode couleur (fonction système d’affichage) |
| 8   | Genlock audio | Active la synchronisation audio via genlock |
| 7–4 | Inutilisés | Réservés / non utilisés |
| 3   | Light Pen | Active le support du crayon optique |
| 2   | Interlace | Active le mode entrelacé (512 lignes en PAL) |
| 1   | Genlock vidéo | Active la synchronisation vidéo externe (genlock) |
| 0   | Inutilisé | Réservé |
---

# BPLCON2 ($104) 

| Adresse | Nom     | Description |
|----------|---------|-------------|
| DFF104   | BPLCON2 | Registre de contrôle des bitplanes (nouveaux bits de contrôle) |

## Vue d’ensemble

| Bit | Fonction   | Description |
|-----|------------|-------------|
| 15  | x          | Indifférent — mais doit être forcé à 0 pour compatibilité ascendante |
| 14  | ZDBPSEL2   | Champ sur 3 bits sélectionnant le bitplane utilisé pour ZD lorsque ZDBPEN est activé. 000 = BB1, 111 = BP8 |
| 13  | ZDBPSEL1   | Bit intermédiaire du champ ZDBPSEL |
| 12  | ZDBPSEL0   | Bit faible du champ ZDBPSEL |
| 11  | ZDBPEN     | Force le signal ZD à refléter le bitplane sélectionné par ZDBPSELx. Ne désactive pas le mode ZD défini par ZDCTEN, mais s’y combine (OR logique) |
| 10  | ZDCTEN     | Force le signal ZD à refléter le bit 15 de l’entrée active de la table de couleurs haute résolution. Si désactivé, ZD revient à refléter la couleur (0) |
| 09  | KILLEHB    | Désactive le mode Extra Half-Brite |
| 08  | RDRAM=0    | Force la lecture de la table de couleurs au lieu de l’écriture |
| 07  | SOGEN=0    | Lorsque activé, force la sortie SOG à l’état haut |
| 06  | PF2PRI     | Donne la priorité au playfield 2 sur le playfield 1 |
| 05  | PF2P2      | Bit de priorité du playfield 2 (avec les sprites) |
| 04  | PF2P1      | Bit de priorité du playfield 2 |
| 03  | PF2P0      | Bit de priorité du playfield 2 |
| 02  | PF1P2      | Bit de priorité du playfield 1 (avec les sprites) |
| 01  | PF1P1      | Bit de priorité du playfield 1 |
| 00  | PF1P0      | Bit de priorité du playfield 1 |

---
# BPLCON3

| Adresse | Nom     | Description |
|----------|---------|-------------|
| DFF106   | BPLCON3 | Registre de contrôle des bitplanes (bits étendus) |

## Vue d’ensemble

| Bit | Fonction   | Description |
|-----|------------|-------------|
| 15-13 | BANKx    | Sélectionne une des huit banques de couleurs (x = 0 à 2) |
| 12-10 | PF2OFx   | Définit l’offset de la table de couleurs pour le playfield 2 en mode double playfield :<br><br>000 : aucun<br>001 : 2 (bitplane 2 affecté)<br>010 : 4 (bitplane 3 affecté)<br>011 : 8 (bitplane 3 affecté, défaut)<br>100 : 16 (bitplane 5 affecté)<br>101 : 32 (bitplane 6 affecté)<br>110 : 64 (bitplane 7 affecté)<br>111 : 128 (bitplane 8 affecté) |
| 09    | LOCT=0   | Les écritures suivantes dans la palette couleur vont vers une seconde palette 12 bits (bits RGB de poids faible). Les écritures vers la palette haute sont automatiquement recopiées pour compatibilité |
| 08    | x        | Indifférent (donc forcer à 0 pour compatibilité ascendante) |
| 07-06 | SPRESx=0 | Résolution des sprites (x = 0,1) :<br><br>00 : valeurs ECS par défaut (LORES, HIRES=140 ns, SHRES=70 ns)<br>01 : LORES (140 ns)<br>10 : HIRES (70 ns)<br>11 : SHRES (35 ns) |
| 05    | BRDRBLNK=0 | La zone de bordure est affichée en noir (non colorée). Désactivé si ECSENA est à 0 |
| 04    | BRDNTRAN=0 | La bordure n’est pas transparente (le signal ZD est bas pendant la bordure). Désactivé si ECSENA est à 0 |
| 03    | x        | Indifférent (forcer à 0 pour compatibilité ascendante) |
| 02    | ZDCLKEN=0 | Le signal ZD sort une horloge 14 MHz synchronisée avec la vidéo. Si activé, désactive les autres fonctions ZD. Désactivé si ECSENA est à 0 |
| 01    | BRDSPRT=0 | Active les sprites en dehors de la fenêtre d’affichage. Désactivé si ECSENA est à 0 |
| 00    | EXTBLKEN=0 | Rend la sortie BLANK programmable au lieu de la décode interne fixe. Désactivé si ECSENA est à 0 |
---
# BPLxPT (pointeurs de bitplanes)

Les registres **BPLxPT** (où x = 1 à 6) sont les pointeurs des bitplanes (plans de bits).  
Ils indiquent l’adresse mémoire de chaque plan d’affichage.

Chaque pointeur est divisé en deux registres :
- **BPLxPTH** : partie haute (High)
- **BPLxPTL** : partie basse (Low)

Il existe donc 6 bitplanes maximum, chacun avec son pointeur.

---

## Adresses des registres

| Bitplane | Registre High | Adresse | Registre Low | Adresse |
|----------|--------------|---------|--------------|---------|
| BPL1     | BPL1PTH      | $E0     | BPL1PTL      | $E2     |
| BPL2     | BPL2PTH      | $E4     | BPL2PTL      | $E6 |
| BPL3     | BPL3PTH      | $E8     | BPL3PTL      | $EA |
| BPL4     | BPL4PTH      | $EC     | BPL4PTL      | $EE |
| BPL5     | BPL5PTH      | $F0     | BPL5PTL      | $F2 |
| BPL6     | BPL6PTH      | $F4     | BPL6PTL      | $F6 |

---

## Rôle

Chaque registre BPLxPT contient l’adresse de départ en mémoire du bitplane correspondant.

- BPL1 → bitplane 1
- BPL2 → bitplane 2
- ...
- BPL6 → bitplane 6

Ces pointeurs sont utilisés par le chipset pour lire les données d’affichage ligne par ligne.

---

## Remarque

- Les pointeurs doivent être alignés correctement en mémoire
- Ils sont généralement mis à jour par le CPU ou le Copper pour les effets graphiques (scrolling, split screens, etc.)

---
# COPCON

| Adresse | Nom    | Description |
|----------|--------|-------------|
| DFF02E   | COPCON | Registre de contrôle du coprocesseur |

## Vue d’ensemble

Ce registre sur 1 bit permet de contrôler l’accès du coprocesseur (Copper) au matériel du Blitter.  
Il est remis à zéro au reset matériel, empêchant ainsi l’accès du coprocesseur au Blitter par défaut.

## Bits

| Bit | Nom    | Fonction |
|-----|--------|----------|
| 01  | CDANG  | Mode « danger » du coprocesseur |

### CDANG (bit 01)
- Si **1** : permet au coprocesseur d’accéder à tous les registres RGA  
- Si **0** : accès limité aux registres (ex. zone restreinte à DFF07E selon les cas matériels)

### Remarques
- Au démarrage (power-on reset), ce bit est toujours à 0
- Sur anciens circuits, le comportement d’accès peut être encore plus limité
- Voir aussi le registre **VPOSR** pour les interactions liées

---
# COP1LCH / COP1LCL

| Adresse | Nom      | Description |
|----------|----------|-------------|
| DFF080   | COP1LCH  | Registre de location du coprocesseur 1 (bits de poids fort) |
| DFF082   | COP1LCL  | Registre de location du coprocesseur 1 (bits de poids faible) |

## Vue d’ensemble

Ces registres contiennent une adresse de saut (jump address) utilisée par le coprocesseur (Copper).  
Ils forment ensemble un pointeur sur 20 bits vers une liste d’instructions Copper.

Voir **COPINS** pour le fonctionnement détaillé.

---

# COP2LCH / COP2LCL

| Adresse | Nom      | Description |
|----------|----------|-------------|
| DFF084   | COP2LCH  | Registre de location du coprocesseur 2 (bits de poids fort) |
| DFF086   | COP2LCL  | Registre de location du coprocesseur 2 (bits de poids faible) |

## Vue d’ensemble

Ces registres contiennent également une adresse de saut pour une seconde liste d’instructions Copper.
Ils fonctionnent comme COP1LC mais pour un second flux d’exécution.

---

# COPINS

| Adresse | Nom     | Description |
|----------|---------|-------------|
| DFF08C   | COPINS  | Registre fictif d’identification de lecture d’instruction du coprocesseur |

## Vue d’ensemble

COPINS n’est pas un registre réel stocké en mémoire : il représente les accès internes du coprocesseur lorsqu’il lit ses instructions.

Le coprocesseur exécute en boucle des cycles d’instructions de 2 mots, de trois types :

- MOVE : transfert de données immédiat vers un registre
- WAIT : attente jusqu’à une position du faisceau vidéo
- SKIP : saut conditionnel selon la position du faisceau

---

## Structure des instructions

Chaque instruction est composée de deux mots :

- IR1 : premier mot d’instruction
- IR2 : second mot d’instruction

### MOVE
- Transfert immédiat vers une destination (DA)
- Le champ DA est chargé en IR1 et utilisé en IR2

### WAIT
- Attend que la position du faisceau vidéo soit atteinte ou dépassée
- Empêche le coprocesseur d’utiliser le bus tant que la condition n’est pas vraie

### SKIP
- Ignore l’instruction suivante si la condition est remplie

---

## Bits importants

| Bit | Nom | Fonction |
|-----|-----|----------|
| VP  | Vertical Position | Comparaison de position verticale du faisceau |
| HP  | Horizontal Position | Comparaison de position horizontale |
| VE  | Vertical Enable | Active le masque de comparaison verticale |
| HE  | Horizontal Enable | Active le masque de comparaison horizontale |
| BFD | Blitter Finished Disable | Ignore le signal de fin du Blitter pour les WAIT/SKIP |

---

## Fonctionnement général du Copper

- Machine à 2 cycles
- Accès bus uniquement sur cycles mémoire impairs
- Priorité sur le Blitter et le CPU
- Chaque instruction nécessite 2 mots et plusieurs cycles mémoire

---

## Registres de saut

- **COP1LC** et **COP2LC** sont des pointeurs 20 bits vers le programme Copper
- Ils sont chargés dans le compteur de programme via les strobe COPJMP1 / COPJMP2
- COP1LC est automatiquement utilisé au début de chaque VBLANK

---

## Remarque importante

Après un reset, il est obligatoire d’initialiser au moins un registre de saut (COP1LC ou COP2LC) et de déclencher son strobe **avant d’activer le DMA Copper**, afin de garantir un état de départ déterminé.


