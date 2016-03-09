ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT padovan.s!!!!!"

assembly:
	gcc -m32 -o padovan.s -O0 -c -S padovan.c
pract02:
	gcc -m32 -g -o padovan padovan.s
pract02_opt:
	gcc -m32 -O1 -ftree-loop-im -c -S -o padovan_opt.s padovan.c
	gcc -m32 -O1 -ftree-loop-im padovan.c -o padovan_opt
clean:
	rm -rf padovan padovan_opt
