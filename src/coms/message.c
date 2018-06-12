#include "message.h"
#include <stdio.h>

void print_msg(message_t *msg) {
    printf("Message size: %d\n", msg->size);
    printf("Message key: %s\n", msg->key);
    printf("Content: \n%s\n", msg->text);
}