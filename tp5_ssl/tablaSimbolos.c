#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tablaSimbolos.h"

TablaScopes* initTS() {
    TablaScopes* ts = (TablaScopes*) malloc(sizeof(TablaScopes));
    ts->ambitos = createStack();
    abrirScope(ts); // Scope global
    return ts;
}

void destroyTS(TablaScopes* tabla) {
    while (!isEmpty(tabla->ambitos)) {
        Scope* s = (Scope*) pop(tabla->ambitos);

        destruirScope(s);

    }

    destroyStack(tabla->ambitos);

    free(tabla);

}



Scope* crearScope() {

    Scope* s = (Scope*) malloc(sizeof(Scope));

    s->cantidad = 0;

    s->simbolos = createArray(50);

    return s;

}



void destruirScope(Scope* s) {

    for (int i = 0; i < arraySize(s->simbolos); i++) {

        Simbolo* sym = (Simbolo*) findElemArray(s->simbolos, i);

        destruirSimbolo(sym);

    }

    destroyArray(s->simbolos);

    free(s);

}



void abrirScope(TablaScopes* tabla) {

    Scope* nuevo = crearScope();

    push(tabla->ambitos, nuevo);

    printf(">>> Nuevo scope abierto (nivel %d)\n", stackSize(tabla->ambitos));

}



void cerrarScope(TablaScopes* tabla) {

    if (!isEmpty(tabla->ambitos)) {

        Scope* actual = (Scope*) pop(tabla->ambitos);

        printf("<<< Cerrando scope (nivel %d)\n", stackSize(tabla->ambitos));

        destruirScope(actual);

    }

}



Simbolo* crearSimbolo ( 

    char* key,

    SimboloTipo clase,

    char* tipoDato,

    int lineaDeclaracion ) {
        Simbolo* s = (Simbolo*) malloc(sizeof(Simbolo));

        s->key = key;

        s->clase = clase;

        s->tipoDato = tipoDato;

        s->lineaDeclaracion = lineaDeclaracion;

        s->miembros = createArray(50);

        s->cantMiembros = 0;



        return s;

}



void destruirSimbolo(Simbolo* s){

    free(s->key);

    free(s->tipoDato);

    destroyArray(s->miembros);

    free(s);

}



// 1 (se agrego) o 0 duplicado

int agregarSimbolo(TablaScopes* tabla, Simbolo* nuevo) {

    Scope* actual = scopeActual(tabla);



    // Verificar duplicados en el mismo scope

    for (int i = 0; i < arraySize(actual->simbolos); i++) {

        Simbolo* existente = (Simbolo*) findElemArray(actual->simbolos, i);

        if (strcmp(existente->key, nuevo->key) == 0) {

            fprintf(stderr, "Error semántico: redeclaración de '%s' en el mismo scope (línea %d).\n",

                    nuevo->key, nuevo->lineaDeclaracion);

            return 0;

        }

    }



    insertElemArray(actual->simbolos, nuevo);

    actual->cantidad++;

    return 1;

}



void eliminarSimbolo(TablaScopes* tabla, Simbolo* sym) {

    Scope* actual = scopeActual(tabla);

    for(int i = 0; i < arraySize(actual->simbolos); i++) {

        Simbolo* s = (Simbolo*) findElemArray(actual->simbolos, i);

        if (strcmp(s->key, sym->key) == 0) {

            removeElemArray(actual->simbolos, i);

            actual->cantidad--;

        }

    }

}



//Buscar símbolo en todos los scopes (de adentro hacia afuera)

Simbolo* buscarSimbolo(TablaScopes* tabla, char* key) {

    node* actual = tabla->ambitos->top; //node con el scope actual y nodo al sig scope

    while (actual != NULL) {

        Scope* scope = (Scope*) actual->value;

        for (int i = 0; i < arraySize(scope->simbolos); i++) {

            Simbolo* s = (Simbolo*) findElemArray(scope->simbolos, i);

            if (strcmp(s->key, key) == 0) {

                return s;

            }

        }

        actual = actual->next; // siguiente scope exterior

    }

    return NULL; // no encontrado

}



Scope* scopeActual(TablaScopes* tabla) {

    if (isEmpty(tabla->ambitos)) return NULL;

    return (Scope*) tabla->ambitos->top->value;

}



Enumerador* crearEnumMember(char* nombre, int valor) {

    Enumerador* m = (Enumerador*) malloc(sizeof(Enumerador));

    m->nombre = strdup(nombre);

    m->valor = valor;

    return m;
}

Parametro* crearParametro(char* nombre, char* tipo) {
    Parametro* p = malloc(sizeof(Parametro));
    p->nombre = strdup(nombre);
    p->tipo = strdup(tipo);
    return p;
}

Expr* crearExpr(char* tipo, int esLvalue) {
    Expr* e = malloc(sizeof(Expr));
    e->tipo = tipo;
    e->esLvalue = esLvalue;
    return e;
}
