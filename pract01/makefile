name=telephone

pract01:
	gcc -O0 -fno-pic -S -m32 ${name}.c
	gcc -O0 -fno-pic -m32 ${name}.c -g -o ${name}

clean:
	rm -rf ${name}.s ${name}

# getemacs:
# 	cp .emacs ../..

.PHONY: clean getemacs pract01
