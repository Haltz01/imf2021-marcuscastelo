# Passos para resolução do problema

## Inspecionando os arquivos

Usando alguns comandos disponíveis no Linux como `file`, `hexdump` e `readelf` somos capazes de obter informações importates sobre os arquivos dados. 

Usando o `file`, obtemos:
- Sobre o `decode.o`: `decode.o: ELF 32-bit LSB relocatable, Intel 80386, version 1 (SYSV), not stripped`
- Sobre o `libcypher.so`: `libcypher.so: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, BuildID[sha1]=672806f57c71050b90766548830b6e6a1f817f3b, not stripped`

Podemos obter algumas informações extrar olhando o dump desses arquivos e usando o "readelf", mas parece que isso não será necessário...

Pelo `hexdump`, também descobrimos que o `decode.o` e o `libcypher.so` foram compilados no GCC em um Ubuntu 20.04:
![](https://i.imgur.com/CBpHAxO.png)
![](https://i.imgur.com/GIW6Nqm.png)

Usando softwares de _reverse engineering_ como o Ghidra, Binary Ninja e Radare2, podemos descobrir outras informações relevantes e entender melhor o funcionamento dos objetos que temos.

## Elaborando Makefile para buildar o "decode"

No Ubuntu 18.04 64 bits, para compilar o "decode" é necessário instalar o GCC para outras arquiteturas - nesse caso 32-bits - usando `sudo apt install gcc-multilib`.
## Executando o programa

## Deobfuscando o arquivo "crypt1.dat"

Para usar o "decode", tanto pelas instruções do desafio como usando `hexdump` ou `strings` é possível descobrir como usar o executável: `decode -d -k <key> <input-file> <output-file>`

Sendo que `<key>` é a string em ASCII usada para encriptar os dados

Ambos os arquivos foram obfuscados usando a string 'ABC'

## Deobfuscando o arquivo "crypt2.dat"

Comentário que veio com o problema:
```
Should you detect a runtime error, our suspicion that libcypher.so is
corrupted will be confirmed.  We do not currently know if this is
intentional or not, but trusted sources have reported that the problem
may affect large data files, which is the case of crypt2.dat.  As a hint,
to start your investigation, one mission control informer advised about
the possibility that the current copy of libcypher is comprised of object
files compiled in different build platforms, each having diverse ABIs,
specially concerning the calling convention.

If you detect the defect, you should fix it according to the same
strategy as described above.
```

Segmentation Fault recebido ao tentar executar o `decode` no crypt2.dat! Olhando no GDB:
![](https://i.imgur.com/xzpuMj0.png)

A diferença no tamanho dos arquivos é bem grande:
![](https://i.imgur.com/oPQmsSS.png)
O GDB mostra que não está conseguindo acessar certa região de memória.

## Finalizando o desafio e preparando entrega final

- Fazer o tarball
- Conferir se o "decode" é capaz de deobfuscar ambos os arquivos "crypt1.dat" e "crypt2.dat"