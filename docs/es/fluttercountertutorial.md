# Flutter: Tutorial de contador

![beginner](https://img.shields.io/badge/nivel-principiante-green)

> En el siguiente tutorial, vamos a construir un Contador en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

```bash
flutter create flutter_counter
```

Luego podemos continuar y reemplazar el contenido de `pubspec.yaml` con

```yaml
name: flutter_counter
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  meta: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

y luego instalar todas nuestras dependencias

```bash
flutter packages get
```

Nuestra aplicación de contador solo tendrá dos botones para aumentar / disminuir el valor del contador y un `Text` widget para mostrar el valor actual. Empecemos a diseñar los `CounterEvents`.

## CounterEvent

```dart
enum CounterEvent { increment, decrement }
```

## Estados del Contador

¡Dado que el estado de nuestro contador puede ser representado por un número entero, no necesitamos crear una clase personalizada!

## CounterBloc

```dart
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

?> **Nota**: Solo por la declaración de clase podemos decir que nuestro `CounterBloc` tomará `CounterEvents` como enteros de entrada y salida.

## App Contador

Ahora que tenemos nuestro `CounterBloc` totalmente implementado, podemos comenzar a crear nuestra aplicación Flutter.

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

?> **Nota**: Estamos utilizando el widget `BlocProvider` de `flutter_bloc` para que la instancia de `CounterBloc` esté disponible para todo el subárbol (`CounterPage`). `BlocProvider` también se encarga de cerrar el `CounterBloc` automáticamente, por lo que no necesitamos usar un `StatefulWidget`.

## CounterPage

Finalmente, todo lo que queda es construir nuestra página de contador.

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

?> **Nota**: Podemos acceder a la instancia de `CounterBloc` usando` BlocProvider.of <CounterBloc>(context)` porque envolvimos nuestra `CounterPage` en un `BlocProvider`.

?> **Nota**: Estamos utilizando el widget `BlocBuilder` de` flutter_bloc` para reconstruir nuestra IU en respuesta a los cambios de estado (cambios en el valor del contador).

?> **Nota**: `BlocBuilder` toma un parámetro opcional `bloc` pero podemos especificar el tipo de bloc y el tipo de estado y `BlocBuilder` encontrará el bloc automáticamente, por lo que no necesitamos usar explícitamente `BlocProvider.of <CounterBloc> (context)`.

!> Solo especifique el bloc en `BlocBuilder` si desea proporcionar un bloc que se abarcará a un solo widget y no es accesible a través de un `BlocProvider` principal y el `BuildContext` actual.

¡Eso es! Hemos separado nuestra capa de presentación de nuestra capa de lógica de negocios. Nuestra `CounterPage` no tiene idea de lo que sucede cuando un usuario presiona un botón; solo agrega un evento para notificar al `CounterBloc`. Además, nuestro `CounterBloc` no tiene idea de lo que está sucediendo con el estado (valor del contador); simplemente convierte los `CounterEvents` en enteros.

Podemos ejecutar nuestra aplicación con `flutter run` y podemos verla en su dispositivo o simulador / emulador.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
