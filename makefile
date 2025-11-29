# ===========================
#       CONFIGURACIÓN
# ===========================
CC = gcc
CFLAGS = -Wall -g -I.

LEX = flex
YACC = bison

# -d → genera lexer.tab.h
# -v → genera lexer.output
YFLAGS = -d -v

# Archivos generados por Bison/Flex
PARSER_C = lexer.tab.c
PARSER_H = lexer.tab.h
LEXER_C = lex.yy.c

# Ejecutable final
TARGET = analizador

# Módulos propios y sus cabeceras
MODULES_C = arrayModule.c stackModule.c tablaSimbolos.c
MODULES_H = arrayModule.h stackModule.h tablaSimbolos.h

# Todos los .o necesarios
OBJS = $(PARSER_C:.c=.o) $(LEXER_C:.c=.o) $(MODULES_C:.c=.o)

# ===========================
#      META PRINCIPAL
# ===========================
all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# ===========================
#     BISON → parser
# ===========================
# Genera lexer.tab.c y lexer.tab.h a partir de lexer.y
$(PARSER_C) $(PARSER_H): lexer.y $(MODULES_H)
	$(YACC) $(YFLAGS) $<

# ===========================
#     FLEX → scanner
# ===========================
# Genera lex.yy.c a partir de lexer.l (depende de la cabecera generada por Bison)
$(LEXER_C): lexer.l $(PARSER_H)
	$(LEX) $<

# ===========================
#     COMPILAR .c → .o
# ===========================
# Regla genérica para compilar archivos .c a .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# ===========================
#         CLEAN 🗑️
# ===========================
clean:
	rm -f *.o $(LEXER_C) $(PARSER_C) $(PARSER_H) lexer.output $(TARGET)