#ifndef AK2_TEA
#define AK2_TEA

#include<stdint.h>
// Encrypt 64 bit data with a 128 bit key
// v - array of 2 32 bit uints to be encrypted
// k - array of 4 32 bit uints (key)
void encrypt_block(uint32_t *v, uint32_t* k);
// Decrypt 64 bit data with a 128 bit key
// v - array of 2 32 bit uints to be decrypted
// k - array of 4 32 bit uints (key)
void decrypt_block(uint32_t *v, uint32_t* k);

void encrypt(uint32_t *v, uint32_t* k, int size);

void decrypt(uint32_t *v, uint32_t* k, int size);

#endif