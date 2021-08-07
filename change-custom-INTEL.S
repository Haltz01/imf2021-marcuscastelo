    .text
    .global change

change:
    push $ebp
    mov $ebp, $esp
    # call 1272 <__x86.get_pc_thunk.ax> -> desnecessário, usado para ASLR, não é problema nosso
    add $eax, 0x2d82
    mov edx, DWORD PTR [$ebp+0x8]
    mov $eax, DWORD PTR [$ebp+0xc]
    add $edx, $eax
    mov $eax, $edx
    sar $eax, 0x1f
    shr $eax, 0x18
    add $edx, $eax
    movzx $edx, $dl
    sub $edx, $eax
    mov $eax, $edx
    pop $ebp
    add $esp, 0x10 # limpando a pilha, está faltando isso no libcypher ao chamar change()...
    ret
