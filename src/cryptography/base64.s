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

.type base64_decode, @function
base64_decode: