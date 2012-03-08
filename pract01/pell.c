#include <stdio.h>
#include <time.h>

int atoi(char *s) {
  int n = 0;

  if(*s == '-')
    return -atoi(s+1);
  else if (*s == '+')
    return atoi(s+1);
  else {
    while (*s) {
      if ((*s >= '0') && (*s <= '9'))
        n = n * 10 + (*s - '0');
      s++;
    }
    return n;
  }
}

int pell(int n) {
  int result = 0;
  if (n < 2)
    result = n;
  else
  {
  	int val1 = pell(n-1);
	int val2 = pell(n-2);

	result =  2*val1 + val2;
  }

	return result;
}

int main(int argc, char *argv[]) {
  if (argc==3) {
    int i, n=atoi(argv[1]), f, t, aantal=atoi(argv[2]);
    t = clock();
    for (i=0; i<aantal; i++) {
      f = pell(n);
    }
    t = clock() - t;
    printf("Pell(%d) = %d (0x%x) %f s\n", n, f, f, (double)t/CLOCKS_PER_SEC);
    return 0;
  }
  else {
    printf("Formaat: %s waarde aantal_iteraties\n", argv[0]);
    return 1;
  }
}
