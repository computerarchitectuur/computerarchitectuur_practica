name=perrin

pract01: getemacs
	gcc -O0 -fno-pic -no-pie -fcf-protection=branch -S -m32 ${name}.c
	gcc -O0 -fno-pic -no-pie -fcf-protection=branch -m32 ${name}.c -g -o ${name}

clean:
	rm -rf ${name}.s ${name}

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs pract01
