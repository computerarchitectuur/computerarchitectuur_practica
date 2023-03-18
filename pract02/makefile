name=telephone

all:
	@echo "Gebruik een van de volgende targets: assembly, pract02, pract02_opt, clean"
	@echo "Let op! assembly OVERSCHRIJFT ${name}.s!!!!!"

assembly:
	gcc -O0 -fno-pie -no-pie -S -m32 ${name}.c -o ${name}.s

pract02:
	gcc -fno-pie -no-pie -m32 ${name}.s -g -o ${name}

pract02_64b:
	gcc -O0 -fno-pie -no-pie -S  ${name}.c -o ${name}_64b.s
	gcc -fno-pie -no-pie ${name}_64b.s -g -o ${name}_64b

pract02_opt:
	gcc -O1 -fno-pie -no-pie -S -m32 ${name}.c -o ${name}_opt.s
	gcc -O1 -fno-pie -no-pie -m32 ${name}.c -o ${name}_opt

clean:
	rm -rf ${name}.s ${name} ${name}_opt.s ${name}_opt timing.out output ${name}_64b ${name}_64b.s

.PHONY: clean all assembly pract02 pract02_opt pract02_64b
