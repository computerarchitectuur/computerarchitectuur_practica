ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT padovan.s!!!!!"

assembly:
	gcc -o padovan.s -O0 -c -S padovan.c
pract02:
	gcc -g -o padovan padovan.s
pract02_opt:
	gcc -O1 -c -S -m32 -o perrin_opt.s padovan.c
	gcc -O1 -m32 padovan.c -o perrin_opt
clean:
	rm -rf padovan perrin_opt
