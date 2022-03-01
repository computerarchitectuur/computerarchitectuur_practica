name=narayana

pract01: #Check if the fno-pie is needed or not?
	gcc -O0 -fno-pie -no-pie -S -m32 ${name}.c
	gcc -O0 -fno-pie -no-pie -m32 ${name}.c -g -o ${name}

clean:
	rm -rf ${name}.s ${name}

# getemacs:
# 	cp .emacs ../..

.PHONY: clean getemacs pract01
