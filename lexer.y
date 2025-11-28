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

int tiposCompatibles(char* t1, char* t2) {

    if (t1 == NULL || t2 == NULL) {

        return 0;

    }



    else if (strcmp(t1, t2) == 0) {

        return 1;

    }



    // conversiones simples

    else if (strcmp(t1, "double") == 0) {

        return (strcmp(t2, "int") == 0 ||

                strcmp(t2, "float") == 0 ||

                strcmp(t2, "char") == 0);

    }



    else if (strcmp(t1, "float") == 0) {

        return (strcmp(t2, "int") == 0 ||

                strcmp(t2, "float") == 0 ||

                strcmp(t2, "char") == 0);

    }



    else if (strcmp(t1, "int") == 0) {

        return (strcmp(t2, "int") == 0 ||

                strcmp(t2, "char") == 0);

    }



    Simbolo* enumTipo = buscarSimbolo(tablaGral, t1);

    if (enumTipo != NULL && enumTipo->clase == ENUM) {

        if (valorPerteneceAlEnum(enumTipo, t2)) // t2 = IDENTIFICADOR o "k" de enum

            return 1;



        return 0; // no pertenece al enum

    }



    return 0;

}

int valorPerteneceAlEnum(Simbolo* enumSimbolo, char* valor) {

    if(esNumeroEntero(valor)){

        for (int i = 0; i < arraySize(enumSimbolo->miembros); i++) {

            Enumerador* enumVal = (Enumerador*) findElemArray(enumSimbolo->miembros, i);

            if (enumVal->valor == valor)

                return 1;

        }

    }



    for (int i = 0; i < arraySize(enumSimbolo->miembros); i++) {

        Enumerador* enumVal = (Enumerador*) findElemArray(enumSimbolo->miembros, i);

        if (strcmp(enumVal->nombre, valor) == 0)

            return 1;

    }

    

    return 0;

}

int esNumeroEntero(const char* s) {

    if (!s || *s == '\0')

        return 0;

    for (int i = 0; s[i]; i++) {

        if (!isdigit(s[i]) && !(i == 0 && s[i] == '-'))

            return 0;

    }

    return 1;

}

int esTipoBasico(const char* t) {

    return strcmp(t, "int") == 0 ||

           strcmp(t, "char") == 0 ||

           strcmp(t, "char*") == 0 ||

           strcmp(t, "float") == 0 ||

           strcmp(t, "double") == 0;

}

char* tipoResultadoNumerico(char* a, char* b) {

    if (!strcmp(a,"double") || !strcmp(b,"double")) return "double";

    if (!strcmp(a,"float")  || !strcmp(b,"float"))  return "float";

    return "int";

}



typedef struct TipoExpr {

    char* tipo;   // "int", "double", "float", "char", "char*", enum (identificador, "k")

    int esLvalue; // 1 si se puede asignar (identificador), 0 en otros casos

} TipoExpr;

TipoExpr* crearExpr(char* tipo, int esLvalue) {

    TipoExpr* e = malloc(sizeof(TipoExpr));

    e->tipo = tipo;

    e->esLvalue = esLvalue;

    return e;

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

    Parametro* p;

    Simbolo* s;

    TipoExpr* expr;

}



// token es para definir el tipo de dato que almacena un terminal

%token <ival> ENTERO //defino que entero es un tipo ival -> es int de union

%token <dval> NUMERO

%token <cval> CARACTER

%token <cadena> CADENA TIPO_DATO IDENTIFICADOR

%token <cadena> RETURN FOR WHILE ELSE IF

%token <cadena> ENUM

%token INCREMENTO DECREMENTO MAS_IGUAL MENOS_IGUAL DIV_IGUAL POR_IGUAL

%token IGUALDAD DIFERENTE AND OR MAYOR_IGUAL MENOR_IGUAL



// type es para definir el tipo de dato que almacena un no terminal

%type <s> declaEnum declaFuncion declaVarSimple

%type <arr> ids_opt lista_ids lista_enumeradores

%type <arr> parametros_opt lista_parametros

%type <cadena> cuerpoFuncion_opt sentencias_opt sentencia

%type <cadena> sentCompuesta sentSeleccion sentSalto

%type <cadena> tipo_opt

%type <p> parametro





/* Precedencia y asociatividad */

%left OR

%left AND

%left IGUALDAD DIFERENTE

%left '<' '>' MENOR_IGUAL MAYOR_IGUAL

%left '+' '-'

%left '*' '/'

%right '!' INCREMENTO DECREMENTO 

%right UNARIO  // UNARIO para -, !

%right '=' MAS_IGUAL MENOS_IGUAL DIV_IGUAL POR_IGUAL



%start input



%%



input

    : declaraciones_opt sentencias_opt

    ;



declaraciones_opt

    : /* vacío */

    | declaraciones_opt declaracion

    ;



declaracion

    : declaVarSimple

    | declaFuncion

    | declaEnum

    | error ';' {

        report_error("en declaracion", @$.first_line, "error sintactico de declaración.");

        yyerrok;

    }

    | error '}' { // para la terminacion de declaFuncion q no es ';'

        report_error("en declaracion", @$.first_line, "error sintactico de declaración.");

        yyerrok;

    }

    ;



declaEnum //me parece que un enum es constante

    : ENUM IDENTIFICADOR '{' lista_enumeradores '}' {

        char* nombre = $2; // obligo a enum a tener key para que sea menos complejo

        Simbolo* s = crearSimbolo(nombre, ENUM, strdup("enum"), @$.first_line, 0);

        // si esta declarado en el scope actual --> redeclarado

        if (!agregarSimbolo(tablaGral, s)) {

            report_error("en declaEnum", @$.first_line, "error semantico, enum redeclarado.");

            destruirSimbolo(s);

            $$ = NULL;

        } else {

            /* lista_enumeradores devuelve Array* de Enumerador* con nom y val del elemEnum*/

            s->miembros = $4;

            s->cantMiembros = arraySize($4);



            printf("Declaración válida de enum <línea:%d>\n", @$.first_line);

            $$ = s;        

        }

    } 

        ids_opt ';' {

            Simbolo* f = $$;

            if (f != NULL) { // variables declaradas al final del enum

                if($6) {

                    int ok = 1;

                    for (int i = 0; i < arraySize($6); i++) {

                        char* varEnum = (char*) findElemArray($6, i); 

                        Simbolo* t = crearSimbolo(varEnum, VARIABLE, nombre, @$.first_line, 0);

                        if (!agregarSimbolo(tablaGral, t)) {

                            report_error("en id_opt", @$.first_line, "error semantico, existe variable con ese nombre. No se declarara enum");

                            destruirSimbolo(t);

                            free(varEnum);

                            ok = 0;

                            break;

                        }

                    }

                }

                if(!ok) {

                    eliminarSimbolo(tablaGral, f);

                    destruirSimbolo(f);

                }

            } else { destruirSimbolo(f); }

    }

    | error ';' {

        report_error("en declaEnum", @$.first_line, "error sintactico de declaración de enum.");

        yyerrok;

    }

    ;



ids_opt

    : /* vacío */ { $$ = NULL; }

    | lista_ids { $$ = $1; }

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

    ;



declaVarSimple

    : tipo_opt IDENTIFICADOR {

        char* tipo = $1;

        if(tipo && esTipoBasico(tipo)) {

            Simbolo* v = crearSimbolo(

                $2,

                VARIABLE,

                tipo,

                @1.first_line,

                0

            );

            if (!agregarSimbolo(tablaGral, v)) {

                report_error("en declaVarSimple", @$.first_line, "error semantico, variable redeclarada.");

                destruirSimbolo(v);

                $$ = NULL;

            } else {

                printf("Declaración válida de varSimple <línea:%d>\n", @$.first_line);

                $$ = v;        

            }

        } else { // tiene que ser identificador enum

            Simbolo* s = buscarSimbolo(tablaGral, tipo);

            if(s && s->clase == ENUM) {

                Simbolo* v = crearSimbolo(

                    $2,

                    VARIABLE,

                    tipo,

                    @1.first_line,

                    0

                );

                if (!agregarSimbolo(tablaGral, v)) {

                    report_error("en declaVarSimple", @$.first_line, "error semantico, variable redeclarada.");

                    destruirSimbolo(v);

                    $$ = NULL;

                } else {

                    printf("Declaración válida de varSimple <línea:%d>\n", @$.first_line);

                    $$ = v;        

                }

            } else {

                report_error("en declaVarSimple", @$.first_line, "error semantico, tipoDato no definido");

                destruirSimbolo(s);

                free(tipo);

                $$ = NULL;

            }

        }

    }

        inicializacion_opt ';' {

            Simbolo* v = $$;   // el símbolo creado

            

            if (v != NULL) {

                if ($4) {

                    char* tipoInit = $4;

                    // Validar inicialización

                    if (!tiposCompatibles(v->tipoDato, tipoInit)) {

                        report_error("en declaVarSimple", @$.first_line,

                                        "error semantico, inicialización incompatible con el tipo de la variable.");

                        eliminarSimbolo(tablaGral, v);

                        destruirSimbolo(v);

                        free(tipoInit);

                    }

                }

            } else { destruirSimbolo(v); }

    }

    | error ';' {

        report_error("en declaVarSimple", @$.first_line, "error sintactico de declaración de variable.");

        yyerrok;

    }

    ;



tipo_opt

    : TIPO_DATO { $$ = $1; }

    | TIPO_DATO '*' {

        if (strcmp($1, "char") == 0) {

            $$ = strdup("char*");

        } else {

            report_error("en tipo_opt", @1.first_line,

                            "no analizo punteros");

            $$ = NULL;

        }

    }

    | IDENTIFICADOR { $$ = $1; }

    ;



inicializacion_opt

    : /* vacío */ { $$ = NULL; }

    | '=' expOr { $$ = $2->tipo; } // numerico

    | '=' CADENA { $$ = strdup("char*"); } // char*

    | '=' IDENTIFICADOR { $$ = $2; } // enum

    ;



declaFuncion

    : TIPO_DATO IDENTIFICADOR '(' parametros_opt ')' {

        Simbolo* s = crearSimbolo(

            $2,

            FUNCION,

            $1,

            @$.first_line,

            0

        );

        if (!agregarSimbolo(tablaGral, s)) {

            report_error("en declaFuncion", @$.first_line, "error semantico, funcion redeclarada.");

            destruirSimbolo(s);

            $$ = NULL;

        } else {

            s->miembros = $4;

            s->cantMiembros = $4? arraySize($4) : 0;



            printf("Declaración válida de funcion <línea:%d>\n", @$.first_line);

            $$ = s;

        }

    } 

        cuerpoFuncion_opt {

            Simbolo* f = $$;

            char* tipoDeclarado = $1;

            char* tipoRetornado = $6;

            if (tipoRetornado == NULL && strcmp(tipoDeclarado, "void") != 0) {

                report_error("en función", @$.first_line,

                                "error semantico, falta retorno en funcion");

                eliminarSimbolo(tablaGral, f);

                destruirSimbolo(f);

                free(tipoDeclarado);

                free(tipoRetornado);

            } else if (tipoRetornado != NULL &&

                        !tiposCompatibles(tipoDeclarado, tipoRetornado)) {

                report_error("en función", @$.first_line,

                                "error semantico, Tipo de retorno incompatible.");

                eliminarSimbolo(tablaGral, f);

                destruirSimbolo(f);

                free(tipoDeclarado);

                free(tipoRetornado);

            }

    }

    | error ';' {

        report_error("en declaFuncion", @$.first_line, "error sintactico de declaración de funcion.");

        yyerrok;

    }

    ;



cuerpoFuncion_opt

    : sentCompuesta { $$ = 1; }

    | ';'

    ;



parametros_opt

    : /* vacío */ { $$ = NULL; }

    | lista_parametros { $$ = $1; } // array*

    ;



lista_parametros

    : parametro {

        Array* arr = createArray(10);

        if ($1 != NULL) insertElemArray(arr, $1);

        $$ = arr;

    }

    | lista_parametros ',' parametro {

        if ($3 != NULL) insertElemArray($1, $3);

        $$ = $1;

    }

    ;



parametro

    : TIPO_DATO IDENTIFICADOR {

        if (strcmp($1, "void") == 0) {

            report_error("en parámetro", @1.first_line,

                            "Un parámetro no puede ser de tipo 'void'.");

            $$ = NULL;

        } else {

            Parametro* p = crearParametro($2, $1);

            $$ = p;

        }

    }

    : TIPO_DATO '*' IDENTIFICADOR {

        if (strcmp($1, "char") == 0) {

            Parametro* p = crearParametro($2, "char*");

            $$ = p;

        } else {

            report_error("en parámetro", @1.first_line,

                            "no analizo punteros, solo char*.");

            $$ = NULL;

        }

    }

    ;



sentencias_opt

    : /* vacío */ { $$ = NULL; }

    | sentencias_opt sentencia {

        if ($2 != NULL)

            { $$ = $2; }     // si hubo un return en esta sentencia, me lo guardo

        else

            { $$ = $1; }     // sino conservo el anterior

    }

    ;



sentencia

    : sentCompuesta

        { $$ = $1; printf("Se leyó una sentCompuesta <linea:%d>\n", @1.first_line); }

    | sentExpresion

        { $$ = NULL; printf("Se leyó una sentExpresion <linea:%d>\n", @1.first_line); }

    | sentSeleccion

        { $$ = $1; printf("Se leyó una sentSeleccion(if, else) <linea:%d>\n", @1.first_line); }

    | sentIteracion

        { $$ = NULL; printf("Se leyó una sentIteracion(while, for) <linea:%d>\n", @1.first_line); }

    | sentSalto

        { $$ = $1; printf("Se leyó una sentSalto(return) <linea:%d>\n", @1.first_line); }

    | error ';' {

        report_error("en sentencia", @$.first_line, "error sintactico de sentencia.");

        yyerrok;

    }

    ;



sentCompuesta

    : '{' { reportAbrirScope("SentCompuesta"); } 

     declaraciones_opt sentencias_opt '}' 

        { reportCerrarScope("sentCompuesta"); $$ = $3;}

    | '{' error '}' {

        report_error("en sentCompuesta", @$.first_line,

                        "Error sintáctico dentro de bloque.");

        yyerrok;

        reportCerrarScope("sentCompuesta"); $$ = NULL;

    }

    ;



sentExpresion // sentencia sin llave no tiene scope

    : expresion_opt ';' 

        {

            // Ejemplo: si expresion_opt fue un identificador usado, verificar si está declarado

            validarExpresion($1, @$.first_line);

        }

    | ';'

    | error ';' {

        report_error("en sentExpresión", @$.first_line, "sintaxis de expresión inválida");

        yyerrok;

    }

    ;



sentSeleccion

    : IF '(' error ')' sentencia opSent {

          report_error("en IF", @$.first_line, "condición inválida, error sintactico");

          yyerrok; $$ = NULL;

    }

    | IF '(' expresion ')' 

        { // Verificar variables usadas en la condición

            validarExpresion($3, @$.first_line);

            reportAbrirScope("(IF)"); 

        }  

     sentencia 

        { reportCerrarScope("(IF)"); }

     opSent

    ;



opSent

    : /* vacío */

    | ELSE 

        { reportAbrirScope("(ELSE)"); } 

     sentencia

        { reportCerrarScope("(ELSE)"); }

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

    | WHILE '(' error ')' sentencia {

          report_error("en WHILE", @$.first_line, "condición inválida, error sintactico");

          yyerrok;

    }

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

    | FOR '(' error ')' sentencia {

        report_error("en FOR", @$.first_line, "estructura sintactica del FOR inválida");

        yyerrok;

    }

    ;



sentSalto // sentencia sin llave no tiene scope

    : RETURN expresion_opt ';' {

        if ($2 == NULL) {

            // return sin valor → tipo = void

            $$ = strdup("void");

        } else {

            // la expresión devuelve un tipo

            $$ = $2->tipo;

        }

    }

    | error ';' {

        report_error("en sentSalto", @$.first_line, "sintaxis de expresión inválida");

        $$ = NULL;

        yyerrok;

    }

    ;



expresion_opt

    : /* vacío */ { $$ = NULL; }

    | expresion { $$ = $1; }

    ; 



expresion

    : expOr { $$ = $1; }

    | IDENTIFICADOR opAsignacion expOr {

        Simbolo* s = buscarSimbolo(tablaGral, $1);

        if(s && s->clase == VARIABLE) {

            if (!tiposCompatibles(s->tipoDato, $3->tipo)) {

                report_error("en asignación", @$.first_line,

                        "error semantico, tipo incompatible en asignación.");

                destruirSimbolo(s);

                $$ = NULL;

            }



            // tipo de la expresión asignación es el del LHS

            $$ = crearExpr(s->tipoDato, 0);

        } else {

            report_error("en expresion", @1.first_line,

                "error semantico, identificador no declarado");

            destruirSimbolo(s);

            $$ = NULL;

        }

    }

    | error {

        report_error("en expresión", @$.first_line, "sintaxis de expresión inválida");

        yyerrok;

        $$ = NULL;

    }

    ;



opAsignacion

    : '=' { $$ = strdup("="); } 

    | MAS_IGUAL { $$ = strdup("+="); } 

    | MENOS_IGUAL { $$ = strdup("-="); } 

    | DIV_IGUAL { $$ = strdup("/="); } 

    | POR_IGUAL { $$ = strdup("*="); } 

    ;



expOr // saque if-in-line por complejidad

    : expAnd { $$ = $1; }

    | expOr OR expAnd {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("en OR", @$.first_line, "error semantico, operador lógico solo admite tipos numéricos.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    ;



expAnd

    : expIgualdad { $$ = $1; }

    | expAnd AND expIgualdad {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("en AND", @$.first_line, "error semantico, operador lógico solo admite tipos numéricos.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    ;



expIgualdad

    : expRelacional { $$ = $1; }

    | expIgualdad IGUALDAD expRelacional {

        if (!tiposCompatibles($1->tipo, $3->tipo) && !tiposCompatibles($3->tipo, $1->tipo)) {

            report_error("en '=='", @$.first_line, "tipos incompatibles en comparación.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    | expIgualdad DIFERENTE expRelacional {

        if (tiposCompatibles($1->tipo, $3->tipo) || tiposCompatibles($3->tipo, $1->tipo)) {

            report_error("en '!='", @$.first_line, "tipos incompatibles en comparación.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    ;



expRelacional

    : expAditiva { $$ = $1; }

    | expRelacional MAYOR_IGUAL expAditiva {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("en MAYOR_IGUAL", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    | expRelacional '>' expAditiva {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("en MAYOR", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    | expRelacional MENOR_IGUAL expAditiva {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("en MENOR_IGUAL", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    | expRelacional '<' expAditiva {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("en MENOR", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");

            $$ = NULL;

        } else {

            $$ = crearExpr("int", 0);

        }

    }

    ;



expAditiva

    : expMultiplicativa { $$ = $1; }

    | expAditiva '+' expMultiplicativa {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("+", @$.first_line, "error semantico, solo suma numérica permitida.");

            $$ = NULL;

        } else {

            $$ = crearExpr(tipoResultadoNumerico($1->tipo, $3->tipo), 0);

        }

    }

    | expAditiva '-' expMultiplicativa {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("-", @$.first_line, "error semantico, solo resta numérica permitida.");

            $$ = NULL;

        } else {

            $$ = crearExpr(tipoResultadoNumerico($1->tipo, $3->tipo), 0);

        }

    }

    ;



expMultiplicativa 

    : expUnaria { $$ = $1; }

    | expMultiplicativa '*' expUnaria {

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("*", @$.first_line, "error semantico, solo multiplicacion numérica permitida.");

            $$ = NULL;

        } else {

            $$ = crearExpr("double", 0);

        }

    }

    | expMultiplicativa '/' expUnaria { 

        if (!esNumerico($1->tipo) || !esNumerico($3->tipo)) {

            report_error("/", @$.first_line, "error semantico, solo division numérica permitida.");

            $$ = NULL;

        } else {

            $$ = crearExpr("double", 0);

        }

    }

    ;



expUnaria

    : expPostfijo { $$ = $1; }

    | operUnario expPostfijo %prec UNARIO {

        if (!esNumerico($2->tipo)) {

            report_error("unario", @$.first_line, "error semantico, solo unario en numerico permitido.");

            $$ = NULL;

        } else {

            if()

            $$ = crearExpr(tipoResultadoNumerico("int", $2->tipo), 1);

        }

    }

    | INCREMENTO expPrimaria { /* ++x */ 

        if (!esNumerico($2->tipo)) {

            report_error("PRE INCREMENTO", @$.first_line, "error semantico, solo ++ numerico permitido.");

            $$ = NULL;

        } else {

            $$ = crearExpr(tipoResultadoNumerico("int", $2->tipo), 1);

        }

    }

    | DECREMENTO expPrimaria { /* --x */ 

        if (!esNumerico($2->tipo)) {

            report_error("PRE DECREMENTO", @$.first_line, "error semantico, solo -- numerico permitido.");

            $$ = NULL;

        } else {

            $$ = crearExpr(tipoResultadoNumerico("int", $2->tipo), 1);

        }

    }

    ;

    

operUnario 

    : '-' { $$ = "-"; }  /* signo negativo */

    | '!' { $$ = "!"; }  /* NOT lógico */

    ;



expPostfijo

    : expPrimaria { $$ = $1; }

    | IDENTIFICADOR '(' listaArgumentos ')' {

    }

    | expPrimaria INCREMENTO /* post ++ (+1 == +int)*/ { 

    }

    | expPrimaria DECREMENTO /* post -- */ { 

    }

    ;



listaArgumentos // hare argumentos simples en funciones, solo identificadores/string/numerico

    : /* vacío */ { $$ = NULL; }

    | argumento {

        Array* arr = createArray(10);

        char* e = $1;

        insertElemArray(arr, e);

        $$ = arr;

    }

    | listaArgumentos ',' argumento {

        char* e = $3;

        insertElemArray($1, e);

        $$ = $1;

    }

    ;



argumento // no analizo funciones de orden superior

    : IDENTIFICADOR { 

    }

    | ENTERO { $$ = strdup("int"); }

    | NUMERO { $$ = strdup("double"); }

    | CARACTER { $$ = strdup("char"); }

    | CADENA { $$ = strdup("char*"); }

    ;



expPrimaria

    : IDENTIFICADOR {

    }

    | ENTERO { 

    }

    | NUMERO { 

    }

    | CARACTER { 

    }

    | CADENA { 

    }

    | '(' expOr ')' { 

    }

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
