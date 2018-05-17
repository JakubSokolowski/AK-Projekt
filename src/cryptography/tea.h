#ifndef AK2_TEA
#define AK2_TEA

#include<stdint.h>
// Encrypt 64 bit data with a 128 bit key
// v - array of 2 32 bit uints to be encrypted
// k - array of 4 32 bit uints (key)
typedef unsigned int uint;
void encrypt_block(char *v, char* k);
/*  Decrypt 64 bit data with a 128 bit key
    v - array of 2 32 bit uints to be decrypted
    k - array of 4 32 bit uints (key) */

void decrypt_block(char* v, char* k);

void encrypt(char *v, char* k, int size);
void decrypt(char *v, char* k, int size);

#endif