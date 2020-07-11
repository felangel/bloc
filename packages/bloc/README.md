<p align="right">
<a href="https://flutter.dev/docs/development/packages-and-plugins/favorites"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/flutter_favorite.png" width="100" alt="build"></a>
</p>

<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://pub.dev/packages/bloc"><img src="https://img.shields.io/pub/v/bloc.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

A dart package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

This package is built to work with:

- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [angular_bloc](https://pub.dev/packages/angular_bloc)
- [bloc_test](https://pub.dev/packages/bloc_test)
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc)

## Overview

The goal of this package is to make it easy to implement the `BLoC` Design Pattern (Business Logic Component).

This design pattern helps to separate _presentation_ from _business logic_. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on writing the business logic.

### Cubit

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" width="300" alt="Cubit Architecture" />

A `Cubit` is the base for `Bloc` (in other words `Bloc` extends `Cubit`). `Cubit` is a special type of `Stream` which can be extended to manage any type of state. `Cubit` requires an initial state which will be the state before `emit` has been called. The current state of a `cubit` can be accessed via the `state` getter and the state of the `cubit` can be updated by calling `emit` with a new `state`.

#### Creating a Cubit

```dart
/// A `CounterCubit` which manages an `int` as its state.
class CounterCubit extends Cubit<int> {
  /// The initial state of the `CounterCubit` is 0.
  CounterCubit() : super(0);

  /// When increment is called, the current state
  /// of the cubit is accessed via `state` and
  /// a new `state` is emitted via `emit`.
  void increment() => emit(state + 1);
}
```

#### Using a Cubit

```dart
void main() {
  /// Create a `CounterCubit` instance.
  final cubit = CounterCubit();

  /// Access the state of the `cubit` via `state`.
  print(cubit.state); // 0

  /// Interact with the `cubit` to trigger `state` changes.
  cubit.increment();

  /// Access the new `state`.
  print(cubit.state); // 1

  /// Close the `cubit` when it is no longer needed.
  cubit.close();
}
```

#### Observing a Cubit

`onChange` can be overridden to observe state changes for a single `cubit`.

`onError` can be overridden to observe errors for a single `cubit`.

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  @override
  void onChange(Change<int> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
```

`BlocObserver` can be used to observe all `cubits`.

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onChange(Cubit cubit, Change change) {
    print(change);
    super.onChange(cubit, change);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onChange(cubit, error, stackTrace);
  }
}
```

```dart
void main() {
  Bloc.observer = MyBlocObserver();
  // Use cubits...
}
```

### Bloc

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" width="300" alt="Bloc Architecture" />

A `Bloc` is a more advanced type of `Cubit` which relies on `events` to trigger `state` changes rather than functions. `Bloc` extends `Cubit` which means it has the same public API as `Cubit`, however, rather than calling a `function` on a `Bloc` and directly emitting a new `state`, `Blocs` receive `events` and convert the incoming `events` into outgoing `states`.

#### Creating a Bloc

```dart
/// The events which `CounterBloc` will react to.
enum CounterEvent { increment }

/// A `CounterBloc` which handles converting `CounterEvent`s into `int`s.
class CounterBloc extends Bloc<CounterEvent, int> {
  /// The initial state of the `CounterBloc` is 0.
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      /// When a `CounterEvent.increment` event is added,
      /// the current `state` of the bloc is accessed via the `state` property
      /// and a new state is emitted via `yield`.
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

#### Using a Bloc

```dart
void main() {
  /// Create a `CounterBloc` instance.
  final bloc = CounterBloc();

  /// Access the state of the `bloc` via `state`.
  print(bloc.state); // 0

  /// Interact with the `bloc` to trigger `state` changes.
  bloc.add(CounterEvent.increment);

  /// Wait for next iteration of the event-loop
  /// to ensure event has been processed.
  await Future.delayed(Duration.zero);

  /// Access the new `state`.
  print(bloc.state); // 1

  /// Close the `bloc` when it is no longer needed.
  bloc.close();
}
```

#### Observing a Bloc

Since all `Blocs` are `Cubits`, `onChange` and `onError` can be overridden in a `Bloc` as well.

In addition, `Blocs` can also override `onEvent` and `onTransition`.

`onEvent` is called any time a new `event` is added to the `Bloc`.

`onTransition` is similar to `onChange`, however, it contains the `event` which triggered the state change in addition to the `currentState` and `nextState`.

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onEvent(CounterEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onChange(Change<int> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
```

`BlocObserver` can be used to observe all `blocs` as well.

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onChange(Cubit cubit, Change change) {
    print(change);
    super.onChange(cubit, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onChange(cubit, error, stackTrace);
  }
}
```

```dart
void main() {
  Bloc.observer = MyBlocObserver();
  // Use blocs...
}
```

## Dart Versions

- Dart 2: >= 2.6.0

## Examples

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - an example of how to create a `CounterBloc` in a pure Dart app.

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120" />](https://verygood.ventures)
