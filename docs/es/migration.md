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
