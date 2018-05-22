.section .data
    base64_table: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\0"
.section .text
.global base64_encode
.global base64_decode
.type base64_encode, @function
base64_encode:
    # INPUT ARGS:
    # %rdi - char* in, %rsi - char* out, %rdx len

     # Empty input, do nothing
    mov $0, %rax
    test %rdx, %rdx
    jz done

    dec %rdx

    # Find the number of chunks, and the size of the last chunk
    mov %rdx, %r10
    mov %r10, %rax  # Put the length of input buffer in %rax
    mov $3, %r10
    mov $0, %rdx    
    div %r10     # Divide length by chunk size. Number of chunks is in %rax, 
                 # size of last chunk is in %edx 
    mov %rax, %r10  
    mov %rdx, %r11
    mov $0, %r9     

    # %rdi - pointer to current position in input buffer
    # %rsi - pointer to current position in output buffer
    # %eax - holds 3 byte input chunk
    # %ebx - placeholder for 4 b64 chars, before moving it to out
    # %r9  - current chunk number
    # %r10 - total number of chunks
    # %r11 - number of significant bytes in last chunk
    
    # Process the input data in chunks of 24b (32b minus the last byte)
    loop:              
        cmp  %r9, %r10
        jl padding
        movl (%rdi), %eax   # Move 4 byte chunk into %rax. It will produce 3 b64 chars
        inc %r9             # 
        add $3, %rdi        # Advance pointer by 3. Last byte is truncated
        bswap %eax          # Reverse the order of bytes in %eax
        shr $8, %eax        # Throw away last byte
        # Gets 4 base characters backward (last 6b group is encoded first)
        mov %eax, %edx      # Copy last 6 bits
        shr $6, %eax        # Shift
        and $0x3F, %edx     # And operation saves only last 6 bits
        mov base64_table(,%edx,1), %bh # Put the corresponding b64 char into bh
        mov %eax, %edx
        shr $6, %eax        # Shift to get next 6 bits
        and $0x3F, %edx
        mov base64_table(,%edx,1), %bl
        shl $16, %ebx       # Both bl,hl full, shift to make place
        mov %eax, %edx
        shr $6, %eax
        and $0x3F, %edx 
        mov base64_table(,%edx,1), %bh
        mov base64_table(,%eax,1), %bl
        mov %ebx, (%rsi)     # Move 4 b64 chars into output buf
        add $4, %rsi
        jmp loop
    padding:
        sub $4, %rsi    # Decrease the pointer, so it inserts last 4 chars in correct place
        bswap %ebx      # Swap the order of byte in ebx
        # Base case - no padding needed
        cmp $0, %r11
        je null_terminate
        # At least one padding byte needed - 1 or 2 sigingicant bytes
        mov $'=', %bl
        cmp $2, %r11
        je overwrite
        # 1 siginificant byte left, need 2 '=' bytes for padding
        mov $'=', %bh 
    overwrite:
        bswap %ebx
        mov %ebx, (%rsi)
        add $4, %rsi
    null_terminate:
        movb $0, (%rsi)
    calculate_len:
        # Length of encoded msg = 4 x num of chunks + num of sig. bytes > 0 ? 4 : 0
        mov %r10, %rax
        mov $4, %r9
        mul %r9
        cmp $0, %r11
        je done
        add $4, %eax
    done:        
        ret

.type my_strchr, @function
my_strchr:
    # function returns pointer to specified character %dl at input string %%rax or null if not found
    # INPUT ARGS:
    # %rdi - char* src, %rsi - char ch
    # my_strchr
        push %rcx
        push %rdx
        mov %rsi, %rdx
        jmp my_strchr_while
    _begin_while:
    # (*src == ch) return (char *)src;
        cmp %cl, %dl
        jz my_strchr_end
    # src++;
        inc %rdi
    # while (*src)
    my_strchr_while:
        mov (%rdi), %cl
        test %cl, %cl
        jnz _begin_while
    # return NULL;
        xor %rdi, %rdi
    my_strchr_end:
        pop %rdx
        pop %rcx
 
        ret

.type base64_decode4, @function
base64_decode4:
    # INPUT ARGS:
    # %rdi - char* src, %rsi - char* dest
        push %rbp
        mov %rsp, %rbp
        sub $16, %rsp
        push %rax
        push %rbx
        push %rcx
        push %rdx
        mov %rdi, %rax
        mov %rsi, %rdx
    # start
        mov %rdx, -8(%rbp) # dest
        xor %rsi, %rsi # x
        mov %rax, %rbx # src
    # for (i = 0; i < 4; i++)
        xor %rdi, %rdi # i
    base64_decode4_begin_for:
    # ((found = (char*)my_strchr(base64_table, src[i])) != NULL)
        mov (%rbx), %dl
        mov base64_table, %rax
        call my_strchr
        mov %rax, -16(%rbp) # found
        test %rax, %rax
        jz base64_decode4_else_if
    base64_decode4_found:
    # x = (x << 6) + (unsigned int)(found - base64_table);
        shl $6, %rsi
        mov -16(%rbp), %rdx
        sub base64_table, %rdx
        add %rdx, %rsi
        jmp base64_decode4_end_for
    base64_decode4_else_if:
    # elseif(src[i] == '=')
        movsx (%rbx), %rcx
        cmp $'=', %rcx
        jnz base64_decode4_end_for
    # x = (x << 6);
        shl $6, %rsi
    base64_decode4_end_for:
        inc %rdi
        inc %rbx
        cmp $4, %rdi
        jl base64_decode4_begin_for
    # dest[2] = (unsigned char)(x & 255);
        mov -8(%rbp), %rdx
        mov %rsi, %rax
        and $255, %al
        mov %al, 2(%rdx)
    # x >>= 8;
        shr $8, %rsi
    # dest[1] = (unsigned char)(x & 255);
        mov -8(%rbp), %rdx
        mov %rsi, %rax
        and $255, %al
        mov %al, 1(%rdx)
    # x >>= 8;
        shr $8, %rsi
    # dest[0] = (unsigned char)(x & 255);
        mov -8(%rbp), %rdx
        mov %rsi, %rax
        and $255, %al
        mov %al, (%rdx)
    # cleanup
        pop %rdx
        pop %rcx
        pop %rbx
        pop %rax
        mov %rbp, %rsp
        pop %rbp
 
        ret
 
.type base64_decode, @function
base64_decode:
    # INPUT ARGS:
    # %rdi - char* in, %rsi - char* out, %rdx len (not used)
        push %rbp
        mov %rsp, %rbp
        sub $32, %rsp
        push %rax
        push %rbx
        push %rcx
        push %rdx
        mov %rdi, %rax # in
        mov %rsi, %rdx # out
    # int length = 0;
        xor %rdx, %rdx
    # int equalsTerm = 0; # -8(%rbp)
        xor %rax, %rax
        mov %rax, -8(%rbp)
    # int i;
    # int numQuantums; # -16(%rbp)
    # unsigned char lastQuantum[3]; # -24(%rbp)
    # unsigned int rawlen; # -32(%rbp)
 
    # *out = NULL;
        mov %rsi, %rax
        jmp base64_decode_while_begin
    # while ((in[length] != '=') && in[length]) length++;
    base64_decode_while:
        inc %rdx
        inc %rax
    base64_decode_while_begin:
        mov (%rax), %cl
        movsx %cl, %rbx
        cmp $'=', %rbx
        jz base64_decode_while_begin2
        test %cl, %cl
        jnz base64_decode_while
    base64_decode_while_begin2:
    # {
        movsx (%rdx,%rsi), %rax
        cmp $'=', %rax
        jnz base64_decode_endif
    # equalsTerm++;
        incq -8(%rbp)
    # (in[length+equalsTerm] == '=')
        lea (%rdx,%rsi), %rcx
        mov -8(%rbp), %rax
        movsx (%rcx,%rax), %rcx
        cmp $'=', %rcx
        jnz base64_decode_endif
    #  equalsTerm++;
        incq -8(%rbp)
    # }
    base64_decode_endif:
    # numQuantums = (length + equalsTerm) / 4;
        add -8(%rbp), %rdx
        test %rdx, %rdx
        jns base64_decode_numQuantums2
        add $3, %rdx
    base64_decode_numQuantums2:
        sar $2, %rdx
        mov %rdx, -16(%rbp)
    # (numQuantums <= 0) return 0;
        cmpq $0, -16(%rbp)
        jnle base64_decode_endif2
        xor %rax, %rax
        jmp base64_decode_end
    base64_decode_endif2:
    # rawlen = (numQuantums * 3) - equalsTerm;
        mov -16(%rbp), %rdx
        lea (%rdx,%rdx,2), %rdx
        sub -8(%rbp), %rdx
    # for (i = 0; i < numQuantums - 1; i++)
    # {
        xor %rbx, %rbx # i
        mov %rdx, -32(%rbp)
        jmp base64_decode_end_for
    base64_decode_for_begin:
    #    base64_decode4(in, (unsigned char *)out);
        mov %rdi, %rdx
        mov %rsi, %rax
        call base64_decode4
    #    out += 3; in += 4;
        add $3, %rdi # out
        add $4, %rsi # in
        inc %rbx
    base64_decode_end_for:
        mov -16(%rbp), %rcx
        dec %rcx
        cmp %rcx, %rbx
        jl base64_decode_for_begin
    # base64_decode4(in, lastQuantum);
        lea -24(%rbp), %rdx
        mov %rsi, %rax
        call base64_decode4
    # for (i = 0; i < 3 - equalsTerm; i++) out[i] = lastQuantum[i];
        xor %rbx, %rbx
        mov %rdi, %rdx
        lea -24(%rbp), %rax
        jmp base64_decode_for_begin2
    base64_decode_for_loop:
        mov (%rax), %cl
        inc %rbx
        mov %cl, (%rdx)
        inc %rdx
        inc %rax
    base64_decode_for_begin2:
        mov $3, %rcx
        sub -8(%rbp), %rcx
        cmp %rcx, %rbx
        jl base64_decode_for_loop
    # out[i] = 0;
        movb $0, (%rbx,%rdi)
    # return rawlen;
        mov -32(%rbp), %rax # rawlen
    base64_decode_end:
        pop %rdx
        pop %rcx
        pop %rbx
        pop %rax
        mov %rbp, %rsp
        pop %rbp
   
        ret