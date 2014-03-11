pract01: getemacs
	gcc -O0 -S -m32 jacobsthal.c
	gcc -O0 -m32 jacobsthal.c -g -o jacobsthal

clean:
	rm -rf jacobsthal.s jacobsthal

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs
