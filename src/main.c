#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include "cryptography/print.h"
#include "cryptography/base64.h"


#define MESSAGE_SIZE 512

typedef struct {
    int msg_size;
    char *text;
} message_t;

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
    print();
    int pid, status;

    // Create pipe for communication between processes
    int msg_pipe[2];
    pipe(msg_pipe);

    // TODO use posix queues
    // Child process
    if((pid = fork()) == 0) {
        char secret_message[MESSAGE_SIZE];
        close(msg_pipe[1]);
        int rd = read(msg_pipe[0], secret_message, sizeof(secret_message));
        if(rd == 0)
            printf("Empty Message.\n");
        else {
            printf("Child proces recived message: \n");
            printf("%s", secret_message);
        }
        exit(0);
    }
    // Parent process
    else {
        // Get message and write it to pipe
        char message[MESSAGE_SIZE];
        printf("Enter a message: \n");
        fgets(message, MESSAGE_SIZE, stdin);
        close(msg_pipe[0]);
        write(msg_pipe[1], message, MESSAGE_SIZE);
    }

    // Wait for process to finish
    pid = wait(&status);
    printf("Child process finished with status: %d.\n", WEXITSTATUS(status));
}

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

int main(int argc, char* argv[]) {
    // run();
    b64_encode_test();
    return 0;
}
