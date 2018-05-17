.section .data
    .equ DELTA, 0x9e3779b9
    .equ SUM, 0xC6EF3720
.section .text
.global encrypt_block
.global decrypt_block
.global encrypt
.global decrypt
.type encrypt_block, @function
encrypt_block:
    # INPUT ARGS:
    # %rdi - uint32_t* v, %rsi - uint32_t* k
    # setup
    pushq %rbp
    movq %rsp, %rbp



    mov $0, %r8     # index
    mov (%rdi, %r8, 4), %rax    # v0
    inc %r8
    mov (%rdi, %r8, 4), %rbx    # v1
    mov $0, %r9    # sum
    mov $0, %r10   # i

    encrypt_block_cycle:
        cmp $32, %r10
        je end_encrypt_block
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
        # ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1) ^ ((v1>>5) + k1)
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
        jmp encrypt_block_cycle
    end_encrypt_block:
        mov $0, %r8
        mov %eax, (%rdi, %r8, 4)
        inc %r8
        mov %ebx, (%rdi, %r8, 4)

        movq %rbp, %rsp
        popq %rbp
        ret
.type decrypt_block, @function
decrypt_block:
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

    decrypt_block_cycle:
        cmp $32, %r10
        je end_decrypt_block  

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
        jmp decrypt_block_cycle
    end_decrypt_block:
        mov $0, %r8
        mov %eax, (%rdi, %r8, 4)
        inc %r8
        mov %ebx, (%rdi, %r8, 4)

        movq %rbp, %rsp
        popq %rbp
        ret
.type encrypt, @function
encrypt:
    pushq %rbp
    movq %rsp, %rbp
    # %rdi - uint32_t* v, %rsi - uint32_t* k , %rdx - size
    cmp $0, %rdx        # empty input buffer - do nothing
    je end_encrypt

    mov %rdx, %rax
    mov $0, %rdx
    mov $8, %rbx
    div %rbx # %rax - number of full chunks

    mov %rax, %r12
    cmp $0, %r12
    je last_enc_chunk

    # %r9 - current chunk count
    mov $0, %r11
    encrypt_loop:
        cmp %r11, %r12
        je last_enc_chunk
        call encrypt_block  # Encrypt next block
        add $8, %rdi        # Point to the next block (8 bytes)
        inc %r11
        jmp encrypt_loop
    last_enc_chunk:
        cmp $0, %rdx
        je end_encrypt
        call encrypt_block
    end_encrypt:
        movq %rbp, %rsp
        popq %rbp
        ret
.type decrypt, @function
decrypt:
    pushq %rbp
    movq %rsp, %rbp
    # %rdi - uint32_t* v, %rsi - uint32_t* k , %rdx - size
    cmp $0, %rdx        # empty input buffer - do nothing
    je end_decrypt

    
    mov %rdx, %rax
    mov $0, %rdx
    mov $8, %rbx
    div %rbx # %rax - number of full chunks

    mov %rax, %r12
    cmp $0, %r12
    je last_dec_chunk
    # %r9 - current chunk count
    mov $0, %r11
    decrypt_loop:
        cmp %r11, %r12
        je last_dec_chunk
        call decrypt_block  # Encrypt next block
        add $8, %rdi        # Point to the next block (8 bytes)
        inc %r11
        jmp decrypt_loop
    last_dec_chunk:
        cmp $0, %rdx
        je end_decrypt
        call decrypt_block
    end_decrypt:
        movq %rbp, %rsp
        popq %rbp
        ret