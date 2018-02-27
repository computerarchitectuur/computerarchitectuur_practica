pract01: getemacs
	gcc -O0 -S -m32 binomial.c
	gcc -O0 -m32 binomial.c -g -o binomial

clean:
	rm -rf binomial.s binomial

getemacs:
	cp .emacs ../..

.PHONY: clean getemacs
