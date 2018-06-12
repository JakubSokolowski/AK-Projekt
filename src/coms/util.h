#ifndef UTIL_H
#define UTIL_H
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

void error_check(int x, const char *s) {
    if(x <= 0) {
        fprintf(stderr, "%s:%d: ", __func__, __LINE__);
        perror(s);
        _exit(1);
    }   
}
#include "message.h"
#endif // !UTIL_H


