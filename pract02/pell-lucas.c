#include <stdio.h>
#include <stdlib.h>

int pell_lucas(int n) {
  int result = 0;

  if (n == 0)
    result = 1;
  else if (n == 1)
    result = 1;
  else
  {
    int n_minus_one = pell_lucas(n-1);
    int n_minus_two = pell_lucas(n-2);

    result =  2*n_minus_one + n_minus_two;
  }

  return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), aantal=atoi(argv[2]);
    unsigned int f;
    for (i=0; i<aantal; i++) {
      f = pell_lucas(n);
    }
    printf("Pell-Lucas(%u) = %u\n", n, f);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
