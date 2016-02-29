pract01: getemacs
	gcc -O0 -S -m32 padovan.c
	gcc -O0 -m32 padovan.c -g -o padovan

clean:
	rm -rf padovan.s padovan

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs
