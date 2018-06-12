#ifndef MESSAGE_H
#define MESSAGE_H
#define MESSAGE_SIZE 512
#define KEY_SIZE 16
#define DH_PUBLIC 1
#define MESSAGE 2
char key[KEY_SIZE] = "TESTKLUCZA12356";


typedef struct {
    int  size;
    int  type;
    char text[MESSAGE_SIZE];
    char key[KEY_SIZE];
} message_t;


void print_msg(message_t *msg);
#endif // !
