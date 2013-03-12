ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT pell.s!!!!!"

assembly:
	gcc -o lucas.s -O0 -c -S lucas.c
pract02:
	gcc -g -o lucas lucas.s
pract02_opt:
	gcc -O1 -c -S -m32 -o lucas_opt.s lucas.c
	gcc -O1 -m32 lucas.c -o lucas_opt
clean:
	rm -rf lucas lucas_opt
