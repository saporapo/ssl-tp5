#ifndef ARRAYMODULE_H_
#define ARRAYMODULE_H_

#include <stddef.h>

#include <stdlib.h>
#include <string.h>

typedef void* arrItem;

struct Array {
    arrItem* elem;
    int len;
    int capacidad;
};

typedef struct Array Array;

Array* createArray(int capacidad_inicial);
void destroyArray(Array* a);
void insertElemArray(Array* a, arrItem valor);
arrItem removeElemArray(Array* a, int indice);
arrItem findElemArray(Array* a, int indice);
int arraySize(Array* a);

#endif