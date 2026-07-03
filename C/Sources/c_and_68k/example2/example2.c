
/*
    Convention d'appel vbcc (68000)

    Paramètres :
    - Sans __reg() : les paramètres sont passés sur la pile.
    - Avec __reg() : les paramètres sont passés dans les registres indiqués.

    Exemple sans __reg() :

        long add_two_numbers(long a, long b);

    À l'entrée de la fonction assembleur :

        0(sp) : adresse de retour (empilée par JSR)
        4(sp) : premier paramètre (a)
        8(sp) : deuxième paramètre (b)

    Exemple :

        _add_two_numbers:
            move.l  4(sp),d0    ; D0 = a
            add.l   8(sp),d0    ; D0 = a + b
            rts

    Valeur de retour :
    - Les fonctions retournant un long, int ou pointeur placent leur résultat
      dans D0 avant le RTS.
    - Le RTS ne renvoie pas la valeur ; il se contente de revenir à l'appelant.
      C'est le compilateur qui récupère automatiquement le contenu de D0 comme
      valeur de retour de la fonction.
*/


#include <stdio.h>

long add_two_numbers(long a, long b);

int main (void)
 {
    long a = add_two_numbers(3,2);
    printf ("The result of 3 + 2 is %ld\n",a);
    return 0;
}
