#include <stdio.h>
#include <stdlib.h>

int narayana(int n) {
  int result = 0;

  if (n < 3)
    result = 1;
  else
  {
    int n_minus_one = narayana(n-1);
    int n_minus_three = narayana(n-3);

    result =  n_minus_one + n_minus_three;
  }

  return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), f, t, aantal=atoi(argv[2]);
    for (i=0; i<aantal; i++) {
      f = narayana(n);
    }
    printf("Narayana(%d) = %d \n", n, f);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
