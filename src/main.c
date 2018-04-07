#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>


#define MESSAGE_SIZE 512

typedef struct {
  int msg_size;
  char *text;
} message_t;

char* GetMessage() {
  // Read the msg from stdin. The size of msg is arbitrary - memory
  // is reallocated as needed
  char* message = (char*)calloc(1,1), buffer[MESSAGE_SIZE];
  printf("Enter a message: \n");
  // Only pressing ctrl+d or ctrl+z stops reading the message
  while (fgets(buffer, MESSAGE_SIZE, stdin)) {
    message = (char*) realloc(message, strlen(message) + 1 + strlen(buffer));
    if(!message)
      perror("fgets");
    strcat(message, buffer);
  }
  return message;
}

int main(int argc, char* argv[]) {
  int pid, status;

  // Create pipe for communication between processes
  int msg_pipe[2];
  pipe(msg_pipe);

  // Child Process
  if((pid = fork()) == 0) {
    char secret_message[MESSAGE_SIZE];
    close(msg_pipe[1]);
    int rd = read(msg_pipe[0], secret_message, sizeof(secret_message));
    if(rd == 0)
      printf("Empty Message.\n");
    printf("Child proces recived message: \n");
    printf("%s", secret_message);
    exit(0);
  }
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
