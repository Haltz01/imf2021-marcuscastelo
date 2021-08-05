all: decode run

decode:
	gcc -m32 -o decode decode.o -lcypher -L.

decode2: libcypher2.so
	gcc -m32 -o decode2 decode.o -lcypher2 -lcypher -L.

explore: explore.c
	gcc -m32 -o explore explore.c -lcypher -L.

libcypher2.so: libcypher2.c 
	gcc -m32 -c libcypher2.c -o libcypher2.o -fpic
	gcc -m32 -shared libcypher2.o -o libcypher2.so

.PHONY: runex
runex: explore
	LD_LIBRARY_PATH=. ./decode

.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode

.PHONY: run2
run2: decode2
	LD_LIBRARY_PATH=. ./decode2 -d -k ABC crypt1.dat crypt1.png