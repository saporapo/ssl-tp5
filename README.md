# ssl-tp5

restricciones en el programa: para asegurar el correcto analisis
- las variables no pueden ser puntero, array ni void, solo nomEnum/char*/char/int/double/float
- no hay if-in-line
- no hay declaracion de lista de variables
- no hay variable const, unsigned ni extern
- no hay operaciones entre char*
- las funciones solo pueden ser void/char*/char/int/double/float
- los parametros de las funciones solo pueden ser NULL/char*/char/int/double/float
- en caso de var de lst_enums son CONSTENUM. Pueden pasarse como argumento, son tratados como int
- no se puede pasar una var nomEnum como parametro, no sera tratado como int
- no analizo funciones de orden superior (funciones que pueden recibir funciones)
- no hay enum unnamed (necesito key/nombre para agregarSimbolo y buscarSimbolo)
- no hay asignacion de int a char valida por ascii
- no se puede asignar int a var nomEnum
- en la llamada a una funcion, no se pueden pasar var nomEnums como argumento, no se tratara como int
(notese diferencia entre var nomEnum y var de lst_enum constenum)
- cuerpo de funciones void deben tener "return ;"
- no colocar parametros repetidos en funciones, hay un problema con la eliminacion de los parametros en la tabla
