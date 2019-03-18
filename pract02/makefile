ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT binomial.s!!!!!"

assembly:
	gcc -m32 -o jacobsthal.s -O0 -c -S jacobsthal.c

pract02:
	gcc -m32 -g -o jacobsthal jacobsthal.s

pract02_opt:
	gcc -m32 -O1 -o jacobsthal_opt.s -c -S jacobsthal.c
	gcc -m32 -O1 -g -o jacobsthal_opt jacobsthal_opt.s

pract02_64b:
	gcc -m64 -o jacobsthal_64b.s -c -S jacobsthal.c
	gcc -m64 -g -o jacobsthal_64b jacobsthal_64b.s

clean:
	rm -rf jacobsthal jacobsthal_opt jacobsthal_64b
