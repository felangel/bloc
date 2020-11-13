# Guía de migración

?> ** Sugerencia **: Consulte el [registro de versiones] (https://github.com/felangel/bloc/releases) para obtener más información sobre los cambios en cada versión.

## v6.1.0

### paquete: flutter_bloc

#### ‚ùócontext.bloc y context.repository están en desuso en favor de context.read y context.watch

##### Justificación

`context.read`,` context.watch` y `context.select` se agregaron para alinearse con la API existente de [proveedor] (https://pub.dev/packages/provider) que muchos desarrolladores están familiarizados y deben abordar. problemas que han sido planteados por la comunidad. Para mejorar la seguridad del código y mantener la coherencia, `context.bloc` fue obsoleto porque puede ser reemplazado por` context.read` o `context.watch` dependiendo de si se usa directamente dentro de` build`.

** context.watch **

`context.watch` aborda la solicitud de tener un [MultiBlocBuilder] (https://github.com/felangel/bloc/issues/538) porque podemos ver varios bloques dentro de un solo` Builder` para representar la interfaz de usuario basada en múltiples estados:

dardo
Constructor(
  constructor: (contexto) {
    estado finalA = context.watch <BlocA> () .state;
    estado finalB = context.watch <BlocB> () .state;
    estado finalC = context.watch <BlocC> () .state;

    // devuelve un widget que depende del estado de BlocA, BlocB y BlocC
  }
);
''

** context.select **

`context.select` permite a los desarrolladores renderizar / actualizar la interfaz de usuario en función de una parte de un estado de bloque y responde a la solicitud de tener un [buildWhen] más simple (https://github.com/felangel/bloc/issues/1521).

dardo
nombre final = context.select ((UserBloc bloc) => bloc.state.user.name);
''

El fragmento anterior nos permite acceder y reconstruir el widget solo cuando cambia el nombre del usuario actual.

** context.read **

Aunque parece que "context.read" es idéntico a "context.bloc", existen algunas diferencias sutiles pero significativas. Ambos le permiten acceder a un bloque con un `BuildContext` y no dan como resultado reconstrucciones; sin embargo, `context.read` no se puede llamar directamente dentro de un método` build`. Hay dos razones principales para usar `context.bloc` dentro de` build`:

1. ** Para acceder al estado del bloque **

dardo
@anular
Compilación del widget (contexto BuildContext) {
  estado final = context.bloc <MyBloc> () .state;
  return Text ('$ estado');
}
''

El uso anterior es propenso a errores porque el widget `Text` no se reconstruirá si cambia el estado del bloque. En este escenario, se debe usar un `BlocBuilder` o un` context.watch`.

dardo
@anular
Compilación del widget (contexto BuildContext) {
  estado final = context.watch <MyBloc> () .state;
  return Text ('$ estado');
}
''

o

dardo
@anular
Compilación del widget (contexto BuildContext) {
  return BlocBuilder <MyBloc, MyState> (
    constructor: (contexto, estado) => Texto ('$ estado'),
  );
}
''

!> El uso de `context.watch` en la raíz del método` build` dará como resultado la reconstrucción del widget completo cuando cambie el estado del bloque. Si no es necesario reconstruir el widget completo, use `BlocBuilder` para envolver las partes que deben reconstruirse, use un` Builder` con `context.watch` para analizar las reconstrucciones o descomponga el widget en widgets más pequeños.

2. ** Para acceder al bloque para que se pueda agregar un evento **

dardo
@anular
Compilación del widget (contexto BuildContext) {
  bloque final = context.bloc <MyBloc> ();
  return RaisedButton (
    onPressed: () => bloc.add (MyEvent ()),
    ...
  )
}
''

El uso anterior es ineficiente porque da como resultado una búsqueda de bloque en cada reconstrucción cuando el bloque solo es necesario cuando el usuario presiona el `RaisedButton`. En este escenario, prefiera usar `context.read` para acceder al bloque directamente donde sea necesario (en este caso, en la devolución de llamada` onPressed`).

dardo
@anular
Compilación del widget (contexto BuildContext) {
  return RaisedButton (
    onPressed: () => context.read <MyBloc> () .add (MyEvent ()),
    ...
  )
}
''

**Resumen**

** v6.0.x **

dardo
@anular
Compilación del widget (contexto BuildContext) {
  bloque final = context.bloc <MyBloc> ();
  return RaisedButton (
    onPressed: () => bloc.add (MyEvent ()),
    ...
  )
}
''

** v6.1.x **

dardo
@anular
Compilación del widget (contexto BuildContext) {
  return RaisedButton (
    onPressed: () => context.read <MyBloc> () .add (MyEvent ()),
    ...
  )
}
''

?> Si accede a un bloque para agregar un evento, realice el acceso al bloque usando `context.read` en la devolución de llamada donde sea necesario.

** v6.0.x **

dardo
@anular
Compilación del widget (contexto BuildContext) {
  estado final = context.bloc <MyBloc> () .state;
  return Text ('$ estado');
}
''

** v6.1.x **

dardo
@anular
Compilación del widget (contexto BuildContext) {
  estado final = context.watch <MyBloc> () .state;
  return Text ('$ estado');
}
''

?> Utilice `context.watch` cuando acceda al estado del bloque para asegurarse de que el widget se reconstruya cuando cambie el estado.

## v6.0.0

### paquete: bloque

#### ‚ùóBlocObserver onError toma Cubit

##### Justificación

Debido a la integración de `Cubit`, ʻonError` ahora se comparte entre las instancias de` Bloc` y `Cubit`. Dado que `Cubit` es la base,` BlocObserver` aceptará un tipo `Cubit` en lugar de un tipo` Bloc` en la anulación ʻonError`.

** v5.x.x **

dardo

class MyBlocObserver extiende BlocObserver {
  @anular
  void onError (bloque de bloque, error de objeto, StackTrace stackTrace) {
    super.onError (bloque, error, stackTrace);
  }
}
''

** v6.0.0 **

dardo
class MyBlocObserver extiende BlocObserver {
  @anular
  void onError (Cubit cubit, Object error, StackTrace stackTrace) {
    super.onError (cubit, error, stackTrace);
  }
}
''

#### ‚ùóBloc no emite el último estado en la suscripción

##### Justificación

Este cambio se realizó para alinear `Bloc` y` Cubit` con el comportamiento incorporado de `Stream` en` Dart`. Además, conformar esto, el antiguo comportamiento en el contexto de `Cubit` condujo a muchos efectos secundarios no deseados y en general complicó las implementaciones internas de otros paquetes como` flutter_bloc` y `bloc_test` innecesariamente (requiriendo` skip (1) `, etc ...).

** v5.x.x **

dardo
bloque final = MyBloc ();
bloc.listen (imprimir);
''

Anteriormente, el fragmento anterior mostraba el estado inicial del bloque seguido de cambios de estado posteriores.

** v6.x.x **

En v6.0.0, el fragmento de código anterior no genera el estado inicial y solo genera los cambios de estado posteriores. El comportamiento anterior se puede lograr con lo siguiente:

dardo
bloque final = MyBloc ();
print (bloc.state);
bloc.listen (imprimir);
''

?> ** Nota **: Este cambio solo afectará al código que depende de las suscripciones de bloque directo. Cuando use `BlocBuilder`,` BlocListener` o `BlocConsumer` no habrá ningún cambio notable en el comportamiento.

### paquete: bloc_test

#### ‚ùóMockBloc solo requiere el tipo de estado

##### Justificación

No es necesario y elimina el código adicional al mismo tiempo que hace que `MockBloc` sea compatible con` Cubit`.

** v5.x.x **

dardo
clase MockCounterBloc extiende MockBloc <CounterEvent, int> implementa CounterBloc {}
''

** v6.0.0 **

dardo
clase MockCounterBloc extiende MockBloc <int> implementa CounterBloc {}
''

#### ‚ùówhenListen solo requiere el tipo de estado

##### Justificación

No es necesario y elimina el código adicional al mismo tiempo que hace que `whenListen` sea compatible con` Cubit`.

** v5.x.x **

dardo
whenListen <CounterEvent, int> (bloque, Stream.fromIterable ([0, 1, 2, 3]));
''

** v6.0.0 **

dardo
whenListen <int> (bloque, Stream.fromIterable ([0, 1, 2, 3]));
''

#### ‚ùóblocTest no requiere tipo de evento

##### Justificación

No es necesario y elimina el código adicional al mismo tiempo que hace que `blocTest` sea compatible con` Cubit`.

** v5.x.x **

dardo
blocTest <CounterBloc, CounterEvent, int> (
  'emite [1] cuando se llama al incremento',
  compilar: () async => CounterBloc (),
  act: (bloque) => bloc.add (CounterEvent.increment),
  esperar: const <int> [1],
);
''

** v6.0.0 **

dardo
blocTest <CounterBloc, int> (
  'emite [1] cuando se llama al incremento',
  compilar: () => CounterBloc (),
  act: (bloque) => bloc.add (CounterEvent.increment),
  esperar: const <int> [1],
);
''

#### ‚ùóblocTest saltar por defecto a 0

##### Justificación

Dado que las instancias `bloc` y` cubit` ya no emitirán el estado más reciente para las nuevas suscripciones, ya no era necesario establecer `skip` a` 1`.

** v5.x.x **

dardo
blocTest <CounterBloc, CounterEvent, int> (
  'emite [0] cuando skip es 0',
  compilar: () async => CounterBloc (),
  saltar: 0,
  esperar: const <int> [0],
);
''

** v6.0.0 **

dardo
blocTest <CounterBloc, int> (
  'emite [] cuando skip es 0',
  compilar: () => CounterBloc (),
  saltar: 0,
  esperar: const <int> [],
);
''

El estado inicial de un bloque o codo se puede probar con lo siguiente:

dardo
test ('el estado inicial es correcto', () {
  esperar (MyBloc (). estado, InitialState ());
});
''

#### ‚ùóblocTest hace que la construcción sea sincrónica

##### Justificación

Anteriormente, `build` se hacía` async` para que se pudieran realizar varios preparativos para poner el bloque bajo prueba en un estado específico. Ya no es necesario y también resuelve varios problemas debido a la latencia adicional entre la compilación y la suscripción internamente. En lugar de hacer una preparación asíncrona para obtener un bloque en el estado deseado, ahora podemos establecer el estado del bloque encadenando `emit` con el estado deseado.

** v5.x.x **

dardo
blocTest <CounterBloc, CounterEvent, int> (
  'emite [2] cuando se agrega un incremento',
  compilar: () async {
    bloque final = CounterBloc ();
    bloc.add (CounterEvent.increment);
    esperar bloc.take (2);
    bloque de retorno;
  }
  act: (bloque) => bloc.add (CounterEvent.increment),
  esperar: const <int> [2],
);
''

** v6.0.0 **

dardo
blocTest <CounterBloc, int> (
  'emite [2] cuando se agrega un incremento',
  build: () => CounterBloc () .. emit (1),
  act: (bloque) => bloc.add (CounterEvent.increment),
  esperar: const <int> [2],
);
''

!> `emit` solo es visible para pruebas y nunca debe usarse fuera de las pruebas.

### paquete: flutter_bloc

#### ‚ùó Parámetro de bloqueBlocBuilder renombrado a cubit

##### Justificación

Para hacer que `BlocBuilder` interopere con instancias de` bloc` y `cubit`, el parámetro` bloc` fue renombrado a `cubit` (ya que` Cubit` es la clase base).

** v5.x.x **

dardo
BlocBuilder (
  bloc: myBloc,
  constructor: (contexto, estado) {...}
)
''

** v6.0.0 **

dardo
BlocBuilder (
  codo: myBloc,
  constructor: (contexto, estado) {...}
)
''

#### ‚ùóBlocListener parámetro de bloque renam

ed a codo

##### Justificación

Para hacer que `BlocListener` interopere con instancias de` bloc` y `cubit`, el parámetro` bloc` fue renombrado a `cubit` (ya que` Cubit` es la clase base).

** v5.x.x **

dardo
BlocListener (
   bloc: myBloc,
   oyente: (contexto, estado) {...}
)
''

** v6.0.0 **

dardo
BlocListener (
   codo: myBloc,
   oyente: (contexto, estado) {...}
)
''

#### ‚ùóBlocConsumer parámetro de bloque renombrado a cubit

##### Justificación

Para hacer que `BlocConsumer` interopere con las instancias de` bloc` y `cubit`, se cambió el nombre del parámetro` bloc` a `cubit` (ya que` Cubit` es la clase base).

** v5.x.x **

dardo
BlocConsumer (
   bloc: myBloc,
   oyente: (contexto, estado) {...},
   constructor: (contexto, estado) {...}
)
''

** v6.0.0 **

dardo
BlocConsumer (
   codo: myBloc,
   oyente: (contexto, estado) {...},
   constructor: (contexto, estado) {...}
)
''

---

# Migrando a v5.0.0

> Instrucciones detalladas sobre cómo migrar a v5.0.0 de la biblioteca de bloc. Consulte el [registro de versiones](https://github.com/felangel/bloc/releases) para obtener más información sobre lo que cambió en cada versión.

## package:bloc

### initialState ha sido removido

#### Razón fundamental

Como desarrollador, tener que anular `initialState` al crear un bloc presenta dos problemas principales:

- El `initialState` del bloc puede ser dinámico y también puede ser referenciado en un momento posterior (incluso fuera del bloc). De alguna manera, esto puede verse como una filtración de información interna del bloc a la capa de la interfaz de usuario.
- Es verboso.

**v4.x.x**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  ...
}
```

**v5.0.0**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```

?> Para obtener más información, consulte [#1304](https://github.com/felangel/bloc/issues/1304)

### BlocDelegate renombrado a BlocObserver

#### Razón fundamental

El nombre `BlocDelegate` no era una descripción precisa del papel que desempeñaba la clase. `BlocDelegate` sugiere que la clase desempeña un papel activo, mientras que en realidad el papel previsto del `BlocDelegate` era que fuera un componente pasivo que simplemente observa todos los blocs en una aplicación.

!> Idealmente no debería haber funcionalidades o funciones orientadas al usuario manejadas dentro de `BlocObserver`.

**v4.x.x**

```dart
class MyBlocDelegate extends BlocDelegate {
  ...
}
```

**v5.0.0**

```dart
class MyBlocObserver extends BlocObserver {
  ...
}
```

### BlocSupervisor ha sido removido

#### Razón fundamental

`BlocSupervisor` era otro componente que los desarrolladores tenían que conocer e interactuar con el único propósito de especificar un `BlocDelegate` personalizado. Con el cambio a `BlocObserver`, sentimos que mejoró la experiencia del desarrollador al establecer el observador directamente en el bloc mismo.

?> Este cambio también nos permitió separar otros complementos de bloc como `HydratedStorage` del `BlocObserver`.

**v4.x.x**

```dart
BlocSupervisor.delegate = MyBlocDelegate();
```

**v5.0.0**

```dart
Bloc.observer = MyBlocObserver();
```

## package:flutter_bloc

### Condición de BlocBuilder renombrada a buildWhen

#### Razón fundamental

Al usar `BlocBuilder`, previamente podríamos especificar una `condition` (condición) para determinar si el `builder` (constructor) debería reconstruirse.

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

El nombre `condition` no se explica por sí mismo ni es obvio y, lo que es más importante, al interactuar con un `BlocConsumer`, la API se volvió inconsistente porque los desarrolladores pueden proporcionar dos condiciones (una para `builder` y otra para `listener` (oyente)). Como resultado, la API `BlocConsumer` expuso un `buildWhen` y `listenWhen`.

```dart
BlocConsumer<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...},
  buildWhen: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...},
)
```

Para alinear la API y proporcionar una experiencia de desarrollador más consistente, se cambió el nombre de `condition` a `buildWhen` (construirse cuando).

**v4.x.x**

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

### Condición BlocListener renombrada a listenWhen

#### Razón fundamental

Por las mismas razones descritas anteriormente, la condición `BlocListener` también fue renombrada.

**v4.x.x**

```dart
BlocListener<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocListener<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...}
)
```

## package:hydrated_bloc

### HydratedStorage y HydratedBlocStorage fueron renombrados

#### Razón fundamental

Para mejorar la reutilización del código entre [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) y [hydrated_cubit](https://pub.dev/packages/hydrated_cubit), la implementación de almacenamiento predeterminada concreta se renombró de `HydratedBlocStorage` a `HydratedStorage`. Además, se cambió el nombre de la interfaz `HydratedStorage` de `HydratedStorage` a `Storage`.

**v4.0.0**

```dart
class MyHydratedStorage implements HydratedStorage {
  ...
}
```

**v5.0.0**

```dart
class MyHydratedStorage implements Storage {
  ...
}
```

### HydratedStorage disociado de BlocDelegate

#### Razón fundamental

Como se mencionó anteriormente, `BlocDelegate` pasó a llamarse `BlocObserver` y se configuró directamente como parte del `bloc` a través de:

```dart
Bloc.observer = MyBlocObserver();
```

Se realizó el siguiente cambio a:

- Mantener consistente con la nueva API de bloc observer
- Mantener el almacenamiento limitado a solo `HydratedBloc`
- Separar el `BlocObserver` de `Storage`

**v4.0.0**

```dart
BlocSupervisor.delegate = await HydratedBlocDelegate.build();
```

**v5.0.0**

```dart
HydratedBloc.storage = await HydratedStorage.build();
```

### Inicialización simplificada

#### Razón fundamental

Anteriormente, los desarrolladores tenían que llamar manualmente a `super.initialState ?? DefaultInitialState()` para configurar sus instancias `HydratedBloc`. Esto es torpe, verboso y también incompatible con los cambios de última hora a `initialState` en `bloc`. Como resultado, en v5.0.0 la inicialización `HydratedBloc` es idéntica a la inicialización normal `Bloc`.

**v4.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  @override
  int get initialState => super.initialState ?? 0;
}
```

**v5.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```
