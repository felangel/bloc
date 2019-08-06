<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/flutter_bloc_logo_full.png" height="60" alt="Flutter Bloc Package" />

[![Pub](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc)
[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Flutter.io](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)
[![Gitter](https://img.shields.io/badge/gitter-chat-hotpink.svg)](https://gitter.im/bloc_package/Lobby)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A Flutter package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

This package is built to work with [bloc](https://pub.dev/packages/bloc).

## Bloc Widgets

**BlocBuilder** is a Flutter widget which requires a `Bloc` and a `builder` function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed. The `builder` function will potentially be called many times and should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that returns a widget in response to the state.

See `BlocListener` if you want to "do" anything in response to state changes such as navigation, showing a dialog, etc...

If the bloc parameter is omitted, `BlocBuilder` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Only specify the bloc if you wish to provide a bloc that will be scoped to a single widget and isn't accessible via a parent `BlocProvider` and the current `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // provide the local bloc instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

If you want fine-grained control over when the builder function is called you can provide an optional `condition` to `BlocBuilder`. The `condition` takes the previous bloc state and current bloc state and returns a boolean. If `condition` returns true, `builder` will be called with `currentState` and the widget will rebuild. If `condition` returns false, `builder` will not be called with `currentState` and no rebuild will occur.

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, currentState) {
    // return true/false to determine whether or not
    // to rebuild the widget with currentState
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

**BlocProvider** is a Flutter widget which provides a bloc to its children via `BlocProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

In most cases, `BlocProvider` should be used to build new `blocs` which will be made available to the rest of the subtree. In this case, since `BlocProvider` is responsible for creating the bloc, it will automatically handle disposing the bloc.

```dart
BlocProvider(
  builder: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

In some cases, `BlocProvider` can be used to provide an existing bloc to a new portion of the widget tree. This will be most commonly used when an existing `bloc` needs to be made available to a new route. In this case, `BlocProvider` will not automatically dispose the bloc since it did not create it.

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

then from either `ChildA`, or `ScreenA` we can retrieve `BlocA` with:

```dart
BlocProvider.of<BlocA>(context)
```

**MultiBlocProvider** is a Flutter widget that merges multiple `BlocProvider` widgets into one.
`MultiBlocProvider` improves the readability and eliminates the need to nest multiple `BlocProviders`.
By using `MultiBlocProvider` we can go from:

```dart
BlocProvider<BlocA>(
  builder: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    builder: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      builder: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

to:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      builder: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      builder: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      builder: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

**BlocListener** is a Flutter widget which takes a `BlocWidgetListener` and an optional `Bloc` and invokes the `listener` in response to state changes in the bloc. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each state change (**NOT** including `initialState`) unlike `builder` in `BlocBuilder` and is a `void` function.

If the bloc parameter is omitted, `BlocListener` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```

Only specify the bloc if you wish to provide a bloc that is otherwise not accessible via `BlocProvider` and the current `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

If you want fine-grained control over when the listener function is called you can provide an optional `condition` to `BlocListener`. The `condition` takes the previous bloc state and current bloc state and returns a boolean. If `condition` returns true, `listener` will be called with `currentState`. If `condition` returns false, `listener` will not be called with `currentState`.

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, currentState) {
    // return true/false to determine whether or not
    // to call listener with currentState
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
  child: Container(),
)
```

**MultiBlocListener** is a Flutter widget that merges multiple `BlocListener` widgets into one.
`MultiBlocListener` improves the readability and eliminates the need to nest multiple `BlocListeners`.
By using `MultiBlocListener` we can go from:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

to:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

**RepositoryProvider** is a Flutter widget which provides a repository to its children via `RepositoryProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a repository can be provided to multiple widgets within a subtree. `BlocProvider` should be used to provide blocs whereas `RepositoryProvider` should only be used for repositories.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

then from `ChildA` we can retrieve the `Repository` instance with:

```dart
RepositoryProvider.of<RepositoryA>(context)
```

**MultiRepositoryProvider** is a Flutter widget that merges multiple `RepositoryProvider` widgets into one.
`MultiRepositoryProvider` improves the readability and eliminates the need to nest multiple `RepositoryProvider`.
By using `MultiRepositoryProvider` we can go from:

```dart
RepositoryProvider<RepositoryA>(
  builder: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    builder: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

to:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      builder: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      builder: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## Usage

Lets take a look at how to use `BlocBuilder` to hook up a `CounterPage` widget to a `CounterBloc`.

### counter_bloc.dart

```dart
enum CounterEvent { increment, decrement }

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

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.dispatch(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` widget knows nothing about what happens when a user taps the buttons. The widget simply tells the `CounterBloc` that the user has pressed either the increment or decrement button.

## Gallery

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/fluttercountertutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_counter.gif" width="200"/>
                </a>
            </td>            
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterinfinitelisttutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_infinite_list.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterfirebaselogintutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_firebase_login.gif" width="200" />
                </a>
            </td>
        </tr>
        <tr>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterangulargithubsearch">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_github_search.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterweathertutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_weather.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/fluttertodostutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_todos.gif" width="200"/>
                </a>
            </td>
        </tr>
    </table>
</div>

## Examples

- [Counter](https://felangel.github.io/bloc/#/fluttercountertutorial) - an example of how to create a `CounterBloc` to implement the classic Flutter Counter app.
- [Form Validation](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - an example of how to use the `bloc` and `flutter_bloc` packages to implement form validation.
- [Bloc with Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - an example of how to hook up a `bloc` to a `Stream` and update the UI in response to data from the `Stream`.
- [Infinite List](https://felangel.github.io/bloc/#/flutterinfinitelisttutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement an infinite scrolling list.
- [Login Flow](https://felangel.github.io/bloc/#/flutterlogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a Login Flow.
- [Firebase Login](https://felangel.github.io/bloc/#/flutterfirebaselogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement login via Firebase.
- [Github Search](https://felangel.github.io/bloc/#/flutterangulargithubsearch) - an example of how to create a Github Search Application using the `bloc` and `flutter_bloc` packages.
- [Weather](https://felangel.github.io/bloc/#/flutterweathertutorial) - an example of how to create a Weather Application using the `bloc` and `flutter_bloc` packages. The app uses a `RefreshIndicator` to implement "pull-to-refresh" as well as dynamic theming.
- [Todos](https://felangel.github.io/bloc/#/fluttertodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages.
- [Timer](https://felangel.github.io/bloc/#/fluttertimertutorial) - an example of how to create a Timer using the `bloc` and `flutter_bloc` packages.
- [Firestore Todos](https://felangel.github.io/bloc/#/flutterfirestoretodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages that integrates with cloud firestore.

## Dart Versions

- Dart 2: >= 2.0.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
