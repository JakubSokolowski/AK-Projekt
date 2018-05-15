.section .data
    .equ DELTA, 0x9e3779b9
    .equ SUM, 0xC6EF3720
.section .text
.global encrypt
.global decrypt
.type encrypt, @function
encrypt:
    # INPUT ARGS:
    # %rdi - uint32_t* v, %rsi - uint32_t* k
    # setup
    pushq %rbp              # save old base pointer
    movq %rsp, %rbp # make stack pointer the base pointer

    mov $0, %r8     # index
    mov (%rdi, %r8, 4), %rax    # v0
    inc %r8
    mov (%rdi, %r8, 4), %rbx    # v1
    mov $0, %r9    # sum
    mov $0, %r10   # i

    encrypt_cycle:
        cmp $32, %r10
        je end_encrypt
        add $-1640531527, %r9   # 0x9e3779b9
        #  v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        mov %ebx, %edx  # v1 to edx
        # ((v1<<4) + k0)
        sall $4, %edx   # (v1<<4)
        mov $0, %r8
        add (%rsi, %r8, 4), %edx    # + k0
        # (v1 + sum) 
        mov %ebx, %ecx
        add %r9, %rcx
        # ((v1<<4) + k0) ^ (v1 + sum)
        xor %ecx, %edx
        # ((v1>>5) + k1)
        mov %ebx, %ecx
        shr $5, %ecx    # (v1>>5)
        mov $1, %r8
        add (%rsi, %r8, 4), %ecx
        # ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);^ ((v1>>5) + k1)
        xor %ecx, %edx
        add %edx, %eax

         # v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        mov %eax, %edx  # v0 to edx
        # ((v0<<4) + k0)
        sall $4, %edx   # (v0<<4)
        mov $2, %r8
        add (%rsi, %r8, 4), %edx    # + k0
        # (v0 + sum) 
        mov %eax, %ecx
        add %r9, %rcx
        # ((v0<<4) + k2) ^ (v0 + sum)
        xor %ecx, %edx
        # ((v0>>5) + k3)
        mov %eax, %ecx
        shr $5, %ecx    # (v1>>5)
        mov $3, %r8
        add (%rsi, %r8, 4), %ecx
        # ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);^ ((v1>>5) + k1)
        xor %ecx, %edx
        add %edx, %ebx
        inc %r10
        jmp encrypt_cycle
    end_encrypt:
        mov $0, %r8
        mov %eax, (%rdi, %r8, 4)
        inc %r8
        mov %ebx, (%rdi, %r8, 4)

        movq %rbp, %rsp
        popq %rbp
        ret
.type decrypt, @function
decrypt:
     # INPUT ARGS:
    # %rdi - uint32_t* v, %rsi - uint32_t* k
    # setup
    pushq %rbp              # save old base pointer
    movq %rsp, %rbp # make stack pointer the base pointer

    mov $0, %r8     # index
    mov (%rdi, %r8, 4), %rax    # v0
    inc %r8
    mov (%rdi, %r8, 4), %rbx    # v1
    mov $-957401312, %r9    # sum
    mov $0, %r10   # i

    decrypt_cycle:
        cmp $32, %r10
        je end_decrypt  

         # v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        mov %eax, %edx  # v0 to edx
        # ((v0<<4) + k0)
        sall $4, %edx   # (v0<<4)
        mov $2, %r8
        add (%rsi, %r8, 4), %edx    # + k0
        # (v0 + sum) 
        mov %eax, %ecx
        add %r9, %rcx
        # ((v0<<4) + k2) ^ (v0 + sum)
        xor %ecx, %edx
        # ((v0>>5) + k3)
        mov %eax, %ecx
        shr $5, %ecx    # (v1>>5)
        mov $3, %r8
        add (%rsi, %r8, 4), %ecx
        # ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);^ ((v1>>5) + k1)
        xor %ecx, %edx
        sub %edx, %ebx

        #  v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        mov %ebx, %edx  # v1 to edx
        # ((v1<<4) + k0)
        sall $4, %edx   # (v1<<4)
        mov $0, %r8
        add (%rsi, %r8, 4), %edx    # + k0
        # (v1 + sum) 
        mov %ebx, %ecx
        add %r9, %rcx
        # ((v1<<4) + k0) ^ (v1 + sum)
        xor %ecx, %edx
        # ((v1>>5) + k1)
        mov %ebx, %ecx
        shr $5, %ecx    # (v1>>5)
        mov $1, %r8
        add (%rsi, %r8, 4), %ecx
        # ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);^ ((v1>>5) + k1)
        xor %ecx, %edx
        sub %edx, %eax        
        inc %r10
        sub $-1640531527, %r9   # 0x9e3779b9
        jmp decrypt_cycle
    end_decrypt:
        mov $0, %r8
        mov %eax, (%rdi, %r8, 4)
        inc %r8
        mov %ebx, (%rdi, %r8, 4)

        movq %rbp, %rsp
        popq %rbp
        ret

