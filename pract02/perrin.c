#include <stdio.h>
#include <stdlib.h>

int perrin(int n) {
  int result = 0;

  if (n == 0)
    result = 3;
  else if (n == 1)
    result = 0;
  else if (n == 2)
    result = 2;
  else
  {
    int n_minus_two = perrin(n-2);
    int n_minus_three = perrin(n-3);

    result =  n_minus_two + n_minus_three;
  }

  return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), aantal=atoi(argv[2]);
    unsigned int f;
    for (i=0; i<aantal; i++) {
      f = perrin(n);
    }
    printf("Perrin(%u) = %u\n", n, f);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
