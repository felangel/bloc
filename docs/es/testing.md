# Pruebas

> Bloc fue diseñado para ser extremadamente fácil de probar.

Para efectos prácticos, vamos a desarrollar pruebas para la clase `CounterBloc` previamente creada en [Conceptos básicos](coreconcepts.md).

Recapitulando, la implementación de la clase `CounterBloc` se muestra a continuación:

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

Antes de comenzar a escribir nuestras pruebas, necesitaremos agregar un marco de trabajo para pruebas a nuestras dependencias.

Debemos agregar los paquetes [test](https://pub.dev/packages/test) y [bloc_test](https://pub.dev/packages/bloc_test) a nuestro archivo `pubspec.yaml`.

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```

Vamos a comenzar creando un archivo `counter_bloc_test.dart` para las pruebas de `CounterBloc` e importando el paquete `test`.

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

Lo siguiente es crear la función `main` asi como también el grupo de pruebas.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

> **Nota:** Los grupos tienen como función organizar las pruebas individuales asi como también para crear un contexto en el cual se pueda compartir una configuración inicial (`setUp`) y una función a ejecutarse al final (`tearDown`) de cada una.

Comencemos creando una instancia de nuestra clase `CounterBloc` la cual será reutilizada en nuestras pruebas.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Ahora podemos comenzar a escribir nuestras pruebas individuales.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
    });
});
```

> **Nota:** Podemos ejecutar todas nuestras pruebas con el comando `pub run test`.

En este punto, ¡deberiamos tener nuestra primera prueba exitosa! Ahora escribamos una prueba mas compleja haciendo uso del paquete [bloc_test](https://pub.dev/packages/bloc_test).


```dart
blocTest(
    'emits [0, 1] when CounterEvent.increment is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.increment),
    expect: [0, 1],
);

blocTest(
    'emits [0, -1] when CounterEvent.decrement is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.decrement),
    expect: [0, -1],
);
```

Deberíamos poder ejecutar las pruebas y observar que todas han terminado exitosamente.

Eso es todo, las pruebas deberían ser muy fáciles y deberíamos sentirnos seguros al hacer cambios y refactorizar nuestro código.

Puede consultar la aplicación [Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) para ver un ejemplo de una aplicación completamente probada.