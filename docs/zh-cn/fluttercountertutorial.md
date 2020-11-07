# Flutter Counter Tutorial

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> In the following tutorial, we're going to build a Counter in Flutter using the Bloc library.

![demo](../assets/gifs/flutter_counter.gif)

## Setup

We'll start off by creating a brand new Flutter project

```sh
flutter create flutter_counter
```

We can then go ahead and replace the contents of `pubspec.yaml` with

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/pubspec.yaml ':include')

and then install all of our dependencies

```sh
flutter packages get
```

## BlocObserver

The first thing we're going to take a look at is how to create a `BlocObserver` which will help us observe all state changes in the application.

Let's create `lib/counter_observer.dart`:

[counter_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter_observer.dart ':include')

In this case, we're only overriding `onChange` to see all state changes that occur.

?> **Note**: `onChange` works the same way for both `Bloc` and `Cubit` instances.

## main.dart

Next, let's replace the contents of `main.dart` with:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/main.dart ':include')

We're initializing the `CounterObserver` we just created and calling `runApp` with the `CounterApp` widget which we'll look at next.

## Counter App

`CounterApp` will be a `MaterialApp` and is specifying the `home` as `CounterPage`.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/app.dart ':include')

?> **Note**: We are extending `MaterialApp` because `CounterApp` _is_ a `MaterialApp`. In most cases, we're going to be creating `StatelessWidget` or `StatefulWidget` instances and composing widgets in `build` but in this case there are no widgets to compose so it's simpler to just extend `MaterialApp`.

Let's take a look at `CounterPage` next!

## Counter Page

The `CounterPage` widget is responsible for creating a `CounterCubit` (which we will look at next) and providing it to the `CounterView`.

[counter_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_page.dart ':include')

?> **Note**: It's important to separate or decouple the creation of a `Cubit` from the consumption of a `Cubit` in order to have code that is much more testable and reusable.

## Counter Cubit

The `CounterCubit` class will expose two methods:

- `increment`: adds 1 to the current state
- `decrement`: subtracts 1 from the current state

The type of state the `CounterCubit` is managing is just an `int` and the initial state is `0`.

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

?> **Tip**: Use the [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) to create new cubits automatically.

Next, let's take a look at the `CounterView` which will be responsible for consuming the state and interacting with the `CounterCubit`.

## Counter View

The `CounterView` is responsible for rendering the current count and rendering two FloatingActionButtons to increment/decrement the counter.

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

A `BlocBuilder` is used to wrap the `Text` widget in order to update the text any time the `CounterCubit` state changes. In addition, `context.read<CounterCubit>()` is used to look-up the closest `CounterCubit` instance.

?> **Note**: Only the `Text` widget is wrapped in a `BlocBuilder` because that is the only widget that needs to be rebuilt in response to state changes in the `CounterCubit`. Avoid unnecessarily wrapping widgets that don't need to be rebuilt when a state changes.

That's it! We've separated the presentation layer from the business logic layer. The `CounterView` has no idea what happens when a user presses a button; it just notifies the `CounterCubit`. Furthermore, the `CounterCubit` has no idea what is happening with the state (counter value); it's simply emitting new states in response to the methods being called.

We can run our app with `flutter run` and can view it on our device or simulator/emulator.

The full source (including unit and widget tests) for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter).
