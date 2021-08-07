void cypher(FILE * fileReader,FILE * fileWriter, char * cypherKey, int isDecodeFlag) {
    int *piVar1;
    int aiStack40 [4];
    int keyIndex;
    int cypherKeySize;
    int charFromFile;

    keyIndex = 0;
    if (cypherKey == (undefined4 *)0x0) {
        cypherKey = &dfl_key;
    }
    cypherKeySize = strlen((char *)cypherKey);
    piVar1 = aiStack40 + 3;
    while( true ) {
        *(undefined4 *)((int)piVar1 + -0x10) = fileReader;
        *(undefined4 *)((int)piVar1 + -0x14) = 0x111ce;
        charFromFile = fgetc(*(FILE **)((int)piVar1 + -0x10));
        if (charFromFile == -1) break;
        /* Cifra de substituição aqui! */
        aiStack40[3] = (int)*(char *)((int)cypherKey + keyIndex);
        keyIndex = (keyIndex + 1) % (int)cypherKeySize;
        if (isDecodeFlag != 0) { /* Decode inverso do Encode (se adiciona, subtrai) */
            aiStack40[3] = -aiStack40[3];
        }
        *(int *)((int)piVar1 + -0xc) = aiStack40[3];
        *(int *)((int)piVar1 + -0x10) = charFromFile;
        *(undefined4 *)((int)piVar1 + -0x14) = 0x111af;
        charFromFile = change(); /* troca do char ocorre aqui */
        *(undefined4 *)((int)piVar1 + -0x1c) = fileWriter;
        *(int *)((int)piVar1 + -0x20) = charFromFile;
        *(undefined4 *)((int)piVar1 + -0x24) = 0x111c0;
        fputc(*(int *)((int)piVar1 + -0x20),*(FILE **)((int)piVar1 + -0x1c)); /* Escrevendo no arquivo de saída */
        piVar1 = (int *)((int)piVar1 + -0x10);
    }
    return;
}