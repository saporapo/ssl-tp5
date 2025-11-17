# ======================
#  Compilador del proyecto
# ======================

CC = gcc
CFLAGS = -Wall -Wextra -std=c11

# Archivos generados por Bison y Flex
BISON = bison
BISON_FLAGS = -d -y        # -d genera .h, -y evita yyparse conflictos (modo Yacc)

FLEX = flex
FLEX_FLAGS =

# Archivos fuente
PARSER = lexer.y
SCANNER = lexer.l

# Módulos auxiliares
MODS = tablaSimbolos.c stackModule.c arrayModule.c

# Objetos
OBJS = lex.yy.o y.tab.o tablaSimbolos.o stackModule.o arrayModule.o

# Ejecutable final
OUT = compilador


# ======================
#  Reglas principales
# ======================

all: $(OUT)


$(OUT): $(OBJS)
	$(CC) $(CFLAGS) -o $(OUT) $(OBJS)


# ======================
#  Bison
# ======================
y.tab.c y.tab.h: $(PARSER)
	$(BISON) $(BISON_FLAGS) $(PARSER)


# ======================
#  Flex
# ======================
lex.yy.c: $(SCANNER) y.tab.h
	$(FLEX) $(FLEX_FLAGS) $(SCANNER)


# ======================
#  Objetos
# ======================

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c

y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -c y.tab.c

tablaSimbolos.o: tablaSimbolos.c tablaSimbolos.h arrayModule.h stackModule.h
	$(CC) $(CFLAGS) -c tablaSimbolos.c

stackModule.o: stackModule.c stackModule.h
	$(CC) $(CFLAGS) -c stackModule.c

arrayModule.o: arrayModule.c arrayModule.h
	$(CC) $(CFLAGS) -c arrayModule.c


# ======================
#  Limpieza
# ======================

clean:
	rm -f *.o lex.yy.c y.tab.c y.tab.h $(OUT)

.PHONY: all clean
