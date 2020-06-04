<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/flutter_cubit_full.png" height="60" alt="Flutter Cubit" />

**WARNING: This is highly experimental**

An experimental Flutter library which exposes widgets that integrate with `cubits`. Built to work with [package:cubit](https://pub.dev/packages/cubit).

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

If you want fine-grained control over when the builder function is called you can provide an optional `condition` to `CubitBuilder`. The `condition` takes the previous cubit state and current cubit state and returns a boolean. If `condition` returns true, `builder` will be called with `state` and the widget will rebuild. If `condition` returns false, `builder` will not be called with `state` and no rebuild will occur.

```dart
CubitBuilder<CubitA, CubitAState>(
  condition: (previousState, state) {
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

**CubitListener** is a Flutter widget which takes a `CubitWidgetListener` and an optional `Cubit` and invokes the `listener` in response to state changes in the cubit. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each state change (**NOT** including `initialState`) unlike `builder` in `CubitBuilder` and is a `void` function.

If the cubit parameter is omitted, `CubitListener` will automatically perform a lookup using `CubitProvider` and the current `BuildContext`.

```dart
CubitListener<CubitA, CubitAState>(
  listener: (context, state) {
    // do stuff here based on CubitA's state
  },
  child: Container(),
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

If you want fine-grained control over when the listener function is called you can provide an optional `condition` to `CubitListener`. The `condition` takes the previous cubit state and current cubit state and returns a boolean. If `condition` returns true, `listener` will be called with `state`. If `condition` returns false, `listener` will not be called with `state`.

```dart
CubitListener<CubitA, CubitAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on CubitA's state
  },
  child: Container(),
)
```

## Usage

Lets take a look at how to use `CubitBuilder` to hook up a `CounterPage` widget to a `CounterCubit`.

### counter_cubit.dart

```dart
class CounterCubit extends Cubit<int> {
  @override
  int get initialState => 0;

  Future<void> increment() => emit(state + 1);
  Future<void> decrement() => emit(state - 1);
}
```

### main.dart

```dart
void main() => runApp(CounterApp());

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      appBar: AppBar(title: const Text('Counter')),
      body: CubitBuilder<CounterCubit, int>(
        builder: (_, count) {
          return Center(
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => context.cubit<CounterCubit>().increment(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: const Icon(Icons.remove),
              onPressed: () => context.cubit<CounterCubit>().decrement(),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
