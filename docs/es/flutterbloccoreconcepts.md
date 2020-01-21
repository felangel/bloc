# Conceptos básicos de Flutter bloc

?> Asegúrese de leer detenidamente y comprender las siguientes secciones antes de trabajar con [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** es un widget de Flutter que requiere una función `Bloc` y un `builder`. `BlocBuilder` maneja la construcción del widget en respuesta a nuevos estados. `BlocBuilder` es muy similar a `StreamBuilder` pero tiene una API más simple para reducir la cantidad de código repetitivo necesario. La función `builder` se llamará muchas veces y debería ser una [función pura](https://en.wikipedia.org/wiki/Pure_function) que devuelve un widget en respuesta al estado.

Consulte `BlocListener` si desea "hacer"algo en respuesta a cambios de estado como navegación, mostrar un diálogo, etc...

Si se omite el parámetro bloc, `BlocBuilder` realizará automáticamente una búsqueda utilizando `BlocProvider` y el actual `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // retorna el widget basado en el estado de BlocA
  }
)
```

Solo especifique el bloc si desea proporcionar un bloc que se abarcará a un solo widget y no es accesible a través de un `BlocProvider` principal y el `BuildContext` actual.

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // proporciona la instancia de bloc local
  builder: (context, state) {
    // retorna el widget basado en el estado de BlocA
  }
)
```

Si desea un control detallado sobre cuándo se llama a la función del generador, puede proporcionar una `condición` opcional a `BlocBuilder`. La `condición` toma el estado de bloque anterior y el estado de bloque actual y devuelve un valor booleano. Si `condición` devuelve verdadero, se llamará a `constructor` con `state` y se reconstruirá el widget. Si `condición` devuelve falso, no se llamará a` constructor` con `state` y no se producirá ninguna reconstrucción.

Si desea un control detallado sobre cuándo se llama a la función builder, puede proporcionar una `condición` opcional a `BlocBuilder`. La `condición` toma el estado de bloc anterior y el estado de bloc actual y devuelve un valor booleano. Si la `condición` devuelve verdadero, se llamará a `builder` con `state` y se reconstruirá el widget. Si la `condición` devuelve falso, no se llamará a `builder` con `state` y no se producirá ninguna reconstrucción.

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // devuelve verdadero / falso para determinar
    // si reconstruir o no el widget con estado
  },
  builder: (context, state) {
    // retorna el widget basado en el estado de BlocA
  }
)
```

### BlocProvider

**BlocProvider** es un widget de Flutter que proporciona un bloc a sus hijos a través de `BlocProvider.of <T> (context)`. Se utiliza como un widget de inyección de dependencia (DI en inglés) para que se pueda proporcionar una sola instancia de un bloc a múltiples widgets dentro de un subárbol.

En la mayoría de los casos, `BlocProvider` debe usarse para crear nuevos `blocs` que estarán disponibles para el resto del subárbol. En este caso, dado que `BlocProvider` es responsable de crear el bloc, se encargará automáticamente de cerrar el bloc.

```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

En la mayoría de los casos, `BlocProvider` debe usarse para crear nuevos `blocs` que estarán disponibles para el resto del subárbol. En este caso, dado que `BlocProvider` es responsable de crear el bloc, se encargará automáticamente de cerrar el bloc.

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

entonces desde `ChildA` o `ScreenA` podemos recuperar `BlocA` con:

```dart
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider

**MultiBlocProvider** es un widget de Flutter que combina múltiples widgets de `BlocProvider` en uno.
`MultiBlocProvider` mejora la legibilidad y elimina la necesidad de anidar múltiples `BlocProviders`.
Al usar `MultiBlocProvider` podemos pasar de:

```dart
BlocProvider<BlocA>(
  create: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

por:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

### BlocListener

**BlocListener** es un widget de Flutter que toma un `BlocWidgetListener` y un `Bloc` opcional e invoca al `listener` en respuesta a los cambios de estado en el bloc. Debe usarse para la funcionalidad que debe ocurrir una vez por cada cambio de estado, como la navegación, mostrar una `SnackBar`, mostrar un `Dialog`, etc.

`listener` solo se llama una vez por cada cambio de estado ( **SIN** incluir `initialState`) a diferencia de `builder` en` BlocBuilder` y es una función `void`.

Si se omite el parámetro bloc, `BlocListener` realizará automáticamente una búsqueda usando `BlocProvider` y el actual `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // haga las cosas aquí según el estado de BlocA
  },
  child: Container(),
)
```

Solo especifique el bloc si desea proporcionar un bloc que de otro modo no sería accesible a través de `BlocProvider` y el` BuildContext` actual.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // haga las cosas aquí según el estado de BlocA
  }
)
```

Si desea un control detallado sobre cuándo se llama a la función listener, puede proporcionar una `condición` opcional a `BlocListener`. La `condición` toma el estado de bloque anterior y el estado de bloque actual y devuelve un valor booleano. Si `condición` devuelve verdadero, se llamará a `listener` con `state`. Si `condición` devuelve falso, `listener` no será llamado con `state`.

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // retorna verdadero / falso para determinar
    // si llamar o no al listener con state
  },
  listener: (context, state) {
    // haga las cosas aquí según el estado de BlocA
  }
  child: Container(),
)
```

### MultiBlocListener

**MultiBlocListener** es un widget de Flutter que combina múltiples widgets `BlocListener` en uno.
`MultiBlocListener` mejora la legibilidad y elimina la necesidad de anidar múltiples `BlocListeners`.
Al usar `MultiBlocListener` podemos pasar de:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

por:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

### BlocConsumer

**BlocConsumer** expone un `constructor` y un `listener` para reaccionar a nuevos estados. `BlocConsumer` es análogo a un `BlocListener` anidado y `BlocBuilder` pero reduce la cantidad de repetitivo necesaria. `BlocConsumer` solo debe usarse cuando sea necesario reconstruir la IU y ejecutar otras reacciones a los cambios de estado en el `bloque`. `BlocConsumer` toma un` BlocWidgetBuilder` y `BlocWidgetListener` requeridos y un `bloc`, `BlocBuilderCondition` y `BlocListenerCondition` opcionales.

Si se omite el parámetro `bloc`, `BlocConsumer` realizará automáticamente una búsqueda utilizando
`BlocProvider` y el actual` BuildContext`.

```dart
BlocConsumer<BlocA, BlocAState>(
  listener: (context, state) {
    // haga las cosas aquí según el estado de BlocA
  },
  builder: (context, state) {
    // retorna aquí el widget basado en el estado de BlocA
  }
)
```

Se puede implementar un `listenWhen` y `buildWhen` opcionales para un control más granular sobre cuándo se llama a `listener` y `builder`. Se invocarán `listenWhen` y `buildWhen` en cada cambio de estado `bloc`. Cada uno toma el `state` anterior y el `state` actual y debe devolver un `bool` que determina si se invocará o no la función `builder` y / o `listener`. El `state` anterior se inicializará al `state` del `bloc` cuando se inicialice el` BlocConsumer`. `listenWhen` y `buildWhen` son opcionales y, si no se implementan, pasarán por defecto a `true`.

```dart
BlocConsumer<BlocA, BlocAState>(
  listenWhen: (previous, current) {
    // retorne verdadero / falso para determinar 
    // si invocar o no al oyente con estado
  },
  listener: (context, state) {
    // hacer las cosas aquí según el estado de BlocA
  },
  buildWhen: (previous, current) {
    // retorna verdadero / falso para determinar 
    // si reconstruir o no el widget con estado
  },
  builder: (context, state) {
    //retorne el widget aquí basado en el estado de BlocA
  }
)
```

### RepositoryProvider

**RepositoryProvider** es un widget de Flutter que proporciona un repositorio a sus hijos a través de `RepositoryProvider.of <T> (context)`. Se utiliza como un widget de inyección de dependencia (DI) para que se pueda proporcionar una sola instancia de un repositorio a múltiples widgets dentro de un subárbol. `BlocProvider` debe usarse para proporcionar bloques mientras que `RepositoryProvider` solo debe usarse para repositorios.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

entonces desde `ChildA` podemos recuperar la instancia de `Repository` con:

```dart
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider** es un widget de Flutter que combina múltiples widgets `RepositoryProvider` en uno.
`MultiRepositoryProvider` mejora la legibilidad y elimina la necesidad de anidar múltiples` RepositoryProvider`.
Al usar `MultiRepositoryProvider` podemos pasar de:

```dart
RepositoryProvider<RepositoryA>(
  builder: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    builder: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

por:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      builder: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      builder: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## Uso

Veamos cómo usar `BlocBuilder` para conectar un widget `CounterPage` a un `CounterBloc`.

### counter_bloc.dart

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

### counter_page.dart

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

En este punto, hemos separado con éxito nuestra capa de presentación de nuestra capa de lógica de negocios. Observe que el widget `CounterPage` no sabe nada sobre lo que sucede cuando un usuario toca los botones. El widget simplemente le dice al `CounterBloc` que el usuario ha presionado el botón de incremento o decremento.