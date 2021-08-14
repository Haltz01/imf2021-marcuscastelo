# Passos para resolução do problema

## Inspecionando os arquivos

Usando alguns comandos disponíveis no Linux como `file`, `hexdump` e `readelf`, somos capazes de obter informações importates sobre os arquivos dados. 

Usando o `file`, obtemos:
- Sobre o `decode.o`: `decode.o: ELF 32-bit LSB relocatable, Intel 80386, version 1 (SYSV), not stripped`
- Sobre o `libcypher.so`: `libcypher.so: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, BuildID[sha1]=672806f57c71050b90766548830b6e6a1f817f3b, not stripped`

Podemos obter algumas informações extras olhando o dump desses arquivos e usando o `readelf`, mas parece que isso não será necessário...

Pelo `hexdump`, também descobrimos que o `decode.o` e o `libcypher.so` foram compilados no GCC em um Ubuntu 20.04:
![](https://i.imgur.com/CBpHAxO.png)
![](https://i.imgur.com/GIW6Nqm.png)

Usando softwares de _reverse engineering_ como o __Ghidra__, __Binary Ninja__ e __Radare2__, podemos descobrir outras informações relevantes e entender melhor o funcionamento dos objetos que temos.

## Elaborando Makefile para buildar o "decode"

No Ubuntu 18.04 64 bits, para linkar o objeto decode.o, é necessário instalar o GCC para outras arquiteturas - nesse caso 32-bits - usando `sudo apt install gcc-multilib`.
No Arch Linux x86_64, os pacotes foram instalados usando `sudo pacman -S lib32-gcc-libs lib32-glibc`.

## Executando o programa

Para usar o "decode", tanto pelas instruções do desafio como usando `hexdump` ou `strings` é possível descobrir como usar o executável: `decode -d -k <key> <input-file> <output-file>`

Para executar o programa, é necessário informar a pasta na qual a `libcypher.so` está localizada.
Para isso, no linux é possível usar a variável de ambiente LD_LIBRARY_PATH, a seguir: 
`LD_LIBRARY_PATH=. ./decode -k <key> <input`

## Deobfuscando o arquivo "crypt1.dat"



Sendo que `<key>` é a string em ASCII usada para encriptar os dados

Ambos os arquivos foram obfuscados usando a string 'ABC'

Além da `<key>`, o programa pede por uma _unlock key_ (basicamente uma senha de acesso). Tentamos fazer engenharia reversa e deduzir uma senha válida, mas no fim foi mais fácil sobrescrever a função unlock() para retornar _true_ sempre.

![image-20210811145037336](/home/marucs/.config/Typora/typora-user-images/image-20210811145037336.png)

Com isso, o comando `./decode -d -k ABC crypt1.dat crypt1.deobfuscated` funciona corretamente, mas ainda precisamos ver qual é o tipo do arquivo. Para isso, basta rodar `file crypt1.deobsfuscated`. 



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

O GDB mostra que não está conseguindo acessar certa região de memória. O que está acontecendo aparentemente é que a stack está ficando tão grande que ultrapassa seu limite...

Finalmente, analisando no Ghidra e no GDB, descobrimos que a função `change()` não está limpando o espaço alocado na stack para seus argumentos, ou seja, seu "stack frame" não é devidamente removido da stack. Sendo assim, a stack fica cada vez mais cheia, até que recebemos um "Segmentation Fault".

Sendo assim, como podemos alterar a `libcypher.so`, basta fazer uma versão nossa da `change()` limpando a stack da maneira correta. Fizemos 2 versões: uma usando sintaxe AT&T e outra com sintaxe Intel. Para ambos os arquivos, só andamos 16 bytes com o stack pointer, desalocando esses bytes da stack depois de chamar a função `change()`. Como base para a nossa versão, pegamos a `change()` da própria libcypher utilizando `objdump -D -M <tipo_sintaxe> libcypher.so`.

Feito isso, conseguimos decriptar corretamente o `crypt2.dat`.

## Finalizando o desafio e preparando entrega final

Com as modificações feitas nos arquivos presentes nesse repositório e o `Makefile` aqui presente é possível concluir o desafio. Basta dar um `make all` que o "decode" será compilado e executado para deobfuscar os arquivos `crypt1.dat` e `crypt2.dat`.

Um detalhe imporante é que para evitar que o `decode` seja modificado, não podemos compilá-lo fazendo o _link_ com a nossa versão da lib. Na verdade, devemos, ao executar o `decode`, usar o `LD_PRELOAD` para carregar a nossa lib ao executar o binário. O linker dinâmico irá fazer isso para nós.

- Fazer o tarball