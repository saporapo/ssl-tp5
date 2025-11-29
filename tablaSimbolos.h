#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "stackModule.h"
#include "arrayModule.h"

typedef enum {
    VARIABLE,
    ENUMR,
    FUNCION,
} SimboloTipo;

struct Simbolo {
    char* key;              // id
    SimboloTipo clase;      // var/fun
    char* tipoDato;         // tipo de dato
    int lineaDeclaracion;   // linea en la que se declaro
    int nivelScope;         // scope declaracion
    Array* miembros;    // funcion: array con el tipoDato parametros
                        // enum: array con valores del enum
    int cantMiembros;   // cantParametros funcion o cantVals enum
};
typedef struct Simbolo Simbolo;

struct Enumerador {
    char* nombre;
    int valor;
};
typedef struct Enumerador Enumerador;

struct Parametro {
    char* nombre;
    char* tipo;
}; // guardo parametro de lista_parametros de declaFuncion para cuerpoFun_opt
typedef struct Parametro Parametro;

struct Expr {
    char* tipo;   // "int", "double", "float", "char", "char*", enum (identificador, "k")
    int esLvalue; // 1 si se puede asignar (identificador), 0 en otros casos
};
typedef struct Expr Expr;

struct Scope {
    Array* simbolos;  // array de simbolos
    int cantidad;
};
typedef struct Scope Scope;

struct TablaScopes {
    stack_t* ambitos;   // pila de scopes
};
typedef struct TablaScopes TablaScopes;


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
    int nivelScope );
void destruirSimbolo(Simbolo* s);
int agregarSimbolo(TablaScopes* tabla, Simbolo* nuevo);
void eliminarSimbolo(TablaScopes* tabla, Simbolo* sym);
Simbolo* buscarSimbolo(TablaScopes* tabla, char* key);
Scope* scopeActual(TablaScopes* tabla);
Enumerador* crearEnumMember(char* nombre, int valor);
Parametro* crearParametro(char* nombre, char* tipo);
Expr* crearExpr(char* tipo, int esLvalue);

#endif
