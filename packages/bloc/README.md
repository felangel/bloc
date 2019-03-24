<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="60" alt="Bloc Package" />

[![Pub](https://img.shields.io/pub/v/bloc.svg)](https://pub.dartlang.org/packages/bloc)
[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Flutter.io](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#bloc)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)
[![Gitter](https://img.shields.io/badge/gitter-chat-hotpink.svg)](https://gitter.im/bloc_package/Lobby)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A dart package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

This package is built to work with [flutter_bloc](https://pub.dartlang.org/packages/flutter_bloc) and [angular_bloc](https://pub.dartlang.org/packages/angular_bloc).

## Overview

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

The goal of this package is to make it easy to implement the `BLoC` Design Pattern (Business Logic Component).

This design pattern helps to separate _presentation_ from _business logic_. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on converting events into states.

## Glossary

**Events** are the input to a Bloc. They are commonly UI events such as button presses. `Events` are `dispatched` and then converted to `States`.

**States** are the output of a Bloc. Presentation components can listen to the stream of states and redraw portions of themselves based on the given state (see `BlocBuilder` for more details).

**Transitions** occur when an `Event` is `dispatched` after `mapEventToState` has been called but before the `Bloc`'s state has been updated. A `Transition` consists of the currentState, the event which was dispatched, and the nextState.

**BlocSupervisor** oversees `Bloc`s and delegates to `BlocDelegate`.

**BlocDelegate** handles events from all `Bloc`s which are delegated by the `BlocSupervisor`. Can be used to intercept all `Bloc` `Transition`s and all `Bloc` errors. **It is a great way to handle logging/analytics as well as error handling universally**.

## Bloc Interface

**initialState** is the state before any events have been processed (before `mapEventToState` has ever been called). `initialState` **must be implemented**.

**mapEventToState** is a method that **must be implemented** when a class extends `Bloc`. The function takes the incoming event as an argument. `mapEventToState` is called whenever an event is `dispatched` by the presentation layer. `mapEventToState` must convert that event into a new state and return the new state in the form of a `Stream` which is consumed by the presentation layer.

**dispatch** is a method that takes an `event` and triggers `mapEventToState`. `dispatch` may be called from the presentation layer or from within the Bloc (see examples) and notifies the Bloc of a new `event`.

**transform** is a method that can be overridden to transform the `Stream<Event>` before `mapEventToState` is called. This allows for operations like `distinct()` and `debounce()` to be used.

**onTransition** is a method that can be overridden to handle whenever a `Transition` occurs. A `Transition` occurs when a new `Event` is dispatched and `mapEventToState` is called. `onTransition` is called before a `Bloc`'s state has been updated. **It is a great place to add bloc-specific logging/analytics**.

**onError** is a method that can be overridden to handle whenever an `Exception` is thrown. By default all exceptions will be ignored and `Bloc` functionality will be unaffected. **It is a great place to add bloc-specific error handling**.

## BlocDelegate Interface

**onTransition** is a method that can be overridden to handle whenever a `Transition` occurs in **any** `Bloc`. **It is a great place to add universal logging/analytics**.

**onError** is a method that can be overriden to handle whenever an `Exception` is thrown from **any** `Bloc`. **It is a great place to add universal error handling**.

## Usage

For simplicity we can create a `CounterBloc` like:

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

Our `CounterBloc` converts `CounterEvents` to integers.

As a result, we need to define our `CounterEvent` like:

```dart
enum CounterEvent { increment, decrement }
```

Then we can dispatch events to our bloc like so:

```dart
void main() {
  final counterBloc = CounterBloc();

  counterBloc.dispatch(CounterEvent.increment);
  counterBloc.dispatch(CounterEvent.increment);
  counterBloc.dispatch(CounterEvent.increment);

  counterBloc.dispatch(CounterEvent.decrement);
  counterBloc.dispatch(CounterEvent.decrement);
  counterBloc.dispatch(CounterEvent.decrement);
}
```

As our app grows and relies on multiple `Blocs`, it becomes useful to see the `Transitions` for all `Blocs`. This can easily be achieved by implementing a `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
  }
}
```

Now that we have our `SimpleBlocDelegate`, we just need to tell the `BlocSupervisor` to use our delegate in our `main.dart`.

```dart
void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();

  final counterBloc = CounterBloc();

  counterBloc.dispatch(CounterEvent.increment); // { currentState: 0, event: CounterEvent.increment, nextState: 1 }
  counterBloc.dispatch(CounterEvent.increment); // { currentState: 1, event: CounterEvent.increment, nextState: 2 }
  counterBloc.dispatch(CounterEvent.increment); // { currentState: 2, event: CounterEvent.increment, nextState: 3 }

  counterBloc.dispatch(CounterEvent.decrement); // { currentState: 3, event: CounterEvent.decrement, nextState: 2 }
  counterBloc.dispatch(CounterEvent.decrement); // { currentState: 2, event: CounterEvent.decrement, nextState: 1 }
  counterBloc.dispatch(CounterEvent.decrement); // { currentState: 1, event: CounterEvent.decrement, nextState: 0 }
}
```

At this point, all `Bloc` `Transitions` will be reported to the `SimpleBlocDelegate` and we can see them in the console after running our app.

If we want to be able to handle any `Exceptions` that might be thrown in `mapEventToState` we can also override `onError` in our `SimpleBlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    print('$error, $stacktrace');
  }
}
```

At this point, all `Bloc` exceptions will also be reported to the `SimpleBlocDelegate` and we can see them in the console.

## Dart Versions

- Dart 2: >= 2.0.0

## Examples

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - an example of how to create a `CounterBloc` in a pure Dart app.

### Maintainers

- [Felix Angelov](https://github.com/felangel)
