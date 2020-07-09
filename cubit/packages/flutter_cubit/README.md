<p align="center"><img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/flutter_cubit_full.png" height="100" alt="Flutter Cubit"></p>

<p align="center">
<a href="https://pub.dev/packages/flutter_cubit"><img src="https://img.shields.io/pub/v/flutter_cubit.svg" alt="Pub"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://github.com/felangel/cubit/workflows/build/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://raw.githubusercontent.com/felangel/cubit/master/packages/flutter_cubit/coverage_badge.svg" alt="coverage"></a>
<a href="https://github.com/felangel/cubit"><img src="https://img.shields.io/github/stars/felangel/cubit.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/zepfietje/starware"><img src="https://img.shields.io/badge/Starware-%E2%AD%90-black?labelColor=%23f9b00d" alt="Starware"></a>
</p>

A Flutter library built to expose widgets that integrate with cubits. Built to work with the [cubit](https://pub.dev/packages/cubit) and [bloc](https://pub.dev/packages/bloc) state management packages.

## Usage

Let's take a look at how to use `CubitBuilder` to hook up a `CounterPage` widget to a `CounterCubit`.

### `counter_cubit.dart`

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

### `main.dart`

```dart
void main() => runApp(CubitCounter());

class CubitCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CubitProvider(
        create: (_) => CounterCubit(),
        child: CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cubit Counter')),
      body: CubitBuilder<CounterCubit, int>(
        builder: (_, count) {
          return Center(
            child: Text('$count'),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: context.cubit<CounterCubit>().increment,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: context.cubit<CounterCubit>().decrement,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Cubit Widgets

**CubitBuilder** is a Flutter widget which requires a `Cubit` and a `builder` function. `CubitBuilder` handles building the widget in response to new states. `CubitBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed. The `builder` function will potentially be called many times and should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that returns a widget in response to the state.

See `CubitListener` if you want to "do" anything in response to state changes such as navigation, showing a dialog, etc...

If the cubit parameter is omitted, `CubitBuilder` will automatically perform a lookup using `CubitProvider` and the current `BuildContext`.

```dart
CubitBuilder<CubitA, CubitAState>(
  builder: (context, state) {
    // return widget here based on CubitA's state
  }
)
```

Only specify the cubit if you wish to provide a cubit that will be scoped to a single widget and isn't accessible via a parent `CubitProvider` and the current `BuildContext`.

```dart
CubitBuilder<CubitA, CubitAState>(
  cubit: cubitA, // provide the local cubit instance
  builder: (context, state) {
    // return widget here based on CubitA's state
  }
)
```

For fine-grained control over when the `builder` function is called an optional `buildWhen` can be provided. `buildWhen` takes the previous cubit state and current cubit state and returns a boolean. If `buildWhen` returns true, `builder` will be called with `state` and the widget will rebuild. If `buildWhen` returns false, `builder` will not be called with `state` and no rebuild will occur.

```dart
CubitBuilder<CubitA, CubitAState>(
  buildWhen: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on CubitA's state
  }
)
```

**CubitProvider** is a Flutter widget which provides a cubit to its children via `CubitProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a cubit can be provided to multiple widgets within a subtree.

In most cases, `CubitProvider` should be used to create new `cubits` which will be made available to the rest of the subtree. In this case, since `CubitProvider` is responsible for creating the cubit, it will automatically handle closing the cubit.

```dart
CubitProvider(
  create: (BuildContext context) => CubitA(),
  child: ChildA(),
);
```

In some cases, `CubitProvider` can be used to provide an existing cubit to a new portion of the widget tree. This will be most commonly used when an existing `cubit` needs to be made available to a new route. In this case, `CubitProvider` will not automatically close the cubit since it did not create it.

```dart
CubitProvider.value(
  value: CubitProvider.of<CubitA>(context),
  child: ScreenA(),
);
```

then from either `ChildA`, or `ScreenA` we can retrieve `CubitA` with:

```dart
// with extensions
context.cubit<CubitA>();

// without extensions
CubitProvider.of<CubitA>(context)
```

**MultiCubitProvider** is a Flutter widget that merges multiple `CubitProvider` widgets into one.
`MultiCubitProvider` improves the readability and eliminates the need to nest multiple `CubitProviders`.
By using `MultiCubitProvider` we can go from:

```dart
CubitProvider<CubitA>(
  create: (BuildContext context) => CubitA(),
  child: CubitProvider<CubitB>(
    create: (BuildContext context) => CubitB(),
    child: CubitProvider<CubitC>(
      create: (BuildContext context) => CubitC(),
      child: ChildA(),
    )
  )
)
```

to:

```dart
MultiCubitProvider(
  providers: [
    CubitProvider<CubitA>(
      create: (BuildContext context) => CubitA(),
    ),
    CubitProvider<CubitB>(
      create: (BuildContext context) => CubitB(),
    ),
    CubitProvider<CubitC>(
      create: (BuildContext context) => CubitC(),
    ),
  ],
  child: ChildA(),
)
```

**CubitListener** is a Flutter widget which takes a `CubitWidgetListener` and an optional `Cubit` and invokes the `listener` in response to state changes in the cubit. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each state change (**NOT** including `initialState`) unlike `builder` in `CubitBuilder` and is a `void` function.

If the cubit parameter is omitted, `CubitListener` will automatically perform a lookup using `CubitProvider` and the current `BuildContext`.

```dart
CubitListener<CubitA, CubitAState>(
  listener: (context, state) {
    // do stuff here based on CubitA's state
  },
  child: const SizedBox(),
)
```

Only specify the cubit if you wish to provide a cubit that is otherwise not accessible via `CubitProvider` and the current `BuildContext`.

```dart
CubitListener<CubitA, CubitAState>(
  cubit: cubitA,
  listener: (context, state) {
    // do stuff here based on CubitA's state
  }
)
```

For fine-grained control over when the `listener` function is called an optional `listenWhen` can be provided. `listenWhen` takes the previous cubit state and current cubit state and returns a boolean. If `listenWhen` returns true, `listener` will be called with `state`. If `listenWhen` returns false, `listener` will not be called with `state`.

```dart
CubitListener<CubitA, CubitAState>(
  listenWhen: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on CubitA's state
  },
  child: const SizedBox(),
)
```

**MultiCubitListener** is a Flutter widget that merges multiple `CubitListener` widgets into one.
`MultiCubitListener` improves the readability and eliminates the need to nest multiple `CubitListeners`.
By using `MultiCubitListener` we can go from:

```dart
CubitListener<CubitA, CubitAState>(
  listener: (context, state) {},
  child: CubitListener<CubitB, CubitBState>(
    listener: (context, state) {},
    child: CubitListener<CubitC, CubitCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

to:

```dart
MultiCubitListener(
  listeners: [
    CubitListener<CubitA, CubitAState>(
      listener: (context, state) {},
    ),
    CubitListener<CubitB, CubitBState>(
      listener: (context, state) {},
    ),
    CubitListener<CubitC, CubitCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

**CubitConsumer** exposes a `builder` and `listener` in order react to new states. `CubitConsumer` is analogous to a nested `CubitListener` and `CubitBuilder` but reduces the amount of boilerplate needed. `CubitConsumer` should only be used when it is necessary to both rebuild UI and execute other reactions to state changes in the `cubit`. `CubitConsumer` takes a required `CubitWidgetBuilder` and `CubitWidgetListener` and an optional `cubit`, `CubitBuilderCondition`, and `CubitListenerCondition`.

If the `cubit` parameter is omitted, `CubitConsumer` will automatically perform a lookup using
`CubitProvider` and the current `BuildContext`.

```dart
CubitConsumer<CubitA, CubitAState>(
  listener: (context, state) {
    // do stuff here based on CubitA's state
  },
  builder: (context, state) {
    // return widget here based on CubitA's state
  }
)
```

An optional `listenWhen` and `buildWhen` can be implemented for more granular control over when `listener` and `builder` are called. The `listenWhen` and `buildWhen` will be invoked on each `cubit` `state` change. They each take the previous `state` and current `state` and must return a `bool` which determines whether or not the `builder` and/or `listener` function will be invoked. The previous `state` will be initialized to the `state` of the `cubit` when the `CubitConsumer` is initialized. `listenWhen` and `buildWhen` are optional and if they aren't implemented, they will default to `true`.

```dart
CubitConsumer<CubitA, CubitAState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether or not
    // to invoke listener with state
  },
  listener: (context, state) {
    // do stuff here based on CubitA's state
  },
  buildWhen: (previous, current) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on CubitA's state
  }
)
```

## Dart Versions

- Dart 2: >= 2.7.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[![Very Good Ventures](https://raw.githubusercontent.com/felangel/cubit/master/assets/vgv_logo.png)](https://verygood.ventures)

## Starware

Flutter Cubit is Starware.  
This means you're free to use the project, as long as you star its GitHub repository.  
Your appreciation makes us grow and glow up. ⭐
