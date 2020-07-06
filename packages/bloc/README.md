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

This package is built to work with [flutter_bloc](https://pub.dev/packages/flutter_bloc) and [angular_bloc](https://pub.dev/packages/angular_bloc) and is built on top of [cubit](https://pub.dev/packages/cubit).

## Overview

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" width="300" alt="Bloc Architecture" />

The goal of this package is to make it easy to implement the `BLoC` Design Pattern (Business Logic Component).

This design pattern helps to separate _presentation_ from _business logic_. Following the BLoC pattern facilitates testability and reusability. This package abstracts reactive aspects of the pattern allowing developers to focus on converting events into states.

## Usage

For simplicity we can create a `CounterBloc` like:

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

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

Our `CounterBloc` converts `CounterEvents` to integers.

As a result, we need to define our `CounterEvent` like:

```dart
enum CounterEvent { increment, decrement }
```

Then we can add events to our bloc like so:

```dart
void main() {
  final counterBloc = CounterBloc();

  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.increment);
  counterBloc.add(CounterEvent.increment);

  counterBloc.add(CounterEvent.decrement);
  counterBloc.add(CounterEvent.decrement);
  counterBloc.add(CounterEvent.decrement);
}
```

As our app grows and relies on multiple `Blocs`, it becomes useful to see the `Transitions` for all `Blocs`. This can easily be achieved by implementing a `BlocObserver`.

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }
}
```

Now that we have our `SimpleBlocObserver`, we just need to tell `Bloc` to use our observer in our `main.dart`.

```dart
void main() {
  Bloc.observer = SimpleBlocObserver();

  final counterBloc = CounterBloc();

  counterBloc.add(CounterEvent.increment); // { currentState: 0, event: CounterEvent.increment, nextState: 1 }
  counterBloc.add(CounterEvent.increment); // { currentState: 1, event: CounterEvent.increment, nextState: 2 }
  counterBloc.add(CounterEvent.increment); // { currentState: 2, event: CounterEvent.increment, nextState: 3 }

  counterBloc.add(CounterEvent.decrement); // { currentState: 3, event: CounterEvent.decrement, nextState: 2 }
  counterBloc.add(CounterEvent.decrement); // { currentState: 2, event: CounterEvent.decrement, nextState: 1 }
  counterBloc.add(CounterEvent.decrement); // { currentState: 1, event: CounterEvent.decrement, nextState: 0 }
}
```

At this point, all `Bloc` `Transitions` will be reported to the `SimpleBlocObserver` and we can see them in the console after running our app.

If we want to be able to handle any incoming `Events` that are added to a `Bloc` we can also override `onEvent` in our `SimpleBlocObserver`.

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }
}
```

If we want to be able to handle any `Exceptions` that might be thrown in a `Bloc` we can also override `onError` in our `SimpleBlocObserver`.

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
```

At this point, all `Bloc` `Exceptions` will also be reported to the `SimpleBlocObserver` and we can see them in the console.

## Glossary

**Events** are the input to a Bloc. They are commonly UI events such as button presses. `Events` are `added` to the Bloc and then converted to `States`.

**States** are the output of a Bloc. Presentation components can listen to the stream of states and redraw portions of themselves based on the given state (see `BlocBuilder` for more details).

**Transitions** occur when an `Event` is `added` after `mapEventToState` has been called but before the `Bloc`'s state has been updated. A `Transition` consists of the currentState, the event which was added, and the nextState.

**BlocObserver** An interface for observing the behavior of a `Bloc`. Can be used to intercept all `Bloc` events, transitions, and errors. **It is a great way to handle logging/analytics as well as error handling universally**.

## Bloc Interface

**mapEventToState** is a method that **must be implemented** when a class extends `Bloc`. The function takes the incoming event as an argument. `mapEventToState` is called whenever an event is `added`. `mapEventToState` must convert that event into a new state and return the new state in the form of a `Stream`.

**add** is a method that takes an `event` and triggers `mapEventToState`. If `close` has already been called, any subsequent calls to `add` will be ignored and will not result in any subsequent state changes.

**addError** is a method that notifies the `bloc` of an `error` and triggers `onError`.

**transformEvents** is a method that transforms the `Stream<Event>` along with a transition function, `transitionFn`, into a `Stream<Transition>`. Events that should be processed by `mapEventToState` need to be passed to `transitionFn`. **By default `asyncExpand` is used to ensure all events are processed in the order in which they are received**. You can override `transformEvents` for advanced usage in order to manipulate the frequency and specificity with which `mapEventToState` is called as well as which events are processed.

**transformTransitions** is a method that transforms the `Stream<Transition>` into a new `Stream<Transition>`. By default `transformTransitions` returns the incoming `Stream<Transition>`. You can override `transformTransitions` for advanced usage in order to manipulate the frequency and specificity at which `transitions` (state changes) occur.

**onEvent** is a method that can be overridden to handle whenever an `Event` is added. **It is a great place to add bloc-specific logging/analytics**.

**onTransition** is a method that can be overridden to handle whenever a `Transition` occurs. A `Transition` occurs when a new `Event` is added and `mapEventToState` is called. `onTransition` is called before a `Bloc`'s state has been updated. **It is a great place to add bloc-specific logging/analytics**.

**onError** is a method that can be overridden to handle whenever an `Exception` is thrown. By default all exceptions will be ignored and `Bloc` functionality will be unaffected. **It is a great place to add bloc-specific error handling**.

**close** is a method that closes the `event` and `state` streams. `close` should be called when a `Bloc` is no longer needed. Once `close` is called, `events` that are `added` will not be processed. In addition, if `close` is called while `events` are still being processed the `bloc` will finish processing the pending `events`.

## BlocObserver Interface

**onEvent** is a method that can be overridden to handle whenever an `Event` is added to **any** `Bloc`. **It is a great place to add universal logging/analytics**.

**onTransition** is a method that can be overridden to handle whenever a `Transition` occurs in **any** `Bloc`. **It is a great place to add universal logging/analytics**.

**onError** is a method that can be overriden to handle whenever an `Exception` is thrown from **any** `Bloc`. **It is a great place to add universal error handling**.

## Dart Versions

- Dart 2: >= 2.6.0

## Examples

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - an example of how to create a `CounterBloc` in a pure Dart app.

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120" />](https://verygood.ventures)
