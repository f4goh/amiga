# Taille d'un sprite Amiga 500

Sur Amiga 500, un sprite matériel a une largeur fixe de **16 pixels**.

La hauteur dépend du nombre de lignes de données présentes dans la structure du sprite.

## Structure d'un sprite Amiga

Un sprite est organisé ainsi :

```c
static UWORD __chip sprite_data[] =
{
    // Position et contrôle
    POS_H, POS_V,
    CTL,

    // Données graphiques
    plan0_ligne1, plan1_ligne1,
    plan0_ligne2, plan1_ligne2,
    ...
    
    // Fin du sprite
    0x0000, 0x0000
};
```

En réalité, les deux premiers mots servent à stocker :

* la position verticale de départ
* la position horizontale
* la position de fin
* les options du sprite

Ils sont modifiés par une fonction comme :

```c
set_sprite_pos()
```

---

# Largeur d'un sprite

Un sprite Amiga fait toujours :

```
16 pixels de large
```

Chaque ligne contient deux mots de 16 bits :

```
mot 1 : bitplane 0
mot 2 : bitplane 1
```

Exemple :

```c
0x0300, 0x0000
```

correspond à une ligne de 16 pixels.

Les deux bitplanes permettent d'obtenir :

| Bitplane 1 | Bitplane 0 | Résultat    |
| ---------- | ---------- | ----------- |
| 0          | 0          | transparent |
| 0          | 1          | couleur 1   |
| 1          | 0          | couleur 2   |
| 1          | 1          | couleur 3   |

Donc un sprite possède :

* 3 couleurs visibles
* 1 couleur transparente

---

# Exemple avec nemo_data

Voici le sprite :

```c
static UWORD __chip nemo_data[] = {
  0x0008, 0x0000,

  0x0300, 0x0000,
  0x1f80, 0x1fe0,
  0x6f30, 0x7ff0,
  0xec78, 0xdff8,
  0x6e78, 0x7dfc,
  0x1ef7, 0x1bfe,
  0x0ee7, 0x07fe,
  0x0466, 0x0004,

  0x0000, 0x0000
};
```

Après l'en-tête :

```c
0x0008, 0x0000
```

on trouve les lignes graphiques :

```
0x0300 0x0000   ligne 1
0x1f80 0x1fe0   ligne 2
0x6f30 0x7ff0   ligne 3
0xec78 0xdff8   ligne 4
0x6e78 0x7dfc   ligne 5
0x1ef7 0x1bfe   ligne 6
0x0ee7 0x07fe   ligne 7
0x0466 0x0004   ligne 8
```

Il y a donc :

```
8 lignes
```

Le sprite fait donc :

```
16 x 8 pixels
```

---

# Faire un sprite 16x16

Pour obtenir un sprite qui correspond à une tuile de ton jeu :

```
16 x 16 pixels
```

il faut fournir :

```
16 lignes graphiques
```

Chaque ligne contient :

```
2 mots de 16 bits
```

Donc :

```
16 lignes × 2 mots = 32 mots
```

La structure complète devient :

```
2 mots       : position/contrôle
32 mots      : données graphiques
2 mots       : fin du sprite
```

Total :

```
36 UWORD
```

---

# Relation avec set_sprite_pos()

La fonction :

```c
set_sprite_pos(sprite, x, y, y2);
```

utilise :

* `x` : position horizontale
* `y` : ligne de départ
* `y2` : ligne de fin

La hauteur du sprite est :

```
hauteur = y2 - y
```

Exemple avec ton sprite 8 pixels :

```c
set_sprite_pos(nemo_data,160,100,108);
```

donne :

```
départ : 100
fin    : 108
hauteur: 8 pixels
```

Pour un sprite 16 pixels :

```c
set_sprite_pos(nemo_data,160,100,116);
```

donne :

```
départ : 100
fin    : 116
hauteur: 16 pixels
```

---

# Conclusion

Sur Amiga 500 :

* La largeur d'un sprite matériel est toujours de **16 pixels**
* La hauteur est donnée par le nombre de lignes de données
* Une ligne = 2 mots de 16 bits
* Un sprite standard possède 3 couleurs + transparence
* Pour un sprite aligné avec tes blocs de jeu 16x16, il faut créer un sprite avec 16 lignes de données

