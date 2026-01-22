enum Color {
    ROJO = 1,
    VERDE,
    AZUL = 5
};

enum Estado {
    APAGADO,
    ENCENDIDO
} eGlobal;


int x = 10;
double y = 3.14;
char c = 'a';
char* mensaje = "hola";


Color colorActual = ROJO;
Estado estadoActual = APAGADO;


int sumar(int a, int b) {
    int r = a + b;
    return r;
}

int sum1 = sumar(x, 20);
sumar(x, 3);

void imprimirMensaje() {
    mensaje = "nuevo mensaje";
    return;
}

int sum2 = sumar(x, 20);
sumar(x, 3);
imprimirMensaje();


