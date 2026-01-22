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
char* nomFuncActual = NULL;
int inFunctionBlock = 0;

/* Helper para reportar errores */
void report_error(const char *where, int line, const char *msg) {
    fprintf(stderr, "Error %s <línea:%d>: %s\n", where ? where : "desconocido", line, msg ? msg : "error");
    fprintf(stderr, "Token: '%s'\n", yytext);
    errorCount++;
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

char* itoa(int n) {
    char buffer[32];             
    int len = snprintf(buffer, sizeof(buffer), "%d", n);

    if (len < 0) {
        return NULL; 
    }

    char* result = malloc(len + 1); // +1 para '\0'
    if (!result) {
        return NULL; 
    }

    strcpy(result, buffer);
    return result;
}

int valorPerteneceAlEnum(Simbolo* enumSimbolo, char* valor) { //se comprobo previamente que valor es int
    for (int i = 0; i < arraySize(enumSimbolo->miembros); i++) {
        Enumerador* enumVal = (Enumerador*) findElemArray(enumSimbolo->miembros, i);
        if (enumVal->valor == atoi(valor))
            return 1;
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
        return (strcmp(t2, "char") == 0 ||
                esNumeroEntero(t2));      // caso asignarle constenum a un int     
    }

    Simbolo* enumTipo = buscarSimbolo(tablaGral, t1); //caso asignarle constenum a un nomEnum
    if (enumTipo != NULL && enumTipo->clase == ENUMR && esNumeroEntero(t2)) {
        if(valorPerteneceAlEnum(enumTipo, t2))
            return 1;

        return 0;
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
%type <s> declaEnum declaVoF
%type <arr> ids_opt lista_ids lista_enumeradores
%type <cadena> items tipo_opt opSent
%type <arr> parametros_opt lista_parametros listaArgumentos
%type <p> parametro
%type <cadena> sentencia sentCompuesta
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
    : items
    ;

items
    : /* vacío */ { $<cadena>$ = NULL; }
    | items item { 
            if ($<cadena>2 != NULL)
                $<cadena>$ = $<cadena>2;
            else
                $<cadena>$ = $<cadena>1;
      }
    ;

item
    : declaracion { $<cadena>$ = $<cadena>1; }
    | sentencia { $<cadena>$ = $<cadena>1; }
    ;

declaracion
    : declaVoF
    | declaEnum

    | error ';' {
        report_error("en declaracion", @$.first_line, "error sintactico de declaración.");
        yyerrok;
    }
    | error '}' { // para la terminacion de declaracion funcion q no es ';'
        report_error("en declaracion", @$.first_line, "error sintactico de declaración.");
        yyerrok;
    }
    ;

declaEnum
    : ENUMERADOR IDENTIFICADOR '{' lista_enumeradores '}' {
        Simbolo* s = crearSimbolo($<cadena>2, ENUMR, strdup("enum"), @$.first_line);

        // si esta declarado en el scope actual --> redeclarado
        if (!agregarSimbolo(tablaGral, s)) {
            report_error("en declaEnum", @$.first_line, "error semantico, enum redeclarado.");
            $<s>$ = NULL;
        } else {
            /* lista_enumeradores devuelve Array* de Enumerador* con nom y val del elemEnum */
            // o NULL si algo salio mal
            if($<arr>4) {
                s->miembros = $<arr>4;
                s->cantMiembros = arraySize($<arr>4);
                printf("Declaración válida de enum <línea:%d>\n", @$.first_line);
                $<s>$ = s; 
            } else {
                report_error("en declaEnum", @$.first_line, "error semantico, error en lista_enumeradores por variable redeclarada");
                eliminarSimbolo(tablaGral, s);
                $<s>$ = NULL;
            }
        }
    }
        ids_opt {
            Simbolo* f = $<s>6;

            if (f != NULL) { // variables declaradas al final del enum
                if($<arr>7) {
                    int ok = 1;
                    for (int i = 0; i < arraySize($<arr>7); i++) {
                        char* varEnum = (char*) findElemArray($<arr>7, i); 
                        Simbolo* t = crearSimbolo(varEnum, VARIABLE, f->key, @$.first_line);
                        if (!agregarSimbolo(tablaGral, t)) {
                            report_error("en id_opt", @$.first_line, "error semantico, existe variable con ese nombre. No se declarara enum");
                            free(varEnum);
                            ok = 0;
                            break;
                        }
                    }
                    if(!ok) {
                        eliminarSimbolo(tablaGral, f);
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
        Simbolo* t = crearSimbolo($<cadena>1, CONSTENUM, "0", @$.first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            $<arr>$ = NULL;
        } else {
            insertElemArray(arr, em);
            $<arr>$ = arr;
        }
    }
    | IDENTIFICADOR '=' ENTERO {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember($<cadena>1, $<ival>3);
        char* c = itoa($<ival>3);
        Simbolo* t = crearSimbolo($<cadena>1, CONSTENUM, c, @$.first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            $<arr>$ = NULL;
        } else {
            insertElemArray(arr, em);
            $<arr>$ = arr;
        }
    }
    | lista_enumeradores ',' IDENTIFICADOR {
        int valor = ((Enumerador*)findElemArray($<arr>1, arraySize($<arr>1)-1))->valor + 1;
        Enumerador* em = crearEnumMember($<cadena>3, valor);
        char* c = itoa(valor);
        Simbolo* t = crearSimbolo($<cadena>3, CONSTENUM, c, @$.first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            $<arr>$ = NULL;
        } else {
            insertElemArray($<arr>1, em);
            $<arr>$ = $<arr>1;
        }
    }
    | lista_enumeradores ',' IDENTIFICADOR '=' ENTERO {
        Enumerador* em = crearEnumMember($<cadena>3, $<ival>5);
        char* c = itoa($<ival>5);
        Simbolo* t = crearSimbolo($<cadena>3, CONSTENUM, c, @$.first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            $<arr>$ = NULL;
        } else {
            insertElemArray($<arr>1, em);
            $<arr>$ = $<arr>1;
        }
    }
    ;

declaVoF
    : tipo_opt IDENTIFICADOR ';' {
        char* tipo = $<cadena>1;
        if(tipo) {
            if(esTipoBasico(tipo)) {
                Simbolo* v = crearSimbolo(
                    $<cadena>2,
                    VARIABLE,
                    tipo,
                    @1.first_line
                );

                if (!agregarSimbolo(tablaGral, v)) {
                    report_error("en declaVoF", @$.first_line, "error semantico, variable redeclarada.");
                    $<s>$ = NULL;
                } else {
                    printf("Declaración válida de varSimple <línea:%d>\n", @$.first_line);
                    $<s>$ = v;        
                }
            } else { // es tipo nomEnum o void
                if(strcmp(tipo, "void") == 0) {
                    report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no valido para variable");
                    $<s>$ = NULL;
                } else {
                    Simbolo* v = crearSimbolo(
                        $<cadena>2,
                        VARIABLE,
                        tipo,
                        @1.first_line
                    );
                    if (!agregarSimbolo(tablaGral, v)) {
                        report_error("en declaVarSimple", @$.first_line, "error semantico, variable redeclarada.");
                        $<s>$ = NULL;
                    } else {
                        printf("Declaración válida de varSimple tipo nomEnum <línea:%d>\n", @$.first_line);
                        $<s>$ = v;        
                    }
                }
            }
        } else {
            report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no definido");
            $<s>$ = NULL;
        }
    }
    | tipo_opt IDENTIFICADOR '(' parametros_opt ')' ';' {
        if($<cadena>1) {
            if(esTipoBasico($<cadena>1) || strcmp($<cadena>1, "void") == 0) {
                Simbolo* f = NULL;
                if(esTipoBasico($<cadena>1)) {
                    f = crearSimbolo(
                        $<cadena>2,
                        FUNCION,
                        $<cadena>1,
                        @$.first_line
                    );
                } else {
                    f = crearSimbolo(
                        $<cadena>2,
                        FUNCION,
                        strdup("void"),
                        @$.first_line
                    );
                }

                if (!agregarSimbolo(tablaGral, f)) {
                    report_error("en declaVoF", @$.first_line, "error semantico, funcion redeclarada.");
                    $<s>$ = NULL;
                } else {
                    if($<arr>4) {
                        int ok = 1;
                        for (int i = 0; i < arraySize($<arr>4); i++) {
                            Parametro* p = (Parametro*) findElemArray($<arr>4, i); 
                            if (strcmp(p->tipo, "error") == 0) {
                                report_error("en declaVoF", @$.first_line, "error en parametro");
                                //falta funcion destroyParametro
                                ok = 0;
                                break;
                            }
                        }
                        if(!ok) {
                            eliminarSimbolo(tablaGral, f);
                            $<s>$ = NULL;
                        } else {
                            printf("Declaración válida de funcion con parametros <línea:%d>\n", @$.first_line);
                            $<s>$ = f;
                        }
                    } else {
                        f->miembros = $<arr>4;
                        f->cantMiembros = 0;
                        printf("Declaración válida de funcion <línea:%d>\n", @$.first_line);
                        $<s>$ = f;
                    }
                }
            } else { // es tipo nomEnum
                report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no valido para funcion");
                $<s>$ = NULL;
            }
        } else {
            report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no definido");
            $<s>$ = NULL;
        }
    }
    | tipo_opt IDENTIFICADOR '=' {
        char* tipo = $<cadena>1;
        if(tipo) {
            if(esTipoBasico(tipo)) {
                Simbolo* v = crearSimbolo(
                    $<cadena>2,
                    VARIABLE,
                    tipo,
                    @1.first_line
                );

                if (!agregarSimbolo(tablaGral, v)) {
                    report_error("en declaVoF", @$.first_line, "error semantico, variable redeclarada.");
                    $<s>$ = NULL;
                } else {
                    printf("Declaración válida de varSimple <línea:%d>\n", @$.first_line);
                    $<s>$ = v;        
                }
            } else { // es tipo nomEnum o void
                if(strcmp(tipo, "void") == 0) {
                    report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no valido para variable");
                    $<s>$ = NULL;
                } else {
                    Simbolo* v = crearSimbolo(
                        $<cadena>2,
                        VARIABLE,
                        tipo,
                        @1.first_line
                    );
                    if (!agregarSimbolo(tablaGral, v)) {
                        report_error("en declaVarSimple", @$.first_line, "error semantico, variable redeclarada.");
                        $<s>$ = NULL;
                    } else {
                        printf("Declaración válida de varSimple tipo nomEnum <línea:%d>\n", @$.first_line);
                        $<s>$ = v;        
                    }
                }
            }
        } else {
            report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no definido");
            $<s>$ = NULL;
        }
    }
        expOr ';' {
            Simbolo* v = $<s>4;   // el símbolo creado

            if (v != NULL) {
                if ($<expr>5) {
                    Expr* exprInit = $<expr>5; char* tipoInit = exprInit->tipo;

                    // Validar inicialización
                    if (!tiposCompatibles(v->tipoDato, tipoInit)) {
                        report_error("en declaVarSimple", @$.first_line,
                                        "error semantico, inicialización incompatible con el tipo de la variable.");
                        eliminarSimbolo(tablaGral, v);
                        $<s>$ = NULL;
                    } else { 
                        printf("Declaración válida de var inicializada <línea:%d>\n", @$.first_line);
                        $<s>$ = v; 
                    }
                } else { destruirSimbolo(v); $<s>$ = NULL; }
            } else { destruirSimbolo(v); $<s>$ = NULL; }
    }
    | tipo_opt IDENTIFICADOR '(' parametros_opt ')' {
        if($<cadena>1) {
            if(esTipoBasico($<cadena>1) || strcmp($<cadena>1, "void") == 0) {
                Simbolo* f = NULL;
                if(esTipoBasico($<cadena>1)) {
                    f = crearSimbolo(
                        $<cadena>2,
                        FUNCION,
                        $<cadena>1,
                        @$.first_line
                    );
                } else {
                    f = crearSimbolo(
                        $<cadena>2,
                        FUNCION,
                        strdup("void"),
                        @$.first_line
                    );
                }

                if (!agregarSimbolo(tablaGral, f)) {
                    report_error("en declaVoF", @$.first_line, "error semantico, funcion redeclarada.");
                    $<s>$ = NULL;
                    nomFuncActual = NULL;
                } else {
                    if($<arr>4) {
                        int ok = 1;
                        for (int i = 0; i < arraySize($<arr>4); i++) {
                            Parametro* p = (Parametro*) findElemArray($<arr>4, i); 
                            if (strcmp(p->tipo, "error") == 0) {
                                report_error("en declaVoF", @$.first_line, "error en parametro");
                                //falta funcion destroyParametro
                                ok = 0;
                                break;
                            }
                        }
                        if(!ok) {
                            eliminarSimbolo(tablaGral, f);
                            $<s>$ = NULL;
                            nomFuncActual = NULL;
                        } else {
                            f->miembros = $<arr>4;
                            f->cantMiembros = arraySize($<arr>4);
                            printf("Declaración válida de funcion con parametros <línea:%d>\n", @$.first_line);
                            $<s>$ = f;
                            nomFuncActual = f->key;
                            abrirScope(tablaGral);
                            inFunctionBlock = 1;
                        }
                    } else {
                        f->miembros = $<arr>4;
                        f->cantMiembros = 0;
                        printf("Declaración válida de funcion <línea:%d>\n", @$.first_line);
                        $<s>$ = f;
                        nomFuncActual = f->key;
                        abrirScope(tablaGral);
                        inFunctionBlock = 1;
                    }
                }
            } else { // es tipo nomEnum
                report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no valido para funcion");
                $<s>$ = NULL;
                nomFuncActual = NULL;
            }
        } else {
            report_error("en declaVoF", @$.first_line, "error semantico, tipoDato no definido");
            $<s>$ = NULL;
            nomFuncActual = NULL;
        }
    }   
        sentCompuesta {
            Simbolo* f = buscarSimbolo(tablaGral, nomFuncActual);
            char* tipoDeclarado = f? f->tipoDato: NULL;
            char* tipoRetornado = $<cadena>7;
            if(f && f->clase == FUNCION){
                if (tipoRetornado == NULL && strcmp(tipoDeclarado, "void") != 0) {
                    report_error("en función", @$.first_line,
                                    "error semantico, falta retorno en funcion");
                    eliminarSimbolo(tablaGral, f);
                    $<s>$ = NULL;
                } else if (tipoRetornado != NULL &&
                            !tiposCompatibles(tipoDeclarado, tipoRetornado)) {
                    report_error("en función", @$.first_line,
                                    "error semantico, Tipo de retorno incompatible.");
                    eliminarSimbolo(tablaGral, f);
                    $<s>$ = NULL;
                } else { 
                    printf("Declaración válida de funcion con cuerpo <línea:%d>\n", @$.first_line);
                    $<s>$ = f;
                }
                if (tipoDeclarado == NULL) {
                    report_error("en funcion", @$.first_line, "funcion sin tipo declarado");
                    eliminarSimbolo(tablaGral, f);
                }
            } else { $<s>$ = NULL; }
            cerrarScope(tablaGral);
            inFunctionBlock = 0;
    }
     
    | error ';' {
        report_error("en declaVoF", @$.first_line, "error sintactico de declaración de variable.");
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
    | IDENTIFICADOR { 
        Simbolo* s = buscarSimbolo(tablaGral, $<cadena>1);
        if(s && s->clase == ENUMR) {
            $<cadena>$ = s->key; 
        } else {
            report_error("en tipo_opt", @1.first_line,
                            "tipoDato no declarado");
            $<cadena>$ = NULL;
        }
    }
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
            Parametro* e = crearParametro("error", "error");
            insertElemArray(arr, e);
            $$ = arr;
        }
    }
    | lista_parametros ',' parametro {
        if ($<p>3 != NULL) { 
            insertElemArray($<arr>1, $<p>3);
            $<arr>$ = $<arr>1;
        } else { 
            Parametro* e = crearParametro("error", "error");
            insertElemArray($<arr>1, e);
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
    | declaracion
    | error ';' {
        report_error("en sentencia", @$.first_line, "error sintactico de sentencia.");
        yyerrok;
        $<cadena>$ = NULL;
    }
    ;

sentCompuesta
    : '{' { 
        if (!inFunctionBlock) {
            abrirScope(tablaGral);
        } else {
            if(nomFuncActual != NULL) {
                Simbolo* f = buscarSimbolo(tablaGral, nomFuncActual);
                if(f && f->clase == FUNCION) {
                    for (int i = 0; i < f->cantMiembros; i++) {
                        Parametro* p = (Parametro*) findElemArray(f->miembros, i); 
                        printf("  param %d: nombre=%s tipo=%s\n", i, p->nombre, p->tipo);
                        Simbolo* t = crearSimbolo(p->nombre, VARIABLE, p->tipo, @$.first_line);
                        agregarSimbolo(tablaGral, t);
                    }
                }
            }
        }
        
    } 
     items 
       '}' { 
        if (!inFunctionBlock) {
            cerrarScope(tablaGral);
        }
        $<cadena>$ = $<cadena>3; 
    }

    | '{' error '}' {
        report_error("en sentCompuesta", @$.first_line,
                        "Error sintáctico dentro de bloque.");
        yyerrok;
        if (!inFunctionBlock) {
            cerrarScope(tablaGral);
        }
        $<cadena>$ = NULL;
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
            abrirScope(tablaGral); 
        }  
     sentencia 
        {
            char* ret = $<cadena>6;
            cerrarScope(tablaGral);
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
        { abrirScope(tablaGral); } 
     sentencia
        { cerrarScope(tablaGral); $<cadena>$ = $<cadena>3; }
    ;

sentIteracion
    : WHILE '(' expresion ')' 
        {
            if(!esNumerico($<expr>3->tipo)){
                report_error("en WHILE", @$.first_line, "condición inválida");
            }
            abrirScope(tablaGral);
        }
     sentencia
        { cerrarScope(tablaGral); }

    | WHILE '(' error ')' sentencia {
          report_error("en WHILE", @$.first_line, "condición inválida, error sintactico");
          yyerrok;
    }
    | FOR '(' forInit_opt expresion_opt ';' expresion_opt ')'
        {
            if($<expr>4 != NULL && !esNumerico($<expr>4->tipo)){
                report_error("en FOR", @$.first_line, "condición inválida");
            }
            abrirScope(tablaGral);
        }
     sentencia
        { cerrarScope(tablaGral); }

    | FOR '(' error ')' sentencia {
        report_error("en FOR", @$.first_line, "estructura sintactica del FOR inválida");
        yyerrok;
    }
    ;

forInit_opt
    : /* vacío */ { $<expr>$ = NULL; }
    | declaracion 
    | expresion { $<expr>$ = $<expr>1; }
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
                    Parametro* p = (Parametro*) findElemArray(s->miembros, i);
                    char* tipoParam  = p->tipo;

                    printf("[DEBUG] Param %d: paramType=%s  argType=%s\n",
                        i, tipoParam, tipoArg);

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
    : ENTERO { $<cadena>$ = strdup("int"); }
    | CADENA { $<cadena>$ = strdup("char*"); }
    | NUMERO { $<cadena>$ = strdup("double"); }
    | CARACTER { $<cadena>$ = strdup("char"); }
    | IDENTIFICADOR { 
        Simbolo* s = buscarSimbolo(tablaGral, $<cadena>1);
        if (s && s->clase == VARIABLE) {
            Simbolo* enumTipo = buscarSimbolo(tablaGral, s->tipoDato);
            if(enumTipo && enumTipo->clase == ENUMR) {
                report_error("en argumento", @$.first_line, "tipo argumento no permitido");
                $<cadena>$ = NULL;
            } else {
                $<cadena>$ = strdup(s->tipoDato);
            }
        } else if(s && s->clase == CONSTENUM) {
            $<cadena>$ = strdup("int");
        } else {
            report_error("en argumento", @$.first_line, "variable no declarada");
            $<cadena>$ = NULL;
        }
    }
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
        } else if(s && s->clase == CONSTENUM) {
            $<expr>$ = crearExpr(s->tipoDato, 0);
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
