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

void imprimirMensaje() {
    mensaje = "nuevo mensaje";
    return;
}



int main() {

    int z = sumar(x, 20);

    if (z > 10) {
        int aux = 5;
        aux++;
    } else {
        z = 0;
    }

    imprimirMensaje();

    sumar(x, 3);

    while (x < 20) {
        ++x;
    }

    for (int i = 0; i < 3; i++) {
        y = y + 0.5;
    }

    return 0;
}
