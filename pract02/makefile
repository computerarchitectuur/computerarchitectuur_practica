ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT binomial.s!!!!!"

assembly:
	gcc -m32 -o binomial.s -O0 -c -S binomial.c

pract02:
	gcc -m32 -g -o binomial binomial.s

pract02_opt:
	gcc -m32 -O1 -o binomial_opt.s -c -S binomial.c
	gcc -m32 -O1 -g -o binomial_opt binomial_opt.s

pract02_64b:
	gcc -m64 -o binomial_64b.s -c -S binomial.c
	gcc -m64 -g -o binomial_64b binomial_64b.s

clean:
	rm -rf binomial binomial_opt binomial_64b
