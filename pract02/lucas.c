#include <stdio.h>
#include <time.h>

int lucas(int n) {
  int result = 0;
  if (n < 2)
    result = 2;
  else
  {
  	int n_minus_one = lucas(n-1);
	int n_minus_two = lucas(n-2);

	result =  2*n_minus_two + n_minus_one;
  }

	return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), f, t, aantal=atoi(argv[2]);
    for (i=0; i<aantal; i++) {
      f = lucas(n);
    }
    printf("Lucas(%d) = %d \n", n, f);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
