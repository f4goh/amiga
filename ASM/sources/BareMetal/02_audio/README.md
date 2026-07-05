# Audio

# Registres Audio et Contrôle - Amiga 500 (OCS)

| Registre | Adresse | Accès | Taille | Description |
|----------|----------|-------|---------|-------------|
| DMACON | $DFF096 | W | 16 bits | Contrôle des DMA |
| INTENA | $DFF09A | W | 16 bits | Activation des interruptions |
| ADKCON | $DFF09E | W | 16 bits | Contrôle Audio/Disk/UART |
| AUD0LC | $DFF0A0 | W | 32 bits | Adresse de début de l'échantillon du canal audio 0 |
| AUD0LEN | $DFF0A4 | W | 16 bits | Longueur de l'échantillon du canal 0 (en mots) |
| AUD0PER | $DFF0A6 | W | 16 bits | Période de lecture du canal 0 |
| AUD0VOL | $DFF0A8 | W | 16 bits | Volume du canal 0 |
| AUD0DAT | $DFF0AA | W | 16 bits | Donnée audio du canal 0 |
| AUD1LC | $DFF0B0 | W | 32 bits | Adresse de début de l'échantillon du canal audio 1 |
| AUD1LEN | $DFF0B4 | W | 16 bits | Longueur de l'échantillon du canal 1 (en mots) |
| AUD1PER | $DFF0B6 | W | 16 bits | Période de lecture du canal 1 |
| AUD1VOL | $DFF0B8 | W | 16 bits | Volume du canal 1 |
| AUD1DAT | $DFF0BA | W | 16 bits | Donnée audio du canal 1 |
| AUD2LC | $DFF0C0 | W | 32 bits | Adresse de début de l'échantillon du canal audio 2 |
| AUD2LEN | $DFF0C4 | W | 16 bits | Longueur de l'échantillon du canal 2 (en mots) |
| AUD2PER | $DFF0C6 | W | 16 bits | Période de lecture du canal 2 |
| AUD2VOL | $DFF0C8 | W | 16 bits | Volume du canal 2 |
| AUD2DAT | $DFF0CA | W | 16 bits | Donnée audio du canal 2 |
| AUD3LC | $DFF0D0 | W | 32 bits | Adresse de début de l'échantillon du canal audio 3 |
| AUD3LEN | $DFF0D4 | W | 16 bits | Longueur de l'échantillon du canal 3 (en mots) |
| AUD3PER | $DFF0D6 | W | 16 bits | Période de lecture du canal 3 |
| AUD3VOL | $DFF0D8 | W | 16 bits | Volume du canal 3 |
| AUD3DAT | $DFF0DA | W | 16 bits | Donnée audio du canal 3 |

---

## DMACON ($DFF096)

Contrôle l'activation des différents canaux DMA du chipset.

| Bit | Nom | Description |
|----:|------|-------------|
|15|SET/CLR|Bit de contrôle. 1 = positionne les bits à 1. 0 = efface les bits à 0. Les bits écrits à 0 restent inchangés.|
|14|BBUSY|État du Blitter (lecture uniquement). 1 = Blitter occupé.|
|13|BZERO|Résultat logique nul du Blitter (lecture uniquement).|
|12|—|Réservé.|
|11|—|Réservé.|
|10|BLTPRI|Priorité DMA du Blitter ("Blitter Nasty"). Lorsque ce bit est activé, le Blitter prend la priorité sur le CPU et peut monopoliser le bus mémoire.|
|9|DMAEN|Active l'ensemble des DMA (bit maître). Sans ce bit, aucun des DMA ci-dessous ne fonctionne.|
|8|BPLEN|Active le DMA des bitplanes.|
|7|COPEN|Active le DMA du Copper.|
|6|BLTEN|Active le DMA du Blitter.|
|5|SPREN|Active le DMA des sprites.|
|4|DSKEN|Active le DMA du contrôleur de disquette.|
|3|AUD3EN|Active le DMA du canal audio 3.|
|2|AUD2EN|Active le DMA du canal audio 2.|
|1|AUD1EN|Active le DMA du canal audio 1.|
|0|AUD0EN|Active le DMA du canal audio 0.|

### Exemples

| Valeur | Effet |
|--------:|-------|
|`$8001`|Active le DMA du canal audio 0 uniquement.|
|`$8201`|Active le DMA maître (`DMAEN`) et le DMA du canal audio 0.|
|`$820F`|Active le DMA maître ainsi que les quatre canaux audio.|
|`$83FF`|Active tous les DMA disponibles.|
|`$0001`|Désactive le DMA du canal audio 0.|
|`$0200`|Désactive le DMA maître (`DMAEN`).|

---

## INTENA ($DFF09A)

Active ou désactive les sources d'interruptions du chipset Amiga.

| Bit | Nom | Niveau | Description |
|----:|------|:------:|-------------|
|15|SET/CLR|—|Bit de contrôle. 1 = positionne les bits à 1 (SET). 0 = efface les bits à 0 (CLEAR). Les bits écrits à 0 restent inchangés.|
|14|INTEN|—|Activation générale des interruptions (Master Interrupt Enable). Ce bit ne génère jamais d'interruption.|
|13|EXTER|6|Interruption externe (/INT2).|
|12|DSKSYN|5|Le mot lu sur la disquette correspond à la valeur du registre DSKSYNC.|
|11|RBF|5|Le tampon de réception du port série est plein (Receive Buffer Full).|
|10|AUD3|4|Le canal audio 3 a terminé la lecture de son bloc.|
|9|AUD2|4|Le canal audio 2 a terminé la lecture de son bloc.|
|8|AUD1|4|Le canal audio 1 a terminé la lecture de son bloc.|
|7|AUD0|4|Le canal audio 0 a terminé la lecture de son bloc.|
|6|BLIT|3|Le Blitter a terminé son opération.|
|5|VERTB|3|Début du retour vertical (Vertical Blank).|
|4|COPER|3|Interruption générée par le Copper.|
|3|PORTS|2|Interruptions provenant des CIA (ports d'E/S et temporisateurs).|
|2|SOFT|1|Interruption logicielle réservée au logiciel.|
|1|DSKBLK|1|Le transfert d'un bloc disque est terminé.|
|0|TBE|1|Le tampon d'émission du port série est vide (Transmit Buffer Empty).|

### Exemples

| Valeur | Effet |
|--------:|-------|
|`$C000`|Active uniquement le bit maître INTEN.|
|`$C080`|Active les interruptions et l'interruption de fin du canal audio 0.|
|`$C020`|Active les interruptions et le Vertical Blank.|
|`$4000`|Désactive uniquement le bit maître INTEN.|
|`$0080`|Désactive l'interruption du canal audio 0.|

### Remarques

- **INTENA** active les sources d'interruptions.
- **INTREQ** est le registre utilisé pour déclencher ou acquitter les interruptions.
- Comme pour **DMACON**, le bit **15 (SET/CLR)** n'appartient pas à l'état du registre ; il indique uniquement si les bits écrits à 1 doivent être activés ou désactivés.
- Les niveaux d'interruption correspondent aux niveaux matériels du processeur **68000** (1 à 6), le niveau 7 étant réservé au signal **NMI**.

---

## ADKCON ($DFF09E)

Contrôle des fonctions Audio, Disquette et Port Série.

| Bit | Nom | Description |
|----:|------|-------------|
|15|SET/CLR|Bit de contrôle. 1 = positionne les bits à 1 (SET). 0 = efface les bits à 0 (CLEAR). Les bits écrits à 0 restent inchangés.|
|14-13|PRECOMP1-0|Précompensation d'écriture disque :<br>00 = aucune<br>01 = 140 ns<br>10 = 280 ns<br>11 = 560 ns|
|12|MFMPREC|Type de précompensation disque : 1 = MFM, 0 = GCR.|
|11|UARTBRK|Force un signal BREAK sur la sortie série (TXD maintenu à 0).|
|10|WORDSYNC|Synchronise la lecture disque sur le mot contenu dans le registre DSKSYNC.|
|9|MSBSYNC|Synchronisation sur le bit de poids fort (MSB), utilisée principalement avec le format GCR.|
|8|FAST|Sélection de la vitesse du contrôleur disque : 1 = rapide (2 µs, MFM), 0 = lente (4 µs, GCR).|
|7|USE3PN|Le canal audio 3 ne module aucun autre canal (bit sans effet pratique).|
|6|USE2P3|Le canal audio 2 module la **période** du canal audio 3.|
|5|USE1P2|Le canal audio 1 module la **période** du canal audio 2.|
|4|USE0P1|Le canal audio 0 module la **période** du canal audio 1.|
|3|USE3VN|Le canal audio 3 ne module aucun autre canal (bit sans effet pratique).|
|2|USE2V3|Le canal audio 2 module le **volume** du canal audio 3.|
|1|USE1V2|Le canal audio 1 module le **volume** du canal audio 2.|
|0|USE0V1|Le canal audio 0 module le **volume** du canal audio 1.|

### Modulation audio

| Bit | Effet |
|------|-------|
|USE0P1|Canal 0 → Période du canal 1|
|USE1P2|Canal 1 → Période du canal 2|
|USE2P3|Canal 2 → Période du canal 3|
|USE3PN|Aucun effet|
|USE0V1|Canal 0 → Volume du canal 1|
|USE1V2|Canal 1 → Volume du canal 2|
|USE2V3|Canal 2 → Volume du canal 3|
|USE3VN|Aucun effet|

### Exemples

| Valeur | Effet |
|--------:|-------|
|`$8001`|Active la modulation du volume du canal 1 par le canal 0.|
|`$8010`|Active la modulation de la période du canal 1 par le canal 0.|
|`$8005`|Active la modulation du volume des canaux 1 et 3 (0→1 et 2→3).|
|`$8140`|Active la modulation de période des canaux 2→3 et 1→2.|

### Remarques

- Comme **DMACON** et **INTENA**, le bit **15 (SET/CLR)** ne fait pas partie de l'état du registre : il détermine uniquement si les bits écrits à 1 sont activés ou désactivés.
- Les bits **USE3PN** et **USE3VN** existent uniquement pour conserver une organisation uniforme des quatre canaux ; ils n'ont aucun effet car il n'existe pas de canal audio 4.
- La modulation est réalisée matériellement par Paula et permet de produire des effets tels que la **modulation d'amplitude (AM)** et la **modulation de fréquence (FM)** sans intervention du processeur.

---

## AUDxLCH / AUDxLCL

Registres contenant l'adresse de départ de l'échantillon lu par le DMA audio.

Le pointeur est constitué de deux registres de 16 bits représentant une adresse DMA de **20 bits**.

| Adresse | Registre | Description |
|---------:|----------|-------------|
|$DFF0A0|AUD0LCH|Adresse de départ du canal 0 (bits 19..15)|
|$DFF0A2|AUD0LCL|Adresse de départ du canal 0 (bits 14..1)|
|$DFF0B0|AUD1LCH|Adresse de départ du canal 1 (bits 19..15)|
|$DFF0B2|AUD1LCL|Adresse de départ du canal 1 (bits 14..1)|
|$DFF0C0|AUD2LCH|Adresse de départ du canal 2 (bits 19..15)|
|$DFF0C2|AUD2LCL|Adresse de départ du canal 2 (bits 14..1)|
|$DFF0D0|AUD3LCH|Adresse de départ du canal 3 (bits 19..15)|
|$DFF0D2|AUD3LCL|Adresse de départ du canal 3 (bits 14..1)|

### Format de l'adresse

```
          AUDxLCH              AUDxLCL
      +-------------+---------------------------+
Adresse 19.........15 14......................1 0
      +-------------+---------------------------+-+
      | 5 bits      |        15 bits            |0|
      +-------------+---------------------------+-+
```

Le bit 0 est toujours à 0 car les échantillons sont lus sur des adresses alignées sur un mot (16 bits).

### Fonctionnement

- Ces registres définissent l'adresse de départ de l'échantillon.
- Lorsqu'un DMA audio est lancé, Paula copie cette valeur dans un pointeur interne.
- Ce pointeur interne est ensuite incrémenté automatiquement pendant la lecture.
- Les registres **AUDxLCH/LCL ne sont pas modifiés** pendant la lecture.
- Ils ne doivent être réécrits que pour lire un autre échantillon.

### Exemple

Pour un échantillon situé à l'adresse :

```
$00040000
```

```
AUD0LCH = $0008
AUD0LCL = $0000
```

En assembleur, les assembleurs 68000 autorisent généralement :

```asm
move.l  #Sample,AUD0LCH
```

ou

```asm
move.w  #Sample>>16,AUD0LCH
move.w  #Sample,AUD0LCL
```

Selon l'assembleur utilisé.

---

## AUDxLEN

Contient la longueur des données DMA du canal audio, exprimée en **mots de 16 bits**.

| Adresse | Registre | Description |
|---------:|----------|-------------|
|$DFF0A4|AUD0LEN|Longueur des données DMA du canal audio 0|
|$DFF0B4|AUD1LEN|Longueur des données DMA du canal audio 1|
|$DFF0C4|AUD2LEN|Longueur des données DMA du canal audio 2|
|$DFF0D4|AUD3LEN|Longueur des données DMA du canal audio 3|

### Format

| Bits | Description |
|------|-------------|
|15..0|Nombre de mots (16 bits) à transférer par le DMA.|

### Fonctionnement

- La valeur représente un **nombre de mots de 16 bits**, et non un nombre d'octets.
- La taille réelle de l'échantillon est donc :

```
Nombre d'octets = AUDxLEN × 2
```

- À chaque mot lu en mémoire, un compteur interne est décrémenté.
- Lorsque ce compteur atteint zéro :
  - une interruption **AUDx** peut être générée si elle est activée ;
  - si le DMA reste actif, Paula recharge automatiquement le pointeur (**AUDxLCH/LCL**) et la longueur (**AUDxLEN**) pour recommencer la lecture depuis le début (lecture en boucle).

### Exemples

| Taille de l'échantillon | Valeur à écrire dans AUDxLEN |
|-------------------------:|-----------------------------:|
|256 octets|128 ($0080)|
|1024 octets|512 ($0200)|
|4096 octets|2048 ($0800)|
|10000 octets|5000 ($1388)|

### Exemple assembleur

```asm
move.w  #SampleSize/2,AUD0LEN
```

où `SampleSize` est la taille de l'échantillon en octets.

---

## AUDxPER

Détermine la période (vitesse de transfert DMA) du canal audio.

| Adresse | Registre | Description |
|---------:|----------|-------------|
|$DFF0A6|AUD0PER|Période du canal audio 0|
|$DFF0B6|AUD1PER|Période du canal audio 1|
|$DFF0C6|AUD2PER|Période du canal audio 2|
|$DFF0D6|AUD3PER|Période du canal audio 3|

### Format

| Bits | Description |
|------|-------------|
|15..0|Période du DMA audio, exprimée en cycles d'horloge.|

### Fonctionnement

- Cette valeur détermine la vitesse à laquelle Paula lit les données audio en mémoire.
- Plus la période est **petite**, plus la lecture est **rapide** et la fréquence de restitution est **élevée**.
- Plus la période est **grande**, plus la lecture est **lente** et la fréquence est **basse**.
- La valeur minimale autorisée est **124 cycles d'horloge**.

```
Valeur minimale : 124
```

Il ne faut donc jamais écrire une valeur inférieure à **124** dans ce registre.

### Fréquence de lecture

Pour un Amiga PAL :

```
Fréquence ≈ 3 546 895 / AUDxPER
```

Pour un Amiga NTSC :

```
Fréquence ≈ 3 579 545 / AUDxPER
```

### Exemples (PAL)

| AUDxPER | Fréquence approximative |
|---------:|------------------------:|
|124|28 604 Hz|
|161|22 030 Hz|
|226|15 694 Hz|
|321|11 049 Hz|
|428|8 287 Hz|

### Exemple assembleur

```asm
move.w  #161,AUD0PER      ; ≈22 kHz (PAL)
```
### Cas avec un nombre d’échantillons

Si on veut jouer un buffer de taille donnée sur une durée précise, on peut relier la période, le nombre d’échantillons et la fréquence :

```
Période = 3 546 895 / (Nombre d’échantillons × Fréquence)
```

### Définitions

| Terme | Description |
|------|-------------|
| 3 546 895 Hz | Horloge audio de référence du chipset Paula (PAL) |
| Fréquence | Fréquence de lecture souhaitée (Hz) |
| Nombre d’échantillons | Taille du buffer audio (en échantillons 8 bits ou 16 bits selon usage logique) |
| Période | Valeur à écrire dans `AUDxPER` |

### Remarques importantes

- `AUDxPER` ne contient pas une fréquence, mais un **diviseur d’horloge**.
- Plus la période est petite → son plus aigu (lecture plus rapide).
- Plus la période est grande → son plus grave (lecture plus lente).
- La valeur minimale recommandée sur Amiga 500 est **124**.

---

## AUDxVOL

Définit le volume du canal audio.

| Adresse | Registre | Description |
|---------:|----------|-------------|
|$DFF0A8|AUD0VOL|Volume du canal audio 0|
|$DFF0B8|AUD1VOL|Volume du canal audio 1|
|$DFF0C8|AUD2VOL|Volume du canal audio 2|
|$DFF0D8|AUD3VOL|Volume du canal audio 3|

---

### Format

| Bits | Fonction |
|------|----------|
|15..7|Non utilisés (doivent rester à 0)|
|6..0|Volume sur 7 bits (0 à 64 maximum effectif)|

---

### Fonctionnement

- Le volume est contrôlé sur **7 bits** (0–127 en écriture possible).
- Toutefois, le matériel limite la valeur effective à **64 niveaux réels**.
- Toute valeur supérieure à 64 est **saturée à 64**.

---

### Table de correspondance

| Valeur écrite | Volume obtenu |
|--------------:|--------------|
|0|Silence|
|1–63|Volume proportionnel|
|64–127|Volume maximum (saturé)|

---

### Important (correction du mythe courant)

- Il n’existe pas de bit “force max” (bit 6 spécial).
- Le champ est **une valeur numérique simple**, pas un masque de bits individuels.
- Le rendu audio est **linéaire en amplitude**, pas logarithmique.

---

### Exemple assembleur

```asm
move.w  #64,AUD0VOL     ; volume max
move.w  #32,AUD0VOL     ; volume moyen
move.w  #0,AUD0VOL      ; silence
```

---

### Remarque technique

Le volume est appliqué **avant mixage matériel**, ce qui permet :
- modulation audio via ADKCON (cross-modulation),
- effets simples sans CPU,
- mixage direct des 4 canaux Paula.
---

# AUDxDAT

Registre de données audio.

Utilisé lorsque le DMA est désactivé.

Chaque écriture fournit une nouvelle donnée PCM.

| Champ | Description |
|--------|-------------|
|15..8|Échantillon suivant|
|7..0|Échantillon courant|

Lorsque le DMA est actif, ce registre est rempli automatiquement par Agnus.
---
## CIAAPRA (CIA A) — Bit 1 : Filtre audio passe-bas

Le registre **CIAAPRA** (CIA A Peripheral Register A) est situé à l’adresse `$BFE001`.  
Il est géré par le chip **CIA A (Complex Interface Adapter)** et contrôle plusieurs signaux matériels du système Amiga.

---

## 🎚️ Rôle du bit 1

Le **bit 1 de CIAAPRA** contrôle un **filtre passe-bas analogique** appliqué à la sortie audio de l’Amiga 500.

| Bit | Fonction |
|----:|----------|
|1|Filtre audio passe-bas (low-pass filter)|

---

## 🔧 Commandes assembleur

### Désactiver le filtre (son plus brillant)

```asm
BCLR.B  #1,CIAAPRA
```

- Met le bit 1 à 0
- Désactive le filtre analogique
- Son plus clair, plus riche en hautes fréquences

---

### Activer le filtre (son plus doux)

```asm
BSET.B  #1,CIAAPRA
```

- Met le bit 1 à 1
- Active le filtre passe-bas
- Atténue les hautes fréquences
- Son plus "chaud" et typique Amiga

---

## 🎧 Effet audio

| État | Bit 1 | Résultat sonore |
|------|------|-----------------|
|OFF | 0 | Son plus aigu, non filtré |
|ON  | 1 | Son plus doux, filtré |

---

## ⚙️ Fonctionnement matériel

- Le filtre est **analogique (hardware)**, pas logiciel.
- Il agit **après le chipset Paula**, sur la sortie audio finale.
- Il affecte **simultanément les 4 canaux audio**.
- Il peut être modifié en temps réel sans interrompre le son.

---

## 🧠 Remarques importantes

- Le filtre est contrôlé par **CIA A**, pas par Paula.
- Il est souvent utilisé dans les jeux et demos pour ajuster le rendu sonore.
- Beaucoup de productions Amiga alternent ON/OFF pour simuler des effets de timbre.

---

## 📌 Résumé

- Registre : `CIAAPRA ($BFE001)`
- Bit 1 : filtre audio passe-bas
- `0` = filtre OFF (son clair)
- `1` = filtre ON (son doux)
- Impact global sur toute la sortie audio
---

# Cartographie des registres Audio (Amiga 500 OCS)

| Canal | AUDxLCH/LCL | AUDxLEN | AUDxPER | AUDxVOL | AUDxDAT |
|------:|-------------|----------|----------|----------|----------|
|0|$DFF0A0 / $DFF0A2|$DFF0A4|$DFF0A6|$DFF0A8|$DFF0AA|
|1|$DFF0B0 / $DFF0B2|$DFF0B4|$DFF0B6|$DFF0B8|$DFF0BA|
|2|$DFF0C0 / $DFF0C2|$DFF0C4|$DFF0C6|$DFF0C8|$DFF0CA|
|3|$DFF0D0 / $DFF0D2|$DFF0D4|$DFF0D6|$DFF0D8|$DFF0DA|

---

# Séquence classique de lecture d'un échantillon

| Étape | Registre | Action |
|------:|----------|--------|
|1|AUDxLCH/LCL|Adresse de l'échantillon|
|2|AUDxLEN|Longueur (en mots)|
|3|AUDxPER|Période (vitesse de lecture)|
|4|AUDxVOL|Volume (0 à 64)|
|5|DMACON|Activation DMA audio|
|6|INTENA (optionnel)|Interruption fin de lecture|

---

# Exemple assembleur corrigé (Amiga 500)

```asm
        LEA     $DFF000,A5

        MOVE.L  #SineData,AUD0LC(A5)   ; Adresse sample (haut + bas gérés par CPU)
        MOVE.W  #6,AUD0LEN(A5)          ; 6 mots = 12 octets
        MOVE.W  #64,AUD0VOL(A5)         ; Volume max
        MOVE.W  #296,AUD0PER(A5)        ; ~1 kHz PAL
        MOVE.W  #$8201,DMACON(A5)       ; Start DMA audio 0

WaitLoop:
        BTST    #6,CIAAPRA              ; Mouse button (bit 6)
        BNE.B   WaitLoop                ; Wait click

        MOVE.W  #$0001,DMACON(A5)      ; Stop audio DMA (clear AUD0EN via SET/CLR)
        RTS
```

---

# Données audio

```asm
SineData:
        DC.B    0,64,111,127,111,64,0,-64,-111,-127,-111,-64
```

---


