#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>
#include "util.h"
#include "cryptography/dhexchange.h"
#define BUFLEN 80
#define KROKI 10
#define PORT 9948
#define SRV_IP "127.0.0.1"
typedef struct {
    int typ;
    char buf[BUFLEN];
} msgt;

int start_client(char* adress, struct sockaddr_in *adr_serw) {
    printf("%s\n", adress);
    int s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    error_check(s, "socket");
    printf("Created socket %d on port %d\n", s, PORT);
    adr_serw->sin_family = AF_INET;
    adr_serw->sin_port = htons(PORT);
    error_check(inet_aton(adress, &adr_serw->sin_addr),"inet_aton()");
    return s;
}

void bob_start(int s, struct sockaddr_in *adr) {
    struct sockaddr_in adr_x;
    int snd,rec, blen = sizeof(message_t), slen = sizeof(struct sockaddr_in);
    DH_KEY bob_private, bob_secret, bob_public, alice_public;
    DH_generate_key_pair(bob_public, bob_private);
    _print_key("Bob public", bob_public);
    _print_key("Bob private", bob_private);
    printf("Exchanging keys...\n");
    printf("Sending public...\n");
    snd = sendto(s, &bob_public, DH_KEY_LENGTH, 0,(struct sockaddr *) adr, (socklen_t) slen);
    sleep(1);
    printf("Reciving public...\n");
    rec = recvfrom(s, &alice_public, DH_KEY_LENGTH, 0, (struct sockaddr *) adr, (socklen_t*) &slen);
    printf("Public received, generating secret...\n");
    DH_generate_key_secret(bob_secret, bob_private, alice_public);
    _print_key("Bob secret", bob_secret);
    sleep(1);
    char buf2[] = "Wiadomość testowa abcsssssssssssssssssssssd1234567";
    int size;
    char buf[512];
  
    rec = recvfrom(s, &size, sizeof(int), 0, (struct sockaddr *) adr, (socklen_t*) &slen);
    printf("Msg size: %d\n", size);
    rec = recvfrom(s, &buf, size, 0, (struct sockaddr *) adr, (socklen_t*) &slen);
 
    printf("Encrypted msg: %s\n", buf);
    printf("Encrypted msg size: %d\n", strlen(buf));
    decrypt(buf,(char*)bob_secret,size);
    printf("Decrypted msg: %s\n", buf);
    printf("Decrypted msg size: %d\n", strlen(buf));
}
int main(int argc, char * argv[]) {
    struct sockaddr_in server_adress;
    int s = start_client(argv[1], &server_adress);
    bob_start(s, &server_adress);    
    close(s);
    return 0;
}