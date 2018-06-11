.section .data
##############################################################

#static const uint128_t P = { 0xffffffffffffff61, 0xffffffffffffffff };
P: .quad 0xffffffffffffff61, 0xffffffffffffffff

#static const uint128_t INVERT_P = { 159 };
INVERT_P: .quad 159, 0

#static const uint128_t G = { 5 };
G: .quad 5, 0

##############################################################
.section .text
##############################################################
.global _u128_is_zero
.global _u128_make
.global _u128_is_odd
.global _u128_lshift
.global _u128_rshift
.global _u128_compare
.global _u128_add
.global _u128_sub
.global _mulmodp
.global _powmodp_r
.global _powmodp
.global DH_generate_key_pair
.global DH_generate_key_secret
.global rand
##############################################################
# Tip: Calling convention parameter registers: %rdi, %rsi, %rdx, %rcx, %r8, %r9
##############################################################

.type _u128_is_zero, @function
_u128_is_zero: #int(const uint128_t dq)
	# Input:
	# dq.low  -> %rdi
	# dq.high -> %rsi

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
	# Input:
	#  dq.low  ->  (%rdi)
	#  dq.high -> 8(%rdi)
	# key.low  ->  (%rsi)
	# key.high -> 8(%rsi)

	mov (%rsi), %rax
	mov %rax, (%rdi)
	mov 8(%rsi), %rax
	mov %rax, 8(%rdi)
	ret

##############################################################

.type _u128_is_odd, @function
_u128_is_odd: #int(const uint128_t dq)
	# Input:
	# dq.low  -> %rdi
	# dq.high -> %rsi

	mov %rdi, %rax
	and $1, %rax
	ret

##############################################################

.type _u128_lshift, @function 
_u128_lshift: #void(uint128_t* dq) 
	# Input:
	#  dq.low  ->  (%rdi)
	#  dq.high -> 8(%rdi)

	mov (%rdi), %rax
	shr $63, %rax
	shlq $1, 8(%rdi)
	or %rax, 8(%rdi)
	shlq $1, (%rdi)
	ret

##############################################################

.type _u128_rshift, @function 
_u128_rshift: #void(uint128_t* dq)
	# Input:
	#  dq.low  ->  (%rdi)
	#  dq.high -> 8(%rdi)

	mov 8(%rdi), %rax
	and $1, %rax
	shl $63, %rax
	shrq $1, 8(%rdi)
	shrq $1, (%rdi)
	or %rax, (%rdi)
	ret

##############################################################

.type _u128_compare, @function 
_u128_compare: #int(const uint128_t a, const uint128_t b)
	# Input:
	# a.low  -> %rdi
	# a.high -> %rsi
	# b.low  -> %rdx
	# b.high -> %rcx

	cmp %rcx, %rsi
	ja _u128_compare_g
	jb _u128_compare_l
	cmp %rdx, %rdi
	ja _u128_compare_g
	jb _u128_compare_l
	mov $0, %rax
	ret
_u128_compare_g:
	mov $1, %rax
	ret
_u128_compare_l:
	mov $-1, %rax
	ret
##############################################################

.type _u128_add, @function
_u128_add: #void(uint128_t* r, const uint128_t a, const uint128_t b)
	# Input:
	# r.low  -> (%rdi)
	# r.high -> 8(%rdi)
	# a.low  -> %rsi
	# a.high -> %rdx
	# b.low  -> %rcx
	# b.high -> %r8

	mov %rsi, (%rdi)
	add %rcx, (%rdi)
	mov %rdx, 8(%rdi)
	adc %r8, 8(%rdi)
	ret

##############################################################

.type _u128_sub, @function
_u128_sub: #void(uint128_t* r, const uint128_t a, const uint128_t b)
	# Input:
	# r.low  -> (%rdi)
	# r.high -> 8(%rdi)
	# a.low  -> %rsi
	# a.high -> %rdx
	# b.low  -> %rcx
	# b.high -> %r8

	mov %rsi, (%rdi)
	sub %rcx, (%rdi)
	mov %rdx, 8(%rdi)
	sbb %r8, 8(%rdi)
	ret

##############################################################

.type _mulmodp, @function
_mulmodp: #void(uint128_t* r, uint128_t a, uint128_t b)
	# Input:
	# *r     -> %rdi
	# a.low  -> %rsi
	# a.high -> %rdx
	# b.low  -> %rcx
	# b.high -> %r8

	#	*r			-88(%rbp)
	#	a.low			-80(%rbp)
	#	a.high			-72(%rbp)
	#	b.low			-64(%rbp)
	#	b.high			-56(%rbp)
	#	t.low;			-48(%rbp)
	#	t.high;			-40(%rbp)
	#	double_a.low;		-32(%rbp)
	#	double_a.high;		-24(%rbp)
	#	P_a.low;		-16(%rbp)
	#	P_a.high;		-8(%rbp)

	enter $11*8, $0 # make space for 11x8 bytes local variables
	# local: *r
	mov %rdi, -88(%rbp)
	# local: a
	mov %rsi, -80(%rbp)
	mov %rdx, -72(%rbp)
	# local: b
	mov %rcx, -64(%rbp)
	mov %r8, -56(%rbp)

	
	mov -88(%rbp), %rax
	movq $0, (%rax)
	movq $0, 8(%rax)

	
	_mulmodp_while:
	mov -64(%rbp), %rdi
	mov -56(%rbp), %rsi
	call _u128_is_zero
	test %rax, %rax
	jnz _mulmodp__end_while

	
	mov -64(%rbp), %rdi
	mov -56(%rbp), %rsi
	call _u128_is_odd
	test %rax, %rax
	jz _mulmodp__u128_is_odd_false

	
	lea -48(%rbp), %rdi	#*t
	mov P, %rsi		#P.low
	mov P+8, %rdx		#P.high
	mov -80(%rbp), %rcx	#a.low
	mov -72(%rbp), %r8	#a.high
	call _u128_sub

	
	mov -88(%rbp), %rax
	mov (%rax), %rdi
	mov 8(%rax), %rsi
	mov -48(%rbp), %rdx
	mov -40(%rbp), %rcx
	call _u128_compare
	cmp $0, %rax
	jl _mulmodp__u128_compare__else

	
 	mov -88(%rbp), %rdi	#r
	mov (%rdi), %rsi	#r.low
	mov 8(%rdi), %rdx	#r.high
	mov -48(%rbp), %rcx	#t.low
	mov -40(%rbp), %r8	#t.high
	call _u128_sub

	 
	jmp _mulmodp__u128_compare__endif
	_mulmodp__u128_compare__else:

	
	mov -88(%rbp), %rdi	#r
	mov (%rdi), %rsi	#r.low
	mov 8(%rdi), %rdx	#r.high
	mov -80(%rbp), %rcx	#a.low
	mov -72(%rbp), %r8	#a.high
	call _u128_add

	
	_mulmodp__u128_compare__endif:
	
	_mulmodp__u128_is_odd_false:
	
	mov -80(%rbp), %rax
	mov %rax, -32(%rbp)
	mov -72(%rbp), %rax
	mov %rax, -24(%rbp)
	
	lea -32(%rbp), %rdi
	call _u128_lshift
	
	lea -16(%rbp), %rdi	#*P_a
	mov P, %rsi		#P.low
	mov P+8, %rdx		#P.high
	mov -80(%rbp), %rcx	#a.low
	mov -72(%rbp), %r8	#a.high
	call _u128_sub
	
	mov -80(%rbp), %rdi
	mov -72(%rbp), %rsi
	mov -16(%rbp), %rdx
	mov -8(%rbp), %rcx
	call _u128_compare
	cmp $0, %rax
	jl _mulmodp__u128_compare2__else
	
	lea -80(%rbp), %rdi	#*a
	mov -32(%rbp), %rsi	#double_a.low
	mov -24(%rbp), %rdx	#double_a.high
	mov INVERT_P, %rcx	#INVERT_P.low
	mov INVERT_P+8, %r8	#INVERT_P.high
	call _u128_add
	
	jmp _mulmodp__u128_compare2__endif
	_mulmodp__u128_compare2__else:
	
	mov -32(%rbp), %rax
	mov %rax, -80(%rbp)
	mov -24(%rbp), %rax
	mov %rax, -72(%rbp)

	_mulmodp__u128_compare2__endif:
	
	lea -64(%rbp), %rdi
	call _u128_rshift
	
	jmp _mulmodp_while
	_mulmodp__end_while:

	leave
	ret

##############################################################

.type _powmodp_r, @function
_powmodp_r: #void(uint128_t* r, const uint128_t a, const uint128_t b)
	# Input:
	# r.low  -> (%rdi)
	# r.high -> 8(%rdi)
	# a.low  -> %rsi
	# a.high -> %rdx
	# b.low  -> %rcx
	# b.high -> %r8

	#	*r		-72(%rbp)
	#	a.low		-64(%rbp)
	#	a.high		-56(%rbp)
	#	b.low		-48(%rbp)
	#	b.high		-40(%rbp)
	#	t.low;		-32(%rbp)
	#	t.high;		-24(%rbp)
	#	half_b.low;	-16(%rbp)
	#	half_b.high;	-8(%rbp)

	enter $9*8, $0 # make space for 9x8 bytes local variables

	# local: *r
	mov %rdi, -72(%rbp)
	# local: a
	mov %rsi, -64(%rbp)
	mov %rdx, -56(%rbp)
	# local: b
	mov %rcx, -48(%rbp)
	mov %r8, -40(%rbp)

	mov -48(%rbp), %rax
	mov %rax, -16(%rbp)
	mov -40(%rbp), %rax
	mov %rax, -8(%rbp)
	
	cmp $0, -40(%rbp)
	jne _powmodp_r__endif_1
	cmp $1, -48(%rbp)
	jne _powmodp_r__endif_1

	mov -72(%rbp), %rdi
	mov -64(%rbp), %rax
	mov %rax, (%rdi)
	mov -56(%rbp), %rax
	mov %rax, 8(%rdi)
		
	jmp _powmodp_r__end
	
	_powmodp_r__endif_1:
	
	lea -16(%rbp), %rdi
	call _u128_rshift

	
	lea -32(%rbp), %rdi
	mov -64(%rbp), %rsi
	mov -56(%rbp), %rdx
	mov -16(%rbp), %rcx
	mov -8(%rbp), %r8
	call _powmodp_r

	
	lea -32(%rbp), %rdi
	mov -32(%rbp), %rsi
	mov -24(%rbp), %rdx
	mov %rsi, %rcx
	mov %rdx, %r8
	call _mulmodp

	
	mov -48(%rbp), %rdi
	mov -40(%rbp), %rsi
	call _u128_is_odd
	test %rax, %rax
	jz _powmodp_r__endif_2

	lea -32(%rbp), %rdi
	mov -32(%rbp), %rsi
	mov -24(%rbp), %rdx
	mov -64(%rbp), %rcx
	mov -56(%rbp), %r8
	call _mulmodp

	_powmodp_r__endif_2:

	mov -72(%rbp), %rdi
	mov -32(%rbp), %rax
	mov %rax, (%rdi)
	mov -24(%rbp), %rax
	mov %rax, 8(%rdi)

_powmodp_r__end:
	leave
	ret

##############################################################

.type _powmodp, @function
_powmodp: #void(uint128_t* r, uint128_t a, uint128_t b)
	# Input:
	# r.low  -> (%rdi)
	# r.high -> 8(%rdi)
	# a.low  -> %rsi
	# a.high -> %rdx
	# b.low  -> %rcx
	# b.high -> %r8

	#	*r		-40(%rbp)
	#	a.low		-32(%rbp)
	#	a.high		-24(%rbp)
	#	b.low		-16(%rbp)
	#	b.high		-8(%rbp)

	enter $5*8, $0 # make space for 5x8 bytes local variables

	# local: *r
	mov %rdi, -40(%rbp)
	# local: a
	mov %rsi, -32(%rbp)
	mov %rdx, -24(%rbp)
	# local: b
	mov %rcx, -16(%rbp)
	mov %r8, -8(%rbp)
	
	mov -32(%rbp), %rdi
	mov -24(%rbp), %rsi
	mov P, %rdx
	mov P+8, %rcx
	call _u128_compare
	cmp $0, %rax
	jle _powmodp__endif

	lea -32(%rbp), %rdi	
	mov -32(%rbp), %rsi		
	mov -24(%rbp), %rdx		
	mov P, %rcx	
	mov P+8, %r8	
	call _u128_sub
	
	_powmodp__endif:	
	mov -40(%rbp), %rdi
	mov -32(%rbp), %rsi
	mov -24(%rbp), %rdx
	mov -16(%rbp), %rcx
	mov -8(%rbp), %r8
	call _powmodp_r

	leave
	ret

##############################################################

.type DH_generate_key_pair, @function
DH_generate_key_pair: #void(DH_KEY public_key, DH_KEY private_key)
	# Input:
	# public_key[16]  -> (%rdi)
	# private_key[16] -> (%rsi)

	# *public_key		-48(%rbp)
	# *private_key		-40(%rbp)
	# private_k.low		-32(%rbp)
	# private_k.high	-24(%rbp)
	# public_k.low		-16(%rbp)
	# public_k.high		-8(%rbp)
	
	enter $6*8, $0 # make space for 6x8 bytes local variables
	push %rbx
	# local: *public_key
	mov %rdi, -48(%rbp)
	# local: *private_key
	mov %rsi, -40(%rbp)

	
	mov $0, %rdi
	mov -40(%rbp), %rbx
	DH_generate_key_pair__for_begin:

		
	push %rdi	
	call rand
	pop %rdi
	# private_key[%rdi] = rand() & 0xFF
	mov %al, (%rbx, %rdi)
		
	
	inc %rdi
	cmp $16, %rdi
	jl DH_generate_key_pair__for_begin

	lea -32(%rbp), %rdi
	mov -40(%rbp), %rsi
	call _u128_make

	lea -16(%rbp), %rdi
	mov G, %rsi	
	mov G+8, %rdx
	mov -32(%rbp), %rcx
	mov -24(%rbp), %r8
	call _powmodp

	mov -48(%rbp), %rdi
	mov -16(%rbp), %rax
	mov %rax, (%rdi)
	mov -8(%rbp), %rax
	mov %rax, 8(%rdi)

	pop %rbx
	leave
	ret

##############################################################

.type DH_generate_key_secret, @function
DH_generate_key_secret: #void(DH_KEY secret_key, const DH_KEY my_private, const DH_KEY another_public)
	# Input:
	# secret_key[16]	-> (%rdi)
	# my_private[16]	-> (%rsi)
	# another_public[16]	-> (%rdx)

	
	# *secret_key		-72(%rbp)
	# *my_private		-64(%rbp)
	# *another_public	-56(%rbp)
	# private_k.low		-48(%rbp)
	# private_k.high	-40(%rbp)
	# another_k.low		-32(%rbp)
	# another_k.high	-24(%rbp)
	# secret_k.low		-16(%rbp)
	# secret_k.high		-8(%rbp)
	
	enter $9*8, $0 # make space for 9x8 bytes local variables
	# local: *secret_key
	mov %rdi, -72(%rbp)
	# local: *my_private
	mov %rsi, -64(%rbp)
	# local: *another_public
	mov %rdx, -56(%rbp)

	lea -48(%rbp), %rdi # *private_k
	mov -64(%rbp), %rsi # *my_private
	call _u128_make

	
	lea -32(%rbp), %rdi # *another_k
	mov -56(%rbp), %rsi # *another_public
	call _u128_make

	
	lea -16(%rbp), %rdi # *secret_k
	mov -32(%rbp), %rsi # another_k.low
	mov -24(%rbp), %rdx # another_k.high
	mov -48(%rbp), %rcx # private_k.low
	mov -40(%rbp), %r8  # private_k.high
	call _powmodp

	
	lea -16(%rbp), %rsi # *secret_k
	mov -72(%rbp), %rdi # *secret_key
	mov (%rsi), %rax
	mov %rax, (%rdi)
	mov 8(%rsi), %rax
	mov %rax, 8(%rdi)
	
	leave
	ret

##############################################################
##############################################################
