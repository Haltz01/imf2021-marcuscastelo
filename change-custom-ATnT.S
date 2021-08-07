    .text
    .global change

change:
    push %ebp
    mov %esp, %ebp
    # call   1272 <__x86.get_pc_thunk.ax> -> desnecessário, usado para ASLR, não é problema nosso
    add $0x2d82, %eax
    mov 0x8(%ebp), %edx
    mov 0xc(%ebp), %eax
    add %eax, %edx
    mov %edx, %eax
    sar $0x1f, %eax
    shr $0x18, %eax
    add %eax, %edx
    movzbl %dl, %edx
    sub %eax, %edx
    mov %edx, %eax
    pop %ebp
    ret $0x10 # andando 16 bytes na stack, ou seja, limpando a pilha, está faltando isso no libcypher ao chamar change()...
