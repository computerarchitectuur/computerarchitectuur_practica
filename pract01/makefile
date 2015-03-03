pract01: getemacs
	gcc -O0 -S -m32 perrin.c
	gcc -O0 -m32 perrin.c -g -o perrin

clean:
	rm -rf perrin.s perrin

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs
