%{

#include<math.h>
#include<stdlib.h>
#include<stdio.h>
#include<ctype.h>
#include<string.h>
#include<tablaSimbolos.h>

extern int yylex();
int yyerror(const char* s);

extern FILE* yyin;
extern char* yytext;
extern void iniciarUbicaciones();

int errorCount = 0;

TablaScopes* tablaGral = NULL;
int nivelScope = 0;

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

int esNumeroEntero(const char* s) {
    if (!s || *s == '\0')
        return 0;

    for (int i = 0; s[i]; i++) {
        if (!isdigit(s[i]) && !(i == 0 && s[i] == '-'))
            return 0;
    }
    return 1;
}

int valorPerteneceAlEnum(Simbolo* enumSimbolo, char* valor) {
    for (int i = 0; i < arraySize(enumSimbolo->miembros); i++) {
        Enumerador* enumVal = (Enumerador*) findElemArray(enumSimbolo->miembros, i);
        if (strcmp(enumVal->nombre, valor) == 0)
            return 1;
    }

    if(esNumeroEntero(valor)){
        for (int i = 0; i < arraySize(enumSimbolo->miembros); i++) {
            Enumerador* enumVal = (Enumerador*) findElemArray(enumSimbolo->miembros, i);
            if (enumVal->valor == atoi(valor))
                return 1;
        }
    }
    
    return 0;
}

int tiposCompatibles(char* t1, char* t2) {
    if (t1 == NULL || t2 == NULL) {
        return 0;
    }

    if (strcmp(t1, "error") == 0 || strcmp(t2, "error") == 0) {
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
                strcmp(t2, "char") == 0);
    }

    else if (strcmp(t1, "int") == 0) {
        return strcmp(t2, "char") == 0;           
    }

    Simbolo* enumTipo = buscarSimbolo(tablaGral, t1); //caso asignarle identificador a un enum
    if (enumTipo != NULL && enumTipo->clase == ENUMR) {
        if (valorPerteneceAlEnum(enumTipo, t2)) // t2 = IDENTIFICADOR o "k" de enum
            return 1;

        return 0; // no pertenece al enum
    }

    return 0;
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

int esNumerico(char* tipo) {
    if (!tipo) return 0;

    // Tipos numéricos básicos
    if (strcmp(tipo, "int") == 0 ||
        strcmp(tipo, "float") == 0 ||
        strcmp(tipo, "double") == 0 ||
        strcmp(tipo, "char") == 0)
        return 1;

    // Enums es equivalente a int
    Simbolo* s = buscarSimbolo(tablaGral, tipo);
    if (s && s->clase == ENUMR)
        return 1;

    return 0;
}

%}

%define parse.error verbose // mensajes de error detallados
%locations // manejo de ubicaciones
%code requires{#include<tablaSimbolos.h>}

%union {
    int ival; // decimal, octal, hex
    double dval; // real
    char cval; // caracter
    char* cadena; // cadena, tipo_dato, identificador
    Array* arr;
    Parametro* p;
    Simbolo* s;
    Expr* expr;
}

// token es para definir el tipo de dato que almacena un terminal
%token <ival> ENTERO //defino que entero es un tipo ival -> es int de union
%token <dval> NUMERO
%token <cval> CARACTER
%token <cadena> CADENA TIPO_DATO IDENTIFICADOR
%token <cadena> RETURN FOR WHILE ELSE IF
%token <cadena> ENUMERADOR
%token INCREMENTO DECREMENTO MAS_IGUAL MENOS_IGUAL DIV_IGUAL POR_IGUAL
%token IGUALDAD DIFERENTE AND OR MAYOR_IGUAL MENOR_IGUAL

// type es para definir el tipo de dato que almacena un no terminal
%type <s> declaEnum declaVarSimple declaFuncion
%type <arr> ids_opt lista_ids lista_enumeradores
%type <cadena> tipo_opt cuerpoFuncion_opt opSent
%type <expr> inicializacion_opt
%type <arr> parametros_opt lista_parametros listaArgumentos
%type <p> parametro
%type <cadena> sentencias_opt sentencia sentCompuesta
%type <cadena> sentSeleccion sentSalto opAsignacion
%type <cadena> operUnario argumento
%type <expr> expresion_opt expresion expOr
%type <expr> expAnd expIgualdad expRelacional
%type <expr> expAditiva expMultiplicativa expUnaria
%type <expr> expPostfijo expPrimaria

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

declaEnum
    : ENUMERADOR IDENTIFICADOR '{' lista_enumeradores '}' {
        Simbolo* s = crearSimbolo($<cadena>2, ENUMR, strdup("enum"), @$.first_line, 0);

        // si esta declarado en el scope actual --> redeclarado
        if (!agregarSimbolo(tablaGral, s)) {
            report_error("en declaEnum", @$.first_line, "error semantico, enum redeclarado.");
            destruirSimbolo(s);
            $<s>$ = NULL;
        } else {
            /* lista_enumeradores devuelve Array* de Enumerador* con nom y val del elemEnum*/
            s->miembros = $<arr>4;
            s->cantMiembros = arraySize($<arr>4);

            printf("Declaración válida de enum <línea:%d>\n", @$.first_line);
            $<s>$ = s;        
        }
    }
        ids_opt {
            Simbolo* f = $<s>6;

            if (f != NULL) { // variables declaradas al final del enum
                if($<arr>7) {
                    int ok = 1;
                    for (int i = 0; i < arraySize($<arr>7); i++) {
                        char* varEnum = (char*) findElemArray($<arr>7, i); 
                        Simbolo* t = crearSimbolo(varEnum, VARIABLE, f->key, @$.first_line, 0);
                        if (!agregarSimbolo(tablaGral, t)) {
                            report_error("en id_opt", @$.first_line, "error semantico, existe variable con ese nombre. No se declarara enum");
                            destruirSimbolo(t);
                            free(varEnum);
                            ok = 0;
                            break;
                        }
                    }
                    if(!ok) {
                        eliminarSimbolo(tablaGral, f);
                        destruirSimbolo(f);
                        $<s>$ = NULL;
                    } else { 
                        printf("Declaración válida de var de enum <línea:%d>\n", @$.first_line);
                        $<s>$ = f; 
                    }
                } else { $<s>$ = f; }
                
            } else { destruirSimbolo(f); $<s>$ = NULL; }
    }

    | error ';' {
        report_error("en declaEnum", @$.first_line, "error sintactico de declaración de enum.");
        yyerrok;
    }
    ;

ids_opt
    : ';' { $<arr>$ = NULL; }
    | lista_ids { $<arr>$ = $<arr>1; }
    ;

lista_ids
    : IDENTIFICADOR {
        Array* arr = createArray(10);
        char* e = strdup($<cadena>1);
        insertElemArray(arr, e);
        $<arr>$ = arr;
    }
    | lista_ids ',' IDENTIFICADOR {
        char* e = strdup($<cadena>3);
        insertElemArray($<arr>1, e);
        $<arr>$ = $<arr>1;
    }
    ;

lista_enumeradores
    : IDENTIFICADOR {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember($<cadena>1, 0);
        insertElemArray(arr, em);
        $<arr>$ = arr;
    }
    | IDENTIFICADOR '=' ENTERO {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember($<cadena>1, $<ival>3);
        insertElemArray(arr, em);
        $<arr>$ = arr;
    }
    | lista_enumeradores ',' IDENTIFICADOR {
        int valor = ((Enumerador*)findElemArray($<arr>1, arraySize($<arr>1)-1))->valor + 1;
        Enumerador* em = crearEnumMember($<cadena>3, valor);
        insertElemArray($<arr>1, em);
        $<arr>$ = $<arr>1;
    }
    | lista_enumeradores ',' IDENTIFICADOR '=' ENTERO {
        Enumerador* em = crearEnumMember($<cadena>3, $<ival>5);
        insertElemArray($<arr>1, em);
        $<arr>$ = $<arr>1;
    }
    ;

declaVarSimple
    : tipo_opt IDENTIFICADOR {
        char* tipo = $<cadena>1;
        if(tipo && esTipoBasico(tipo)) {
            Simbolo* v = crearSimbolo(
                $<cadena>2,
                VARIABLE,
                tipo,
                @1.first_line,
                0
            );

            if (!agregarSimbolo(tablaGral, v)) {
                report_error("en declaVarSimple", @$.first_line, "error semantico, variable redeclarada.");
                destruirSimbolo(v);
                $<s>$ = NULL;
            } else {
                printf("Declaración válida de varSimple <línea:%d>\n", @$.first_line);
                $<s>$ = v;        
            }
        } else { // tiene que ser identificador enum
            Simbolo* s = buscarSimbolo(tablaGral, tipo);
            if(s && s->clase == ENUMR) {
                Simbolo* v = crearSimbolo(
                    $<cadena>2,
                    VARIABLE,
                    tipo,
                    @1.first_line,
                    0
                );
                if (!agregarSimbolo(tablaGral, v)) {
                    report_error("en declaVarSimple", @$.first_line, "error semantico, variable redeclarada.");
                    destruirSimbolo(v);
                    $<s>$ = NULL;
                } else {
                    printf("Declaración válida de varSimple <línea:%d>\n", @$.first_line);
                    $<s>$ = v;        
                }
            } else {
                report_error("en declaVarSimple", @$.first_line, "error semantico, tipoDato no definido");
                free(tipo);
                $<s>$ = NULL;
            }
        }
    }
        inicializacion_opt {
            Simbolo* v = $<s>3;   // el símbolo creado

            if (v != NULL) {
                if ($<expr>4) {
                    Expr* exprInit = $<expr>4; char* tipoInit = exprInit->tipo;

                    // Validar inicialización
                    if (!tiposCompatibles(v->tipoDato, tipoInit)) {
                        report_error("en declaVarSimple", @$.first_line,
                                        "error semantico, inicialización incompatible con el tipo de la variable.");
                        eliminarSimbolo(tablaGral, v);
                        destruirSimbolo(v);
                        $<s>$ = NULL;
                    } else { 
                        printf("Declaración válida de var inicializada <línea:%d>\n", @$.first_line);
                        $<s>$ = v; 
                    }
                } else { $<s>$ = v; }
            } else { destruirSimbolo(v); $<s>$ = NULL;}
    }

    | error ';' {
        report_error("en declaVarSimple", @$.first_line, "error sintactico de declaración de variable.");
        yyerrok;
    }
    ;

tipo_opt
    : TIPO_DATO { $<cadena>$ = $<cadena>1; }
    | TIPO_DATO '*' {
        if (strcmp($<cadena>1, "char") == 0) {
            $<cadena>$ = strdup("char*");
        } else {
            report_error("en tipo_opt", @1.first_line,
                            "no analizo punteros");
            $<cadena>$ = NULL;
        }
    }
    | IDENTIFICADOR { $<cadena>$ = $<cadena>1; }
    ;

inicializacion_opt
    : ';' { $<expr>$ = NULL; }
    | '=' expOr ';' { $<expr>$ = $<expr>2; }
    ;

declaFuncion
    : TIPO_DATO IDENTIFICADOR '(' parametros_opt ')' {
        Simbolo* s = crearSimbolo(
            $<cadena>2,
            FUNCION,
            $<cadena>1,
            @$.first_line,
            0
        );

        if (!agregarSimbolo(tablaGral, s)) {
            report_error("en declaFuncion", @$.first_line, "error semantico, funcion redeclarada.");
            destruirSimbolo(s);
            $<s>$ = NULL;
        } else {
            if($<arr>4) {
                int ok = 1;
                for (int i = 0; i < arraySize($<arr>4); i++) {
                    char* tipoParametro = (char*) findElemArray($<arr>4, i); 
                    if (strcmp(tipoParametro, "error") == 0) {
                        report_error("en declaFuncion", @$.first_line, "error en parametro");
                        free(tipoParametro);
                        ok = 0;
                        break;
                    }
                }
                if(!ok) {
                    eliminarSimbolo(tablaGral, s);
                    destruirSimbolo(s);
                    $<s>$ = NULL;
                } 
            } else {
                s->miembros = $<arr>4;
                s->cantMiembros = 0;
                printf("Declaración válida de funcion <línea:%d>\n", @$.first_line);
                $<s>$ = s;
            }
        }    
    } 
        cuerpoFuncion_opt {
            Simbolo* f = $<s>6;
            char* tipoDeclarado = $<cadena>1;
            char* tipoRetornado = $<cadena>7;
            if (tipoRetornado == NULL && strcmp(tipoDeclarado, "void") != 0) {
                report_error("en función", @$.first_line,
                                "error semantico, falta retorno en funcion");
                eliminarSimbolo(tablaGral, f);
                destruirSimbolo(f);
                free(tipoDeclarado);
                free(tipoRetornado);
                $<s>$ = NULL;
            } else if (tipoRetornado != NULL && strcmp(tipoRetornado, ";") != 0 &&
                        !tiposCompatibles(tipoDeclarado, tipoRetornado)) {
                report_error("en función", @$.first_line,
                                "error semantico, Tipo de retorno incompatible.");
                eliminarSimbolo(tablaGral, f);
                destruirSimbolo(f);
                free(tipoDeclarado);
                free(tipoRetornado);
                $<s>$ = NULL;
            } else { 
                printf("Declaración válida de funcion con cuerpo <línea:%d>\n", @$.first_line);
                $<s>$ = f; 
            }
    }

    | error ';' {
        report_error("en declaFuncion", @$.first_line, "error sintactico de declaración de funcion.");
        yyerrok;
    }
    ;

cuerpoFuncion_opt
    : sentCompuesta { $<cadena>$ = $<cadena>1; }
    | ';' { $<cadena>$ = ";"; }
    ;

parametros_opt
    : /* vacío */ { $<arr>$ = NULL; }
    | lista_parametros { $<arr>$ = $<arr>1; }
    ;

lista_parametros
    : parametro {
        Array* arr = createArray(10);
        if ($<p>1 != NULL) { 
            insertElemArray(arr, $<p>1);
            $$ = arr;
        } else { 
            insertElemArray(arr, "error");
            $$ = arr;
        }
    }
    | lista_parametros ',' parametro {
        if ($<p>3 != NULL) { 
            insertElemArray($<arr>1, $<p>3);
            $<arr>$ = $<arr>1;
        } else { 
            insertElemArray($<arr>1, "error");
            $<arr>$ = $<arr>1;
        }
    }
    ;

parametro
    : TIPO_DATO IDENTIFICADOR {
        if (strcmp($<cadena>1, "void") == 0) {
            report_error("en parámetro", @1.first_line,
                            "Un parámetro no puede ser de tipo 'void'.");
            $<p>$ = NULL;
        } else {
            Parametro* p = crearParametro($<cadena>2, $<cadena>1);
            $<p>$ = p;
        }
    }
    | TIPO_DATO '*' IDENTIFICADOR {
        if (strcmp($<cadena>1, "char") == 0) {
            Parametro* p = crearParametro($<cadena>2, "char*");
            $<p>$ = p;
        } else {
            report_error("en parámetro", @1.first_line,
                            "no analizo punteros, solo char*.");
            $<p>$ = NULL;
        }
    }
    ;

sentencias_opt
    : /* vacío */ { $<cadena>$ = NULL; }
    | sentencias_opt sentencia {
        if ($<cadena>2 != NULL)
            { $<cadena>$ = $<cadena>2; }     // si hubo un return en esta sentencia, me lo guardo
        else
            { $<cadena>$ = $<cadena>1; }     // sino conservo el anterior
    }
    ;

sentencia
    : sentCompuesta
        { $<cadena>$ = $<cadena>1; printf("Se leyó una sentCompuesta <linea:%d>\n", @1.first_line); }
    | sentExpresion
        { $<cadena>$ = NULL; printf("Se leyó una sentExpresion <linea:%d>\n", @1.first_line); }
    | sentSeleccion
        { $<cadena>$ = $<cadena>1; printf("Se leyó una sentSeleccion(if, else) <linea:%d>\n", @1.first_line); }
    | sentIteracion
        { $<cadena>$ = NULL; printf("Se leyó una sentIteracion(while, for) <linea:%d>\n", @1.first_line); }
    | sentSalto
        { $<cadena>$ = $<cadena>1; printf("Se leyó una sentSalto(return) <linea:%d>\n", @1.first_line); }
    | error ';' {
        report_error("en sentencia", @$.first_line, "error sintactico de sentencia.");
        yyerrok;
        $<cadena>$ = NULL;
    }
    ;

sentCompuesta
    : '{' { reportAbrirScope("SentCompuesta"); } 
     declaraciones_opt sentencias_opt '}' 
        { reportCerrarScope("sentCompuesta"); $<cadena>$ = $<cadena>4; }

    | '{' error '}' {
        report_error("en sentCompuesta", @$.first_line,
                        "Error sintáctico dentro de bloque.");
        yyerrok;
        reportCerrarScope("sentCompuesta"); $<cadena>$ = NULL;
    }
    ;

sentExpresion // sentencia sin llave no tiene scope
    : expresion_opt ';' 
    | ';'

    | error ';' {
        report_error("en sentExpresión", @$.first_line, "sintaxis de expresión inválida");
        yyerrok;
    }
    ;

sentSeleccion
    : IF '(' error ')' sentencia opSent {
          report_error("en IF", @$.first_line, "condición inválida, error sintactico");
          yyerrok; $<cadena>$ = NULL;
    }
    | IF '(' expresion ')' 
        { // Verificar variables usadas en la condición
            if(!esNumerico($<expr>3->tipo)){
                report_error("en IF", @$.first_line, "condición inválida");
            }
            reportAbrirScope("(IF)"); 
        }  
     sentencia 
        {
            char* ret = $<cadena>6;
            reportCerrarScope("(IF)");
            $<cadena>$ = ret;
        }
     opSent 
        {
            if ($<cadena>8 != NULL) { /* ELSE existe */
                char* retIf   = $<cadena>6; 
                char* retElse = $<cadena>8;

                if (retIf != NULL && retElse != NULL) {
                    if (!tiposCompatibles(retIf, retElse))
                        report_error("en IF-ELSE", @$.first_line, "tipos de retorno incompatibles en IF/ELSE");

                    $<cadena>$ = retIf; /* return válido */
                } else {
                    $<cadena>$ = retIf ? retIf : retElse;
                }
            }
        }
    ;

opSent
    : /* vacío */ { $<cadena>$ = NULL; }
    | ELSE 
        { reportAbrirScope("(ELSE)"); } 
     sentencia
        { reportCerrarScope("(ELSE)"); $<cadena>$ = $<cadena>3; }
    ;

sentIteracion
    : WHILE '(' expresion ')' 
        {
            if(!esNumerico($<expr>3->tipo)){
                report_error("en WHILE", @$.first_line, "condición inválida");
            }
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
            if($<expr>5 != NULL && !esNumerico($<expr>5->tipo)){
                report_error("en FOR", @$.first_line, "condición inválida");
            }
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
        if ($<expr>2 == NULL) {
            // return sin valor → tipo = void
            $<cadena>$ = strdup("void");
        } else {
            // la expresión devuelve un tipo
            $<cadena>$ = $<expr>2->tipo;
        }
    }

    | error ';' {
        report_error("en sentSalto", @$.first_line, "sintaxis de expresión inválida");
        $<cadena>$ = NULL;
        yyerrok;
    }
    ;

expresion_opt
    : /* vacío */ { $<expr>$ = NULL; }
    | expresion { $<expr>$ = $<expr>1; }
    ; 

expresion
    : expOr { $<expr>$ = $<expr>1; }
    | IDENTIFICADOR opAsignacion expOr {
        Simbolo* s = buscarSimbolo(tablaGral, $<cadena>1);
        if(s && s->clase == VARIABLE) {
            if (!tiposCompatibles(s->tipoDato, $<expr>3->tipo)) {
                report_error("en asignación", @$.first_line,
                        "error semantico, tipo incompatible en asignación.");
                $<expr>$ = NULL;
            }

            // tipo de la expresión asignación es el del LHS
            $<expr>$ = crearExpr(s->tipoDato, 0);
        } else {
            report_error("en expresion", @1.first_line,
                "error semantico, identificador no declarado");
            $<expr>$ = NULL;
        }
    }

    | error {
        report_error("en expresión", @$.first_line, "sintaxis de expresión inválida");
        yyerrok;
        $<expr>$ = NULL;
    }
    ;

opAsignacion
    : '=' { $<cadena>$ = strdup("="); } 
    | MAS_IGUAL { $<cadena>$ = strdup("+="); } 
    | MENOS_IGUAL { $<cadena>$ = strdup("-="); } 
    | DIV_IGUAL { $<cadena>$ = strdup("/="); } 
    | POR_IGUAL { $<cadena>$ = strdup("*="); } 
    ;

expOr // saque if-in-line por complejidad
    : expAnd { $<expr>$ = $<expr>1; }
    | expOr OR expAnd {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("en OR", @$.first_line, "error semantico, operador lógico solo admite tipos numéricos.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    ;

expAnd
    : expIgualdad { $<expr>$ = $<expr>1; }
    | expAnd AND expIgualdad {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("en AND", @$.first_line, "error semantico, operador lógico solo admite tipos numéricos.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    ;

expIgualdad
    : expRelacional { $<expr>$ = $<expr>1; }
    | expIgualdad IGUALDAD expRelacional {
        if (!tiposCompatibles($<expr>1->tipo, $<expr>3->tipo) && !tiposCompatibles($<expr>3->tipo, $<expr>1->tipo)) {
            report_error("en '=='", @$.first_line, "tipos incompatibles en comparación.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    | expIgualdad DIFERENTE expRelacional {
        if (tiposCompatibles($<expr>1->tipo, $<expr>3->tipo) || tiposCompatibles($<expr>3->tipo, $<expr>1->tipo)) {
            report_error("en '!='", @$.first_line, "tipos incompatibles en comparación.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    ;

expRelacional
    : expAditiva { $<expr>$ = $<expr>1; }
    | expRelacional MAYOR_IGUAL expAditiva {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("en MAYOR_IGUAL", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    | expRelacional '>' expAditiva {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("en MAYOR", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    | expRelacional MENOR_IGUAL expAditiva {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("en MENOR_IGUAL", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    | expRelacional '<' expAditiva {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("en MENOR", @$.first_line, "error semantico, comparacion solo admite tipos numéricos.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("int", 0);
        }
    }
    ;

expAditiva
    : expMultiplicativa { $<expr>$ = $<expr>1; }
    | expAditiva '+' expMultiplicativa {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("+", @$.first_line, "error semantico, solo suma numérica permitida.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico($<expr>1->tipo, $<expr>3->tipo), 0);
        }
    }
    | expAditiva '-' expMultiplicativa {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("-", @$.first_line, "error semantico, solo resta numérica permitida.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico($<expr>1->tipo, $<expr>3->tipo), 0);
        }
    }
    ;

expMultiplicativa 
    : expUnaria { $<expr>$ = $<expr>1; }
    | expMultiplicativa '*' expUnaria {
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("*", @$.first_line, "error semantico, solo multiplicacion numérica permitida.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico($<expr>1->tipo, $<expr>3->tipo), 0);
        }
    }
    | expMultiplicativa '/' expUnaria { 
        if (!esNumerico($<expr>1->tipo) || !esNumerico($<expr>3->tipo)) {
            report_error("/", @$.first_line, "error semantico, solo division numérica permitida.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr("double", 0);
        }
    }
    ;

expUnaria
    : expPostfijo { $<expr>$ = $<expr>1; }
    | operUnario expPostfijo %prec UNARIO {
        if (!esNumerico($<expr>2->tipo)) {
            report_error("unario", @$.first_line, "error semantico, solo unario en numerico permitido.");
            $<expr>$ = NULL;
        } else {
            if(strcmp($1, "!") == 0) {
                $<expr>$ = crearExpr("int", 0);
            } else { // (-1) * k
                $<expr>$ = crearExpr(tipoResultadoNumerico("int", $<expr>2->tipo), 0);
            }
        }
    }
    | INCREMENTO expPrimaria { /* ++x */ 
        if (!esNumerico($<expr>2->tipo)) {
            report_error("PRE INCREMENTO", @$.first_line, "error semantico, solo ++ numerico permitido.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico("int", $<expr>2->tipo), 0);
        }
    }
    | DECREMENTO expPrimaria { /* --x */ 
        if (!esNumerico($<expr>2->tipo)) {
            report_error("PRE DECREMENTO", @$.first_line, "error semantico, solo -- numerico permitido.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico("int", $<expr>2->tipo), 0);
        }
    }
    ;

operUnario 
    : '-' { $<cadena>$ = "-"; }  /* signo negativo */
    | '!' { $<cadena>$ = "!"; }  /* NOT lógico */
    ;

expPostfijo
    : expPrimaria { $<expr>$ = $<expr>1; }
    | IDENTIFICADOR '(' listaArgumentos ')' {
        Simbolo* s = buscarSimbolo(tablaGral, $<cadena>1);
        if(s && s->clase == FUNCION) {
            int cantArgs = $<arr>3? arraySize($<arr>3) : 0;
            int cantArgsFunc = s->cantMiembros;
            // verifico cantArgs y compatibilidad de tipoDato var con el que retorna func
            if(cantArgs == cantArgsFunc) {
                // verifico que los args correspondan al tipo pedido en los parametros de func
                int ok = 1;
                for (int i = 0; i < cantArgsFunc; i++) {
                    char* tipoArg = findElemArray($<arr>3, i);
                    char* tipoParam  = findElemArray(s->miembros, i);

                    if (!tiposCompatibles(tipoParam, tipoArg)) {
                        ok = 0;
                        break;
                    }
                }
                if (!ok) {
                    report_error("en llamada a funcion", @1.first_line,
                                    "tipos incompatibles en los argumentos");
                    $<expr>$ = NULL;
                } else {
                    // La llamada es válida: retorna el tipo de la función
                    $<expr>$ = crearExpr(s->tipoDato, 0);
                }
            } else {
                report_error("en expPostfijo", @$.first_line, "cantidad de argumentos en funcion invalida");
                $<expr>$ = NULL;
            }
        } else {
            report_error("en expPostfijo", @$.first_line, "funcion no declarada o identificador no es funcion");
            $<expr>$ = NULL;
        }
    }
    | expPrimaria INCREMENTO /* post ++ (+1 == +int)*/ { 
        if (!esNumerico($<expr>1->tipo)) {
            report_error("INCREMENTO", @$.first_line, "error semantico, solo ++ numerico permitido.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico($<expr>1->tipo, "int"), 0);
        }
    }
    | expPrimaria DECREMENTO /* post -- */ { 
        if (!esNumerico($<expr>1->tipo)) {
            report_error("DECREMENTO", @$.first_line, "error semantico, solo -- numerico permitido.");
            $<expr>$ = NULL;
        } else {
            $<expr>$ = crearExpr(tipoResultadoNumerico($<expr>1->tipo, "int"), 0);
        }
    }
    ;

listaArgumentos // hare argumentos simples en funciones, solo identificadores/string/numerico
    : /* vacío */ { $$ = NULL; }
    | argumento {
        Array* arr = createArray(10);
        if ($<cadena>1 != NULL) { 
            insertElemArray(arr, $<cadena>1);
            $$ = arr;
        } else { 
            insertElemArray(arr, "error");
            $$ = arr;
        }
    }
    | listaArgumentos ',' argumento {
        if ($<cadena>3 != NULL) { 
            insertElemArray($<arr>1, $<cadena>3);
            $<arr>$ = $<arr>1;
        } else { 
            insertElemArray($<arr>1, "error");
            $<arr>$ = $<arr>1;
        }
    }
    ;

argumento // no analizo funciones de orden superior
    : IDENTIFICADOR { 
        Simbolo* s = buscarSimbolo(tablaGral, $<cadena>1);
        if (s && s->clase == VARIABLE) {
            Simbolo* enumTipo = buscarSimbolo(tablaGral, s->tipoDato);
            if(enumTipo && enumTipo->clase == ENUMR) {
                report_error("en argumento", @$.first_line, "tipo argumento no permitido");
                $<cadena>$ = NULL;
            } else {
                $<cadena>$ = s->tipoDato;
            }
        } else {
            report_error("en argumento", @$.first_line, "variable no declarada");
            destruirSimbolo(s);
            $<cadena>$ = NULL;
        }
    }
    | ENTERO { $<cadena>$ = strdup("int"); }
    | NUMERO { $<cadena>$ = strdup("double"); }
    | CARACTER { $<cadena>$ = strdup("char"); }
    | CADENA { $<cadena>$ = strdup("char*"); }
    ;

expPrimaria
    : IDENTIFICADOR {
        Simbolo* s = buscarSimbolo(tablaGral, $<cadena>1);
        if (s && s->clase == VARIABLE) {
            char* e = s->tipoDato; //puede ser var de un enum
            if(esTipoBasico(e)) {
                $<expr>$ = crearExpr(s->tipoDato, 1);
            } else {
                Simbolo* enumTipo = buscarSimbolo(tablaGral, s->tipoDato);
                if(enumTipo && enumTipo->clase == ENUMR) {
                    $<expr>$ = crearExpr("int", 1);
                } else {
                    report_error("en expPrimaria", @$.first_line, "variable no permitida");
                    $<expr>$ = NULL;
                }
            }
        } else {
            report_error("en expPrimaria", @$.first_line, "variable no declarada");
            $<expr>$ = NULL;
        }
    }
    | ENTERO { 
        $<expr>$ = crearExpr("int", 0);
    }
    | NUMERO { 
        $<expr>$ = crearExpr("double", 0);
    }
    | CARACTER { 
        $<expr>$ = crearExpr("char", 0);
    }
    | CADENA { 
        $<expr>$ = crearExpr("char*", 0);
    }
    | '(' expOr ')' { 
        $<expr>$ = $<expr>2;
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
