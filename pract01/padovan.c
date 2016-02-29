#include <stdio.h>

int padovan(int n) {
  int result = 0;

  if (n == 1)
    result = 1;
  else if (n == 2)
    result = 1;
  else if (n == 3)
    result = 1;
  else
  {
    int n_minus_two = padovan(n-2);
    int n_minus_three = padovan(n-3);

    result = n_minus_two + n_minus_three;
  }

  return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), f, t, aantal=atoi(argv[2]);
    for (i=0; i<aantal; i++) {
      f = padovan(n);
    }
    printf("padovan(%d) = %d \n", n, f);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
