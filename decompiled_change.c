int change(int param_1,int param_2) {
    int uVar1;

    uVar1 = (int)(param_1 + param_2 >> 0x1f) >> 0x18;
    return (param_1 + param_2 + uVar1 & 0xff) - uVar1;
}