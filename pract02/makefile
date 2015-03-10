ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT perrin.s!!!!!"

assembly:
	gcc -o perrin.s -O0 -c -S perrin.c
pract02:
	gcc -g -o perrin perrin.s
pract02_opt:
	gcc -O1 -c -S -m32 -o perrin_opt.s perrin.c
	gcc -O1 -m32 perrin.c -o perrin_opt
clean:
	rm -rf perrin perrin_opt
