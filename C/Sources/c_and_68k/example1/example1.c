/*
Le compilateur comprend :
- a est passé dans D0
- b est passé dans D1
Pour les fonctions qui retournent un long, vbcc utilise D0 comme registre de retour.
Le compilateur considère alors que le contenu de D0 est la valeur retournée
bilan
add_two_numbers(3,2)

        │
        ▼
D0 = 3
D1 = 2
JSR _add_two_numbers
        │
        ▼
_add_two_numbers:
    add.l d1,d0   ; D0 = 5
    rts
        │
        ▼
retour dans main
        │
        ▼
result = D0
*/
#include <stdio.h>

long add_two_numbers(__reg("d0") long a, __reg("d1") long b);

int main() {
    long result = add_two_numbers(3,2);
    printf("The result of 3+2 is %ld\n", result);
    return 0;
}
