#include <stdio.h>
#include <stdlib.h>

unsigned int telephone(unsigned int n) {
  unsigned int result = 0;

  if (n < 2)
    result = 1;
  else
  {
    unsigned int n_minus_one = telephone(n-1);
    unsigned int n_minus_two = telephone(n-2);

    result = n_minus_one + (n - 1) * n_minus_two;
  }

  return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), aantal=atoi(argv[2]);
    unsigned int f;
    for (i=0; i<aantal; i++) {
      f = telephone(n);
    }
    printf("Telephone(%u) = %u\n", n, f);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
