# Core Concepts (package:flutter_bloc)

?> Please make sure to carefully read the following sections before working with [package:flutter_bloc](https://pub.dev/packages/flutter_bloc).

?> **Note**: All widgets exported by the `flutter_bloc` package integrate with both `Cubit` and `Bloc` instances.

## Bloc Widgets

### BlocBuilder

**BlocBuilder** is a Flutter widget which requires a `Bloc` and a `builder` function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed. The `builder` function will potentially be called many times and should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that returns a widget in response to the state.

See `BlocListener` if you want to "do" anything in response to state changes such as navigation, showing a dialog, etc...

If the `bloc` parameter is omitted, `BlocBuilder` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

[bloc_builder.dart](_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Only specify the bloc if you wish to provide a bloc that will be scoped to a single widget and isn't accessible via a parent `BlocProvider` and the current `BuildContext`.

[bloc_builder.dart](_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

For fine-grained control over when the `builder` function is called an optional `buildWhen` can be provided. `buildWhen` takes the previous bloc state and current bloc state and returns a boolean. If `buildWhen` returns true, `builder` will be called with `state` and the widget will rebuild. If `buildWhen` returns false, `builder` will not be called with `state` and no rebuild will occur.

[bloc_builder.dart](_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocSelector

**BlocSelector** is a Flutter widget which is analogous to `BlocBuilder` but allows developers to filter updates by selecting a new value based on the current bloc state. Unnecessary builds are prevented if the selected value does not change. The selected value must be immutable in order for `BlocSelector` to accurately determine whether `builder` should be called again.

If the `bloc` parameter is omitted, `BlocSelector` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

[bloc_selector.dart](_snippets/flutter_bloc_core_concepts/bloc_selector.dart.md ':include')

### BlocProvider

**BlocProvider** is a Flutter widget which provides a bloc to its children via `BlocProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

In most cases, `BlocProvider` should be used to create new blocs which will be made available to the rest of the subtree. In this case, since `BlocProvider` is responsible for creating the bloc, it will automatically handle closing the bloc.

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

By default, `BlocProvider` will create the bloc lazily, meaning `create` will get executed when the bloc is looked up via `BlocProvider.of<BlocA>(context)`.

To override this behavior and force `create` to be run immediately, `lazy` can be set to `false`.

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/bloc_provider_lazy.dart.md ':include')

In some cases, `BlocProvider` can be used to provide an existing bloc to a new portion of the widget tree. This will be most commonly used when an existing bloc needs to be made available to a new route. In this case, `BlocProvider` will not automatically close the bloc since it did not create it.

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

then from either `ChildA`, or `ScreenA` we can retrieve `BlocA` with:

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider** is a Flutter widget that merges multiple `BlocProvider` widgets into one.
`MultiBlocProvider` improves the readability and eliminates the need to nest multiple `BlocProviders`.
By using `MultiBlocProvider` we can go from:

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

to:

[multi_bloc_provider.dart](_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** is a Flutter widget which takes a `BlocWidgetListener` and an optional `Bloc` and invokes the `listener` in response to state changes in the bloc. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each state change (**NOT** including the initial state) unlike `builder` in `BlocBuilder` and is a `void` function.

If the `bloc` parameter is omitted, `BlocListener` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

[bloc_listener.dart](_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Only specify the bloc if you wish to provide a bloc that is otherwise not accessible via `BlocProvider` and the current `BuildContext`.

[bloc_listener.dart](_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

For fine-grained control over when the `listener` function is called an optional `listenWhen` can be provided. `listenWhen` takes the previous bloc state and current bloc state and returns a boolean. If `listenWhen` returns true, `listener` will be called with `state`. If `listenWhen` returns false, `listener` will not be called with `state`.

[bloc_listener.dart](_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener** is a Flutter widget that merges multiple `BlocListener` widgets into one.
`MultiBlocListener` improves the readability and eliminates the need to nest multiple `BlocListeners`.
By using `MultiBlocListener` we can go from:

[bloc_listener.dart](_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

to:

[multi_bloc_listener.dart](_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer** exposes a `builder` and `listener` in order to react to new states. `BlocConsumer` is analogous to a nested `BlocListener` and `BlocBuilder` but reduces the amount of boilerplate needed. `BlocConsumer` should only be used when it is necessary to both rebuild UI and execute other reactions to state changes in the `bloc`. `BlocConsumer` takes a required `BlocWidgetBuilder` and `BlocWidgetListener` and an optional `bloc`, `BlocBuilderCondition`, and `BlocListenerCondition`.

If the `bloc` parameter is omitted, `BlocConsumer` will automatically perform a lookup using
`BlocProvider` and the current `BuildContext`.

[bloc_consumer.dart](_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

An optional `listenWhen` and `buildWhen` can be implemented for more granular control over when `listener` and `builder` are called. The `listenWhen` and `buildWhen` will be invoked on each `bloc` `state` change. They each take the previous `state` and current `state` and must return a `bool` which determines whether or not the `builder` and/or `listener` function will be invoked. The previous `state` will be initialized to the `state` of the `bloc` when the `BlocConsumer` is initialized. `listenWhen` and `buildWhen` are optional and if they aren't implemented, they will default to `true`.

[bloc_consumer.dart](_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** is a Flutter widget which provides a repository to its children via `RepositoryProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a repository can be provided to multiple widgets within a subtree. `BlocProvider` should be used to provide blocs whereas `RepositoryProvider` should only be used for repositories.

[repository_provider.dart](_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

then from `ChildA` we can retrieve the `Repository` instance with:

[repository_provider.dart](_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider** is a Flutter widget that merges multiple `RepositoryProvider` widgets into one.
`MultiRepositoryProvider` improves the readability and eliminates the need to nest multiple `RepositoryProvider`.
By using `MultiRepositoryProvider` we can go from:

[repository_provider.dart](_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

to:

[multi_repository_provider.dart](_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Usage

Lets take a look at how to use `BlocProvider` to provide a `CounterBloc` to a `CounterPage` and react to state changes with `BlocBuilder`.


### counter_bloc.dart

[counter_bloc.dart](_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### main.dart

[main.dart](_snippets/flutter_bloc_core_concepts/counter_main.dart.md ':include')

### counter_page.dart

[counter_page.dart](_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` widget knows nothing about what happens when a user taps the buttons. The widget simply tells the `CounterBloc` that the user has pressed either the increment or decrement button.

## RepositoryProvider Usage

We are going to take a look at how to use `RepositoryProvider` within the context of the [`flutter_weather`][flutter_weather_link] example.

### weather_repository.dart

[weather_repository.dart](_snippets/flutter_bloc_core_concepts/weather_repository.dart.md ':include')

Since the app has an explicit dependency on the `WeatherRepository` we inject an instance via constructor. This allows us to inject different instances of `WeatherRepository` based on the build flavor or environment.

### main.dart

[main.dart](_snippets/flutter_bloc_core_concepts/main.dart.md ':include')

Since we only have one repository in our app, we will inject it into our widget tree via `RepositoryProvider.value`. If you have more than one repository, you can use `MultiRepositoryProvider` to provide multiple repository instances to the subtree.

### app.dart

[app.dart](_snippets/flutter_bloc_core_concepts/app.dart.md ':include')

 In most cases, the root app widget will expose one or more repositories to the subtree via `RepositoryProvider`.

### weather_page.dart

[weather_page.dart](_snippets/flutter_bloc_core_concepts/weather_page.dart.md ':include')

Now when instantiating a bloc, we can access the instance of a repository via `context.read` and inject the repository into the bloc via constructor.

[flutter_weather_link]: https://github.com/felangel/bloc/blob/master/examples/flutter_weather

## Extension Methods

> [Extension methods](https://dart.dev/guides/language/extension-methods), introduced in Dart 2.7, are a way to add functionality to existing libraries. In this section, we'll take a look at extension methods included in `package:flutter_bloc` and how they can be used.

`flutter_bloc` has a dependency on [package:provider](https://pub.dev/packages/provider) which simplifies the use of [`InheritedWidget`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html).

Internally, `package:flutter_bloc` uses `package:provider` to implement: `BlocProvider`, `MultiBlocProvider`, `RepositoryProvider` and `MultiRepositoryProvider` widgets. `package:flutter_bloc` exports the `ReadContext`, `WatchContext` and `SelectContext`, extensions from `package:provider`.

?> Learn more about [package:provider](https://pub.dev/packages/provider).

### context.read

`context.read<T>()` looks up the closest ancestor instance of type `T` and is functionally equivalent to `BlocProvider.of<T>(context)`. `context.read` is most commonly used for retrieving a bloc instance in order to add an event within `onPressed` callbacks.

!> **Note**: `context.read<T>()` does not listen to `T` -- if the provided `Object` of type `T` changes, `context.read` will not trigger a widget rebuild.

#### Usage

✅ **DO** use `context.read` to add events in callbacks.

```dart
onPressed() {
  context.read<CounterBloc>().add(CounterIncrementPressed()),
}
```

❌ **AVOID** using `context.read` to retrieve state within a `build` method.

```dart
@override
Widget build(BuildContext context) {
  final state = context.read<MyBloc>().state;
  return Text('$state');
}
```

The above usage is error prone because the `Text` widget will not be rebuilt if the state of the bloc changes.

!> Use `BlocBuilder` or `context.watch` instead in order to rebuild in response to state changes.

### context.watch

Like `context.read<T>()`, `context.watch<T>()` provides the closest ancestor instance of type `T`, however it also listens to changes on the instance. It is functionally equivalent to `BlocProvider.of<T>(context, listen: true)`.

If the provided `Object` of type `T` changes, `context.watch` will trigger a rebuild.

!> `context.watch` is only accessible within the `build` method of a `StatelessWidget` or `State` class.

#### Usage

✅ **DO** use `BlocBuilder` instead of `context.watch` to explicitly scope rebuilds.

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: BlocBuilder<MyBloc, MyState>(
        builder: (context, state) {
          // Whenever the state changes, only the Text is rebuilt.
          return Text(state.value);
        },
      ),
    ),
  );
}
```

Alternatively, use a `Builder` to scope rebuilds.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          // Whenever the state changes, only the Text is rebuilt.
          final state = context.watch<MyBloc>().state;
          return Text(state.value);
        },
      ),
    ),
  );
}
```

✅ **DO** use `Builder` and `context.watch` as `MultiBlocBuilder`.

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

❌ **AVOID** using `context.watch` when the parent widget in the `build` method doesn't depend on the state.

```dart
@override
Widget build(BuildContext context) {
  // Whenever the state changes, the MaterialApp is rebuilt
  // even though it is only used in the Text widget.
  final state = context.watch<MyBloc>().state;
  return MaterialApp(
    home: Scaffold(
      body: Text(state.value),
    ),
  );
}
```

!> Using `context.watch` at the root of the `build` method will result in the entire widget being rebuilt when the bloc state changes.

### context.select

Just like `context.watch<T>()`, `context.select<T, R>(R function(T value))` provides the closest ancestor instance of type `T` and listens to changes on `T`. Unlike `context.watch`, `context.select` allows you listen for changes in a smaller part of a state.

```dart
Widget build(BuildContext context) {
  final name = context.select((ProfileBloc bloc) => bloc.state.name);
  return Text(name);
}
```

The above will only rebuild the widget when the property `name` of the `ProfileBloc`'s state changes.

#### Usage

✅ **DO** use `BlocSelector` instead of `context.select` to explicitly scope rebuilds.

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: BlocSelector<ProfileBloc, ProfileState, String>(
        selector: (state) => state.name,
        builder: (context, name) {
          // Whenever the state.name changes, only the Text is rebuilt.
          return Text(name);
        },
      ),
    ),
  );
}
```

Alternatively, use a `Builder` to scope rebuilds.

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          // Whenever state.name changes, only the Text is rebuilt.
          final name = context.select((ProfileBloc bloc) => bloc.state.name);
          return Text(name);
        },
      ),
    ),
  );
}
```

❌ **AVOID** using `context.select` when the parent widget in a build method doesn't depend on the state.

```dart
@override
Widget build(BuildContext context) {
  // Whenever the state.value changes, the MaterialApp is rebuilt
  // even though it is only used in the Text widget.
  final name = context.select((ProfileBloc bloc) => bloc.state.name);
  return MaterialApp(
    home: Scaffold(
      body: Text(name),
    ),
  );
}
```

!> Using `context.select` at the root of the `build` method will result in the entire widget being rebuilt when the selection changes.
