all: decode run

decode:
	gcc -m32 -o decode decode.o -lcypher -L.

.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode