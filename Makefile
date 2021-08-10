# PASSANDO NO DESAFIO COM SUCESSO:
all: decode run-ld-preload

# "test" modifica o "decode", não faz uso do LD_PRELOAD 
test: decode-custom run-custom-crypt1 run-custom-crypt2

BINARIES = decode decode-custom

# Indica que a libcypher está na raiz do diretório
CC = gcc
CFLAGS = -m32
LDFLAGS = -L.

# (intel ou atnt)
CHANGE_CUSTOM_SYNTAX ?= intel

# Gera o "decode" sem modificações nossas
decode: decode.o
	$(CC) $(CFLAGS) $^ -lcypher $(LDFLAGS) -o $@

# Gera a versão modificada do decode, usando a nossa lib com maior prioridade que a lib original
# Isso aqui altera o "decode" e, segundo o enunciado, não podemos fazer isso...
# O ideal é usar o LD_PRELOAD para injetar a nossa lib ao executar o binário
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
ifeq ($(CHANGE_CUSTOM_SYNTAX),atnt)
change-custom.o: change-custom-ATnT.S
	gcc -c -m32 change-custom-ATnT.S -o change-custom.o -nostdlib -no-pie
else ifeq ($(CHANGE_CUSTOM_SYNTAX),intel)
change-custom.o: change-custom-INTEL.S
	gcc -c -m32 change-custom-INTEL.S -o change-custom.o -nostdlib -no-pie
endif


# Roda o "decode" sem quaiquer modificações
.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode -d -k ABC crypt2.dat crypt2.png

# ===== Deobfuscando o arquivo crypt1 com a nossa lib customizada =====
# A saída é um arquivo PNG (.png)
.PHONY: run-custom-crypt1
run-custom-crypt1: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt1.dat crypt1.png

# ===== Deobfuscando ambos os arquivos com a nossa lib customizada sem alterar o "decode" =====
# Usando LD_PRELOAD não alteramos o "decode" e nos mantemos dentro das especificações do desafio
.PHONY: run-ld-preload
run-ld-preload: decode libcypher-custom.so
	LD_PRELOAD=./libcypher-custom.so LD_LIBRARY_PATH=. ./decode -d -k ABC crypt1.dat crypt1.png
	LD_PRELOAD=./libcypher-custom.so LD_LIBRARY_PATH=. ./decode -d -k ABC crypt2.dat crypt2.bmp

# ===== Deobfuscando o arquivo crypt2 com a nossa lib customizada + função change() limpando a stack corretamente =====
# A saída é um arquivo Bitmap (.bmp)
.PHONY: run-custom-crypt2
run-custom-crypt2: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt2.dat crypt2.bmp

# ===== Limpando arquivos =====
.PHONY: clean
clean:
	rm -f change-custom.o libcypher-custom.o decode decode-custom crypt1.png crypt2.bmp
