%{
#include<math.h>
#include<stdlib.h>
#include<stdio.h>
#include<ctype.h>
#include<string.h>
#include "tablaSimbolos.h"

extern int yylex();
int yyerror(const char* s);

extern FILE* yyin;
extern char* yytext;
extern void iniciarUbicaciones();

int errorCount = 0;

TablaScopes* tablaGral = NULL;
int nivelScope = 0;
char* tipoDatoActual = NULL;
int esConstante = 0, esExterno = 0, esUnsigned = 0;

/* Helper para reportar errores */
void report_error(const char *where, int line, const char *msg) {
    fprintf(stderr, "Error %s <línea:%d>: %s\n", where ? where : "desconocido", line, msg ? msg : "error");
    fprintf(stderr, "Token: '%s'\n", yytext);
    errorCount++;
}
/* para abrir scope */
void reportAbrirScope(const char *msg) {
    nivelScope++; 
    abrirScope(tablaGral); 
    fprintf(stdout, "Abriendo scope nivel %d %s\n", nivelScope, msg);
}
/* para cerrar scope */
void reportCerrarScope(const char *msg) {
    cerrarScope(tablaGral); 
    fprintf(stdout, "Cerrando scope nivel %d %s\n", nivelScope, msg);
    nivelScope--;
}
/* para validar identificadores */
// void validarExpresion(const char* expr, int line) {
//     if (expr && esIdentificador(expr)) {
//         Simbolo* s = buscarSimbolo(tablaGral, expr);
//         if (!s)
//             report_error("Error semántico", line, "identificador no declarado");
//     }
// }
// tipos compatibles para asignaciones
int tiposCompatibles(char* t1, char* t2) {
    if (!t1 || !t2) return 0;
    if (strcmp(t2, "error") == 0) return 0;

    if (strcmp(t1, t2) == 0) return 1;

    // conversiones simples
    if ((strcmp(t1,"double")==0 && strcmp(t2,"int")==0) ||
        (strcmp(t1,"double")==0 && strcmp(t2,"float")==0) ||
        (strcmp(t1, "float") == 0 && strcmp(t2, "int") == 0) ||
        (strcmp(t1, "int") == 0 && strcmp(t2, "char") == 0))
        return 1;
    
    // asignacion int a char por ascii extendido
    if (strcmp(t1, "char") == 0 && strcmp(t2, "int") == 0 &&
        t2 >= 0 && t2 <= 255) return 1;

    return 0;
}
int valorPerteneceAlEnum(Simbolo* enumSimbolo, char* valor) {
    for (int i = 0; i < arraySize(enumSimbolo->miembros); i++) {
        Enumerador* enumVal = (Enumerador*) findElemArray(enumSimbolo->miembros, i);
        if (itoa(enumVal->valor) == valor || enumVal->nombre == valor) return 1;
    }
    return 0;
}
%}

%define parse.error verbose // mensajes de error detallados
%locations // manejo de ubicaciones

%union {
    int ival; // decimal, octal, hex
    double dval; // real
    char cval; // caracter
    char* cadena; // cadena, tipo_dato, identificador
    Array* arr;
}

// token es para definir el tipo de dato que almacena un terminal
%token <ival> ENTERO //defino que entero es un tipo ival -> es int de union
%token <dval> NUMERO
%token <cval> CARACTER
%token <cadena> CADENA TIPO_DATO IDENTIFICADOR
%token <cadena> RETURN FOR WHILE ELSE IF
%token <cadena> CONST UNSIGNED EXTERN ENUM
%token INCREMENTO DECREMENTO MAS_IGUAL MENOS_IGUAL DIV_IGUAL POR_IGUAL
%token IGUALDAD DIFERENTE AND OR MAYOR_IGUAL MENOR_IGUAL

// type es para definir el tipo de dato que almacena un no terminal
%type <cadena> expresion expresion_opt expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo expPrimaria
%type <cadena> inicializacion_opt parametro
%type <arr> lista_ids lista_enumeradores ids_opt parametros_opt

/* Precedencia y asociatividad */
%left OR
%left AND
%left IGUALDAD DIFERENTE
%left '<' '>' MENOR_IGUAL MAYOR_IGUAL
%left '+' '-'
%left '*' '/'
%right '!' INCREMENTO DECREMENTO 
%right UNARIO  // UNARIO para -, !
%right '?' ':' 
%right '=' MAS_IGUAL MENOS_IGUAL DIV_IGUAL POR_IGUAL

%start input

%%

input
    : declaraciones_opt sentencias_opt
    ;

declaraciones_opt
    : /* vacío */
    | declaraciones_opt declaracion
    | declaraciones_opt error {
        report_error("en declaraciones_opt", @$.first_line, "declaracion invalida");
        yyerrok;
        yyclearin;
    }
    ;

declaracion
    : declaVarSimples
    | declaFuncion
    | declaEnum
    
    | error {
        report_error("en declaracion", @$.first_line, "Token inesperado a nivel de declaración.");
        yyerrok;
        yyclearin;
    }
    ;

declaEnum //me parece que un enum es constante
    : ENUM IDENTIFICADOR '{' lista_enumeradores '}' lista_ids ';' {
        char* nombre = $2; // obligo a enum a tener key para que sea menos complejo
        Simbolo* s = crearSimbolo(nombre, ENUM, strdup("enum"), @$.first_line, nivelScope, 1, 0, 0);
        // si esta declarado en el scope actual --> redeclarado
        if (!agregarSimbolo(tablaGral, s)) {
            report_error("en declaEnum", @$.first_line, "enum redeclarado.");
            destruirSimbolo(s);
        } else {
            /* lista_enumeradores devuelve Array* de char* con noms de los enumeradores*/
            s->miembros = $4;
            s->cantMiembros = arraySize($4);
            if ($6) {
                for (int i = 0; i < arraySize($6); i++) {
                    char* varEnum = (char*) findElemArray($6, i); // variable declarada al final del enum
                    Simbolo* t = crearSimbolo(varEnum, VARIABLE, nombre, @$.first_line, nivelScope, 0, 0, 0);
                    if (!agregarSimbolo(tablaGral, s)) {
                        report_error("en id_opt", @$.first_line, "existe variable con ese nombre");
                        destruirSimbolo(s);
                    } else {
                        t->miembros = s->miembros; // a la variable solo puede asignarsele 1 de los enumeradores
                        t->cantMiembros = s->cantMiembros;
                    }
                }
                printf("Enum '%s' agregado con %d miembros (scope %d)\n", nombre, s->cantMiembros, nivelScope);
            } else {
                printf("Enum '%s' agregado con %d miembros (scope %d)\n", nombre, s->cantMiembros, nivelScope);
            }
        }
    }

    | ENUM IDENTIFICADOR error lista_enumeradores '}' lista_ids ';' {
        report_error("en declaEnum", @$.first_line, "Falta la llave de apertura '{'.");
        yyerrok;
        yyclearin;
    }
    | ENUM IDENTIFICADOR '{' lista_enumeradores error ';' {
        report_error("en declaEnum", @$.first_line, "falta la llave de cierre '}'. Recuperado hasta ';'.");
        yyerrok;
        yyclearin;
    }
    | ENUM IDENTIFICADOR '{' lista_enumeradores '}' lista_ids error {
        report_error("en declaEnum", @$.first_line, "Falta el punto y coma ';' al final de la definición de enum.");
        yyerrok;
        yyclearin;
    }
    | ENUM IDENTIFICADOR '{' error '}' lista_ids ';' {
        report_error("en declaEnum", @$.first_line, "error en lista_enums");
        yyerrok;
        yyclearin;
    }
    | ENUM IDENTIFICADOR '{' lista_enumeradores '}' error ';' {
        report_error("en declaEnum", @$.first_line, "error en lista_ids");
        yyerrok;
        yyclearin;
    }
    ;

ids_opt
    : /* vacío */ { $$ = NULL; }
    | lista_ids { $$ = $1; }
    | error {
        report_error("en ids_opt", @$.first_line, "error en lista_ids");
        yyerrok;
        yyclearin;
    }
    ;

lista_ids
    : IDENTIFICADOR {
        Array* arr = createArray(10);
        char* e = strdup($1);
        insertElemArray(arr, e);
        $$ = arr;
    }
    | lista_ids ',' IDENTIFICADOR {
        char* e = strdup($3);
        insertElemArray($1, e);
        $$ = $1;
    }
    | lista_ids error IDENTIFICADOR {
        report_error("en lista_ids", @$.first_line, "Identificadores separados incorrectamente, se esperaba ','");
        yyerrok;
        yyclearin;
    }
    ;

lista_enumeradores
    : IDENTIFICADOR {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember($1, 0);
        insertElemArray(arr, em);
        $$ = arr;
    }
    | IDENTIFICADOR '=' ENTERO {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember($1, $3);
        insertElemArray(arr, em);
        $$ = arr;
    }
    | lista_enumeradores ',' IDENTIFICADOR {
        int valor = ((Enumerador*)findElemArray($1, arraySize($1)-1))->valor + 1;
        Enumerador* em = crearEnumMember($3, valor);
        insertElemArray($1, em);
        $$ = $1;
    }
    | lista_enumeradores ',' IDENTIFICADOR '=' ENTERO {
        Enumerador* em = crearEnumMember($3, $5);
        insertElemArray($1, em);
        $$ = $1;
    }

    | lista_enumeradores error IDENTIFICADOR {
        report_error("en lista_enumeradores", @$.first_line, "Enumeradores separados incorrectamente, se esperaba ','");
        yyerrok;
        yyclearin;
    }
    | lista_enumeradores error IDENTIFICADOR '=' ENTERO {
        report_error("en lista_enumeradores", @$.first_line, "Enumeradores separados incorrectamente, se esperaba ','");
        yyerrok;
        yyclearin;
    }
    | lista_enumeradores ',' IDENTIFICADOR error ENTERO {
        report_error("en lista_enumeradores", @$.first_line, "Valor asignado a enumerador incorrectamente, se esperaba '='");
        yyerrok;
        yyclearin;
    }
    ;

declaVarSimples
    : TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $1;
        esConstante = 0; esExterno = 0; esUnsigned = 0;
    }
    | TIPO_DATO '*' listaVarSimples ';' { // caso char*
        if(strcmp($1, "char") == 0){
            tipoDatoActual = "char*";
            esConstante = 0; esExterno = 0; esUnsigned = 0;
        } else {
            report_error("en declaVarSimple", @$.first_line, "Tipo de dato no analizable");
            yyerrok;
            yyclearin;
        }
        
    }
    | UNSIGNED TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $2;
        esConstante = 0; esExterno = 0; esUnsigned = 1;
    }
    | CONST TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $2;
        esConstante = 1; esExterno = 0; esUnsigned = 0;
    }
    | CONST UNSIGNED TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $3;
        esConstante = 1; esExterno = 0; esUnsigned = 1;
    }
    | EXTERN TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $2;
        esConstante = 0; esExterno = 1; esUnsigned = 0;
    }
    | EXTERN UNSIGNED TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $3;
        esConstante = 0; esExterno = 1; esUnsigned = 1;
    }
    | EXTERN CONST TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $3;
        esConstante = 1; esExterno = 1; esUnsigned = 0;
    }
    | EXTERN CONST UNSIGNED TIPO_DATO listaVarSimples ';' {
        tipoDatoActual = $4;
        esConstante = 1; esExterno = 1; esUnsigned = 1;
    }
    | IDENTIFICADOR listaVarSimples ';' { //caso de var de un enum
        tipoDatoActual = $1;
        esConstante = 0; esExterno = 0; esUnsigned = 0;
    }

    | TIPO_DATO error ';' {
        report_error("en declaVarSimples", @$.first_line, "Lista de variables o inicialización mal formada. Recuperado hasta ';'");
        yyerrok;
        yyclearin;
    }
    | TIPO_DATO listaVarSimples error {
        report_error("en declaVarSimples", @$.first_line, "Falta ';' al final de la declaración de variables.");
        yyerrok;
        yyclearin;
    }
    ;

listaVarSimples
    : unaVarSimple
    | listaVarSimples ',' unaVarSimple

    | listaVarSimples error unaVarSimple {
        report_error("en listaVarSimples", @$.first_line, "Separación inválida de variables, se esperaba','");
        yyerrok;
        yyclearin; /* descarta el token actual, evita loops de error */
    }
    | listaVarSimples ',' error { 
        report_error("en listaVarSimples", @$.first_line, "Coma de más al final de la lista de variables o variable mal formada.");
        yyerrok;
        yyclearin;
    }
    ;

unaVarSimple
    : IDENTIFICADOR inicializacion_opt // inicializacion necesito que guarde val de enum o tipoDato de la expresion
        {
            char* nombre = $1;

            Simbolo* v = crearSimbolo(
                nombre,
                VARIABLE,
                tipoDatoActual,  // global
                @1.first_line,
                nivelScope,
                esConstante,
                esExterno,
                esUnsigned
            );

            if (!agregarSimbolo(tablaGral, v)) {
                report_error("en varSimple", @$.first_line, "variable redeclarada en el mismo scope");
                destruirSimbolo(v);
            } else {
                // Si hay inicialización, verificamos compatibilidad
                if ($2) {  // si la inicialización devuelve el tipo de la expresión
                    char* tipoExp = $2;
                    if(v->tipoDato != "char" || v->tipoDato != "char*" || v->tipoDato != "int"
                    || v->tipoDato != "double" || v->tipoDato != "float"){
                        Simbolo* tipoEnum = buscarSimbolo(tablaGral, v->tipoDato); //si es enum conseguira declaENum
                        if(tipoEnum){
                            if(valorPerteneceAlEnum(tipoEnum, tipoExp)) {
                                printf("Declaración válida de variable(s) <línea:%d>\n", @$.first_line);
                            }
                            else {
                                report_error("en varSimple", @$.first_line, "tipo incompatible en asignacion");
                                destruirSimbolo(tipoEnum);
                                eliminarSimbolo(tablaGral, v);
                                destruirSimbolo(v);
                            }
                        } else {
                            report_error("en varSimple", @$.first_line, "tipo dato no declarado");
                            eliminarSimbolo(tablaGral, v);
                            destruirSimbolo(v);
                        }
                    } else { // no verifico const ni unsg para mas facil
                        if(v->tipoDato == "char" || v->tipoDato == "char*" || v->tipoDato == "int"
                        || v->tipoDato == "double" || v->tipoDato == "float") {
                            if (!tiposCompatibles(v->tipoDato, tipoExp)) {
                                report_error("en varSimple", @$.first_line, "tipo incompatible en asignacion");
                                eliminarSimbolo(tablaGral, v);
                                destruirSimbolo(v);
                            } else {
                                printf("Declaración válida de variable(s) <línea:%d>\n", @$.first_line);
                            }
                        } else {
                            report_error("en varSimple", @$.first_line, "tipo dato no analizable");
                            eliminarSimbolo(tablaGral, v);
                            destruirSimbolo(v);
                        }
                    }
                    
                }
            } 
        }
    | IDENTIFICADOR error {
        report_error("en unaVarSimple", @$.first_line, "error en inicializacion de variable");
        yyerrok;
        yyclearin;
    }
    ;

inicializacion_opt
    : /* vacío */ { $$ = NULL; }
    | '=' expresion { $$ = $2; }

    | '=' error { 
        report_error("en inicializacion_opt", @$.first_line, "Expresión inválida después de '=' en inicialización");
        yyerrok;
        yyclearin;
    }
    | error expresion {
        report_error("en inicializacion_opt", @$.first_line, "Falta el operador de asignación '=' en la inicialización.");
        yyerrok;
        yyclearin;
    }
    ;

declaFuncion
    : TIPO_DATO IDENTIFICADOR '(' parametros_opt ')' cuerpoFuncion_opt {
        tipoDatoActual = $1;
        Simbolo* s = crearSimbolo(
            $2,
            FUNCION,
            tipoDatoActual,
            @$.first_line,
            nivelScope,
            0, 0, 0
        );
        if (!agregarSimbolo(tablaGral, s)) {
            report_error("en declaFuncion", @$.first_line, "funcion redeclarada.");
            destruirSimbolo(s);
        } else {
            if($4) {
                s->miembros = $4;
                s->cantMiembros = arraySize($4);
            }
            if($6) {
                // verificar tipoDato retorno de cuerpoFuncion_opt con tipoDato funcion
            }
            // printf("Declaración válida de función <línea:%d>\n", @$.first_line);
        }
    }

    | TIPO_DATO IDENTIFICADOR '(' error ')' cuerpoFuncion_opt {
        report_error("en declaFuncion", @$.first_line, "declaración de parámetros en función inválida. Recuperado hasta ')'");
        yyerrok;
        yyclearin;
    }
    | TIPO_DATO IDENTIFICADOR error parametros_opt ')' cuerpoFuncion_opt {
        report_error("en declaFuncion", @$.first_line, "Falta el paréntesis de apertura '(' en la firma de función.");
        yyerrok;
        yyclearin;
    }
    | TIPO_DATO IDENTIFICADOR '(' parametros_opt error cuerpoFuncion_opt {
        report_error("en declaFuncion", @$.first_line, "Falta el paréntesis de cierre ')' en la firma de función.");
        yyerrok;
        yyclearin;
    }
    | TIPO_DATO IDENTIFICADOR '(' parametros_opt ')' error {
        report_error("en declaFuncion", @$.first_line, "declaración de función incompleta, agregue ';' o cuerpo de función");
        yyerrok;
        yyclearin;
    }
    ;

cuerpoFuncion_opt
    : sentCompuesta { $$ = $1; }
    | ';' { $$ = NULL; }
    | error {
        report_error("en declaFuncion", @$.first_line, "declaración de función incompleta, agregue ';' o cuerpo de función");
        yyerrok;
        yyclearin;
    }
    ;

parametros_opt
    : /* vacío */ { $$ = NULL; }
    | lista_parametros { $$ = $1; }
    | error {
        report_error("en parametros_opt", @$.first_line, "error en lista_parametros");
        yyerrok;
        yyclearin;
    }
    ;

lista_parametros
    : parametro {
        Array* arr = createArray(10);
        insertElemArray(arr, strdup($1)); // tipo del primer parámetro
        $$ = arr;
    }
    | lista_parametros ',' parametro {
        insertElemArray($1, strdup($3));
        $$ = $1;
    }

    | lista_parametros error parametro {
        report_error("en lista_parametros", @$.first_line, "Separación inválida de parametros, se esperaba','");
        yyerrok;
        yyclearin; /* descarta el token actual, evita loops de error */
    }
    ;

parametro
    : TIPO_DATO IDENTIFICADOR { 
        Simbolo* v = crearSimbolo(
                $2,
                VARIABLE,
                $1,
                @1.first_line,
                nivelScope,
                0,
                0,
                0
            );
        $$ = $1; 
    }
    | CONST TIPO_DATO IDENTIFICADOR { 
        $$ = $2; 
    }
    | UNSIGNED TIPO_DATO IDENTIFICADOR { 
        $$ = $2; 
    }
    | CONST UNSIGNED TIPO_DATO IDENTIFICADOR { 
        $$ = $3; 
    }
    ;

sentencias_opt
    : /* vacío */
    | sentencias_opt sentencia
    | sentencias_opt error {
        report_error("en sentencias_opt", @$.first_line, "sentencia invalida");
        yyerrok;
        yyclearin;
    }
    ;

sentencia
    : sentCompuesta
        { printf("Se leyó una sentCompuesta <linea:%d>\n", @1.first_line); }
    | sentExpresion
        { printf("Se leyó una sentExpresion <linea:%d>\n", @1.first_line); }
    | sentSeleccion
        { printf("Se leyó una sentSeleccion(if, else) <linea:%d>\n", @1.first_line); }
    | sentIteracion
        { printf("Se leyó una sentIteracion(while, for) <linea:%d>\n", @1.first_line); }
    | sentSalto
        { printf("Se leyó una sentSalto(return) <linea:%d>\n", @1.first_line); }
    
    | error {
        report_error("en sentencia", @$.first_line, "Error en sentencia");
        yyerrok;
        yyclearin;
    }
    ;

sentCompuesta
    : '{' { reportAbrirScope("SentCompuesta"); } 
     declaraciones_opt sentencias_opt '}' 
        { reportCerrarScope("sentCompuesta"); }

    | '{' declaraciones_opt sentencias_opt error {
        report_error("en sentCompuesta", @$.first_line, "Falta '}' al final del bloque de sentencias.");
        yyerrok;
        yyclearin;
    }
    | error declaraciones_opt sentencias_opt '}' {
        report_error("en sentCompuesta", @$.first_line, "Falta '{' al inicio del bloque de sentencias.");
        yyerrok;
        yyclearin;
    }
    | '{' error sentencias_opt '}' {
        report_error("en bloque declaraciones_opt", @$.first_line, "Error dentro de bloque. Recuperado hasta '}'");
        yyerrok;
        yyclearin;
    }
    | '{' declaraciones_opt error '}' {
        report_error("en bloque sentencias_opt", @$.first_line, "Error dentro de bloque. Recuperado hasta '}'");
        yyerrok;
        yyclearin;
    }
    ;

sentExpresion
    : expresion_opt ';' 
        {
            // Ejemplo: si expresion_opt fue un identificador usado, verificar si está declarado
            $$ = $1
            validarExpresion($1, @$.first_line);
        }
    | ';'

    | expresion_opt error {
        report_error("en sentExpresion", @$.first_line, "Expresión incompleta, se esperaba ';'");
        yyerrok;
        yyclearin;
    }
    | error {
        report_error("en sentExpresion", @$.first_line, "agregue expresion o ';'");
        yyerrok;
        yyclearin;
    }
    ;

sentSeleccion
    : IF '(' expresion ')' 
        { // Verificar variables usadas en la condición
            validarExpresion($3, @$.first_line);
            reportAbrirScope("(IF)"); 
        }  
     sentencia 
        { reportCerrarScope("(IF)"); }
     opSent

    | IF '(' error ')' sentencia opSent {
        report_error("en sentSeleccion", @$.first_line, "Estructura de 'if' incompleta, error en condición. Recuperado.");
        yyerrok;
        yyclearin;
    }
    | IF '(' expresion error sentencia opSent {
        report_error("en sentSeleccion", @$.first_line, "Falta el paréntesis de cierre ')' después de la condición del IF.");
        yyerrok;
        yyclearin;
    }
    | IF error expresion ')' sentencia opSent {
        report_error("en sentSeleccion", @$.first_line, "Falta el paréntesis de apertura '(' en la condición del IF.");
        yyerrok;
        yyclearin;
    }
    | IF '(' expresion ')' error opSent {
        report_error("en sentSeleccion", @$.first_line, "Falta la sentencia después de la condición del IF.");
        yyerrok;
        yyclearin;
    }
    | IF '(' expresion ')' sentencia error {
        report_error("en sentSeleccion", @$.first_line, "opcion invalida al terminar IF");
        yyerrok;
        yyclearin;
    }
    ;

opSent
    : /* vacío */
    | ELSE 
        { reportAbrirScope("(ELSE)"); } 
     sentencia
        { reportCerrarScope("(ELSE)"); }

    | ELSE error {
        report_error("en opSent", @$.first_line, "Sentencia de 'else' inválida");
        yyerrok;
        yyclearin;
    }
    ;

sentIteracion
    : WHILE '(' expresion ')' 
        {
            // Ejemplo: si expresion_opt fue un identificador usado, verificar si está declarado
            validarExpresion($3, @$.first_line);
            reportAbrirScope("(WHILE)");
        }
     sentencia
        { reportCerrarScope("(WHILE)"); }
    | FOR '(' expresion_opt ';' expresion_opt ';' expresion_opt ')'
        {
            // Validar identificadores en partes del FOR
            validarExpresion($3, @$.first_line);
            validarExpresion($5, @$.first_line);
            validarExpresion($7, @$.first_line);
            reportAbrirScope("(FOR)");
        }
     sentencia
        { reportCerrarScope("(FOR)"); }

    | WHILE '(' error ')'  sentencia {
        report_error("en sentIteracion", @$.first_line, "Expresion en 'while' mal formada");
        yyerrok;
        yyclearin;
    }
    | WHILE '(' expresion error sentencia {
        report_error("en sentIteracion", @$.first_line, "Falta el paréntesis de cierre ')' después de la condición del WHILE.");
        yyerrok;
        yyclearin;
    }
    | WHILE error expresion ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "Falta el paréntesis de apertura '(' en la condición del WHILE.");
        yyerrok;
        yyclearin;
    }
    | WHILE '(' expresion ')' error {
        report_error("en sentIteracion", @$.first_line, "Falta la sentencia para el bucle WHILE.");
        yyerrok;
        yyclearin;
    }
    | FOR error expresion_opt ';' expresion_opt ';' expresion_opt ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "Sintaxis de 'for' inválida. Recuperado.");
        yyerrok;
        yyclearin;
    }
    | FOR '(' expresion_opt error expresion_opt ';' expresion_opt ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "Sintaxis de 'for' inválida: Falta el primer ';' de separación.");
        yyerrok;
        yyclearin;
    }
    | FOR '(' expresion_opt ';' expresion_opt error expresion_opt ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "Sintaxis de 'for' inválida: Falta el segundo ';' de separación.");
        yyerrok;
        yyclearin;
    }
    | FOR '(' expresion_opt ';' expresion_opt ';' expresion_opt error sentencia {
        report_error("en sentIteracion", @$.first_line, "Falta el paréntesis de cierre ')' en la cabecera del FOR.");
        yyerrok;
        yyclearin;
    }
    | FOR '(' expresion_opt ';' expresion_opt ';' expresion_opt ')' error {
        report_error("en sentIteracion", @$.first_line, "Falta la sentencia para el bucle FOR.");
        yyerrok;
        yyclearin;
    }
    | FOR '(' error ';' expresion_opt ';' expresion_opt ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "expresion en FOR incorrecta");
        yyerrok;
        yyclearin;
    }
    | FOR '(' expresion_opt ';' error ';' expresion_opt ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "expresion en FOR incorrecta");
        yyerrok;
        yyclearin;
    }
    | FOR '(' expresion_opt ';' expresion_opt ';' error ')' sentencia {
        report_error("en sentIteracion", @$.first_line, "expresion en FOR incorrecta");
        yyerrok;
        yyclearin;
    }
    ;

sentSalto
    : RETURN expresion_opt 
        {
            validarExpresion($2, @$.first_line);
        }
     ';'

    | RETURN error ';' {
        report_error("en sentSalto", @$.first_line, "Expresión de 'return' inválida. Recuperado hasta ';'");
        yyerrok;
        yyclearin;
    }
    | RETURN expresion_opt error {
        report_error("en sentSalto", @$.first_line, "Falta el ';' al final de la sentencia 'return'.");
        yyerrok;
        yyclearin;
    }
    ;

expresion_opt
    : /* vacío */ { $$ = NULL; }
    | expresion { $$ = $1; } // conseguir resultado de la expresion
    | error {
        report_error("en expresion_opt", @$.first_line, "expresion invalida");
        yyerrok;
        yyclearin;
    }
    ; 

expresion
    : expCondicional { $$ = $1; }
    | IDENTIFICADOR opAsignacion expresion {
        char* key = $1;
        Simbolo* s = buscarSimbolo(tablaGral, key);
        if(s) {
            if(s->constante) {
                report_error("en expresion", @$.first_line, "no se pueden modificar vars constantes");
                $$ = strdup("error");
            }
            else {
                if (strcmp($2, "=") == 0) {
                    Simbolo* tipoReal = buscarSimbolo(tablaGral, s->tipoDato); // tipoDato podria ser el nom de un enum donde se declaro esta variable
                    if (tipoReal && tipoReal->clase == ENUM) {
                        if (strcmp($3, "int") != 0) {
                            report_error("en expresion", @$.first_line,
                                        "solo se puede asignar valores enteros a variables enum");
                        } else {
                            if (!valorPerteneceAlEnum(s, $3)) {
                                report_error("en expresion", @1.first_line,
                                            "valor no pertenece al enum");
                                $$ = strdup("error");
                            }
                        }    
                    }
                    if (s->unsg && expresionNegativa($3)) {
                        report_error("en expresion", @1.first_line,
                                "unsigned no puede recibir valor negativo");
                        $$ = strdup("error");
                    }
                    // Verificamos compatibilidad de tipos
                    if (!tiposCompatibles($1, $3)) {
                        report_error("en expresion", @$.first_line, "tipos incompatibles");
                        $$ = strdup("error");
                    } else {
                        $$ = strdup($1);
                    }
                } else {
                    // Operadores compuestos +=, -=, etc. Solo tipoCompatibles para simplicidad
                    if (!tiposCompatibles($1, $3)) {
                        report_error("en expresion", @$.first_line, "tipos incompatibles");
                        $$ = strdup("error");
                    } else {
                        $$ = strdup($1);
                    }
                }
            }
        } else {
            report_error("en expresion", @1.first_line,
                "variable no definida");
            $$ = strdup("error");
        }
    }

    | IDENTIFICADOR opAsignacion error {
        report_error("en expresion", @$.first_line, "Expresión inválida después del operador de asignación.");
        yyerrok;
        yyclearin;
    }
    | IDENTIFICADOR opAsignacion {
        report_error("en expresion", @$.first_line, "Falta la expresión a asignar después del operador.");
        yyerrok;
        yyclearin;
    }
    ;

opAsignacion
    : '=' { $$ = strdup("="); } 
    | MAS_IGUAL { $$ = strdup("+="); } 
    | MENOS_IGUAL { $$ = strdup("-="); } 
    | DIV_IGUAL { $$ = strdup("/="); } 
    | POR_IGUAL { $$ = strdup("*="); } 
    ;

expCondicional 
    : expOr { $$ = $1; }    //expresion booleana
    | expOr '?' expresion ':' expCondicional {
        /* tipo resultante: promover numeric o error */
        char* t1 = $1; char* t2 = $3; char* t3 = $5;
        /* si t2 y t3 compatibles => tipo resultante */
        if (tiposCompatibles(t2,t3)) $$ = strdup(t2);
        else { report_error("en expCondicional", @$.first_line, "tipos incompatibles en ternario"); $$ = strdup("error"); }
        free(t1); free(t2); free(t3);
    }

    | expOr '?' expresion error {
        report_error("en expCondicional", @$.first_line, "Operador ternario inválido, se esperaba ':'");
        yyerrok;
        yyclearin;
    }
    | expOr error expresion ':' expCondicional {
        report_error("en expCondicional", @$.first_line, "Operador ternario inválido, se esperaba '?'");
        yyerrok;
        yyclearin;
    }
    | expOr '?' error ':' expCondicional {
        report_error("en expCondicional", @$.first_line, "Falta la expresión después de '?' en el ternario.");
        yyerrok;
        yyclearin;
    }
    ;

expOr
    : expAnd { $$ = $1; }
    | expOr OR expAnd {
        char* a = $1; char* b = $3;
        if ((strcmp(a,"error")==0) || (strcmp(b,"error")==0)) $$ = strdup("error");
        else $$ = strdup("int");
        free(a); free(b);
    }
    ;

expAnd
    : expIgualdad { $$ = $1; }
    | expAnd AND expIgualdad {
        char* a = $1; char* b = $3;
        if ((strcmp(a,"error")==0) || (strcmp(b,"error")==0)) $$ = strdup("error");
        else $$ = strdup("int");
        free(a); free(b);
    }
    ;

expIgualdad
    : expRelacional { $$ = $1; }
    | expIgualdad IGUALDAD expRelacional {
        char* a = $1; char* b = $3;
        if (tiposCompatibles(a,b) || tiposCompatibles(b,a)) $$ = strdup("int");
        else { report_error("en expCondicional", @$.first_line, "comparacion == tipos incompatibles"); $$ = strdup("error"); }
        free(a); free(b);
    }
    | expIgualdad DIFERENTE expRelacional {
        char* a = $1; char* b = $3;
        if (tiposCompatibles(a,b) || tiposCompatibles(b,a)) $$ = strdup("int");
        else { report_error("en expCondicional", @$.first_line, "comparacion != tipos incompatibles"); $$ = strdup("error"); }
        free(a); free(b);
    }
    ;

expRelacional
    : expAditiva { $$ = $1; }
    | expRelacional MAYOR_IGUAL expAditiva {
        char* a = $1; char* b = $3;
        if ( (strcmp(a,"int")==0 || strcmp(a,"float")==0 || strcmp(a,"double")==0) &&
             (strcmp(b,"int")==0 || strcmp(b,"float")==0 || strcmp(b,"double")==0) )
            $$ = strdup("int");
        else { report_error("en expCondicional", @$.first_line, "error semantico en operador relacional"); $$ = strdup("error"); }
        free(a); free(b);
    }
    | expRelacional '>' expAditiva {
        char* a = $1; char* b = $3;
        if ( (strcmp(a,"int")==0 || strcmp(a,"float")==0 || strcmp(a,"double")==0) &&
             (strcmp(b,"int")==0 || strcmp(b,"float")==0 || strcmp(b,"double")==0) )
            $$ = strdup("int");
        else { report_error("en expCondicional", @$.first_line, "error semantico en operador relacional"); $$ = strdup("error"); }
        free(a); free(b);
    }
    | expRelacional MENOR_IGUAL expAditiva {
        char* a = $1; char* b = $3;
        if ( (strcmp(a,"int")==0 || strcmp(a,"float")==0 || strcmp(a,"double")==0) &&
             (strcmp(b,"int")==0 || strcmp(b,"float")==0 || strcmp(b,"double")==0) )
            $$ = strdup("int");
        else { report_error("en expCondicional", @$.first_line, "error semantico en operador relacional"); $$ = strdup("error"); }
        free(a); free(b);
    }
    | expRelacional '<' expAditiva {
        char* a = $1; char* b = $3;
        if ( (strcmp(a,"int")==0 || strcmp(a,"float")==0 || strcmp(a,"double")==0) &&
             (strcmp(b,"int")==0 || strcmp(b,"float")==0 || strcmp(b,"double")==0) )
            $$ = strdup("int");
        else { report_error("en expCondicional", @$.first_line, "error semantico en operador relacional"); $$ = strdup("error"); }
        free(a); free(b);
    }
    ;

expAditiva
    : expMultiplicativa { $$ = $1; }
    | expAditiva '+' expMultiplicativa {
        char* a = $1; char* b = $3;
        if (strcmp(a,"double")==0 || strcmp(b,"double")==0) $$ = strdup("double");
        else if (strcmp(a,"float")==0 || strcmp(b,"float")==0) $$ = strdup("float");
        else if (strcmp(a,"int")==0 && strcmp(b,"int")==0) $$ = strdup("int");
        else { report_error("en expAditiva", @$.first_line, "error semantico en operador suma"); $$ = strdup("error"); }
        free(a); free(b);
    }
    | expAditiva '-' expMultiplicativa {
        char* a = $1; char* b = $3;
        if (strcmp(a,"double")==0 || strcmp(b,"double")==0) $$ = strdup("double");
        else if (strcmp(a,"float")==0 || strcmp(b,"float")==0) $$ = strdup("float");
        else if (strcmp(a,"int")==0 && strcmp(b,"int")==0) $$ = strdup("int");
        else { report_error("en expAditiva", @$.first_line, "error semantico en operador resta"); $$ = strdup("error"); }
        free(a); free(b);
    }
    ;

expMultiplicativa
    : expUnaria { $$ = $1; }
    | expMultiplicativa '*' expUnaria {
        char* a = $1; char* b = $3;
        if (strcmp(a, "int") == 0 && strcmp(b, "int") == 0) $$ = strdup("int");
        else if (strcmp(a,"double")==0 || strcmp(b,"double")==0) $$ = strdup("double");
        else if (strcmp(a,"float")==0 || strcmp(b,"float")==0) $$ = strdup("float");
        else {
            report_error("en expMultiplicativa", @$.first_line, "tipo incompatible");
            $$ = strdup("error");
        }
        free(a); free(b);
    }
    | expMultiplicativa '/' expUnaria {
        char* a = $1; char* b = $3;
        if ( b /= 0 && strcmp(a, "int") == 0 && strcmp(b, "int") == 0) $$ = strdup("int");
        else if ( b /= 0 && strcmp(a,"double")==0 || strcmp(b,"double")==0) $$ = strdup("double");
        else if ( b /= 0 && strcmp(a,"float")==0 || strcmp(b,"float")==0) $$ = strdup("float");
        else {
            report_error("en expDivision", @$.first_line, "tipo incompatible o division por 0");
            $$ = strdup("error");
        }
        free(a); free(b);
    }
    ;

expUnaria
    : operUnario expUnaria %prec UNARIO {
        char* t = $2; char s = $1;
        if (s == '-') {
            if (strcmp(t,"int")==0 || strcmp(t,"float")==0 || strcmp(t,"double")==0) $$ = strdup("negativo");
            else { report_error("en expUnaria", @$.first_line, "aplicacion '-' sobre tipo no numerico"); $$ = strdup("error"); }
        } else if (s == '!') {
            if (strcmp(t,"int")==0 || strcmp(t,"float")==0 || strcmp(t,"double")==0 || strcmp(t,"char")==0)
                $$ = strdup("int");
            else {
                report_error("en expUnaria", @$.first_line, "aplicación de '!' sobre tipo no numérico");
                $$ = strdup("error");
            }
        } else {
            report_error("en expUnaria", @$.first_line, "tipo incompatible");
            $$ = strdup("error");
        }
        free(t); free(s);
    }
    | expPostfijo { $$ = $1; }
    | INCREMENTO expUnaria  { 
        char* t = $2; /* ++x */ 
        if (strcmp(t,"int")==0 || strcmp(t,"float")==0 || strcmp(t,"double")==0) { 
            $$=strdup(t);
        } 
        else { report_error("en expUnaria", @$.first_line, "aplicacion '++' sobre tipo no numerico"); $$ = strdup("error"); }
        free(t); 
    }
    | DECREMENTO expUnaria { 
        char* t = $2; /* ++x */ 
        if (strcmp(t,"int")==0 || strcmp(t,"float")==0 || strcmp(t,"double")==0) { 
            $$=strdup(t);
        } 
        else { report_error("en expUnaria", @$.first_line, "aplicacion '--' sobre tipo no numerico"); $$ = strdup("error"); }
        free(t); 
    }

    | INCREMENTO error {
        report_error("en expUnaria", @$.first_line, "El operador de incremento '++' requiere un operando válido.");
        yyerrok;
        yyclearin;
    }
    | DECREMENTO error {
        report_error("en expUnaria", @$.first_line, "El operador de decremento '--' requiere un operando válido.");
        yyerrok;
        yyclearin;
    }
    | operUnario error {
        report_error("en expUnaria", @$.first_line, "El operador unario requiere un operando válido.");
        yyerrok;
        yyclearin;
    }
    ;
    
operUnario 
    : '-' { $$ = '-'; }  /* signo negativo */
    | '!' { $$ = '!'; }  /* NOT lógico */
    ;

expPostfijo
    : expPrimaria { $$ = $1; }
    | IDENTIFICADOR '(' listaArgumentos ')' { // acepta x ej: int x = dobleDe(2);
        /* Llamada a función: verificar existencia y compatibilidad de args */
        char* funcKey = $1; 
        Simbolo* func = buscarSimbolo(tablaGral, funcKey);
        if (func != NULL && func->clase == FUNCION) {
            int cantArgs = $3? arraySize($3) : 0;
            int cantArgsFun = func->cantMiembros;
            // verifico cantArgs y compatibilidad de tipoDato var con el que retorna func
            if(cantArgs == cantArgsFun && tiposCompatibles(tipoDatoActual, func->tipoDato)) {
                // verifico que los args correspondan al tipo pedido en los parametros de func
                int ok = 1;
                for (int i = 0; i < cantArgsFunc; i++) {
                    char* tipoArg = findElemArray($3, i);
                    char* tipoParam  = findElemArray(fun->miembros, i);

                    if (!tiposCompatibles(tipoActual, tipoParam)) {
                        ok = 0;
                        break;
                    }
                }
                if (!ok) {
                    report_error("en llamada a funcion", @1.first_line,
                                    "tipos incompatibles en los argumentos");
                    $$ = strdup("error");
                } else {
                    // La llamada es válida: retorna el tipo de la función
                    $$ = strdup(fun->tipoDato);
                }
            }
            else {
                report_error("en expPostfijo", @$.first_line, "cantidad de argumentos en funcion invalido o tipos incompatibles");
                $$ = strdup("error");
            }
        }
        else {
            report_error("en expPostfijo", @$.first_line, "funcion no declarada o identificador no es funcion");
            $$ = strdup("error");
        }
        free(funcKey); destroyArray($3);
    }
    | expPostfijo INCREMENTO /* post ++ */ { 
        char* t = $1;
        if (strcmp(t,"int")==0 || strcmp(t,"float")==0 || strcmp(t,"double")==0) { 
            $$=strdup(t);
        } 
        else { report_error("en expUnaria", @$.first_line, "aplicacion '++' sobre tipo no numerico"); $$ = strdup("error"); }
        free(t); 
    }
    | expPostfijo DECREMENTO /* post -- */ { 
        char* t = $1;
        if (strcmp(t,"int")==0 || strcmp(t,"float")==0 || strcmp(t,"double")==0) { 
            $$=strdup(t);
        } 
        else { report_error("en expUnaria", @$.first_line, "aplicacion '--' sobre tipo no numerico"); $$ = strdup("error"); }
        free(t); 
    }

    | expPostfijo '(' listaArgumentos error {
        report_error("en expPostfijo", @$.first_line, "Falta el paréntesis de cierre ')' en la llamada a función.");
        yyerrok;
        yyclearin;
    }
    | expPostfijo error listaArgumentos ')' {
        report_error("en expPostfijo", @$.first_line, "Falta el paréntesis de apertura '(' en la llamada a función.");
        yyerrok;
        yyclearin;
    }
    ;

listaArgumentos
    : /* vacío */ { $$ = NULL; }
    | expresion {
        Array* arr = createArray(10);
        char* e = strdup($1);
        insertElemArray(arr, e);
        $$ = arr;
    }
    | listaArgumentos ',' expresion {
        char* e = strdup($3);
        insertElemArray($1, e);
        $$ = $1;
    }

    | listaArgumentos error expresion {
        report_error("en listaArgumentos", @$.first_line, "Argumentos separados incorrectamente, se esperaba ','");
        yyerrok;
        yyclearin;
    }
    | listaArgumentos ',' error {
        report_error("en listaArgumentos", @$.first_line, "Coma de más al final de la lista de argumentos.");
        yyerrok;
        yyclearin;
    }
    ;

expPrimaria
    : IDENTIFICADOR {
        Simbolo* s = buscarSimbolo(tablaGral, $1);
        if (!s) {
            report_error("en expPrimaria", @$.first_line, "variable no declarada");
            $$ = strdup("error");
        } else {
            $$ = strdup(s->tipoDato);
        }
    }
    | ENTERO { $$ = strdup("int"); }
    | NUMERO { $$ = strdup("float"); }
    | CARACTER { $$ = strdup("char"); }
    | CADENA { $$ = strdup("char*"); }
    | '(' expresion_opt ')' { $$ = $2 ? strdup($2) : ( report_error("en expPrimaria", @$.first_line, "problema con expresion"); strdup("error"); ); } //podria ser para x ej: 2*(2+2)
    ;


%%

/* yyerror: se usa cuando Bison no sabe cómo recuperar;
   incrementamos contador y mostramos un msj para el usuario */
int yyerror(const char *mensaje) {
    /* Mensaje de Bison + ubicación */
    fprintf(stderr, "Error sintáctico <línea:%d columna:[%d:%d]>: %s\n",
            yylloc.first_line, yylloc.first_column, yylloc.last_column,
            mensaje ? mensaje : "error");
    errorCount++;

    fprintf(stderr, "Revisar código\n");
    return 0;
}

int main(int argc, char *argv[]) {
    // tendra el scope actual para el control semantico
    tablaGral = initTS(); // scope global abierto
    
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");

    if (!yyin) {
        perror("No se pudo abrir el archivo");
        return 1;
    }

    // Inicializa las ubicaciones antes del análisis
    iniciarUbicaciones();

    int resultado = yyparse();

    if (errorCount == 0 && resultado == 0) {
        printf("El archivo %s es válido\n", argv[1]);
    } else {
        printf("El archivo %s contiene %d errores (yyparse devolvió %d)\n", argv[1], errorCount, resultado);
    }

    destroyTS(tablaGral);
    fclose(yyin);
    return 0;
}