# Flutter: Tutorial de contador

![beginner](https://img.shields.io/badge/nivel-principiante-green)

> En el siguiente tutorial, vamos a construir un Contador en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

Luego podemos continuar y reemplazar el contenido de `pubspec.yaml` con

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

y luego instalar todas nuestras dependencias

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Nuestra aplicación de contador solo tendrá dos botones para aumentar / disminuir el valor del contador y un `Text` widget para mostrar el valor actual. Empecemos a diseñar los `CounterEvents`.

## CounterEvent

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Estados del Contador

¡Dado que el estado de nuestro contador puede ser representado por un número entero, no necesitamos crear una clase personalizada!

## CounterBloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Nota**: Solo por la declaración de clase podemos decir que nuestro `CounterBloc` tomará `CounterEvents` como enteros de entrada y salida.

## App Contador

Ahora que tenemos nuestro `CounterBloc` totalmente implementado, podemos comenzar a crear nuestra aplicación Flutter.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Nota**: Estamos utilizando el widget `BlocProvider` de `flutter_bloc` para que la instancia de `CounterBloc` esté disponible para todo el subárbol (`CounterPage`). `BlocProvider` también se encarga de cerrar el `CounterBloc` automáticamente, por lo que no necesitamos usar un `StatefulWidget`.

## CounterPage

Finalmente, todo lo que queda es construir nuestra página de contador.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Nota**: Podemos acceder a la instancia de `CounterBloc` usando` BlocProvider.of <CounterBloc>(context)` porque envolvimos nuestra `CounterPage` en un `BlocProvider`.

?> **Nota**: Estamos utilizando el widget `BlocBuilder` de` flutter_bloc` para reconstruir nuestra IU en respuesta a los cambios de estado (cambios en el valor del contador).

?> **Nota**: `BlocBuilder` toma un parámetro opcional `bloc` pero podemos especificar el tipo de bloc y el tipo de estado y `BlocBuilder` encontrará el bloc automáticamente, por lo que no necesitamos usar explícitamente `BlocProvider.of <CounterBloc> (context)`.

!> Solo especifique el bloc en `BlocBuilder` si desea proporcionar un bloc que se abarcará a un solo widget y no es accesible a través de un `BlocProvider` principal y el `BuildContext` actual.

¡Eso es! Hemos separado nuestra capa de presentación de nuestra capa de lógica de negocios. Nuestra `CounterPage` no tiene idea de lo que sucede cuando un usuario presiona un botón; solo agrega un evento para notificar al `CounterBloc`. Además, nuestro `CounterBloc` no tiene idea de lo que está sucediendo con el estado (valor del contador); simplemente convierte los `CounterEvents` en enteros.

Podemos ejecutar nuestra aplicación con `flutter run` y podemos verla en su dispositivo o simulador / emulador.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
