# Explication de la routine de copie avec le blitter (Amiga 500)

Cette routine programme directement le **blitter** du chipset **OCS/ECS** de l'Amiga 500,
utilisant uniquement les canaux **C** (source) et **D** (destination), sans opération logique supplémentaire.

Le registre `a6` contient très probablement l'adresse de base des registres personnalisés :

```asm
a6 = $DFF000
```

---

## Code

```asm
copie_lettre
        btst    #14,$2(a6)
        bne.s   copie_lettre

        move.l  #spchar,$54(a6)
        move.l  a1,$50(a6)

        move.l  #$ffffffff,$44(a6)

        move.l  #$09f00000,$40(a6)

        move.l  #$00000000,$64(a6)

        move.w  #16*64+2,$58(a6)

        rts
```

---

# 1. Attendre que le blitter soit libre

```asm
btst    #14,$2(a6)
bne.s   copie_lettre
```

Le registre :

```
$DFF002 = DMACONR
```

Le bit 14 est le bit **BBUSY** (Blitter Busy).

La boucle attend que ce bit devienne à 0.

En pseudo-code :

```c
while (BlitterBusy)
    ;
```

---

# 2. Adresse de destination

```asm
move.l  #spchar,$54(a6)
```

Le registre :

```
$DFF054 = BLTDPT
```

On indique où le résultat sera écrit.

```
Destination = spchar
```

---

# 3. Adresse source

```asm
move.l  a1,$50(a6)
```

Le registre :

```
$DFF050 = BLTCPT
```

Le canal **C** devient la source.

```
Source = a1
```

---

# 4. Masques du canal A

```asm
move.l  #$FFFFFFFF,$44(a6)
```

Cette écriture remplit :

```
BLTAFWM
BLTALWM
```

avec :

```
FFFF
FFFF
```

Cela signifie :

- aucun masque
- tous les bits sont copiés

---

# 5. Configuration du blitter

```asm
move.l  #$09F00000,$40(a6)
```

Cette instruction écrit deux registres :

```
BLTCON0 = $09F0
BLTCON1 = $0000
```

## BLTCON0

Le minterm est :

```
$F0
```

Ce minterm signifie :

```
D = C
```

Autrement dit :

> Copier simplement le canal C vers le canal D.

Le blitter effectue donc une simple copie mémoire.

## BLTCON1

```
$0000
```

Donc :

- pas de décalage
- pas de remplissage
- pas de mode ligne

Le commentaire `; descend` semble étrange, car le bit DESC n'est pas activé dans cette valeur.

---

# 6. Modulos

```asm
move.l  #0,$64(a6)
```

Cette instruction écrit :

```
BLTAMOD = 0
BLTCMOD = 0
```

Aucun saut supplémentaire n'est effectué en fin de ligne.

Les données sont supposées être contiguës.

Remarque :

Le registre **BLTDMOD** n'est pas initialisé ici. Il devait probablement avoir été configuré auparavant.

---

# 7. Taille du blit

```asm
move.w  #16*64+2,$58(a6)
```

Le registre :

```
BLTSIZE
```

Le format est :

```
bits 15..6 = hauteur
bits 5..0  = largeur en mots
```

Calcul :

```
16 * 64 = 1024 = $400

$400 + 2 = $402
```

Décodage :

```
Hauteur = 16 lignes

Largeur = 2 mots
```

Un mot = 16 bits.

Donc :

```
2 mots = 32 bits
        = 4 octets
```

En mode 1 bitplane :

```
32 bits = 32 pixels
```

La taille copiée est donc :

```
32 pixels × 16 lignes
```

---

# Pourquoi le +2 ?

Le registre BLTSIZE est construit ainsi :

```
BLTSIZE = (hauteur << 6) | largeur
```

La largeur est exprimée en **mots de 16 bits**.

Exemples :

| Taille | Valeur |
|---------|---------|
|16×16| (16<<6)+1 = $401 |
|32×16| (16<<6)+2 = $402 |
|48×16| (16<<6)+3 = $403 |
|64×16| (16<<6)+4 = $404 |

Le `+2` signifie simplement :

```
largeur = 2 mots = 32 bits = 32 pixels
```

---

# Taille mémoire

Chaque ligne :

```
2 mots
= 4 octets
```

Pour 16 lignes :

```
16 × 4 = 64 octets
```

Le blitter copie donc un bloc de **64 octets**.

---

# Résumé

La routine :

1. Attend que le blitter soit libre.
2. Définit la destination (`spchar`).
3. Définit la source (`a1`).
4. Désactive les masques.
5. Configure le blitter pour effectuer :

```
D = C
```

6. Indique une taille de :

```
16 lignes
×
2 mots (32 pixels)
```

7. L'écriture dans `BLTSIZE` lance immédiatement le blit.

Schéma :

```
        a1
         │
         ▼
      Canal C
         │
         ▼
    Minterm D = C
         │
         ▼
      BLTDPT
      (spchar)
```

