#include <stdio.h>
#include <dlfcn.h>

typedef int(*fptr)(int, int);

int main(){
    char op[10];
    int num1, num2;
    while(1){
        if(scanf("%s %d %d", op, &num1, &num2) != 3)
            break;
        char lib[20];
        sprintf(lib, "./lib%s.so", op);
        void* handle=dlopen(lib, RTLD_LAZY);
        fptr operation = dlsym(handle, op);
        int result=operation(num1, num2);
        printf("%d\n", result);
        dlclose(handle);
    }
    return 0;
}