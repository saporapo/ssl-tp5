/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_LEXER_TAB_H_INCLUDED
# define YY_YY_LEXER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 146 "lexer.y"
#include<tablaSimbolos.h>

#line 52 "lexer.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    ENTERO = 258,                  /* ENTERO  */
    NUMERO = 259,                  /* NUMERO  */
    CARACTER = 260,                /* CARACTER  */
    CADENA = 261,                  /* CADENA  */
    TIPO_DATO = 262,               /* TIPO_DATO  */
    IDENTIFICADOR = 263,           /* IDENTIFICADOR  */
    RETURN = 264,                  /* RETURN  */
    FOR = 265,                     /* FOR  */
    WHILE = 266,                   /* WHILE  */
    ELSE = 267,                    /* ELSE  */
    IF = 268,                      /* IF  */
    ENUMERADOR = 269,              /* ENUMERADOR  */
    INCREMENTO = 270,              /* INCREMENTO  */
    DECREMENTO = 271,              /* DECREMENTO  */
    MAS_IGUAL = 272,               /* MAS_IGUAL  */
    MENOS_IGUAL = 273,             /* MENOS_IGUAL  */
    DIV_IGUAL = 274,               /* DIV_IGUAL  */
    POR_IGUAL = 275,               /* POR_IGUAL  */
    IGUALDAD = 276,                /* IGUALDAD  */
    DIFERENTE = 277,               /* DIFERENTE  */
    AND = 278,                     /* AND  */
    OR = 279,                      /* OR  */
    MAYOR_IGUAL = 280,             /* MAYOR_IGUAL  */
    MENOR_IGUAL = 281,             /* MENOR_IGUAL  */
    UNARIO = 282                   /* UNARIO  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 148 "lexer.y"

    int ival; // decimal, octal, hex
    double dval; // real
    char cval; // caracter
    char* cadena; // cadena, tipo_dato, identificador
    Array* arr;
    Parametro* p;
    Simbolo* s;
    Expr* expr;

#line 107 "lexer.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;

int yyparse (void);


#endif /* !YY_YY_LEXER_TAB_H_INCLUDED  */
