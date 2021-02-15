# Guía de migración

?> **Sugerencia**: Consulte el [registro de versiones](https://github.com/felangel/bloc/releases) para obtener más información sobre los cambios en cada versión.

## v6.1.0

### paquete:flutter_bloc

#### ❗ccontext.bloc y context.repository están en desuso en favor de context.read y context.watch

##### Razón fundamental

`context.read`,` context.watch` y `context.select` se agregaron para alinearse con la API existente de [provider](https://pub.dev/packages/provider) que muchos desarrolladores están familiarizados y enfrentar problemas(issues) que han sido planteados por la comunidad. Para mejorar la seguridad del código y mantener la coherencia, `context.bloc` es obsoleto porque puede ser reemplazado por `context.read` o `context.watch` dependiendo de si se usa directamente dentro de `build`.

**context.watch**

`context.watch` aborda la solicitud de tener un [MultiBlocBuilder](https://github.com/felangel/bloc/issues/538) porque podemos ver varios blocs dentro de un solo `Builder` para representar la interfaz de usuario basada en múltiples estados:

```dart
Builder(
  builder: (context) {
    final stateA = context.watch<BlocA>().state;
    final stateB = context.watch<BlocB>().state;
    final stateC = context.watch<BlocC>().state;
    // return a Widget which depends on the state of BlocA, BlocB, and BlocC
  }
);
```

**context.select**

`context.select` permite a los desarrolladores renderizar/actualizar la interfaz de usuario en función de una parte de un estado de bloc y responde a la solicitud de tener un [buildWhen más simple](https://github.com/felangel/bloc/issues/1521).

```dart
final name = context.select((UserBloc bloc) => bloc.state.user.name);
```

El fragmento anterior nos permite acceder y reconstruir el widget solo cuando cambia el nombre del usuario actual.

**context.read**

Aunque parece que `context.read` es idéntico a `context.bloc`, existen algunas diferencias sutiles pero significativas. Ambos le permiten acceder a un bloc con un `BuildContext` y no dan como resultado reconstrucciones; sin embargo, `context.read` no se puede llamar directamente dentro de un método `build`. Hay dos razones principales para usar `context.bloc` dentro de `build`:

1. **Para acceder al estado bloc**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

El uso anterior es propenso a errores porque el widget `Text` no se reconstruye si cambia el estado del bloc. En este escenario, se debe usar un `BlocBuilder` o un`context.watch`.

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

o

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) => Text('$state'),
  );
}
```

!> El uso de `context.watch` en la raíz del método `build` dará como resultado la reconstrucción del widget completo cuando cambie el estado del bloc. Si no es necesario reconstruir el widget completo, use `BlocBuilder` para envolver las partes que deben reconstruirse, use un `Builder` con `context.watch` para analizar las reconstrucciones o descomponga el widget en widgets más pequeños.

2. **Para acceder al bloc para que se pueda agregar un evento**

```dart
@override
Widget build(BuildContext context) {
  final bloc = context.bloc<MyBloc>();
  return ElevatedButton(
    onPressed: () => bloc.add(MyEvent()),
    ...
  )
}
```

El uso anterior es ineficiente porque da como resultado una búsqueda de bloc en cada reconstrucción cuando el bloc solo es necesario cuando el usuario presiona el `ElevatedButton`. En este escenario, prefiera usar `context.read` para acceder al bloc directamente donde sea necesario (en este caso, en el callback `onPressed`).

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

**Resumen**

**v6.0.x**

```dart
@override
Widget build(BuildContext context) {
  final bloc = context.bloc<MyBloc>();
  return ElevatedButton(
    onPressed: () => bloc.add(MyEvent()),
    ...
  )
}
```

**v6.1.x**

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

?> Si accede a un bloc para agregar un evento, realice el acceso al bloc usando `context.read` en el callback donde sea necesario.

**v6.0.x**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

**v6.1.x**

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

?> Utilice `context.watch` cuando acceda al estado del bloc para asegurarse de que el widget se reconstruya cuando cambie el estado.

## v6.0.0

### paquete: bloc

#### ❗BBlocObserver onError toma Cubit

##### Razón fundamental

Debido a la integración de `Cubit`, `onError` ahora se comparte entre las instancias de `Bloc` y `Cubit`. Dado que `Cubit` es la base, `BlocObserver` aceptará un tipo `Cubit` en lugar de un tipo `Bloc` en la anulación `onError`.

**v5.x.x**

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}
```

**v6.0.0**


```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    super.onError(cubit, error, stackTrace);
  }
}
```

#### ❗Bloc no emite el último estado en la suscripción

##### Razón fundamental

Este cambio se realizó para alinear `Bloc` y `Cubit` con el comportamiento incorporado de `Stream` en `Dart`. Además, conformar esto el antiguo comportamiento en el context de `Cubit` condujo a muchos efectos secundarios no deseados y en general complicó las implementaciones internas de otros paquetes como `flutter_bloc` y `bloc_test` innecesariamente (requiriendo `skip (1) `, etc ...).

**v5.x.x**

```dart
final bloc = MyBloc();
bloc.listen(print);
```

Anteriormente, el fragmento anterior mostraba el estado inicial del bloc seguido de cambios de estado posteriores.

**v6.x.x**

En v6.0.0, el fragmento de código anterior no genera el estado inicial y solo genera los cambios de estado posteriores. El comportamiento anterior se puede lograr con lo siguiente:

```dart
final bloc = MyBloc();
print(bloc.state);
bloc.listen(print);
```

?> **Nota**: Este cambio solo afectará al código que depende de las suscripciones de bloc directo. Cuando use `BlocBuilder`,` BlocListener` o `BlocConsumer` no habrá ningún cambio notable en el comportamiento.

### paquete:bloc_test

#### ❗MockBloc solo requiere el tipo de estado

##### Razón fundamental

No es necesario y elimina el código adicional al mismo tiempo que hace que `MockBloc` sea compatible con` Cubit`.

**v5.x.x**

```dart
class MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
```

**v6.0.0**

```dart
class MockCounterBloc extends MockBloc<int> implements CounterBloc {}
```

#### ❗wwhenListen solo requiere el tipo de estado

##### Razón fundamental

No es necesario y elimina el código adicional al mismo tiempo que hace que `whenListen` sea compatible con` Cubit`.

**v5.x.x**

```dart
whenListen<CounterEvent,int>(bloc, Stream.fromIterable([0, 1, 2, 3]));
```

**v6.0.0**

```dart
whenListen<int>(bloc, Stream.fromIterable([0, 1, 2, 3]));
```

#### ❗bblocTest no requiere tipo de evento

##### Razón fundamental

No es necesario y elimina el código adicional al mismo tiempo que hace que `blocTest` sea compatible con `Cubit`.

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [1] when increment is called',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[1],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [1] when increment is called',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[1],
);
```

#### ❗blocTest saltar por defecto a 0

##### Razón fundamental

Dado que las instancias `bloc` y `cubit` ya no emitirán el estado más reciente para las nuevas suscripciones, ya no es necesario establecer `skip` a `1`.

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [0] when skip is 0',
  build: () async => CounterBloc(),
  skip: 0,
  expect: const <int>[0],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [] when skip is 0',
  build: () => CounterBloc(),
  skip: 0,
  expect: const <int>[],
);
```

El estado inicial de un bloc o codo se puede probar con lo siguiente:

```dart
test('initial state is correct', () {
  expect(MyBloc().state, InitialState());
});
```

#### ❗blocTest hace que la construcción sea sincrónica

##### Razón fundamental

Anteriormente, `build` se hacía `async` para que se pudieran realizar varios preparativos para poner el bloc bajo prueba en un estado específico. Ya no es necesario y también resuelve varios problemas debido a la latencia adicional entre la compilación y la suscripción internamente. En lugar de hacer una preparación asíncrona para obtener un bloc en el estado deseado, ahora podemos establecer el estado del bloc encadenando `emit` con el estado deseado.

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [2] when increment is added',
  build: () async {
    final bloc = CounterBloc();
    bloc.add(CounterEvent.increment);
    await bloc.take(2);
    return bloc;
  }
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[2],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [2] when increment is added',
  build: () => CounterBloc()..emit(1),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[2],
);
```

!> `emit` solo es visible para pruebas y nunca debe usarse fuera de las pruebas.

### paquete:flutter_bloc

#### ❗Parámetro de BlocBlocBuilder de bloc renombrado a cubit

##### Razón fundamental

Para hacer que `BlocBuilder` interopere con instancias de `bloc` y `cubit`, el parámetro `bloc` fue renombrado a `cubit` (ya que `Cubit` es la clase base).

**v5.x.x**

```dart
BlocBuilder(
  bloc: myBloc,
  builder: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocBuilder(
  cubit: myBloc,
  builder: (context, state) {...}
)
```

#### ❗Parámetro BlocListener de bloc renambrado a cubit

##### Razón fundamental

Para hacer que `BlocListener` interopere con instancias de` bloc` y `cubit`, el parámetro `bloc` fue renombrado a `cubit` (ya que `Cubit` es la clase base).

**v5.x.x**

```dart
BlocListener(
  bloc: myBloc,
  listener: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocListener(
  cubit: myBloc,
  listener: (context, state) {...}
)
```

#### ❗Parámetro BlocConsumer de bloc renombrado a cubit

##### Razón fundamental

Para hacer que `BlocConsumer` interopere con las instancias de `bloc` y `cubit`, se cambió el nombre del parámetro `bloc` a `cubit` (ya que `Cubit` es la clase base).

**v5.x.x**

```dart
BlocConsumer(
  bloc: myBloc,
  listener: (context, state) {...},
  builder: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocConsumer(
  cubit: myBloc,
  listener: (context, state) {...},
  builder: (context, state) {...}
)
```

---

## v5.0.0

## package:bloc

### ❗iinitialState ha sido removido

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
