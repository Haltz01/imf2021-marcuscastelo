# Resumo de utilização:
# make all  -> versão final da entrega:
# 	cria um executável "decode" mais fiel ao ambiente real, linkado com a lib original
# 	porém, usa LD_PRELOAD para sobrescrever duas funcões da lib original em runtime.
#
# make test -> rotina utilizada durante a realização do trabalho:
#	cria um executável "decode" que já busca por uma lib modificada
#
# make tarball -> cria um arquivo tarball do projeto para entrega


# PASSANDO NO DESAFIO COM SUCESSO:
# make all já realiza as operacoes necessárias para deobfuscar os arquivos
# cria o executável decode com o decode.o original, linkado dinamicamente com a libcypher.so original
# na hora de executar, é utilizado LD_PRELOAD para sobrescrever as funções unlock() e change()
all: decode run-ld-preload

# "test" modifica o executável "decode", linkando com libcypher-custom.so
# em vez da libcypher.so original. Do mesmo modo 
test: decode-custom run-custom-crypt1 run-custom-crypt2

.PHONY: tarball
tarball: clean
	tar -cvf entrega.tar.gz *

BINARIES = decode decode-custom

CC = gcc
CFLAGS = -m32	# -m32 para 32 bits
LDFLAGS = -L.	# Indica que a libcypher.so e a libcypher-custom.so estão na raiz do diretório

# Define qual dos arquivos deve ser usado para criar a libcypher-custom.so
# change-custom-ATnT.S ou change-custom-INTEL.S
# valores: (intel | atnt)
CHANGE_CUSTOM_SYNTAX ?= intel

# Gera o "decode" sem modificações nossas
decode: decode.o
	$(CC) $(CFLAGS) $^ -lcypher $(LDFLAGS) -o $@

# Gera a versão modificada do decode, usando a nossa lib com maior prioridade que a lib original
# Isso aqui altera o executável "decode" e, segundo o enunciado, não podemos fazer isso...
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

# ===== Execução do programa em condições normais =====
# Roda o executável "decode" original, sem modificações,
# indicando que a libcypher original encontra-se na pasta atual
.PHONY: run
run: decode
	LD_LIBRARY_PATH=. ./decode -d -k ABC crypt2.dat crypt2.png

# ===== Deobfuscando o arquivo crypt1 com a nossa lib customizada =====
# Utiliza o executável "decode-custom" para decodificar o arquivo crypt1.dat
# esse é o executável criado para buscar a libcypher-custom.so.
# A saída é um arquivo PNG (.png)
.PHONY: run-custom-crypt1
run-custom-crypt1: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt1.dat crypt1.png

# ===== Deobfuscando o arquivo crypt2 com a nossa lib customizada + função change() limpando a stack corretamente =====
# Utiliza o executável "decode-custom" para decodificar o arquivo crypt1.dat
# esse é o executável criado para buscar a libcypher-custom.so.
# A saída é um arquivo Bitmap (.bmp)
.PHONY: run-custom-crypt2
run-custom-crypt2: decode-custom
	LD_LIBRARY_PATH=. ./decode-custom -d -k ABC crypt2.dat crypt2.bmp

# ===== Deobfuscando ambos os arquivos com a nossa lib customizada sem alterar o executável "decode" =====
# Usando LD_PRELOAD não alteramos o executável e nos mantemos dentro das especificações do desafio
# O binário "decode" é o mesmo que o original, então ele busca pela libcypher.so original,
# porém, o LD_PRELOAD nos permite sobrescrever a função unlock() e a função change() usando o arquivo
# libcypher-custom.so. A diferença para a abordagem anterior (com -lcyper-custom)
# é que o executável "decode" não precisa ser alterado em tempo de link.
.PHONY: run-ld-preload
run-ld-preload: decode libcypher-custom.so
	LD_PRELOAD=./libcypher-custom.so LD_LIBRARY_PATH=. ./decode -d -k ABC crypt1.dat crypt1.png
	LD_PRELOAD=./libcypher-custom.so LD_LIBRARY_PATH=. ./decode -d -k ABC crypt2.dat crypt2.bmp

# ===== Limpando arquivos =====
.PHONY: clean
clean:
	rm -f change-custom.o libcypher-custom.o decode decode-custom crypt1.png crypt2.bmp
