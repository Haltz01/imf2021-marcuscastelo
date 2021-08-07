all: decode run

decode:
	gcc -m32 -o decode decode.o -lcypher -L.

decode-custom: libcypher-custom.so
	gcc -m32 -o decode-custom decode.o -lcypher-custom -lcypher -L.

explore: explore.c
	gcc -m32 -o explore explore.c -lcypher -L.

libcypher-custom.so: libcypher-custom.c 
	gcc -m32 -c libcypher-custom.c -o libcypher-custom.o -fpic
	gcc -m32 -shared libcypher-custom.o -o libcypher-custom.so

.PHONY: runex
runex: explore
	LD_LIBRARY_PATH=. ./decode

.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode

.PHONY: run-custom-crypt1
run-custom-crypt1: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt1.dat crypt1.png

.PHONY: run-custom-crypt2
run-custom-crypt2: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt2.dat crypt2.png
