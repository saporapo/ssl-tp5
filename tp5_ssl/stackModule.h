#ifndef STACKMODULE_H_
#define STACKMODULE_H_

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef void* stackItem;

// Declaración anticipada: 'struct node' existe.
typedef struct node node;

// Definición completa usando 'struct node' para auto-referenciar.
struct node {
    stackItem value;
    node* next; // Usa el alias 'node' conocido
};

typedef struct {
    node* top;
} stack_t;

stack_t* createStack();
void destroyStack(stack_t* pila);
int isEmpty(const stack_t* pila);
void push(stack_t* pila, stackItem valor);
stackItem pop(stack_t* pila);
int stackSize(stack_t* pila);

#endif
