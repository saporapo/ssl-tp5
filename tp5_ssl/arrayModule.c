#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "arrayModule.h"

// Funciones públicas
Array* createArray(int capacidad_inicial) {
    Array* a = (Array*)malloc(sizeof(Array));
    a->elem = (arrItem*)malloc(sizeof(arrItem) * capacidad_inicial);
    a->len = 0;
    a->capacidad = capacidad_inicial;
    return a;
}

void destroyArray(Array* a) {
    free(a->elem);
    free(a);
}

void redimensionar(Array* a, int nueva_capacidad) {
    arrItem* nuevo_elem = (arrItem*)realloc(a->elem, sizeof(arrItem) * nueva_capacidad);
    a->elem = nuevo_elem;
    a->capacidad = nueva_capacidad;
}

// Función de inserción que maneja el redimensionamiento
void insertElemArray(Array* a, arrItem valor) {
    if(a->len >= a->capacidad) {
        int nueva_capacidad = a->capacidad *2;
        redimensionar(a, nueva_capacidad);
    }

    a->elem[a->len] = valor;
    a->len++;
}

arrItem removeElemArray(Array* a, int indice) {
    arrItem elemR = a->elem[indice];

    // acomodar elementos
    for (int i = indice; i < a->len - 1; i++) {
        a->elem[i] = a->elem[i + 1];
    }
    a->len--;

    return elemR;
}

arrItem findElemArray(Array* a, int indice) {
    return a->elem[indice];
}

int arraySize(Array* a) { 
    return a->len; 
}
