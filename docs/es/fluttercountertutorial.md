# Tutorial de Contador en Flutter

![beginner](https://img.shields.io/badge/nivel-princiante-green.svg)

> En el siguiente tutorial, vamos a construir un Contador en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Para comenzar

Empezaremos creando un nuevo proyecto de Flutter

```sh
flutter create flutter_counter
```

Luego podemos continuar y reemplazar el contenido de `pubspec.yaml` con

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/pubspec.yaml ':include')

y luego instale todas nuestras dependencias

```sh
flutter packages get
```
## Estructura del Proyecto

```
├── lib
│   ├── app.dart
│   ├── counter
│   │   ├── counter.dart
│   │   ├── cubit
│   │   │   └── counter_cubit.dart
│   │   └── view
│   │       ├── counter_page.dart
│   │       └── counter_view.dart
│   ├── counter_observer.dart
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml
```

La aplicación utiliza una estructura de directorios basada en funciones. Esta estructura de proyecto nos permite escalar el proyecto al tener características independientes. En este ejemplo solo tendremos una característica (el contador en sí) pero en aplicaciones más complejas podemos tener cientos de características diferentes.

## BlocObserver

Lo primero que vamos a ver es cómo crear un `BlocObserver` que nos ayudará a observar todos los cambios de estado en la aplicación.

Vamos a crear `lib/counter_observer.dart`:

[counter_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter_observer.dart ':include')

En este caso, solo anulamos `onChange` para ver todos los cambios de estado que ocurren.

?> **Nota**: `onChange` funciona de la misma manera para las instancias de `Bloc` y `Cubit`.

## main.dart

A continuación, reemplacemos el contenido de `main.dart` con:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/main.dart ':include')

Estamos inicializando el `CounterObserver` que acabamos de crear y llamando a `runApp` con el widget `CounterApp` que veremos a continuación.

## Counter App

`CounterApp` será un `MaterialApp` y específica el `home` como `CounterPage`.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/app.dart ':include')

?> **Nota**: Estamos ampliando `MaterialApp` porque `CounterApp` _es_ un `MaterialApp`. En la mayoría de los casos, crearemos instancias de `StatelessWidget` o `StatefulWidget` y compondremos widgets en `build`, pero en este caso no hay widgets para componer, por lo que es más sencillo extender `MaterialApp`.

¡Echemos un vistazo a continuación a `CounterPage`!

## Counter Page

The `CounterPage` widget is responsible for creating a `CounterCubit` (which we will look at next) and providing it to the `CounterView`.

[counter_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_page.dart ':include')

?> **Nota**: Es importante separar o desacoplar la creación de un `Cubit` del consumo de un `Cubit` para tener un código que sea mucho más comprobable y reutilizable.

## Counter Cubit

La clase `CounterCubit` expondrá dos métodos:

- `increment`: agrega 1 al estado actual
- `decrement`: resta 1 del estado actual

El tipo de estado que gestiona el `CounterCubit` es solo un `int` y el estado inicial es `0`.

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

?> **Tip**: Use la [extensión de VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) o el [plugin de IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc) para crear nuevos codos automáticamente.

A continuación, echemos un vistazo al `CounterView` que será responsable de consumir el estado e interactuar con el `CounterCubit`.

## Counter View

El `CounterView` es responsable de representar el conteo actual y de generar dos FloatingActionButtons para incrementar/disminuir el contador.

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

Un `BlocBuilder` se usa para envolver el widget `Text` con el fin de actualizar el texto en cualquier momento que cambie el estado de `CounterCubit`. Además, `context.read<CounterCubit>()` se usa para buscar la instancia de `CounterCubit` más cercana.

?> **Nota**: Sólo el widget `Text` está envuelto en un `BlocBuilder` porque es el único widget que necesita ser reconstruido en respuesta a los cambios de estado en el `CounterCubit`. Evite envolver innecesariamente los widgets que no necesitan ser reconstruidos cuando cambia un estado.

## Barril

Agregue `counter.dart` para exportar todas las partes que se deberían de mostrar.

[counter.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/counter.dart ':include')

¡Eso es! Hemos separado la capa de presentación de la capa de lógica empresarial. El `CounterView` no tiene idea de lo que sucede cuando un usuario presiona un botón; simplemente notifica al `CounterCubit`. Además, el `CounterCubit` no tiene idea de lo que está sucediendo con el estado (el valor del contador); simplemente emite nuevos estados en respuesta a los métodos que se llaman.

Podemos ejecutar nuestra aplicación con `flutter run` y podemos verla en nuestro dispositivo o simulador/emulador.

La fuente completa (incluidas las pruebas unitarias y de widgets) de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter).
