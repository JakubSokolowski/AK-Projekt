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
#include "cryptography/tea.h"
#include "cryptography/base64.h"
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
    printf("Utworzona gniazdo: %d na porcie %d\n", s, PORT);
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
    _print_key("Klucz publiczny Alice", alice_public);
    _print_key("Klucz prywatny Alice", alice_private);
   
    rec = recvfrom(s, &bob_public, DH_KEY_LENGTH, 0, (struct sockaddr *) addr, (socklen_t*) &slen);
    printf("Wymiana kluczy...\n");
    printf("\nOdbieranie klucza publicznego Boba...\n");
    error_check(rec, "DHPUBLIC"); 
    printf("Klucz odebrany, generowanie sekretu...\n");
    DH_generate_key_secret(alice_secret, alice_private, bob_public);
    _print_key("Klucz sekretny Alice", alice_secret);
    printf("Alice wysyła klucz publiczny...\n");
    snd = sendto(s, &alice_public, DH_KEY_LENGTH, 0,(struct sockaddr *) addr, (socklen_t) slen);
    char buf[] = "Protokół Diffiego-Hellmana- protokół uzgadniania kluczy szyfrujących opracowany przez Witfielda Diffiego oraz Martina Hellmana 1976";
    printf("\nWiadomość:\n%s\n", buf);
    printf("Szyfrowanie wiadomośći...\n");       
    char enc[512];
    int size = strlen(buf);
    encrypt(buf, (char*)alice_secret, size);
    // base64_encode(buf, enc, size);
    printf("Wysyłanie zaszyfrowanej wiadomośći...\n"); 
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