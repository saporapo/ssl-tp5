#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stackModule.h"
#include "arrayModule.h"

typedef enum {
    VARIABLE,
    ENUM,
    FUNCION,
} SimboloTipo;

typedef struct {
    char* key;              // id
    SimboloTipo clase;      // var/fun
    char* tipoDato;         // tipo de dato
    int lineaDeclaracion;   // linea en la que se declaro
    int nivelScope;         // scope declaracion
    int constante;          // 1 cte o 0 no cte
    int externo;            // 1 externo o 0 no
    int unsg;               // 1 unsigned o 0 signed

    Array* miembros;       // funcion: array con el tipoDato parametros
                          // enum: array con valores del enum
    int cantMiembros;     // cantParametros funcion o cantVals enum
} Simbolo;

typedef struct {
    char* nombre;
    int valor; // guardo valor del enumerador en la lst enumeradores de declaEnum
} Enumerador; // me sirve tmb para guardar parametros de funciones

typedef struct {
    Array* simbolos;  // array de simbolos
    int cantidad;
} Scope;

typedef struct {
    stack_t* ambitos;   // pila de scopes
} TablaScopes;

TablaScopes* initTS();
void destroyTS(TablaScopes* tabla);
Scope* crearScope();
void destruirScope(Scope* s);
void abrirScope(TablaScopes* tabla);
void cerrarScope(TablaScopes* tabla);
Simbolo* crearSimbolo ( 
    char* key,
    SimboloTipo clase,
    char* tipoDato,
    int lineaDeclaracion,
    int nivelScope,
    int constante,
    int externo,
    int unsg ) ;
void destruirSimbolo(Simbolo* s);
int agregarSimbolo(TablaScopes* tabla, Simbolo* nuevo);
void eliminarSimbolo(TablaScopes* tabla, Simbolo* sym);
Simbolo* buscarSimbolo(TablaScopes* tabla, char* key);
Scope* scopeActual(TablaScopes* tabla);
Enumerador* crearEnumMember(char* nombre, int valor);

#endif