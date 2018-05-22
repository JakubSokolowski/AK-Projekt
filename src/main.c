#include <stdio.h>
#include <mqueue.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "cryptography/print.h"
#include "cryptography/base64.h"
#include "cryptography/tea.h"


#define MESSAGE_SIZE 512
#define KEY_SIZE 16
char key[KEY_SIZE] = "TESTKLUCZA123456";

#define CHECK(x) \
    do { \
        if ( 0>(x)){ \
            fprintf(stderr, "%s:%d: ", __func__, __LINE__); \
            perror(#x); \
            exit(-1); \
        } \
    } while (0) \

typedef struct {
    int  size;
    char text[MESSAGE_SIZE];
    char key[KEY_SIZE];
} message_t;


void b64_encode_test() {
    char message[] = "any carnal pleasure.";
    char encoded[512];
    int len = sizeof(message) / sizeof(char);
    base64_encode(message, encoded, len);
    printf("Msg: %s\nYW55IGNhcm5hbCBwbGVhc3VyZS4=\n%s\n", message, encoded);
    char message2[] = "any carnal pleasure";
    char encoded2[512];
    int len2 = sizeof(message2) / sizeof(char);
    base64_encode(message2, encoded2, len2);
    printf("Msg: %s\nYW55IGNhcm5hbCBwbGVhc3VyZQ==\n%s\n", message2, encoded2);
    char message3[] = "any carnal pleasur";
    char encoded3[512];
    int len3 = sizeof(message3) / sizeof(char);
    int len4 = base64_encode(message3, encoded3, len3);
    printf("Msg: %s\nYW55IGNhcm5hbCBwbGVhc3Vy\n%s\n", message3, encoded3);
    printf("Len 24: %d\n", len4);
}

void b64_decode_test() {
    int len, len_out;
    char decoded[512];
   
    char message1[] = "YW55IGNhcm5hbCBwbGVhc3VyZS4=";
    len = sizeof(message1) / sizeof(char);
    len_out = base64_decode(message1, decoded, len);
    decoded[len_out] = 0; // set end of string
    printf("Msg: %s\n%s\n", message1, decoded);
   
    char message2[] = "YW55IGNhcm5hbCBwbGVhc3VyZQ==";
    len = sizeof(message2) / sizeof(char);
    len_out = base64_decode(message2, decoded, len);
    decoded[len_out] = 0; // set end of string
    printf("Msg: %s\n%s\n", message2, decoded);
   
    char message3[] = "YW55IGNhcm5hbCBwbGVhc3Vy";
    len = sizeof(message3) / sizeof(char);
    len_out = base64_encode(message3, decoded, len);
    decoded[len_out] = 0; // set end of string
    printf("Msg: %s\n%s\n", message3, decoded);
}


void tea_block_encrypt_test() {
    uint32_t k[4] = {0x32,0x32,0x43,0xAB};
    uint32_t actual[] = {0xFFFFFFFF, 0xFFFFFFFF}; 
    encrypt_block(actual, k);   
}
void tea_encrypt_test() {
    uint32_t k[4] = {0x32,0x32,0x43,0xAB};
    uint32_t actual[] = {0xFFFFFFFF, 0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF};
    int len = sizeof(actual) / sizeof(char);
    printf("[%X][%X][%X][%X]\n", actual[0],actual[1],actual[2],actual[3]); 
    encrypt(actual, k, len);
    printf("[%X][%X][%X][%X]\n", actual[0],actual[1],actual[2],actual[3]); 
    decrypt(actual, k, len);
    printf("[%X][%X][%X][%X]\n", actual[0],actual[1],actual[2],actual[3]); 
}
void tea_encryption_text_test() {
    char key[16] = "TESTKLUCZA123456";
    char message[] = "Hello World! Nice to meet you asdashdasdgakshda!";
    int size = sizeof(message)/ sizeof(char);
    printf("%s\n", message);
    encrypt(message,key, size);
    printf("%s\n", message);
    decrypt(message,key,size);
    printf("%s\n", message);
} 
void mq_run() {
    
    mq_unlink("queue");
    mqd_t mq;
    struct mq_attr attr;
    attr.mq_msgsize = sizeof(message_t);
    attr.mq_maxmsg = 1;
    attr.mq_flags = 0;
    attr.mq_curmsgs = 0;
  
    mq = mq_open("/queue", O_RDWR | O_CREAT | O_NONBLOCK, 0777, &attr);
    char msg_text[] = "Wiadomość testowa 123456!";
    char msg_key[] = "TESTKLUCZA123456";
    int size = (int)strlen(msg_text);   
    printf("Before encryption: %s\n", msg_text);
    encrypt(msg_text, msg_key, size);
    message_t msg;
    sprintf(msg.text,"%s", msg_text);
    sprintf(msg.key, "%s", msg_key);
    msg.size = size;

    printf("Key sent: %s\n",msg.key);
    printf("Encrypted msg sent: %s\n", msg.text);
    printf("Len of msg sent: %d\n", msg.size);
    printf("Size of message_type: %d\n", (int)sizeof(message_t));

    mq_send(mq,(char*)&msg, sizeof(message_t), 0);
    mq_close(mq);

    int pid;
    if((pid = fork()) == 0) {  
        mqd_t mq = mq_open("/queue", O_RDWR | O_NONBLOCK);
        sleep(1);
        message_t msg;
        mq_receive(mq, (char*)&msg, sizeof(message_t), NULL);
        printf("\nKey received: %s\n", msg.key);
        printf("Message received: %s\n", msg.text);
        printf("Len of msg: %d\n", msg.size);
        decrypt(msg.text, msg.key, msg.size);
        printf("Decrypted msg: %s\n", msg.text);
        mq_close(mq);
        exit(0);
    }
   
    int status;
    pid = wait(&status);
 
    printf("Child process finished with status: %d.\n", WEXITSTATUS(status));
} 

char* get_message() {
    // Read the msg from stdin. The size of msg is arbitrary - memory
    // is reallocated as needed
    char* message = (char*)calloc(1,1), buffer[MESSAGE_SIZE];
    printf("Enter a message: \n");
    // Only pressing ctrl+d or ctr+z stops reading the message
    while (fgets(buffer, MESSAGE_SIZE, stdin)) {
        message = (char*) realloc(message, strlen(message) + 1 + strlen(buffer));
        if(!message)
            perror("fgets");
        strcat(message, buffer);
    }
    return message;
}

void run() {
    int pid, status;
    // Create pipe for communication between processes
    int msg_pipe[2];
    pipe(msg_pipe);

    // TODO use posix queues
    // Child process
    if((pid = fork()) == 0) {
        int rd;
        message_t msg;
        close(msg_pipe[1]); 
        rd = read(msg_pipe[0], &msg, sizeof(message_t));
        if(rd == 0)
            printf("Empty Message.\n");
        else {
            printf("\nKey received: %s\n", msg.key);
            printf("Msg received: %s\n", msg.text);
            char b64[512];
            base64_encode(msg.text, b64, msg.size);
            printf("b64 encoded: %s\n", b64);
            decrypt(msg.text,msg.key,msg.size);
            printf("Msg decrypted: %s\n", msg.text);
        }
        exit(0);
    }
    // Parent process
    else {
        char msg_text[] = "Wiadomość testowa 123456!";
        char msg_key[] = "TESTKLUCZA123456";
        int size = (int)strlen(msg_text);   
        printf("Before encryption: %s\n", msg_text);
        encrypt(msg_text, msg_key, size);
        message_t msg;
        sprintf(msg.text,"%s", msg_text);
        sprintf(msg.key, "%s", msg_key);
        msg.size = size;
        printf("Key sent: %s\n",msg.key);
        printf("Encrypted msg sent: %s\n", msg.text);
        char b64[512];
        base64_encode(msg.text, b64, msg.size);
        printf("b64 encoded: %s\n", b64);
        printf("Len of msg sent: %d\n", msg.size);
        close(msg_pipe[0]);
        write(msg_pipe[1], &msg, sizeof(message_t));
    }

    // Wait for process to finish
    pid = wait(&status);
    printf("Child process finished with status: %d.\n", WEXITSTATUS(status));
}


int main(int argc, char* argv[]) {
    run();
    //mq_run();
    // b64_encode_test();
    // tea_encryption_text_test();
    return 0;
}
