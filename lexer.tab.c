/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "lexer.y"


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


#line 215 "lexer.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "lexer.tab.h"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_ENTERO = 3,                     /* ENTERO  */
  YYSYMBOL_NUMERO = 4,                     /* NUMERO  */
  YYSYMBOL_CARACTER = 5,                   /* CARACTER  */
  YYSYMBOL_CADENA = 6,                     /* CADENA  */
  YYSYMBOL_TIPO_DATO = 7,                  /* TIPO_DATO  */
  YYSYMBOL_IDENTIFICADOR = 8,              /* IDENTIFICADOR  */
  YYSYMBOL_RETURN = 9,                     /* RETURN  */
  YYSYMBOL_FOR = 10,                       /* FOR  */
  YYSYMBOL_WHILE = 11,                     /* WHILE  */
  YYSYMBOL_ELSE = 12,                      /* ELSE  */
  YYSYMBOL_IF = 13,                        /* IF  */
  YYSYMBOL_ENUMERADOR = 14,                /* ENUMERADOR  */
  YYSYMBOL_INCREMENTO = 15,                /* INCREMENTO  */
  YYSYMBOL_DECREMENTO = 16,                /* DECREMENTO  */
  YYSYMBOL_MAS_IGUAL = 17,                 /* MAS_IGUAL  */
  YYSYMBOL_MENOS_IGUAL = 18,               /* MENOS_IGUAL  */
  YYSYMBOL_DIV_IGUAL = 19,                 /* DIV_IGUAL  */
  YYSYMBOL_POR_IGUAL = 20,                 /* POR_IGUAL  */
  YYSYMBOL_IGUALDAD = 21,                  /* IGUALDAD  */
  YYSYMBOL_DIFERENTE = 22,                 /* DIFERENTE  */
  YYSYMBOL_AND = 23,                       /* AND  */
  YYSYMBOL_OR = 24,                        /* OR  */
  YYSYMBOL_MAYOR_IGUAL = 25,               /* MAYOR_IGUAL  */
  YYSYMBOL_MENOR_IGUAL = 26,               /* MENOR_IGUAL  */
  YYSYMBOL_27_ = 27,                       /* '<'  */
  YYSYMBOL_28_ = 28,                       /* '>'  */
  YYSYMBOL_29_ = 29,                       /* '+'  */
  YYSYMBOL_30_ = 30,                       /* '-'  */
  YYSYMBOL_31_ = 31,                       /* '*'  */
  YYSYMBOL_32_ = 32,                       /* '/'  */
  YYSYMBOL_33_ = 33,                       /* '!'  */
  YYSYMBOL_UNARIO = 34,                    /* UNARIO  */
  YYSYMBOL_35_ = 35,                       /* '='  */
  YYSYMBOL_36_ = 36,                       /* ';'  */
  YYSYMBOL_37_ = 37,                       /* '}'  */
  YYSYMBOL_38_ = 38,                       /* '{'  */
  YYSYMBOL_39_ = 39,                       /* ','  */
  YYSYMBOL_40_ = 40,                       /* '('  */
  YYSYMBOL_41_ = 41,                       /* ')'  */
  YYSYMBOL_YYACCEPT = 42,                  /* $accept  */
  YYSYMBOL_input = 43,                     /* input  */
  YYSYMBOL_items = 44,                     /* items  */
  YYSYMBOL_item = 45,                      /* item  */
  YYSYMBOL_declaracion = 46,               /* declaracion  */
  YYSYMBOL_declaEnum = 47,                 /* declaEnum  */
  YYSYMBOL_48_1 = 48,                      /* @1  */
  YYSYMBOL_ids_opt = 49,                   /* ids_opt  */
  YYSYMBOL_lista_ids = 50,                 /* lista_ids  */
  YYSYMBOL_lista_enumeradores = 51,        /* lista_enumeradores  */
  YYSYMBOL_declaVoF = 52,                  /* declaVoF  */
  YYSYMBOL_53_2 = 53,                      /* @2  */
  YYSYMBOL_54_3 = 54,                      /* @3  */
  YYSYMBOL_tipo_opt = 55,                  /* tipo_opt  */
  YYSYMBOL_parametros_opt = 56,            /* parametros_opt  */
  YYSYMBOL_lista_parametros = 57,          /* lista_parametros  */
  YYSYMBOL_parametro = 58,                 /* parametro  */
  YYSYMBOL_sentencia = 59,                 /* sentencia  */
  YYSYMBOL_sentCompuesta = 60,             /* sentCompuesta  */
  YYSYMBOL_61_4 = 61,                      /* $@4  */
  YYSYMBOL_sentExpresion = 62,             /* sentExpresion  */
  YYSYMBOL_sentSeleccion = 63,             /* sentSeleccion  */
  YYSYMBOL_64_5 = 64,                      /* $@5  */
  YYSYMBOL_65_6 = 65,                      /* @6  */
  YYSYMBOL_opSent = 66,                    /* opSent  */
  YYSYMBOL_67_7 = 67,                      /* $@7  */
  YYSYMBOL_sentIteracion = 68,             /* sentIteracion  */
  YYSYMBOL_69_8 = 69,                      /* $@8  */
  YYSYMBOL_70_9 = 70,                      /* $@9  */
  YYSYMBOL_sentSalto = 71,                 /* sentSalto  */
  YYSYMBOL_expresion_opt = 72,             /* expresion_opt  */
  YYSYMBOL_expresion = 73,                 /* expresion  */
  YYSYMBOL_opAsignacion = 74,              /* opAsignacion  */
  YYSYMBOL_expOr = 75,                     /* expOr  */
  YYSYMBOL_expAnd = 76,                    /* expAnd  */
  YYSYMBOL_expIgualdad = 77,               /* expIgualdad  */
  YYSYMBOL_expRelacional = 78,             /* expRelacional  */
  YYSYMBOL_expAditiva = 79,                /* expAditiva  */
  YYSYMBOL_expMultiplicativa = 80,         /* expMultiplicativa  */
  YYSYMBOL_expUnaria = 81,                 /* expUnaria  */
  YYSYMBOL_operUnario = 82,                /* operUnario  */
  YYSYMBOL_expPostfijo = 83,               /* expPostfijo  */
  YYSYMBOL_listaArgumentos = 84,           /* listaArgumentos  */
  YYSYMBOL_argumento = 85,                 /* argumento  */
  YYSYMBOL_expPrimaria = 86                /* expPrimaria  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_uint8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if 1

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* 1 */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
             && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
  YYLTYPE yyls_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE) \
             + YYSIZEOF (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  3
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   320

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  42
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  45
/* YYNRULES -- Number of rules.  */
#define YYNRULES  117
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  183

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   282


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    33,     2,     2,     2,     2,     2,     2,
      40,    41,    31,    29,    39,    30,     2,    32,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    36,
      27,    35,    28,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    38,     2,    37,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    34
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   200,   200,   204,   205,   214,   215,   219,   220,   222,
     226,   233,   233,   283,   290,   291,   295,   301,   309,   321,
     334,   347,   362,   405,   463,   463,   526,   526,   625,   632,
     633,   642,   655,   656,   660,   671,   684,   694,   707,   709,
     711,   713,   715,   717,   718,   726,   726,   752,   764,   765,
     767,   774,   779,   786,   778,   810,   812,   811,   819,   818,
     828,   833,   832,   842,   849,   859,   867,   868,   872,   873,
     891,   899,   900,   901,   902,   903,   907,   908,   919,   920,
     931,   932,   940,   951,   952,   960,   968,   976,   987,   988,
     996,  1007,  1008,  1016,  1027,  1028,  1040,  1048,  1059,  1060,
    1064,  1065,  1104,  1112,  1123,  1124,  1134,  1146,  1147,  1148,
    1149,  1150,  1170,  1192,  1195,  1198,  1201,  1204
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if 1
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "ENTERO", "NUMERO",
  "CARACTER", "CADENA", "TIPO_DATO", "IDENTIFICADOR", "RETURN", "FOR",
  "WHILE", "ELSE", "IF", "ENUMERADOR", "INCREMENTO", "DECREMENTO",
  "MAS_IGUAL", "MENOS_IGUAL", "DIV_IGUAL", "POR_IGUAL", "IGUALDAD",
  "DIFERENTE", "AND", "OR", "MAYOR_IGUAL", "MENOR_IGUAL", "'<'", "'>'",
  "'+'", "'-'", "'*'", "'/'", "'!'", "UNARIO", "'='", "';'", "'}'", "'{'",
  "','", "'('", "')'", "$accept", "input", "items", "item", "declaracion",
  "declaEnum", "@1", "ids_opt", "lista_ids", "lista_enumeradores",
  "declaVoF", "@2", "@3", "tipo_opt", "parametros_opt", "lista_parametros",
  "parametro", "sentencia", "sentCompuesta", "$@4", "sentExpresion",
  "sentSeleccion", "$@5", "@6", "opSent", "$@7", "sentIteracion", "$@8",
  "$@9", "sentSalto", "expresion_opt", "expresion", "opAsignacion",
  "expOr", "expAnd", "expIgualdad", "expRelacional", "expAditiva",
  "expMultiplicativa", "expUnaria", "operUnario", "expPostfijo",
  "listaArgumentos", "argumento", "expPrimaria", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-121)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-67)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    -121,    28,    58,  -121,     6,  -121,  -121,  -121,  -121,     8,
     274,   203,   -15,    30,    39,    82,    49,    49,  -121,  -121,
    -121,   111,   280,  -121,  -121,  -121,  -121,    87,  -121,  -121,
    -121,  -121,  -121,  -121,    74,  -121,    75,   100,    15,    81,
      20,    61,  -121,    97,  -121,    68,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,    72,   280,  -121,   195,    96,   241,
      11,   257,    59,  -121,  -121,  -121,   103,  -121,   121,    -1,
      46,  -121,   280,   280,   280,   280,   280,   280,   280,   280,
     280,   280,   280,   280,  -121,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,   -10,  -121,    75,  -121,   102,   132,   128,   129,
     130,   131,   165,  -121,   149,  -121,  -121,  -121,   167,   100,
      15,    81,    81,    20,    20,    20,    20,    61,    61,  -121,
    -121,    72,  -121,   187,   203,   187,  -121,   187,  -121,   140,
      48,  -121,   280,    25,   135,   138,  -121,  -121,  -121,  -121,
     142,  -121,   187,   168,   187,   178,  -121,   175,    -6,  -121,
     176,   163,   167,     5,  -121,  -121,  -121,  -121,  -121,    -4,
     170,  -121,  -121,  -121,   172,  -121,   180,   187,   168,  -121,
    -121,  -121,   177,   219,  -121,  -121,  -121,  -121,   216,  -121,
     187,  -121,  -121
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       3,     0,     0,     1,     0,   113,   114,   115,   116,    29,
     112,     0,     0,     0,     0,     0,     0,     0,    98,    99,
      49,     0,     0,     4,     5,     8,     7,     0,     6,    38,
      39,    40,    41,    42,     0,    67,    68,    76,    78,    80,
      83,    88,    91,     0,    94,   100,     9,    10,    30,    72,
      73,    74,    75,    71,   104,     0,    70,   112,     0,     0,
       0,     0,     0,   112,    96,    97,     0,     3,   112,     0,
       0,    48,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    95,   102,   103,   107,   109,   110,
     108,   111,     0,   105,    69,    64,    70,     0,     0,     0,
       0,     0,     0,    47,     0,   117,    24,    22,    32,    77,
      79,    81,    82,    84,    86,    87,    85,    89,    90,    92,
      93,     0,   101,     0,     0,     0,    58,     0,    52,    18,
       0,    46,     0,     0,     0,    33,    34,   106,    43,    63,
       0,    60,     0,    55,     0,     0,    11,     0,     0,    36,
       0,    26,     0,     0,    59,    56,    51,    53,    19,     0,
      20,    25,    37,    23,     0,    35,     0,     0,    55,    16,
      14,    12,    15,     0,    27,    61,    57,    54,     0,    21,
       0,    17,    62
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -121,  -121,   159,  -121,     0,  -121,  -121,  -121,  -121,  -121,
    -121,  -121,  -121,  -121,  -121,  -121,    76,  -120,    65,  -121,
    -121,  -121,  -121,  -121,    66,  -121,  -121,  -121,  -121,  -121,
     -11,    73,  -121,   -21,   160,   158,    64,    52,    55,    63,
    -121,   194,  -121,   117,   150
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_uint8 yydefgoto[] =
{
       0,     1,     2,    23,   138,    25,   159,   171,   172,   130,
      26,   132,   164,    27,   134,   135,   136,    28,    29,    67,
      30,    31,   144,   168,   156,   167,    32,   142,   180,    33,
      34,    35,    55,    36,    37,    38,    39,    40,    41,    42,
      43,    44,    92,    93,    45
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      58,    69,    24,   139,   169,   141,    56,   143,     5,     6,
       7,     8,    98,    57,     5,     6,     7,     8,    72,    57,
      16,    17,   154,    72,   157,    59,    16,    17,     3,   121,
     161,   122,   170,   149,    94,    18,    74,    75,    19,    48,
     105,    18,    46,    47,    19,    22,   -66,   176,    97,    80,
      81,    22,     5,     6,     7,     8,   150,    63,    -2,     4,
     182,     5,     6,     7,     8,     9,    10,    11,    12,    13,
      60,    14,    15,    16,    17,    87,    88,    89,    90,    61,
      91,   106,   107,    85,    86,   146,   108,   147,    18,    22,
      62,    19,    82,    83,    20,    70,    21,   102,    22,    72,
       5,     6,     7,     8,    24,    68,    76,    77,    78,    79,
      71,   148,    66,   140,   -45,   -45,   -45,   -45,   -45,   -45,
     -45,   -45,   -45,    73,   -45,   -45,   -45,   -45,   113,   114,
     115,   116,    95,    99,   101,   117,   118,    22,   111,   112,
     103,   -45,   166,   123,   -45,   119,   120,   -45,   -45,   -45,
       4,   -45,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    54,    14,    15,    16,    17,    64,    65,   124,   125,
     126,   127,   128,   129,   133,   145,   151,   152,   153,    18,
     155,   158,    19,   160,   162,    20,   131,    21,     4,    22,
       5,     6,     7,     8,     9,    10,    11,    12,    13,   163,
      14,    15,    16,    17,    56,   173,     5,     6,     7,     8,
      21,    57,    49,    50,    51,    52,   178,    18,    16,    17,
      19,   175,   179,    20,   181,    21,   104,    22,   165,   174,
      53,   110,   109,    18,   177,    54,    19,    84,   137,   -66,
       0,     0,    96,    22,     5,     6,     7,     8,     0,    57,
       0,     0,     0,     0,     0,     0,    16,    17,   100,     0,
       5,     6,     7,     8,     0,    57,     0,     0,     0,     0,
       0,    18,    16,    17,    19,     0,     0,   -66,     0,     0,
       0,    22,   -31,     5,     6,     7,     8,    18,    68,     0,
      19,    49,    50,    51,    52,    16,    17,    22,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    53,
      18,     0,     0,    19,    54,     0,     0,     0,     0,     0,
      22
};

static const yytype_int16 yycheck[] =
{
      11,    22,     2,   123,     8,   125,     1,   127,     3,     4,
       5,     6,     1,     8,     3,     4,     5,     6,    24,     8,
      15,    16,   142,    24,   144,    40,    15,    16,     0,    39,
      36,    41,    36,     8,    55,    30,    21,    22,    33,    31,
      41,    30,    36,    37,    33,    40,    41,   167,    59,    29,
      30,    40,     3,     4,     5,     6,    31,     8,     0,     1,
     180,     3,     4,     5,     6,     7,     8,     9,    10,    11,
      40,    13,    14,    15,    16,     3,     4,     5,     6,    40,
       8,    35,    36,    15,    16,    37,    40,    39,    30,    40,
       8,    33,    31,    32,    36,     8,    38,    38,    40,    24,
       3,     4,     5,     6,   104,     8,    25,    26,    27,    28,
      36,   132,     1,   124,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    23,    13,    14,    15,    16,    76,    77,
      78,    79,    36,    60,    61,    80,    81,    40,    74,    75,
      37,    30,   153,    41,    33,    82,    83,    36,    37,    38,
       1,    40,     3,     4,     5,     6,     7,     8,     9,    10,
      11,    40,    13,    14,    15,    16,    16,    17,    36,    41,
      41,    41,    41,     8,     7,    35,    41,    39,    36,    30,
      12,     3,    33,     8,     8,    36,    37,    38,     1,    40,
       3,     4,     5,     6,     7,     8,     9,    10,    11,    36,
      13,    14,    15,    16,     1,    35,     3,     4,     5,     6,
      38,     8,    17,    18,    19,    20,    39,    30,    15,    16,
      33,    41,     3,    36,     8,    38,    67,    40,   152,   164,
      35,    73,    72,    30,   168,    40,    33,    43,   121,    36,
      -1,    -1,     1,    40,     3,     4,     5,     6,    -1,     8,
      -1,    -1,    -1,    -1,    -1,    -1,    15,    16,     1,    -1,
       3,     4,     5,     6,    -1,     8,    -1,    -1,    -1,    -1,
      -1,    30,    15,    16,    33,    -1,    -1,    36,    -1,    -1,
      -1,    40,     8,     3,     4,     5,     6,    30,     8,    -1,
      33,    17,    18,    19,    20,    15,    16,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    35,
      30,    -1,    -1,    33,    40,    -1,    -1,    -1,    -1,    -1,
      40
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    43,    44,     0,     1,     3,     4,     5,     6,     7,
       8,     9,    10,    11,    13,    14,    15,    16,    30,    33,
      36,    38,    40,    45,    46,    47,    52,    55,    59,    60,
      62,    63,    68,    71,    72,    73,    75,    76,    77,    78,
      79,    80,    81,    82,    83,    86,    36,    37,    31,    17,
      18,    19,    20,    35,    40,    74,     1,     8,    72,    40,
      40,    40,     8,     8,    86,    86,     1,    61,     8,    75,
       8,    36,    24,    23,    21,    22,    25,    26,    27,    28,
      29,    30,    31,    32,    83,    15,    16,     3,     4,     5,
       6,     8,    84,    85,    75,    36,     1,    72,     1,    73,
       1,    73,    38,    37,    44,    41,    35,    36,    40,    76,
      77,    78,    78,    79,    79,    79,    79,    80,    80,    81,
      81,    39,    41,    41,    36,    41,    41,    41,    41,     8,
      51,    37,    53,     7,    56,    57,    58,    85,    46,    59,
      72,    59,    69,    59,    64,    35,    37,    39,    75,     8,
      31,    41,    39,    36,    59,    12,    66,    59,     3,    48,
       8,    36,     8,    36,    54,    58,    72,    67,    65,     8,
      36,    49,    50,    35,    60,    41,    59,    66,    39,     3,
      70,     8,    59
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    42,    43,    44,    44,    45,    45,    46,    46,    46,
      46,    48,    47,    47,    49,    49,    50,    50,    51,    51,
      51,    51,    52,    52,    53,    52,    54,    52,    52,    55,
      55,    55,    56,    56,    57,    57,    58,    58,    59,    59,
      59,    59,    59,    59,    59,    61,    60,    60,    62,    62,
      62,    63,    64,    65,    63,    66,    67,    66,    69,    68,
      68,    70,    68,    68,    71,    71,    72,    72,    73,    73,
      73,    74,    74,    74,    74,    74,    75,    75,    76,    76,
      77,    77,    77,    78,    78,    78,    78,    78,    79,    79,
      79,    80,    80,    80,    81,    81,    81,    81,    82,    82,
      83,    83,    83,    83,    84,    84,    84,    85,    85,    85,
      85,    85,    86,    86,    86,    86,    86,    86
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     0,     2,     1,     1,     1,     1,     2,
       2,     0,     7,     2,     1,     1,     1,     3,     1,     3,
       3,     5,     3,     6,     0,     6,     0,     7,     2,     1,
       2,     1,     0,     1,     1,     3,     2,     3,     1,     1,
       1,     1,     1,     1,     2,     0,     4,     3,     2,     1,
       2,     6,     0,     0,     8,     0,     0,     3,     0,     6,
       5,     0,    10,     5,     3,     2,     0,     1,     1,     3,
       1,     1,     1,     1,     1,     1,     1,     3,     1,     3,
       1,     3,     3,     1,     3,     3,     3,     3,     1,     3,
       3,     1,     3,     3,     1,     2,     2,     2,     1,     1,
       1,     4,     2,     2,     0,     1,     3,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     3
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF

/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)                                \
    do                                                                  \
      if (N)                                                            \
        {                                                               \
          (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;        \
          (Current).first_column = YYRHSLOC (Rhs, 1).first_column;      \
          (Current).last_line    = YYRHSLOC (Rhs, N).last_line;         \
          (Current).last_column  = YYRHSLOC (Rhs, N).last_column;       \
        }                                                               \
      else                                                              \
        {                                                               \
          (Current).first_line   = (Current).last_line   =              \
            YYRHSLOC (Rhs, 0).last_line;                                \
          (Current).first_column = (Current).last_column =              \
            YYRHSLOC (Rhs, 0).last_column;                              \
        }                                                               \
    while (0)
#endif

#define YYRHSLOC(Rhs, K) ((Rhs)[K])


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)


/* YYLOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

# ifndef YYLOCATION_PRINT

#  if defined YY_LOCATION_PRINT

   /* Temporary convenience wrapper in case some people defined the
      undocumented and private YY_LOCATION_PRINT macros.  */
#   define YYLOCATION_PRINT(File, Loc)  YY_LOCATION_PRINT(File, *(Loc))

#  elif defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL

/* Print *YYLOCP on YYO.  Private, do not rely on its existence. */

YY_ATTRIBUTE_UNUSED
static int
yy_location_print_ (FILE *yyo, YYLTYPE const * const yylocp)
{
  int res = 0;
  int end_col = 0 != yylocp->last_column ? yylocp->last_column - 1 : 0;
  if (0 <= yylocp->first_line)
    {
      res += YYFPRINTF (yyo, "%d", yylocp->first_line);
      if (0 <= yylocp->first_column)
        res += YYFPRINTF (yyo, ".%d", yylocp->first_column);
    }
  if (0 <= yylocp->last_line)
    {
      if (yylocp->first_line < yylocp->last_line)
        {
          res += YYFPRINTF (yyo, "-%d", yylocp->last_line);
          if (0 <= end_col)
            res += YYFPRINTF (yyo, ".%d", end_col);
        }
      else if (0 <= end_col && yylocp->first_column < end_col)
        res += YYFPRINTF (yyo, "-%d", end_col);
    }
  return res;
}

#   define YYLOCATION_PRINT  yy_location_print_

    /* Temporary convenience wrapper in case some people defined the
       undocumented and private YY_LOCATION_PRINT macros.  */
#   define YY_LOCATION_PRINT(File, Loc)  YYLOCATION_PRINT(File, &(Loc))

#  else

#   define YYLOCATION_PRINT(File, Loc) ((void) 0)
    /* Temporary convenience wrapper in case some people defined the
       undocumented and private YY_LOCATION_PRINT macros.  */
#   define YY_LOCATION_PRINT  YYLOCATION_PRINT

#  endif
# endif /* !defined YYLOCATION_PRINT */


# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value, Location); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  YY_USE (yylocationp);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  YYLOCATION_PRINT (yyo, yylocationp);
  YYFPRINTF (yyo, ": ");
  yy_symbol_value_print (yyo, yykind, yyvaluep, yylocationp);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp, YYLTYPE *yylsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)],
                       &(yylsp[(yyi + 1) - (yynrhs)]));
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, yylsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


/* Context of a parse error.  */
typedef struct
{
  yy_state_t *yyssp;
  yysymbol_kind_t yytoken;
  YYLTYPE *yylloc;
} yypcontext_t;

/* Put in YYARG at most YYARGN of the expected tokens given the
   current YYCTX, and return the number of tokens stored in YYARG.  If
   YYARG is null, return the number of expected tokens (guaranteed to
   be less than YYNTOKENS).  Return YYENOMEM on memory exhaustion.
   Return 0 if there are more than YYARGN expected tokens, yet fill
   YYARG up to YYARGN. */
static int
yypcontext_expected_tokens (const yypcontext_t *yyctx,
                            yysymbol_kind_t yyarg[], int yyargn)
{
  /* Actual size of YYARG. */
  int yycount = 0;
  int yyn = yypact[+*yyctx->yyssp];
  if (!yypact_value_is_default (yyn))
    {
      /* Start YYX at -YYN if negative to avoid negative indexes in
         YYCHECK.  In other words, skip the first -YYN actions for
         this state because they are default actions.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;
      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yyx;
      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
        if (yycheck[yyx + yyn] == yyx && yyx != YYSYMBOL_YYerror
            && !yytable_value_is_error (yytable[yyx + yyn]))
          {
            if (!yyarg)
              ++yycount;
            else if (yycount == yyargn)
              return 0;
            else
              yyarg[yycount++] = YY_CAST (yysymbol_kind_t, yyx);
          }
    }
  if (yyarg && yycount == 0 && 0 < yyargn)
    yyarg[0] = YYSYMBOL_YYEMPTY;
  return yycount;
}




#ifndef yystrlen
# if defined __GLIBC__ && defined _STRING_H
#  define yystrlen(S) (YY_CAST (YYPTRDIFF_T, strlen (S)))
# else
/* Return the length of YYSTR.  */
static YYPTRDIFF_T
yystrlen (const char *yystr)
{
  YYPTRDIFF_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
# endif
#endif

#ifndef yystpcpy
# if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#  define yystpcpy stpcpy
# else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
# endif
#endif

#ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYPTRDIFF_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYPTRDIFF_T yyn = 0;
      char const *yyp = yystr;
      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            else
              goto append;

          append:
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (yyres)
    return yystpcpy (yyres, yystr) - yyres;
  else
    return yystrlen (yystr);
}
#endif


static int
yy_syntax_error_arguments (const yypcontext_t *yyctx,
                           yysymbol_kind_t yyarg[], int yyargn)
{
  /* Actual size of YYARG. */
  int yycount = 0;
  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yyctx->yytoken != YYSYMBOL_YYEMPTY)
    {
      int yyn;
      if (yyarg)
        yyarg[yycount] = yyctx->yytoken;
      ++yycount;
      yyn = yypcontext_expected_tokens (yyctx,
                                        yyarg ? yyarg + 1 : yyarg, yyargn - 1);
      if (yyn == YYENOMEM)
        return YYENOMEM;
      else
        yycount += yyn;
    }
  return yycount;
}

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return -1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return YYENOMEM if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYPTRDIFF_T *yymsg_alloc, char **yymsg,
                const yypcontext_t *yyctx)
{
  enum { YYARGS_MAX = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat: reported tokens (one for the "unexpected",
     one per "expected"). */
  yysymbol_kind_t yyarg[YYARGS_MAX];
  /* Cumulated lengths of YYARG.  */
  YYPTRDIFF_T yysize = 0;

  /* Actual size of YYARG. */
  int yycount = yy_syntax_error_arguments (yyctx, yyarg, YYARGS_MAX);
  if (yycount == YYENOMEM)
    return YYENOMEM;

  switch (yycount)
    {
#define YYCASE_(N, S)                       \
      case N:                               \
        yyformat = S;                       \
        break
    default: /* Avoid compiler warnings. */
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
#undef YYCASE_
    }

  /* Compute error message size.  Don't count the "%s"s, but reserve
     room for the terminator.  */
  yysize = yystrlen (yyformat) - 2 * yycount + 1;
  {
    int yyi;
    for (yyi = 0; yyi < yycount; ++yyi)
      {
        YYPTRDIFF_T yysize1
          = yysize + yytnamerr (YY_NULLPTR, yytname[yyarg[yyi]]);
        if (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM)
          yysize = yysize1;
        else
          return YYENOMEM;
      }
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return -1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yytname[yyarg[yyi++]]);
          yyformat += 2;
        }
      else
        {
          ++yyp;
          ++yyformat;
        }
  }
  return 0;
}


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
{
  YY_USE (yyvaluep);
  YY_USE (yylocationp);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
  = { 1, 1, 1, 1 }
# endif
;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

    /* The location stack: array, bottom, top.  */
    YYLTYPE yylsa[YYINITDEPTH];
    YYLTYPE *yyls = yylsa;
    YYLTYPE *yylsp = yyls;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* The locations where the error started and ended.  */
  YYLTYPE yyerror_range[3];

  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYPTRDIFF_T yymsg_alloc = sizeof yymsgbuf;

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  yylsp[0] = yylloc;
  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;
        YYLTYPE *yyls1 = yyls;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yyls1, yysize * YYSIZEOF (*yylsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
        yyls = yyls1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
        YYSTACK_RELOCATE (yyls_alloc, yyls);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      yyerror_range[1] = yylloc;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END
  *++yylsp = yylloc;

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location. */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  yyerror_range[1] = yyloc;
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 3: /* items: %empty  */
#line 204 "lexer.y"
                   { (yyval.cadena) = NULL; }
#line 1836 "lexer.tab.c"
    break;

  case 4: /* items: items item  */
#line 205 "lexer.y"
                 { 
            if ((yyvsp[0].cadena) != NULL)
                (yyval.cadena) = (yyvsp[0].cadena);
            else
                (yyval.cadena) = (yyvsp[-1].cadena);
      }
#line 1847 "lexer.tab.c"
    break;

  case 5: /* item: declaracion  */
#line 214 "lexer.y"
                  { (yyval.cadena) = (yyvsp[0].cadena); }
#line 1853 "lexer.tab.c"
    break;

  case 6: /* item: sentencia  */
#line 215 "lexer.y"
                { (yyval.cadena) = (yyvsp[0].cadena); }
#line 1859 "lexer.tab.c"
    break;

  case 9: /* declaracion: error ';'  */
#line 222 "lexer.y"
                {
        report_error("en declaracion", (yyloc).first_line, "error sintactico de declaración.");
        yyerrok;
    }
#line 1868 "lexer.tab.c"
    break;

  case 10: /* declaracion: error '}'  */
#line 226 "lexer.y"
                { // para la terminacion de declaracion funcion q no es ';'
        report_error("en declaracion", (yyloc).first_line, "error sintactico de declaración.");
        yyerrok;
    }
#line 1877 "lexer.tab.c"
    break;

  case 11: /* @1: %empty  */
#line 233 "lexer.y"
                                                          {
        Simbolo* s = crearSimbolo((yyvsp[-3].cadena), ENUMR, strdup("enum"), (yyloc).first_line);

        // si esta declarado en el scope actual --> redeclarado
        if (!agregarSimbolo(tablaGral, s)) {
            report_error("en declaEnum", (yyloc).first_line, "error semantico, enum redeclarado.");
            (yyval.s) = NULL;
        } else {
            /* lista_enumeradores devuelve Array* de Enumerador* con nom y val del elemEnum */
            // o NULL si algo salio mal
            if((yyvsp[-1].arr)) {
                s->miembros = (yyvsp[-1].arr);
                s->cantMiembros = arraySize((yyvsp[-1].arr));
                printf("Declaración válida de enum <línea:%d>\n", (yyloc).first_line);
                (yyval.s) = s; 
            } else {
                report_error("en declaEnum", (yyloc).first_line, "error semantico, error en lista_enumeradores por variable redeclarada");
                eliminarSimbolo(tablaGral, s);
                (yyval.s) = NULL;
            }
        }
    }
#line 1904 "lexer.tab.c"
    break;

  case 12: /* declaEnum: ENUMERADOR IDENTIFICADOR '{' lista_enumeradores '}' @1 ids_opt  */
#line 255 "lexer.y"
                {
            Simbolo* f = (yyvsp[-1].s);

            if (f != NULL) { // variables declaradas al final del enum
                if((yyvsp[0].arr)) {
                    int ok = 1;
                    for (int i = 0; i < arraySize((yyvsp[0].arr)); i++) {
                        char* varEnum = (char*) findElemArray((yyvsp[0].arr), i); 
                        Simbolo* t = crearSimbolo(varEnum, VARIABLE, f->key, (yyloc).first_line);
                        if (!agregarSimbolo(tablaGral, t)) {
                            report_error("en id_opt", (yyloc).first_line, "error semantico, existe variable con ese nombre. No se declarara enum");
                            free(varEnum);
                            ok = 0;
                            break;
                        }
                    }
                    if(!ok) {
                        eliminarSimbolo(tablaGral, f);
                        (yyval.s) = NULL;
                    } else { 
                        printf("Declaración válida de var de enum <línea:%d>\n", (yyloc).first_line);
                        (yyval.s) = f; 
                    }
                } else { (yyval.s) = f; }
                
            } else { destruirSimbolo(f); (yyval.s) = NULL; }
    }
#line 1936 "lexer.tab.c"
    break;

  case 13: /* declaEnum: error ';'  */
#line 283 "lexer.y"
                {
        report_error("en declaEnum", (yyloc).first_line, "error sintactico de declaración de enum.");
        yyerrok;
    }
#line 1945 "lexer.tab.c"
    break;

  case 14: /* ids_opt: ';'  */
#line 290 "lexer.y"
          { (yyval.arr) = NULL; }
#line 1951 "lexer.tab.c"
    break;

  case 15: /* ids_opt: lista_ids  */
#line 291 "lexer.y"
                { (yyval.arr) = (yyvsp[0].arr); }
#line 1957 "lexer.tab.c"
    break;

  case 16: /* lista_ids: IDENTIFICADOR  */
#line 295 "lexer.y"
                    {
        Array* arr = createArray(10);
        char* e = strdup((yyvsp[0].cadena));
        insertElemArray(arr, e);
        (yyval.arr) = arr;
    }
#line 1968 "lexer.tab.c"
    break;

  case 17: /* lista_ids: lista_ids ',' IDENTIFICADOR  */
#line 301 "lexer.y"
                                  {
        char* e = strdup((yyvsp[0].cadena));
        insertElemArray((yyvsp[-2].arr), e);
        (yyval.arr) = (yyvsp[-2].arr);
    }
#line 1978 "lexer.tab.c"
    break;

  case 18: /* lista_enumeradores: IDENTIFICADOR  */
#line 309 "lexer.y"
                    {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember((yyvsp[0].cadena), 0);
        Simbolo* t = crearSimbolo((yyvsp[0].cadena), CONSTENUM, "0", (yyloc).first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            (yyval.arr) = NULL;
        } else {
            insertElemArray(arr, em);
            (yyval.arr) = arr;
        }
    }
#line 1995 "lexer.tab.c"
    break;

  case 19: /* lista_enumeradores: IDENTIFICADOR '=' ENTERO  */
#line 321 "lexer.y"
                               {
        Array* arr = createArray(10);
        Enumerador* em = crearEnumMember((yyvsp[-2].cadena), (yyvsp[0].ival));
        char* c = itoa((yyvsp[0].ival));
        Simbolo* t = crearSimbolo((yyvsp[-2].cadena), CONSTENUM, c, (yyloc).first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            (yyval.arr) = NULL;
        } else {
            insertElemArray(arr, em);
            (yyval.arr) = arr;
        }
    }
#line 2013 "lexer.tab.c"
    break;

  case 20: /* lista_enumeradores: lista_enumeradores ',' IDENTIFICADOR  */
#line 334 "lexer.y"
                                           {
        int valor = ((Enumerador*)findElemArray((yyvsp[-2].arr), arraySize((yyvsp[-2].arr))-1))->valor + 1;
        Enumerador* em = crearEnumMember((yyvsp[0].cadena), valor);
        char* c = itoa(valor);
        Simbolo* t = crearSimbolo((yyvsp[0].cadena), CONSTENUM, c, (yyloc).first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            (yyval.arr) = NULL;
        } else {
            insertElemArray((yyvsp[-2].arr), em);
            (yyval.arr) = (yyvsp[-2].arr);
        }
    }
#line 2031 "lexer.tab.c"
    break;

  case 21: /* lista_enumeradores: lista_enumeradores ',' IDENTIFICADOR '=' ENTERO  */
#line 347 "lexer.y"
                                                      {
        Enumerador* em = crearEnumMember((yyvsp[-2].cadena), (yyvsp[0].ival));
        char* c = itoa((yyvsp[0].ival));
        Simbolo* t = crearSimbolo((yyvsp[-2].cadena), CONSTENUM, c, (yyloc).first_line);
        if (!agregarSimbolo(tablaGral, t)) {
            destruirSimbolo(t);
            (yyval.arr) = NULL;
        } else {
            insertElemArray((yyvsp[-4].arr), em);
            (yyval.arr) = (yyvsp[-4].arr);
        }
    }
#line 2048 "lexer.tab.c"
    break;

  case 22: /* declaVoF: tipo_opt IDENTIFICADOR ';'  */
#line 362 "lexer.y"
                                 {
        char* tipo = (yyvsp[-2].cadena);
        if(tipo) {
            if(esTipoBasico(tipo)) {
                Simbolo* v = crearSimbolo(
                    (yyvsp[-1].cadena),
                    VARIABLE,
                    tipo,
                    (yylsp[-2]).first_line
                );

                if (!agregarSimbolo(tablaGral, v)) {
                    report_error("en declaVoF", (yyloc).first_line, "error semantico, variable redeclarada.");
                    (yyval.s) = NULL;
                } else {
                    printf("Declaración válida de varSimple <línea:%d>\n", (yyloc).first_line);
                    (yyval.s) = v;        
                }
            } else { // es tipo nomEnum o void
                if(strcmp(tipo, "void") == 0) {
                    report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no valido para variable");
                    (yyval.s) = NULL;
                } else {
                    Simbolo* v = crearSimbolo(
                        (yyvsp[-1].cadena),
                        VARIABLE,
                        tipo,
                        (yylsp[-2]).first_line
                    );
                    if (!agregarSimbolo(tablaGral, v)) {
                        report_error("en declaVarSimple", (yyloc).first_line, "error semantico, variable redeclarada.");
                        (yyval.s) = NULL;
                    } else {
                        printf("Declaración válida de varSimple tipo nomEnum <línea:%d>\n", (yyloc).first_line);
                        (yyval.s) = v;        
                    }
                }
            }
        } else {
            report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no definido");
            (yyval.s) = NULL;
        }
    }
#line 2096 "lexer.tab.c"
    break;

  case 23: /* declaVoF: tipo_opt IDENTIFICADOR '(' parametros_opt ')' ';'  */
#line 405 "lexer.y"
                                                        {
        if((yyvsp[-5].cadena)) {
            if(esTipoBasico((yyvsp[-5].cadena)) || strcmp((yyvsp[-5].cadena), "void") == 0) {
                Simbolo* f = NULL;
                if(esTipoBasico((yyvsp[-5].cadena))) {
                    f = crearSimbolo(
                        (yyvsp[-4].cadena),
                        FUNCION,
                        (yyvsp[-5].cadena),
                        (yyloc).first_line
                    );
                } else {
                    f = crearSimbolo(
                        (yyvsp[-4].cadena),
                        FUNCION,
                        strdup("void"),
                        (yyloc).first_line
                    );
                }

                if (!agregarSimbolo(tablaGral, f)) {
                    report_error("en declaVoF", (yyloc).first_line, "error semantico, funcion redeclarada.");
                    (yyval.s) = NULL;
                } else {
                    if((yyvsp[-2].arr)) {
                        int ok = 1;
                        for (int i = 0; i < arraySize((yyvsp[-2].arr)); i++) {
                            Parametro* p = (Parametro*) findElemArray((yyvsp[-2].arr), i); 
                            if (strcmp(p->tipo, "error") == 0) {
                                report_error("en declaVoF", (yyloc).first_line, "error en parametro");
                                //falta funcion destroyParametro
                                ok = 0;
                                break;
                            }
                        }
                        if(!ok) {
                            eliminarSimbolo(tablaGral, f);
                            (yyval.s) = NULL;
                        } else {
                            printf("Declaración válida de funcion con parametros <línea:%d>\n", (yyloc).first_line);
                            (yyval.s) = f;
                        }
                    } else {
                        f->miembros = (yyvsp[-2].arr);
                        f->cantMiembros = 0;
                        printf("Declaración válida de funcion <línea:%d>\n", (yyloc).first_line);
                        (yyval.s) = f;
                    }
                }
            } else { // es tipo nomEnum
                report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no valido para funcion");
                (yyval.s) = NULL;
            }
        } else {
            report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no definido");
            (yyval.s) = NULL;
        }
    }
#line 2159 "lexer.tab.c"
    break;

  case 24: /* @2: %empty  */
#line 463 "lexer.y"
                                 {
        char* tipo = (yyvsp[-2].cadena);
        if(tipo) {
            if(esTipoBasico(tipo)) {
                Simbolo* v = crearSimbolo(
                    (yyvsp[-1].cadena),
                    VARIABLE,
                    tipo,
                    (yylsp[-2]).first_line
                );

                if (!agregarSimbolo(tablaGral, v)) {
                    report_error("en declaVoF", (yyloc).first_line, "error semantico, variable redeclarada.");
                    (yyval.s) = NULL;
                } else {
                    printf("Declaración válida de varSimple <línea:%d>\n", (yyloc).first_line);
                    (yyval.s) = v;        
                }
            } else { // es tipo nomEnum o void
                if(strcmp(tipo, "void") == 0) {
                    report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no valido para variable");
                    (yyval.s) = NULL;
                } else {
                    Simbolo* v = crearSimbolo(
                        (yyvsp[-1].cadena),
                        VARIABLE,
                        tipo,
                        (yylsp[-2]).first_line
                    );
                    if (!agregarSimbolo(tablaGral, v)) {
                        report_error("en declaVarSimple", (yyloc).first_line, "error semantico, variable redeclarada.");
                        (yyval.s) = NULL;
                    } else {
                        printf("Declaración válida de varSimple tipo nomEnum <línea:%d>\n", (yyloc).first_line);
                        (yyval.s) = v;        
                    }
                }
            }
        } else {
            report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no definido");
            (yyval.s) = NULL;
        }
    }
#line 2207 "lexer.tab.c"
    break;

  case 25: /* declaVoF: tipo_opt IDENTIFICADOR '=' @2 expOr ';'  */
#line 506 "lexer.y"
                  {
            Simbolo* v = (yyvsp[-2].s);   // el símbolo creado

            if (v != NULL) {
                if ((yyvsp[-1].expr)) {
                    Expr* exprInit = (yyvsp[-1].expr); char* tipoInit = exprInit->tipo;

                    // Validar inicialización
                    if (!tiposCompatibles(v->tipoDato, tipoInit)) {
                        report_error("en declaVarSimple", (yyloc).first_line,
                                        "error semantico, inicialización incompatible con el tipo de la variable.");
                        eliminarSimbolo(tablaGral, v);
                        (yyval.s) = NULL;
                    } else { 
                        printf("Declaración válida de var inicializada <línea:%d>\n", (yyloc).first_line);
                        (yyval.s) = v; 
                    }
                } else { destruirSimbolo(v); (yyval.s) = NULL; }
            } else { destruirSimbolo(v); (yyval.s) = NULL; }
    }
#line 2232 "lexer.tab.c"
    break;

  case 26: /* @3: %empty  */
#line 526 "lexer.y"
                                                    {
        if((yyvsp[-4].cadena)) {
            if(esTipoBasico((yyvsp[-4].cadena)) || strcmp((yyvsp[-4].cadena), "void") == 0) {
                Simbolo* f = NULL;
                if(esTipoBasico((yyvsp[-4].cadena))) {
                    f = crearSimbolo(
                        (yyvsp[-3].cadena),
                        FUNCION,
                        (yyvsp[-4].cadena),
                        (yyloc).first_line
                    );
                } else {
                    f = crearSimbolo(
                        (yyvsp[-3].cadena),
                        FUNCION,
                        strdup("void"),
                        (yyloc).first_line
                    );
                }

                if (!agregarSimbolo(tablaGral, f)) {
                    report_error("en declaVoF", (yyloc).first_line, "error semantico, funcion redeclarada.");
                    (yyval.s) = NULL;
                    nomFuncActual = NULL;
                } else {
                    if((yyvsp[-1].arr)) {
                        int ok = 1;
                        for (int i = 0; i < arraySize((yyvsp[-1].arr)); i++) {
                            Parametro* p = (Parametro*) findElemArray((yyvsp[-1].arr), i); 
                            if (strcmp(p->tipo, "error") == 0) {
                                report_error("en declaVoF", (yyloc).first_line, "error en parametro");
                                //falta funcion destroyParametro
                                ok = 0;
                                break;
                            }
                        }
                        if(!ok) {
                            eliminarSimbolo(tablaGral, f);
                            (yyval.s) = NULL;
                            nomFuncActual = NULL;
                        } else {
                            f->miembros = (yyvsp[-1].arr);
                            f->cantMiembros = arraySize((yyvsp[-1].arr));
                            printf("Declaración válida de funcion con parametros <línea:%d>\n", (yyloc).first_line);
                            (yyval.s) = f;
                            nomFuncActual = f->key;
                            abrirScope(tablaGral);
                            inFunctionBlock = 1;
                        }
                    } else {
                        f->miembros = (yyvsp[-1].arr);
                        f->cantMiembros = 0;
                        printf("Declaración válida de funcion <línea:%d>\n", (yyloc).first_line);
                        (yyval.s) = f;
                        nomFuncActual = f->key;
                        abrirScope(tablaGral);
                        inFunctionBlock = 1;
                    }
                }
            } else { // es tipo nomEnum
                report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no valido para funcion");
                (yyval.s) = NULL;
                nomFuncActual = NULL;
            }
        } else {
            report_error("en declaVoF", (yyloc).first_line, "error semantico, tipoDato no definido");
            (yyval.s) = NULL;
            nomFuncActual = NULL;
        }
    }
#line 2307 "lexer.tab.c"
    break;

  case 27: /* declaVoF: tipo_opt IDENTIFICADOR '(' parametros_opt ')' @3 sentCompuesta  */
#line 596 "lexer.y"
                      {
            Simbolo* f = buscarSimbolo(tablaGral, nomFuncActual);
            char* tipoDeclarado = f? f->tipoDato: NULL;
            char* tipoRetornado = (yyvsp[0].cadena);
            if(f && f->clase == FUNCION){
                if (tipoRetornado == NULL && strcmp(tipoDeclarado, "void") != 0) {
                    report_error("en función", (yyloc).first_line,
                                    "error semantico, falta retorno en funcion");
                    eliminarSimbolo(tablaGral, f);
                    (yyval.s) = NULL;
                } else if (tipoRetornado != NULL &&
                            !tiposCompatibles(tipoDeclarado, tipoRetornado)) {
                    report_error("en función", (yyloc).first_line,
                                    "error semantico, Tipo de retorno incompatible.");
                    eliminarSimbolo(tablaGral, f);
                    (yyval.s) = NULL;
                } else { 
                    printf("Declaración válida de funcion con cuerpo <línea:%d>\n", (yyloc).first_line);
                    (yyval.s) = f;
                }
                if (tipoDeclarado == NULL) {
                    report_error("en funcion", (yyloc).first_line, "funcion sin tipo declarado");
                    eliminarSimbolo(tablaGral, f);
                }
            } else { (yyval.s) = NULL; }
            cerrarScope(tablaGral);
            inFunctionBlock = 0;
    }
#line 2340 "lexer.tab.c"
    break;

  case 28: /* declaVoF: error ';'  */
#line 625 "lexer.y"
                {
        report_error("en declaVoF", (yyloc).first_line, "error sintactico de declaración de variable.");
        yyerrok;
    }
#line 2349 "lexer.tab.c"
    break;

  case 29: /* tipo_opt: TIPO_DATO  */
#line 632 "lexer.y"
                { (yyval.cadena) = (yyvsp[0].cadena); }
#line 2355 "lexer.tab.c"
    break;

  case 30: /* tipo_opt: TIPO_DATO '*'  */
#line 633 "lexer.y"
                    {
        if (strcmp((yyvsp[-1].cadena), "char") == 0) {
            (yyval.cadena) = strdup("char*");
        } else {
            report_error("en tipo_opt", (yylsp[-1]).first_line,
                            "no analizo punteros");
            (yyval.cadena) = NULL;
        }
    }
#line 2369 "lexer.tab.c"
    break;

  case 31: /* tipo_opt: IDENTIFICADOR  */
#line 642 "lexer.y"
                    { 
        Simbolo* s = buscarSimbolo(tablaGral, (yyvsp[0].cadena));
        if(s && s->clase == ENUMR) {
            (yyval.cadena) = s->key; 
        } else {
            report_error("en tipo_opt", (yylsp[0]).first_line,
                            "tipoDato no declarado");
            (yyval.cadena) = NULL;
        }
    }
#line 2384 "lexer.tab.c"
    break;

  case 32: /* parametros_opt: %empty  */
#line 655 "lexer.y"
                   { (yyval.arr) = NULL; }
#line 2390 "lexer.tab.c"
    break;

  case 33: /* parametros_opt: lista_parametros  */
#line 656 "lexer.y"
                       { (yyval.arr) = (yyvsp[0].arr); }
#line 2396 "lexer.tab.c"
    break;

  case 34: /* lista_parametros: parametro  */
#line 660 "lexer.y"
                {
        Array* arr = createArray(10);
        if ((yyvsp[0].p) != NULL) { 
            insertElemArray(arr, (yyvsp[0].p));
            (yyval.arr) = arr;
        } else { 
            Parametro* e = crearParametro("error", "error");
            insertElemArray(arr, e);
            (yyval.arr) = arr;
        }
    }
#line 2412 "lexer.tab.c"
    break;

  case 35: /* lista_parametros: lista_parametros ',' parametro  */
#line 671 "lexer.y"
                                     {
        if ((yyvsp[0].p) != NULL) { 
            insertElemArray((yyvsp[-2].arr), (yyvsp[0].p));
            (yyval.arr) = (yyvsp[-2].arr);
        } else { 
            Parametro* e = crearParametro("error", "error");
            insertElemArray((yyvsp[-2].arr), e);
            (yyval.arr) = (yyvsp[-2].arr);
        }
    }
#line 2427 "lexer.tab.c"
    break;

  case 36: /* parametro: TIPO_DATO IDENTIFICADOR  */
#line 684 "lexer.y"
                              {
        if (strcmp((yyvsp[-1].cadena), "void") == 0) {
            report_error("en parámetro", (yylsp[-1]).first_line,
                            "Un parámetro no puede ser de tipo 'void'.");
            (yyval.p) = NULL;
        } else {
            Parametro* p = crearParametro((yyvsp[0].cadena), (yyvsp[-1].cadena));
            (yyval.p) = p;
        }
    }
#line 2442 "lexer.tab.c"
    break;

  case 37: /* parametro: TIPO_DATO '*' IDENTIFICADOR  */
#line 694 "lexer.y"
                                  {
        if (strcmp((yyvsp[-2].cadena), "char") == 0) {
            Parametro* p = crearParametro((yyvsp[-1].cadena), "char*");
            (yyval.p) = p;
        } else {
            report_error("en parámetro", (yylsp[-2]).first_line,
                            "no analizo punteros, solo char*.");
            (yyval.p) = NULL;
        }
    }
#line 2457 "lexer.tab.c"
    break;

  case 38: /* sentencia: sentCompuesta  */
#line 708 "lexer.y"
        { (yyval.cadena) = (yyvsp[0].cadena); printf("Se leyó una sentCompuesta <linea:%d>\n", (yylsp[0]).first_line); }
#line 2463 "lexer.tab.c"
    break;

  case 39: /* sentencia: sentExpresion  */
#line 710 "lexer.y"
        { (yyval.cadena) = NULL; printf("Se leyó una sentExpresion <linea:%d>\n", (yylsp[0]).first_line); }
#line 2469 "lexer.tab.c"
    break;

  case 40: /* sentencia: sentSeleccion  */
#line 712 "lexer.y"
        { (yyval.cadena) = (yyvsp[0].cadena); printf("Se leyó una sentSeleccion(if, else) <linea:%d>\n", (yylsp[0]).first_line); }
#line 2475 "lexer.tab.c"
    break;

  case 41: /* sentencia: sentIteracion  */
#line 714 "lexer.y"
        { (yyval.cadena) = NULL; printf("Se leyó una sentIteracion(while, for) <linea:%d>\n", (yylsp[0]).first_line); }
#line 2481 "lexer.tab.c"
    break;

  case 42: /* sentencia: sentSalto  */
#line 716 "lexer.y"
        { (yyval.cadena) = (yyvsp[0].cadena); printf("Se leyó una sentSalto(return) <linea:%d>\n", (yylsp[0]).first_line); }
#line 2487 "lexer.tab.c"
    break;

  case 44: /* sentencia: error ';'  */
#line 718 "lexer.y"
                {
        report_error("en sentencia", (yyloc).first_line, "error sintactico de sentencia.");
        yyerrok;
        (yyval.cadena) = NULL;
    }
#line 2497 "lexer.tab.c"
    break;

  case 45: /* $@4: %empty  */
#line 726 "lexer.y"
          { 
        if (!inFunctionBlock) {
            abrirScope(tablaGral);
        } else {
            if(nomFuncActual != NULL) {
                Simbolo* f = buscarSimbolo(tablaGral, nomFuncActual);
                if(f && f->clase == FUNCION) {
                    for (int i = 0; i < f->cantMiembros; i++) {
                        Parametro* p = (Parametro*) findElemArray(f->miembros, i); 
                        printf("  param %d: nombre=%s tipo=%s\n", i, p->nombre, p->tipo);
                        Simbolo* t = crearSimbolo(p->nombre, VARIABLE, p->tipo, (yyloc).first_line);
                        agregarSimbolo(tablaGral, t);
                    }
                }
            }
        }
        
    }
#line 2520 "lexer.tab.c"
    break;

  case 46: /* sentCompuesta: '{' $@4 items '}'  */
#line 745 "lexer.y"
           { 
        if (!inFunctionBlock) {
            cerrarScope(tablaGral);
        }
        (yyval.cadena) = (yyvsp[-1].cadena); 
    }
#line 2531 "lexer.tab.c"
    break;

  case 47: /* sentCompuesta: '{' error '}'  */
#line 752 "lexer.y"
                    {
        report_error("en sentCompuesta", (yyloc).first_line,
                        "Error sintáctico dentro de bloque.");
        yyerrok;
        if (!inFunctionBlock) {
            cerrarScope(tablaGral);
        }
        (yyval.cadena) = NULL;
    }
#line 2545 "lexer.tab.c"
    break;

  case 50: /* sentExpresion: error ';'  */
#line 767 "lexer.y"
                {
        report_error("en sentExpresión", (yyloc).first_line, "sintaxis de expresión inválida");
        yyerrok;
    }
#line 2554 "lexer.tab.c"
    break;

  case 51: /* sentSeleccion: IF '(' error ')' sentencia opSent  */
#line 774 "lexer.y"
                                        {
          report_error("en IF", (yyloc).first_line, "condición inválida, error sintactico");
          yyerrok; (yyval.cadena) = NULL;
    }
#line 2563 "lexer.tab.c"
    break;

  case 52: /* $@5: %empty  */
#line 779 "lexer.y"
        { // Verificar variables usadas en la condición
            if(!esNumerico((yyvsp[-1].expr)->tipo)){
                report_error("en IF", (yyloc).first_line, "condición inválida");
            }
            abrirScope(tablaGral); 
        }
#line 2574 "lexer.tab.c"
    break;

  case 53: /* @6: %empty  */
#line 786 "lexer.y"
        {
            char* ret = (yyvsp[0].cadena);
            cerrarScope(tablaGral);
            (yyval.cadena) = ret;
        }
#line 2584 "lexer.tab.c"
    break;

  case 54: /* sentSeleccion: IF '(' expresion ')' $@5 sentencia @6 opSent  */
#line 792 "lexer.y"
        {
            if ((yyvsp[0].cadena) != NULL) { /* ELSE existe */
                char* retIf   = (yyvsp[-2].cadena); 
                char* retElse = (yyvsp[0].cadena);

                if (retIf != NULL && retElse != NULL) {
                    if (!tiposCompatibles(retIf, retElse))
                        report_error("en IF-ELSE", (yyloc).first_line, "tipos de retorno incompatibles en IF/ELSE");

                    (yyval.cadena) = retIf; /* return válido */
                } else {
                    (yyval.cadena) = retIf ? retIf : retElse;
                }
            }
        }
#line 2604 "lexer.tab.c"
    break;

  case 55: /* opSent: %empty  */
#line 810 "lexer.y"
                   { (yyval.cadena) = NULL; }
#line 2610 "lexer.tab.c"
    break;

  case 56: /* $@7: %empty  */
#line 812 "lexer.y"
        { abrirScope(tablaGral); }
#line 2616 "lexer.tab.c"
    break;

  case 57: /* opSent: ELSE $@7 sentencia  */
#line 814 "lexer.y"
        { cerrarScope(tablaGral); (yyval.cadena) = (yyvsp[0].cadena); }
#line 2622 "lexer.tab.c"
    break;

  case 58: /* $@8: %empty  */
#line 819 "lexer.y"
        {
            if(!esNumerico((yyvsp[-1].expr)->tipo)){
                report_error("en WHILE", (yyloc).first_line, "condición inválida");
            }
            abrirScope(tablaGral);
        }
#line 2633 "lexer.tab.c"
    break;

  case 59: /* sentIteracion: WHILE '(' expresion ')' $@8 sentencia  */
#line 826 "lexer.y"
        { cerrarScope(tablaGral); }
#line 2639 "lexer.tab.c"
    break;

  case 60: /* sentIteracion: WHILE '(' error ')' sentencia  */
#line 828 "lexer.y"
                                    {
          report_error("en WHILE", (yyloc).first_line, "condición inválida, error sintactico");
          yyerrok;
    }
#line 2648 "lexer.tab.c"
    break;

  case 61: /* $@9: %empty  */
#line 833 "lexer.y"
        {
            if((yyvsp[-3].expr) != NULL && !esNumerico((yyvsp[-3].expr)->tipo)){
                report_error("en FOR", (yyloc).first_line, "condición inválida");
            }
            abrirScope(tablaGral);
        }
#line 2659 "lexer.tab.c"
    break;

  case 62: /* sentIteracion: FOR '(' expresion_opt ';' expresion_opt ';' expresion_opt ')' $@9 sentencia  */
#line 840 "lexer.y"
        { cerrarScope(tablaGral); }
#line 2665 "lexer.tab.c"
    break;

  case 63: /* sentIteracion: FOR '(' error ')' sentencia  */
#line 842 "lexer.y"
                                  {
        report_error("en FOR", (yyloc).first_line, "estructura sintactica del FOR inválida");
        yyerrok;
    }
#line 2674 "lexer.tab.c"
    break;

  case 64: /* sentSalto: RETURN expresion_opt ';'  */
#line 849 "lexer.y"
                               {
        if ((yyvsp[-1].expr) == NULL) {
            // return sin valor → tipo = void
            (yyval.cadena) = strdup("void");
        } else {
            // la expresión devuelve un tipo
            (yyval.cadena) = (yyvsp[-1].expr)->tipo;
        }
    }
#line 2688 "lexer.tab.c"
    break;

  case 65: /* sentSalto: error ';'  */
#line 859 "lexer.y"
                {
        report_error("en sentSalto", (yyloc).first_line, "sintaxis de expresión inválida");
        (yyval.cadena) = NULL;
        yyerrok;
    }
#line 2698 "lexer.tab.c"
    break;

  case 66: /* expresion_opt: %empty  */
#line 867 "lexer.y"
                   { (yyval.expr) = NULL; }
#line 2704 "lexer.tab.c"
    break;

  case 67: /* expresion_opt: expresion  */
#line 868 "lexer.y"
                { (yyval.expr) = (yyvsp[0].expr); }
#line 2710 "lexer.tab.c"
    break;

  case 68: /* expresion: expOr  */
#line 872 "lexer.y"
            { (yyval.expr) = (yyvsp[0].expr); }
#line 2716 "lexer.tab.c"
    break;

  case 69: /* expresion: IDENTIFICADOR opAsignacion expOr  */
#line 873 "lexer.y"
                                       {
        Simbolo* s = buscarSimbolo(tablaGral, (yyvsp[-2].cadena));
        if(s && s->clase == VARIABLE) {
            if (!tiposCompatibles(s->tipoDato, (yyvsp[0].expr)->tipo)) {
                report_error("en asignación", (yyloc).first_line,
                        "error semantico, tipo incompatible en asignación.");
                (yyval.expr) = NULL;
            }

            // tipo de la expresión asignación es el del LHS
            (yyval.expr) = crearExpr(s->tipoDato, 0);
        } else {
            report_error("en expresion", (yylsp[-2]).first_line,
                "error semantico, identificador no declarado");
            (yyval.expr) = NULL;
        }
    }
#line 2738 "lexer.tab.c"
    break;

  case 70: /* expresion: error  */
#line 891 "lexer.y"
            {
        report_error("en expresión", (yyloc).first_line, "sintaxis de expresión inválida");
        yyerrok;
        (yyval.expr) = NULL;
    }
#line 2748 "lexer.tab.c"
    break;

  case 71: /* opAsignacion: '='  */
#line 899 "lexer.y"
          { (yyval.cadena) = strdup("="); }
#line 2754 "lexer.tab.c"
    break;

  case 72: /* opAsignacion: MAS_IGUAL  */
#line 900 "lexer.y"
                { (yyval.cadena) = strdup("+="); }
#line 2760 "lexer.tab.c"
    break;

  case 73: /* opAsignacion: MENOS_IGUAL  */
#line 901 "lexer.y"
                  { (yyval.cadena) = strdup("-="); }
#line 2766 "lexer.tab.c"
    break;

  case 74: /* opAsignacion: DIV_IGUAL  */
#line 902 "lexer.y"
                { (yyval.cadena) = strdup("/="); }
#line 2772 "lexer.tab.c"
    break;

  case 75: /* opAsignacion: POR_IGUAL  */
#line 903 "lexer.y"
                { (yyval.cadena) = strdup("*="); }
#line 2778 "lexer.tab.c"
    break;

  case 76: /* expOr: expAnd  */
#line 907 "lexer.y"
             { (yyval.expr) = (yyvsp[0].expr); }
#line 2784 "lexer.tab.c"
    break;

  case 77: /* expOr: expOr OR expAnd  */
#line 908 "lexer.y"
                      {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("en OR", (yyloc).first_line, "error semantico, operador lógico solo admite tipos numéricos.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2797 "lexer.tab.c"
    break;

  case 78: /* expAnd: expIgualdad  */
#line 919 "lexer.y"
                  { (yyval.expr) = (yyvsp[0].expr); }
#line 2803 "lexer.tab.c"
    break;

  case 79: /* expAnd: expAnd AND expIgualdad  */
#line 920 "lexer.y"
                             {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("en AND", (yyloc).first_line, "error semantico, operador lógico solo admite tipos numéricos.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2816 "lexer.tab.c"
    break;

  case 80: /* expIgualdad: expRelacional  */
#line 931 "lexer.y"
                    { (yyval.expr) = (yyvsp[0].expr); }
#line 2822 "lexer.tab.c"
    break;

  case 81: /* expIgualdad: expIgualdad IGUALDAD expRelacional  */
#line 932 "lexer.y"
                                         {
        if (!tiposCompatibles((yyvsp[-2].expr)->tipo, (yyvsp[0].expr)->tipo) && !tiposCompatibles((yyvsp[0].expr)->tipo, (yyvsp[-2].expr)->tipo)) {
            report_error("en '=='", (yyloc).first_line, "tipos incompatibles en comparación.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2835 "lexer.tab.c"
    break;

  case 82: /* expIgualdad: expIgualdad DIFERENTE expRelacional  */
#line 940 "lexer.y"
                                          {
        if (tiposCompatibles((yyvsp[-2].expr)->tipo, (yyvsp[0].expr)->tipo) || tiposCompatibles((yyvsp[0].expr)->tipo, (yyvsp[-2].expr)->tipo)) {
            report_error("en '!='", (yyloc).first_line, "tipos incompatibles en comparación.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2848 "lexer.tab.c"
    break;

  case 83: /* expRelacional: expAditiva  */
#line 951 "lexer.y"
                 { (yyval.expr) = (yyvsp[0].expr); }
#line 2854 "lexer.tab.c"
    break;

  case 84: /* expRelacional: expRelacional MAYOR_IGUAL expAditiva  */
#line 952 "lexer.y"
                                           {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("en MAYOR_IGUAL", (yyloc).first_line, "error semantico, comparacion solo admite tipos numéricos.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2867 "lexer.tab.c"
    break;

  case 85: /* expRelacional: expRelacional '>' expAditiva  */
#line 960 "lexer.y"
                                   {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("en MAYOR", (yyloc).first_line, "error semantico, comparacion solo admite tipos numéricos.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2880 "lexer.tab.c"
    break;

  case 86: /* expRelacional: expRelacional MENOR_IGUAL expAditiva  */
#line 968 "lexer.y"
                                           {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("en MENOR_IGUAL", (yyloc).first_line, "error semantico, comparacion solo admite tipos numéricos.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2893 "lexer.tab.c"
    break;

  case 87: /* expRelacional: expRelacional '<' expAditiva  */
#line 976 "lexer.y"
                                   {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("en MENOR", (yyloc).first_line, "error semantico, comparacion solo admite tipos numéricos.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("int", 0);
        }
    }
#line 2906 "lexer.tab.c"
    break;

  case 88: /* expAditiva: expMultiplicativa  */
#line 987 "lexer.y"
                        { (yyval.expr) = (yyvsp[0].expr); }
#line 2912 "lexer.tab.c"
    break;

  case 89: /* expAditiva: expAditiva '+' expMultiplicativa  */
#line 988 "lexer.y"
                                       {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("+", (yyloc).first_line, "error semantico, solo suma numérica permitida.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico((yyvsp[-2].expr)->tipo, (yyvsp[0].expr)->tipo), 0);
        }
    }
#line 2925 "lexer.tab.c"
    break;

  case 90: /* expAditiva: expAditiva '-' expMultiplicativa  */
#line 996 "lexer.y"
                                       {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("-", (yyloc).first_line, "error semantico, solo resta numérica permitida.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico((yyvsp[-2].expr)->tipo, (yyvsp[0].expr)->tipo), 0);
        }
    }
#line 2938 "lexer.tab.c"
    break;

  case 91: /* expMultiplicativa: expUnaria  */
#line 1007 "lexer.y"
                { (yyval.expr) = (yyvsp[0].expr); }
#line 2944 "lexer.tab.c"
    break;

  case 92: /* expMultiplicativa: expMultiplicativa '*' expUnaria  */
#line 1008 "lexer.y"
                                      {
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("*", (yyloc).first_line, "error semantico, solo multiplicacion numérica permitida.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico((yyvsp[-2].expr)->tipo, (yyvsp[0].expr)->tipo), 0);
        }
    }
#line 2957 "lexer.tab.c"
    break;

  case 93: /* expMultiplicativa: expMultiplicativa '/' expUnaria  */
#line 1016 "lexer.y"
                                      { 
        if (!esNumerico((yyvsp[-2].expr)->tipo) || !esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("/", (yyloc).first_line, "error semantico, solo division numérica permitida.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr("double", 0);
        }
    }
#line 2970 "lexer.tab.c"
    break;

  case 94: /* expUnaria: expPostfijo  */
#line 1027 "lexer.y"
                  { (yyval.expr) = (yyvsp[0].expr); }
#line 2976 "lexer.tab.c"
    break;

  case 95: /* expUnaria: operUnario expPostfijo  */
#line 1028 "lexer.y"
                                          {
        if (!esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("unario", (yyloc).first_line, "error semantico, solo unario en numerico permitido.");
            (yyval.expr) = NULL;
        } else {
            if(strcmp((yyvsp[-1].cadena), "!") == 0) {
                (yyval.expr) = crearExpr("int", 0);
            } else { // (-1) * k
                (yyval.expr) = crearExpr(tipoResultadoNumerico("int", (yyvsp[0].expr)->tipo), 0);
            }
        }
    }
#line 2993 "lexer.tab.c"
    break;

  case 96: /* expUnaria: INCREMENTO expPrimaria  */
#line 1040 "lexer.y"
                             { /* ++x */ 
        if (!esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("PRE INCREMENTO", (yyloc).first_line, "error semantico, solo ++ numerico permitido.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico("int", (yyvsp[0].expr)->tipo), 0);
        }
    }
#line 3006 "lexer.tab.c"
    break;

  case 97: /* expUnaria: DECREMENTO expPrimaria  */
#line 1048 "lexer.y"
                             { /* --x */ 
        if (!esNumerico((yyvsp[0].expr)->tipo)) {
            report_error("PRE DECREMENTO", (yyloc).first_line, "error semantico, solo -- numerico permitido.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico("int", (yyvsp[0].expr)->tipo), 0);
        }
    }
#line 3019 "lexer.tab.c"
    break;

  case 98: /* operUnario: '-'  */
#line 1059 "lexer.y"
          { (yyval.cadena) = "-"; }
#line 3025 "lexer.tab.c"
    break;

  case 99: /* operUnario: '!'  */
#line 1060 "lexer.y"
          { (yyval.cadena) = "!"; }
#line 3031 "lexer.tab.c"
    break;

  case 100: /* expPostfijo: expPrimaria  */
#line 1064 "lexer.y"
                  { (yyval.expr) = (yyvsp[0].expr); }
#line 3037 "lexer.tab.c"
    break;

  case 101: /* expPostfijo: IDENTIFICADOR '(' listaArgumentos ')'  */
#line 1065 "lexer.y"
                                            {
        Simbolo* s = buscarSimbolo(tablaGral, (yyvsp[-3].cadena));
        if(s && s->clase == FUNCION) {
            int cantArgs = (yyvsp[-1].arr)? arraySize((yyvsp[-1].arr)) : 0;
            int cantArgsFunc = s->cantMiembros;
            // verifico cantArgs y compatibilidad de tipoDato var con el que retorna func
            if(cantArgs == cantArgsFunc) {
                // verifico que los args correspondan al tipo pedido en los parametros de func
                int ok = 1;
                for (int i = 0; i < cantArgsFunc; i++) {
                    char* tipoArg = findElemArray((yyvsp[-1].arr), i);
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
                    report_error("en llamada a funcion", (yylsp[-3]).first_line,
                                    "tipos incompatibles en los argumentos");
                    (yyval.expr) = NULL;
                } else {
                    // La llamada es válida: retorna el tipo de la función
                    (yyval.expr) = crearExpr(s->tipoDato, 0);
                }
            } else {
                report_error("en expPostfijo", (yyloc).first_line, "cantidad de argumentos en funcion invalida");
                (yyval.expr) = NULL;
            }
        } else {
            report_error("en expPostfijo", (yyloc).first_line, "funcion no declarada o identificador no es funcion");
            (yyval.expr) = NULL;
        }
    }
#line 3081 "lexer.tab.c"
    break;

  case 102: /* expPostfijo: expPrimaria INCREMENTO  */
#line 1104 "lexer.y"
                                                       { 
        if (!esNumerico((yyvsp[-1].expr)->tipo)) {
            report_error("INCREMENTO", (yyloc).first_line, "error semantico, solo ++ numerico permitido.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico((yyvsp[-1].expr)->tipo, "int"), 0);
        }
    }
#line 3094 "lexer.tab.c"
    break;

  case 103: /* expPostfijo: expPrimaria DECREMENTO  */
#line 1112 "lexer.y"
                                           { 
        if (!esNumerico((yyvsp[-1].expr)->tipo)) {
            report_error("DECREMENTO", (yyloc).first_line, "error semantico, solo -- numerico permitido.");
            (yyval.expr) = NULL;
        } else {
            (yyval.expr) = crearExpr(tipoResultadoNumerico((yyvsp[-1].expr)->tipo, "int"), 0);
        }
    }
#line 3107 "lexer.tab.c"
    break;

  case 104: /* listaArgumentos: %empty  */
#line 1123 "lexer.y"
                   { (yyval.arr) = NULL; }
#line 3113 "lexer.tab.c"
    break;

  case 105: /* listaArgumentos: argumento  */
#line 1124 "lexer.y"
                {
        Array* arr = createArray(10);
        if ((yyvsp[0].cadena) != NULL) { 
            insertElemArray(arr, (yyvsp[0].cadena));
            (yyval.arr) = arr;
        } else { 
            insertElemArray(arr, "error");
            (yyval.arr) = arr;
        }
    }
#line 3128 "lexer.tab.c"
    break;

  case 106: /* listaArgumentos: listaArgumentos ',' argumento  */
#line 1134 "lexer.y"
                                    {
        if ((yyvsp[0].cadena) != NULL) { 
            insertElemArray((yyvsp[-2].arr), (yyvsp[0].cadena));
            (yyval.arr) = (yyvsp[-2].arr);
        } else { 
            insertElemArray((yyvsp[-2].arr), "error");
            (yyval.arr) = (yyvsp[-2].arr);
        }
    }
#line 3142 "lexer.tab.c"
    break;

  case 107: /* argumento: ENTERO  */
#line 1146 "lexer.y"
             { (yyval.cadena) = strdup("int"); }
#line 3148 "lexer.tab.c"
    break;

  case 108: /* argumento: CADENA  */
#line 1147 "lexer.y"
             { (yyval.cadena) = strdup("char*"); }
#line 3154 "lexer.tab.c"
    break;

  case 109: /* argumento: NUMERO  */
#line 1148 "lexer.y"
             { (yyval.cadena) = strdup("double"); }
#line 3160 "lexer.tab.c"
    break;

  case 110: /* argumento: CARACTER  */
#line 1149 "lexer.y"
               { (yyval.cadena) = strdup("char"); }
#line 3166 "lexer.tab.c"
    break;

  case 111: /* argumento: IDENTIFICADOR  */
#line 1150 "lexer.y"
                    { 
        Simbolo* s = buscarSimbolo(tablaGral, (yyvsp[0].cadena));
        if (s && s->clase == VARIABLE) {
            Simbolo* enumTipo = buscarSimbolo(tablaGral, s->tipoDato);
            if(enumTipo && enumTipo->clase == ENUMR) {
                report_error("en argumento", (yyloc).first_line, "tipo argumento no permitido");
                (yyval.cadena) = NULL;
            } else {
                (yyval.cadena) = s->tipoDato;
            }
        } else if(s && s->clase == CONSTENUM) {
            (yyval.cadena) = strdup("int");
        } else {
            report_error("en argumento", (yyloc).first_line, "variable no declarada");
            (yyval.cadena) = NULL;
        }
    }
#line 3188 "lexer.tab.c"
    break;

  case 112: /* expPrimaria: IDENTIFICADOR  */
#line 1170 "lexer.y"
                    {
        Simbolo* s = buscarSimbolo(tablaGral, (yyvsp[0].cadena));
        if (s && s->clase == VARIABLE) {
            char* e = s->tipoDato; //puede ser var de un enum
            if(esTipoBasico(e)) {
                (yyval.expr) = crearExpr(s->tipoDato, 1);
            } else {
                Simbolo* enumTipo = buscarSimbolo(tablaGral, s->tipoDato);
                if(enumTipo && enumTipo->clase == ENUMR) {
                    (yyval.expr) = crearExpr("int", 1);
                } else {
                    report_error("en expPrimaria", (yyloc).first_line, "variable no permitida");
                    (yyval.expr) = NULL;
                }
            }
        } else if(s && s->clase == CONSTENUM) {
            (yyval.expr) = crearExpr(s->tipoDato, 0);
        } else {
            report_error("en expPrimaria", (yyloc).first_line, "variable no declarada");
            (yyval.expr) = NULL;
        }
    }
#line 3215 "lexer.tab.c"
    break;

  case 113: /* expPrimaria: ENTERO  */
#line 1192 "lexer.y"
             { 
        (yyval.expr) = crearExpr("int", 0);
    }
#line 3223 "lexer.tab.c"
    break;

  case 114: /* expPrimaria: NUMERO  */
#line 1195 "lexer.y"
             { 
        (yyval.expr) = crearExpr("double", 0);
    }
#line 3231 "lexer.tab.c"
    break;

  case 115: /* expPrimaria: CARACTER  */
#line 1198 "lexer.y"
               { 
        (yyval.expr) = crearExpr("char", 0);
    }
#line 3239 "lexer.tab.c"
    break;

  case 116: /* expPrimaria: CADENA  */
#line 1201 "lexer.y"
             { 
        (yyval.expr) = crearExpr("char*", 0);
    }
#line 3247 "lexer.tab.c"
    break;

  case 117: /* expPrimaria: '(' expOr ')'  */
#line 1204 "lexer.y"
                    { 
        (yyval.expr) = (yyvsp[-1].expr);
    }
#line 3255 "lexer.tab.c"
    break;


#line 3259 "lexer.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      {
        yypcontext_t yyctx
          = {yyssp, yytoken, &yylloc};
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = yysyntax_error (&yymsg_alloc, &yymsg, &yyctx);
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == -1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = YY_CAST (char *,
                             YYSTACK_ALLOC (YY_CAST (YYSIZE_T, yymsg_alloc)));
            if (yymsg)
              {
                yysyntax_error_status
                  = yysyntax_error (&yymsg_alloc, &yymsg, &yyctx);
                yymsgp = yymsg;
              }
            else
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = YYENOMEM;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == YYENOMEM)
          YYNOMEM;
      }
    }

  yyerror_range[1] = yylloc;
  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, &yylloc);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;

      yyerror_range[1] = *yylsp;
      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp, yylsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  yyerror_range[2] = yylloc;
  ++yylsp;
  YYLLOC_DEFAULT (*yylsp, yyerror_range, 2);

  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, &yylloc);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp, yylsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
  return yyresult;
}

#line 1209 "lexer.y"


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
