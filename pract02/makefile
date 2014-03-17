ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT jacobsthal.s!!!!!"

assembly:
	gcc -o jacobsthal.s -O0 -c -S jacobsthal.c
pract02:
	gcc -g -o jacobsthal jacobsthal.s
pract02_opt:
	gcc -O1 -c -S -m32 -o jacobsthal_opt.s jacobsthal.c
	gcc -O1 -m32 jacobsthal.c -o jacobsthal_opt
clean:
	rm -rf jacobsthal jacobsthal_opt
