int main(int argc,char **argv) {
    int iVar1;
    int * piVar2;
    char * pcVar3;
    char * cypherKey;
    FILE * fileReader;
    FILE * fileWriter;
    int isDecodeFlag;

    cypherKey = 0;
    isDecodeFlag = 0;
    unlock();
    while (iVar1 = getopt(argc,argv,"hvk:ed"), iVar1 != -1) {
        switch(iVar1) {
        case 100: /* Escolhendo opção de Decoding (d) */
            isDecodeFlag = 1;
            break;
        case 0x65: /* Escolhendo opção de Encoding (e) */
            isDecodeFlag = 0;
            break;
        default:
            fputs(usage, stderr);
                        /* WARNING: Subroutine does not return */
            exit(1);
        case 0x68:
            printf("%s",usage);
                        /* WARNING: Subroutine does not return */
            exit(0);
        case 0x6b:
            cypherKey = optarg;
            break;
        case 0x76:
            puts("decode 0.1.0");
                        /* WARNING: Subroutine does not return */
            exit(0);
        }
    }
    fileReader = stdin;
    if ((optind < argc) && (fileReader = fopen64(argv[optind],"r"), fileReader == (FILE *)0x0)) {
        piVar2 = __errno_location();
        pcVar3 = strerror(*piVar2);
        fprintf(stderr,"%s : %d : %s\n","decode",0x54,pcVar3);
                    /* WARNING: Subroutine does not return */
        exit(1);
    }
    fileWriter = stdout;
    if ((optind + 1 < argc) && (fileWriter = fopen64(argv[optind + 1],"w"), fileWriter == (FILE *)0x0)) {
        piVar2 = __errno_location();
        pcVar3 = strerror(*piVar2);
        fprintf(stderr,"%s : %d : %s\n","decode",0x5d,pcVar3);
                    /* WARNING: Subroutine does not return */
        exit(1);
    }
    cypher(fileReader,fileWriter,cypherKey,isDecodeFlag);
    if (fileReader != stdin) {
        fclose(fileReader);
    }
    if (fileWriter != stdout) {
        fclose(fileWriter);
    }
    return 0;
}