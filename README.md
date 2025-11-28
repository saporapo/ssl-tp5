# ssl-tp5

restricciones en el programa:
- las variables no pueden ser puntero, array ni void, solo enum/char*/char/int/double/float
- no hay if-in-line
- no hay declaracion de lista de variables
- no hay variable const, unsigned ni extern
- las funciones solo pueden ser void/char*/char/int/double/float
- los parametros de las funciones solo pueden ser NULL/char*/char/int/double/float
- no analizo funciones de orden superior (funciones que pueden recibir funciones)
- no hay enum unnamed
- no hay asignacion de int a char valida por ascii
- no hay control de que en lista_enumeradores hayan enumeradores que se llamen como otros simbolos existentes (arreglo proximo)
- en la llamada a una funcion, no se pueden pasar enums como int
- cuerpo de funciones void deben tener "return ;"