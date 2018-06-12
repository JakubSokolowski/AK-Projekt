#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <inttypes.h>
#include "cryptography/dhexchange.h"
#include "util.h"
#define BUFLEN 80
#define KROKI 10
#define PORT 9948

typedef struct {
    int typ;
    char buf[BUFLEN];
} msgt;

void check(int s) {

}
int start_server(struct sockaddr_in *server_addr) {
    char buf[BUFLEN];
    gethostname(buf,sizeof(buf));
    printf("Host: %s\n",buf);
    int s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    error_check(s,"socket");
    printf("Created socket: %d on port %d\n", s, PORT);
    server_addr->sin_family = AF_INET;
    server_addr->sin_port = htons(PORT);
    server_addr->sin_addr.s_addr = htonl(INADDR_ANY);
    bind(s, (struct sockaddr *) server_addr, sizeof(struct sockaddr_in));
    error_check(s, "bind");
    return s;
}
void blad(char *s) {
    perror(s);
    _exit(1);
}

void alice_start(int s, struct sockaddr_in* addr) {
    int rec, snd, blen = sizeof(message_t), slen = sizeof(struct sockaddr_in);
    DH_KEY alice_private, alice_secret, alice_public, bob_public;
    time_t seed;
	time(&seed);
	srand((unsigned int)seed);
    DH_generate_key_pair(alice_public, alice_private);
    _print_key("Alice public", alice_public);
    _print_key("Alice private", alice_private);
    printf("Exchanging keys...\n");
    printf("Receiving public...\n");
    rec = recvfrom(s, &bob_public, DH_KEY_LENGTH, 0, (struct sockaddr *) addr, (socklen_t*) &slen);
    error_check(rec, "DHPUBLIC"); 
    printf("Public received, generating secret...\n");
    DH_generate_key_secret(alice_secret, alice_private, bob_public);
    _print_key("Alice secret", alice_secret);
    printf("Sending public...\n");
    sleep(1);
    snd = sendto(s, &alice_public, DH_KEY_LENGTH, 0,(struct sockaddr *) addr, (socklen_t) slen);
    printf("Encrypting message...");
    char buf[] = "Wiadomość testowa 12345sssssssssssssssssss6";
    int size = strlen(buf);
    printf("Msg size: %d\n", size);
    encrypt(buf, (char*)alice_secret, size);
    snd = sendto(s, &size, sizeof(int), 0,(struct sockaddr *) addr, (socklen_t) slen);
    snd = sendto(s, &buf, size, 0,(struct sockaddr *) addr, (socklen_t) slen);
    
}
int main(void) {
    struct sockaddr_in adr_cli;
    int s = start_server(&adr_cli);
    alice_start(s, &adr_cli);
    close(s);
    return 0;
}