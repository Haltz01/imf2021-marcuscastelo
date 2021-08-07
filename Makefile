all: decode-custom run-custom-crypt1 run-custom-crypt2

# Gera o "decode" sem modificações nossas
decode:
	gcc -m32 -o decode decode.o -lcypher -L.

# Gera a versão modificada do decode, usando a nossa lib
decode-custom: libcypher-custom.so change-custom.o
	gcc -m32 -o decode-custom decode.o change-custom.o -lcypher-custom -lcypher -L.

# Gera nossa libcypher customizada (só tem a função unlock)
libcypher-custom.so: libcypher-custom.c 
	gcc -m32 -c libcypher-custom.c -o libcypher-custom.o -fpic
	gcc -m32 -shared libcypher-custom.o -o libcypher-custom.so

# Gera o objeto da versão modificada da função change() a partir do assembly
# Não consegui usar sintaxe INTEL :(
change-custom.o: change-custom-ATnT.S
	as -32 change-custom-ATnT.S -o change-custom.o

# Roda o "decode" sem quaiquer modificações
.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode

# ===== Deobfuscando o arquivo crypt1 com a nossa lib customizada =====
# A saída é um arquivo PNG (.png)
.PHONY: run-custom-crypt1
run-custom-crypt1: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt1.dat crypt1.png

# ===== Deobfuscando o arquivo crypt2 com a nossa lib customizada + função change() limpando a stack corretamente =====
# A saída é um arquivo Bitmap (.bmp)
.PHONY: run-custom-crypt2
run-custom-crypt2: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt2.dat crypt2.bpm 
