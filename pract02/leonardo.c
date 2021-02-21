#include <stdio.h>
#include <stdlib.h>

int leonardo(int n) {
  int result = 0;

  if (n == 0)
    result = 2;
  else if (n == 1)
    result = 2;
  else
  {
    int n_minus_two = leonardo(n-2);
    int n_minus_one = leonardo(n-1);

    result =  n_minus_two + n_minus_one + 2;
  }

  return result;
}
int main(int argc, char *argv[]) {
    int i, n, k, b, aantal = 1;
    if (argc==2 || argc==3) {
        n = atoi(argv[1]);
        if (argc == 3) aantal = atoi(argv[2]);
        for (i=0; i<aantal; i++){
            b = leonardo(n);
        }
        printf("leonardo(n = %d) = %d \n", n, b);
        return 0;
    } else {
        printf("Formaat: %s <getal n> [# interaties: default 1]\n", argv[0]);
        return 1;
    }
}
