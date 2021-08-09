all: decode-custom run-custom-crypt1 run-custom-crypt2

BINARIES = decode decode-custom

# Indica que a libcypher está na raiz do diretório
CC = gcc
CFLAGS = -m32
LDFLAGS = -L.

# Gera o "decode" sem modificações nossas
decode: decode.o
	$(CC) $(CFLAGS) $^ -lcypher $(LDFLAGS) -o $@

# Gera a versão modificada do decode, usando a nossa lib com maior prioridade que a lib original
decode-custom: decode.o libcypher-custom.so
	$(CC) $(CFLAGS) $^ -lcypher-custom -lcypher $(LDFLAGS) -o decode-custom


# Gera nossa libcypher customizada (só tem a função unlock() e change())
libcypher-custom.so: libcypher-custom.o change-custom.o

# Regra geral de compilação de DLLs (biblioteca dinâmica)
%.so: %.o 
	$(CC) $(CFLAGS) -shared $^ -o $@

# Regra geral de compilação de objetos
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@ -fpic

# Gera o objeto da versão modificada da função change() a partir do assembly
# OBS: sobrescreve a regra anterior para esse objeto, que vem diretamente do assembly
# Não consegui usar sintaxe INTEL :(
change-custom.o: change-custom-ATnT.S
	as -32 change-custom-ATnT.S -o change-custom.o

# Roda o "decode" sem quaiquer modificações
.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode -d -k ABC crypt2.dat crypt2.png

# ===== Deobfuscando o arquivo crypt1 com a nossa lib customizada =====
# A saída é um arquivo PNG (.png)
.PHONY: run-custom-crypt1
run-custom-crypt1: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt1.dat crypt1.png

# ===== Deobfuscando o arquivo crypt2 com a nossa lib customizada + função change() limpando a stack corretamente =====
# A saída é um arquivo Bitmap (.bmp)
.PHONY: run-custom-crypt2
run-custom-crypt2: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt2.dat crypt2.bmp

# ===== Limpando arquivos =====
.PHONY: clean
clean:
	rm -f change-custom.o libcypher-custom.o decode decode-custom crypt1.png crypt2.bmp
