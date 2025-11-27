%option noinput nounput noyywrap


%{
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
   #include "lexer.tab.h"

void iniciarUbicaciones() {
    yylloc.first_line = yylloc.last_line = 1;
    yylloc.first_column = yylloc.last_column = 0;
}

void actualizarLocationsNuevaFila() {
    yylloc.first_column = yylloc.last_column = 0;
    yylloc.first_line += 1;
    yylloc.last_line += 1;
}

void actualizarLocationsColumnas() {
    yylloc.first_column = yylloc.last_column;
    yylloc.last_column += yyleng;
}

extern int errorCount;
%}


DECIMAL         0|[1-9][0-9]*
OCTAL           0[0-7]+
HEXADECIMAL     0[xX][0-9a-fA-F]+
REAL            ("-")?(([0-9]+"."[0-9]+([Ee]("+"|"-")?[0-9]+)?)|([0-9]+[Ee]("+"|"-")?[0-9]+))
CARACTER        \'(.|\\.)\'
LITERAL_CADENA  \"(.|\\.)*\"
TIPO_DATO       int|double|float|char|void
IDENTIFICADOR   [a-zA-Z_][a-zA-Z0-9_]*


%%
[ \t\r] { 
    actualizarLocationsColumnas();
}
"\n" {
    actualizarLocationsNuevaFila();
}

{DECIMAL} { 
    printf("Constante entera decimal: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.ival=strtol(yytext, NULL, 0); 
    return ENTERO;
} //ival guarda en yylval el num entero con su valor como decimal
{OCTAL} { 
    printf("Constante entera octal: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.ival=strtol(yytext, NULL, 0); 
    return ENTERO;
}
{HEXADECIMAL} { 
    printf("Constante entera hexadecimal: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.ival=strtol(yytext, NULL, 0); 
    return ENTERO;
}

{REAL} { 
    printf("Constante real: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.dval=atof(yytext); 
    return NUMERO;
} //dval guarda en yylval el num como punto flotante

{CARACTER} { 
    printf("Constante caracter: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cval = yytext[1]; 
    return CARACTER;
} //cval guardara en yylval el char ya sea 'a' o '\n'

{LITERAL_CADENA} { 
    printf("Literal cadena: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return CADENA;
} //guarda en yylval un string del erx leido

{TIPO_DATO} { 
    printf("Palabra reservada (tipo de dato): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return TIPO_DATO;
}

if { 
    printf("Palabra reservada (estructura de control): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return IF;
}
else { 
    printf("Palabra reservada (estructura de control): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return ELSE;
}
while { 
    printf("Palabra reservada (estructura de control): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return WHILE;
}
for { 
    printf("Palabra reservada (estructura de control): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return FOR;
}
return { 
    printf("Palabra reservada (estructura de control): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return RETURN;
}

const { 
    printf("Palabra reservada (otro): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return CONST;
}
unsigned {
    printf("Palabra reservada (otro): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return UNSIGNED;
}
extern { 
    printf("Palabra reservada (otro): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return EXTERN;
}

enum { 
    printf("Palabra reservada (enumerador): %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return ENUM;
}

{IDENTIFICADOR} { 
    printf("Identificador: %s\n", yytext); 
    actualizarLocationsColumnas();
    yylval.cadena = strdup(yytext); 
    return IDENTIFICADOR;
}

"++" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return INCREMENTO; 
}
"--" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return DECREMENTO; 
}
"+=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return MAS_IGUAL; 
}
"-=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return MENOS_IGUAL;
}
"+"  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '+'; 
}
"-"  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '-'; 
}
"*=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return POR_IGUAL; 
}
"*" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '*'; 
}
"/=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return DIV_IGUAL; 
}
"/"  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '/'; 
}
"==" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return IGUALDAD; 
}
"="  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '='; 
}
"!=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return DIFERENTE; 
}
"!"  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '!'; 
}
"&&" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return AND; 
}
"||" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return OR; 
}
">=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return MAYOR_IGUAL; 
}
">"  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '>'; 
}
"<=" { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return MENOR_IGUAL; 
}
"<"  { 
    printf("Operador: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '<'; 
}

";" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return ';'; 
}
"," { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return ','; 
}
"{" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '{';
}
"}" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '}'; 
}
"(" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '('; 
}
")" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return ')'; 
}
"[" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return '['; 
}
"]" { 
    printf("Caracter de puntuacion: %s\n", yytext); 
    actualizarLocationsColumnas();
    return ']'; 
}

. {
    actualizarLocationsColumnas();
    fprintf(stderr, "Error léxico <linea:%d columna:%d> Caracter no válido: '%s'\n", yylloc.first_line, yylloc.first_column, yytext);
    errorCount++;
}

%%