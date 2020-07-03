# Flutter Bloc Core Concepts

?> Please make sure to carefully read and understand the following sections before working with [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** is a Flutter widget which requires a `Bloc` and a `builder` function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed. The `builder` function will potentially be called many times and should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that returns a widget in response to the state.

See `BlocListener` if you want to "do" anything in response to state changes such as navigation, showing a dialog, etc...

If the bloc parameter is omitted, `BlocBuilder` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

[bloc_builder.dart](_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Only specify the bloc if you wish to provide a bloc that will be scoped to a single widget and isn't accessible via a parent `BlocProvider` and the current `BuildContext`.

[bloc_builder.dart](_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

For fine-grained control over when the `builder` function is called an optional `buildWhen` can be provided. `buildWhen` takes the previous bloc state and current bloc state and returns a boolean. If `buildWhen` returns true, `builder` will be called with `state` and the widget will rebuild. If `buildWhen` returns false, `builder` will not be called with `state` and no rebuild will occur.

[bloc_builder.dart](_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** is a Flutter widget which provides a bloc to its children via `BlocProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

In most cases, `BlocProvider` should be used to create new `blocs` which will be made available to the rest of the subtree. In this case, since `BlocProvider` is responsible for creating the bloc, it will automatically handle closing the bloc.

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

By default, BlocProvider will create the bloc lazily, meaning `create` will get executed when the bloc is looked up via `BlocProvider.of<BlocA>(context)`.

To override this behavior and force `create` to be run immediately, `lazy` can be set to `false`.

[bloc_provider.dart](_snippets/flutter_bloc_core_concepts/bloc_provider_lazy.dart.md ':include')

In some cases, `BlocProvider` can be used to provide an existing bloc to a new portion of the widget tree. This will be most commonly used when an existing `bloc` needs to be made available to a new route. In this case, `BlocProvider` will not automatically close the bloc since it did not create it.

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

`listener` is only called once for each state change (**NOT** including `initialState`) unlike `builder` in `BlocBuilder` and is a `void` function.

If the bloc parameter is omitted, `BlocListener` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

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

Lets take a look at how to use `BlocBuilder` to hook up a `CounterPage` widget to a `CounterBloc`.

### counter_bloc.dart

[counter_bloc.dart](_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` widget knows nothing about what happens when a user taps the buttons. The widget simply tells the `CounterBloc` that the user has pressed either the increment or decrement button.
