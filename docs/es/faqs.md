# Preguntas Frecuentes

## Estado no se está actualizando

❔ **Pregunta**: Estoy produciendo un estado en mi bloc pero la interfaz de usuario no se está actualizando. ¿Qué estoy haciendo mal?

💡 **Respuesta**: Si está utilizando Equatable, asegúrese de pasar todas las propiedades al props getter.

✅ **BIEN**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // Pasa todas las propiedades a props
}
```

❌ **MAL**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [];
}
```

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => null;
}
```

Además, asegúrese de obtener una nueva instancia del estado en su bloc.

✅ **BIEN**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // siempre cree una nueva instancia del estado que va a producir
    yield state.copyWith(property: event.property);
}
```

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // siempre cree una nueva instancia del estado que va a producir
    yield MyState(data: data);
}
```

❌ **MAL**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // nunca modificar / mutar un estado
    state.property = event.property;
    // nunca hacer "yield" en la misma instancia del estado
    yield state;
}
```

## Cuando usar Equatable

❔**Pregunta**: ¿Cuándo debo usar Equatable?

💡**Respuesta**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

En el escenario anterior, si `StateA` extiende `Equatable` solo se producirá un cambio de estado (se ignorará el segundo "yield"). En general, debe usar `Equatable` si desea optimizar su código para reducir el número de reconstrucciones. No debe usar `Equatable` si desea que el mismo estado de forma consecutiva desencadene múltiples transiciones.

Además, el uso de `Equatable` hace que sea mucho más fácil probar bloc, ya que podemos esperar instancias específicas de estados de bloc en lugar de usar `Matchers` o `Predicates`.

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        MyStateA(),
        MyStateB(),
    ],
)
```

Sin `Equatable`, la prueba anterior fallaría y necesitaría reescribirse como:

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```

## Bloc vs. Redux

❔ **Pregunta**: ¿Cuál es la diferencia entre Bloc y Redux?

💡 **Respuesta**:

BLoC es un patrón de diseño que se define mediante las siguientes reglas:

1. La entrada y salida de BLoC son simples Streams y Sinks.
2. Las dependencias deben ser inyectables y agnósticas a la plataforma.
3. No se permite la ramificación de la plataforma.
4. La implementación puede ser lo que quieras siempre y cuando sigas las reglas anteriores.

Las pautas de UI son:

1. Cada componente "suficientemente complejo" tiene un BLoC correspondiente.
2. Los componentes deben enviar entradas "tal cual".
3. Los componentes deben mostrar las salidas lo más cerca posible de "tal cual".
4. Todas las ramificaciones deben basarse en salidas booleanas BLoC simples.

La Biblioteca de Bloc implementa el patrón de diseño BLoC y tiene como objetivo abstraer RxDart para simplificar la experiencia del desarrollador.

Los tres principios de Redux son:

1. Única fuente fiable
2. El estado es de solo lectura
3. Los cambios se realizan con funciones puras.

La biblioteca de bloc viola el primer principio; con el estado de bloc que se distribuye en múltiples blocs.
Además, no hay un concepto de middleware en bloc y el bloc está diseñado para hacer que los cambios de estado asíncrono sean muy fáciles, lo que le permite emitir múltiples estados para un solo evento.

## Bloc vs. Provider

❔ **Pregunta**: ¿Cuál es la diferencia entre Bloc y Provider?

💡 **Respuesta**: `provider` está diseñado para inyección de dependencia (envuelve` InheritedWidget`). Aún necesita descubrir cómo administrar su estado (a través de `ChangeNotifier`,` Bloc`, `Mobx`, etc.). La Biblioteca de Bloc utiliza internamente el "provider" para facilitar el suministro y el acceso a los bloques en todo el árbol de widgets.

## Navegación con Bloc

❔ **Pregunta**: ¿Cómo hago la navegación con Bloc?

💡 **Respuesta**: Echa un vistazo a [Navegación con Flutter](recipesflutternavigation.md)

## BlocProvider.of() Falla al encontrar bloc

❔ **Pregunta**: Cuando se usa `BlocProvider.of (context)` no puede encontrar el bloque. ¿Cómo puedo arreglar esto?

💡 **Respuesta**: No puede acceder a un bloc desde el mismo contexto en el que se proporcionó, por lo que debe asegurarse de que se llame a `BlocProvider.of ()` dentro de un elemento secundario `BuildContext`.

✅ **GOOD**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      },
    )
    ...
  }
}
```

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          final blocA = BlocProvider.of<BlocA>(context);
          ...
        },
      ),
    ),
  );
}
```

❌ **BAD**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      }
    )
  );
}
```

## Estructura del proyecto

❔ **Question**: ¿Cómo debo estructurar mi proyecto?

💡 **Answer**: Si bien realmente no hay una respuesta correcta / incorrecta a esta pregunta, algunas referencias recomendadas son

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Lo más importante es tener una estructura de proyecto **consistente** e **intencional**.