<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/flutter_bloc_logo_full.png" height="60" alt="Flutter Bloc Package" />

[![Pub](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dartlang.org/packages/flutter_bloc)
[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Flutter.io](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#bloc)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)
[![Gitter](https://img.shields.io/badge/gitter-chat-hotpink.svg)](https://gitter.im/bloc_package/Lobby)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A Flutter package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

This package is built to work with [bloc](https://pub.dartlang.org/packages/bloc).

## Bloc Widgets

**BlocBuilder** is a Flutter widget which requires a `Bloc` and a `builder` function. `BlocBuilder` handles building the widget in response to new states. `BlocBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed.

```dart
BlocBuilder(
  bloc: BlocA(),
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

**BlocProvider** is a Flutter widget which provides a bloc to its children via `BlocProvider.of<T>(context)`. It is used as a DI widget so that a single instance of a bloc can be provided to multiple widgets within a subtree.

```dart
BlocProvider(
  bloc: BlocA(),
  child: ChildA(),
);
```

then from `ChildA` we can retrieve `BlocA` with:

```dart
BlocProvider.of<BlocA>(context)
```

**BlocProviderTree** is a Flutter widget that merges multiple `BlocProvider` widgets into one.
`BlocProviderTree` improves the readability and eliminates the need to nest multiple `BlocProviders`.
By using `BlocProviderTree` we can go from:

```dart
BlocProvider<BlocA>(
   bloc: BlocA(),
   child: BlocProvider<BlocB>(
     bloc: BlocB(),
     child: BlocProvider<BlocC>(
       value: BlocC(),
       child: ChildA(),
     )
   )
 )
 ```

to:

```dart
BlocProviderTree(
  blocProviders: [
    BlocProvider<BlocA>(bloc: BlocA()),
    BlocProvider<BlocB>(bloc: BlocB()),
    BlocProvider<BlocC>(bloc: BlocC()),
  ],
  child: ChildA(),
)
```

## Usage

Lets take a look at how to use `BlocBuilder` to hook up a `CounterPage` widget to a `CounterBloc`.

`counter_bloc.dart`

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

`counter_page.dart`

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, int>(
        bloc: _counterBloc,
        builder: (BuildContext context, int count) {
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
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.decrement);
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

## Dart Versions

- Dart 2: >= 2.0.0

## Examples

- [Counter](https://felangel.github.io/bloc/#/fluttercountertutorial) - an example of how to create a `CounterBloc` to implement the classic Flutter Counter app.
- [Infinite List](https://felangel.github.io/bloc/#/flutterinfinitelisttutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement an infinite scrolling list.
- [Login Flow](https://felangel.github.io/bloc/#/flutterlogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a Login Flow.
- [Github Search](https://felangel.github.io/bloc/#/flutterangulargithubsearch) - an example of how to create a Github Search Application using the `bloc` and `flutter_bloc` packages.
- [Weather](https://felangel.github.io/bloc/#/flutterweathertutorial) - an example of how to create a Weather Application using the `bloc` and `flutter_bloc` packages. The app uses a `RefreshIndicator` to implement "pull-to-refresh" as well as dynamic theming.
- [Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages.

### Maintainers

- [Felix Angelov](https://github.com/felangel)
