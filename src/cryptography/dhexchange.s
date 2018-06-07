.section .data
####    base64_table: .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\0"
.section .text
##############################################################
.global test_asm
.global _u128_is_zero
.global _u128_make
.global _u128_is_odd
.global _u128_lshift
.global _u128_rshift
.global _u128_compare
.global rand
##############################################################
# Calling convention parameter registers: %rdi, %rsi, %rdx, %rcx, %r8, %r9
##############################################################
.type test_asm, @function
test_asm:
	#int test(int a, int b, int c);
	# %rdi - char* in, %rsi - char* out, %rdx len
	call rand	
	ret
##############################################################
.type _u128_is_zero, @function
_u128_is_zero: #int(const uint128_t dq)
	test %rdi, %rdi
	jnz _u128_is_zero_false
	test %rsi, %rsi
	jnz _u128_is_zero_false
	mov $1, %rax
	ret
_u128_is_zero_false:
	mov $0, %rax
	ret
##############################################################
.type _u128_make, @function
_u128_make: #void(uint128_t* dq, const DH_KEY key)
	mov (%rsi), %rax
	mov %rax, (%rdi)
	mov 8(%rsi), %rax
	mov %rax, 8(%rdi)
	ret
##############################################################
.type _u128_is_odd, @function
_u128_is_odd: #int(const uint128_t dq)
	bt $0, %rdi
	jc _u128_is_odd_true
	mov $0, %rax
	ret
_u128_is_odd_true:
	mov $1, %rax
	ret
##############################################################
.type _u128_lshift, @function 
_u128_lshift: #void(uint128_t* dq) 
	mov (%rdi), %rax
	shr $63, %rax
	shlq $1, 8(%rdi)
	or %rax, 8(%rdi)
	shlq $1, (%rdi)
	ret
##############################################################
.type _u128_rshift, @function 
_u128_rshift: #void(uint128_t* dq)
	mov 8(%rdi), %rax
	and $1, %rax
	shl $63, %rax
	shrq $1, 8(%rdi)
	shrq $1, (%rdi)
	or %rax, (%rdi)
	ret
##############################################################
.type _u128_compare, @function
_u128_compare: # int(const uint128_t a, const uint128_t b)
	# a.low  -> %rdi
	# a.high -> %rsi
	# b.low  -> %rdx
	# b.high -> %rcx
	pushq %rbp
	high_cmp:
		cmpq %rcx, %rsi			# a.high > b.high ? cmp %rcx, %rsi
		jbe high_less_equal
		jmp greater
	high_less_equal:    		# a.high <= b.high
		cmpq %rcx, %rsi 		# a.high == b.high ?
		jne lesser	
		cmpq %rdx, %rdi         # a.low > b.low ?
		jbe low_less_equal
		jmp greater
	low_less_equal:				# a.low <= b.low
		cmpq %rdx, %rdi
		jne lesser				# a < b		
		jmp equal				# a == b
	greater:
		movl $1, %eax
		jmp end
	equal:
		movl $0, %eax
		jmp end
	lesser:  
		movl $-1, %eax
	end:
		popq %rbp
		ret


##############################################################
##############################################################
##############################################################
##############################################################






