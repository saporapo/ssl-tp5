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

    Array* miembros;    // funcion: array con el tipoDato parametros

                        // enum: array con valores del enum
    int cantMiembros;   // cantParametros funcion o cantVals enum

} Simbolo;



typedef struct {

    char* nombre;

    int valor; // guardo valor del enumerador de la lista_enumeradores de declaEnum

} Enumerador;



typedef struct {

    char* nombre;
    int valor; // guardo valor del enumerador de la lista_enumeradores de declaEnum
} Enumerador;

typedef struct {
    char* nombre;
    char* tipo;
} Parametro; // guardo parametro de lista_parametros de declaFuncion para cuerpoFun_opt

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
    int nivelScope ) ;
void destruirSimbolo(Simbolo* s);

int agregarSimbolo(TablaScopes* tabla, Simbolo* nuevo);

void eliminarSimbolo(TablaScopes* tabla, Simbolo* sym);

Simbolo* buscarSimbolo(TablaScopes* tabla, char* key);

Scope* scopeActual(TablaScopes* tabla);

Enumerador* crearEnumMember(char* nombre, int valor);
Parametro* crearParametro(char* nombre, char* tipo);

#endif
