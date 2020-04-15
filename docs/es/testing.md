# Testeo

> Bloc fue diseñado para ser extremadamente fácil de probar.

Para efectos prácticos, vamos a desarrollar pruebas para la clase `CounterBloc` previamente creada en [Conceptos básicos](coreconcepts.md).

Recapitulando, la implementación de la clase `CounterBloc` se muestra a continuación:

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Antes de comenzar a escribir nuestras pruebas, necesitaremos agregar un marco de trabajo para pruebas a nuestras dependencias.

Debemos agregar los paquetes [test](https://pub.dev/packages/test) y [bloc_test](https://pub.dev/packages/bloc_test) a nuestro archivo `pubspec.yaml`.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

Vamos a comenzar creando un archivo `counter_bloc_test.dart` para las pruebas de `CounterBloc` e importando el paquete `test`.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Lo siguiente es crear la función `main` asi como también el grupo de pruebas.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Nota:** Los grupos tienen como función organizar las pruebas individuales asi como también para crear un contexto en el cual se pueda compartir una configuración inicial (`setUp`) y una función a ejecutarse al final (`tearDown`) de cada una.

Comencemos creando una instancia de nuestra clase `CounterBloc` la cual será reutilizada en nuestras pruebas.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Ahora podemos comenzar a escribir nuestras pruebas individuales.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Nota:** Podemos ejecutar todas nuestras pruebas con el comando `pub run test`.

En este punto, ¡deberiamos tener nuestra primera prueba exitosa! Ahora escribamos una prueba mas compleja haciendo uso del paquete [bloc_test](https://pub.dev/packages/bloc_test).

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Deberíamos poder ejecutar las pruebas y observar que todas han terminado exitosamente.

Eso es todo, las pruebas deberían ser muy fáciles y deberíamos sentirnos seguros al hacer cambios y refactorizar nuestro código.

Puede consultar la aplicación [Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) para ver un ejemplo de una aplicación completamente probada.