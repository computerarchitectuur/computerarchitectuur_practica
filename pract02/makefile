ECHO=/bin/echo

all:
	@$(ECHO) "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@$(ECHO) "Let op! assembly OVERSCHRIJFT leonardo.s!!!!!"

assembly:
	gcc -m32 -o leonardo.s -O0 -c -S leonardo.c

pract02:
	gcc -m32 -g -o leonardo leonardo.s

pract02_opt:
	gcc -m32 -O1 -o leonardo_opt.s -c -S leonardo.c
	gcc -m32 -O1 -g -o leonardo_opt leonardo_opt.s

pract02_64b:
	gcc -m64 -o leonardo_64b.s -c -S leonardo.c
	gcc -m64 -g -o leonardo_64b leonardo_64b.s

clean:
	rm -rf leonardo leonardo_opt leonardo_64b
