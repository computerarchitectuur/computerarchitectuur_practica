pract01: getemacs
	gcc -O0 -S -m32 leonardo.c
	gcc -O0 -m32 leonardo.c -g -o leonardo

clean:
	rm -rf leonardo.s leonardo

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs
