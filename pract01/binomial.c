#include <stdio.h>
#include <stdlib.h>

int binomial(int n, int k) {
    if (k == 0) {
        return 1;
    }
    if (n == k) {
        return 1;
    }
    return binomial(n-1, k) + binomial(n-1, k-1);
}

int main(int argc, char *argv[]) {
    int i, n, k, b, aantal = 1;
    if (argc==3 | argc==4) {
        n = atoi(argv[1]);
        k = atoi(argv[2]);
        if (argc == 4) aantal = atoi(argv[3]);
        for (i=0; i<aantal; i++){
            b = binomial(n, k);
        }
        printf("C(%d, %d) = %d \n", n, k, b);
        return 0;
    } else {
        printf("Formaat: %s <getal n> <getal k> [# interaties: default 1]\n", argv[0]);
        return 1;
    }
}
