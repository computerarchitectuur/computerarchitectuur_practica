ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT pell.s!!!!!"

assembly:
	gcc -o pell.s -O0 -c -S pell.c
pract02:
	gcc -g -o pell pell.s
pract02_opt:
	gcc -O1 -c -S -m32 -o pell_opt.s pell.c
	gcc -O1 -m32 pell.c -o pell_opt
clean:
	rm -rf pell pell_opt pell_debug
