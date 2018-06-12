#ifndef DIFFIE_HELLMAN_EXCHANGE_ASM_H
#define DIFFIE_HELLMAN_EXCHANGE_ASM_H
#include <inttypes.h>
#include <stdio.h>
#define DH_KEY_LENGTH	(16)

typedef union _uint128_t {
	struct {
		uint64_t low;
		uint64_t high;
	};
	unsigned char byte[DH_KEY_LENGTH];
} uint128_t;

typedef unsigned char DH_KEY[DH_KEY_LENGTH];

void DH_generate_key_pair(DH_KEY public_key, DH_KEY private_key);
void DH_generate_key_secret(DH_KEY secret_key, const DH_KEY my_private, const DH_KEY another_public);
void _print_key(const char* name, const DH_KEY key) {
	int i;

	printf("%s\t=\t", name);
	for (i = DH_KEY_LENGTH-1; i>=0; i--) {
		printf("%02x", key[i]);
	}
	printf("\n");
}

extern int test_asm(char a, char b, char c);
extern int _u128_is_zero(const uint128_t dq);
extern void _u128_make(uint128_t* dq, const DH_KEY key);
extern int _u128_is_odd(const uint128_t dq);
extern void _u128_lshift(uint128_t* dq);
extern void _u128_rshift(uint128_t* dq);
extern int _u128_compare(const uint128_t a, const uint128_t b);
#endif
