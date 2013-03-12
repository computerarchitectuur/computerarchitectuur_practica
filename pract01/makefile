pract01: getemacs
	gcc -O0 -S -m32 lucas.c
	gcc -O0 -m32 lucas.c -g -o lucas

clean:
	rm -rf lucas.s lucas

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs
