# Recipes: Bloc Access

> In this recipe, we're going to take a look at how to use `BlocProvider` to make a bloc accessible throughout the widget tree. We're going to explore three scenarios: Local Access, Route Access, and Global Access.

## Local Access

> In this example, we're going to use `BlocProvider` to make a bloc available to a local sub-tree. In this context, local means within a context where there are no routes being pushed/popped.

### Bloc

For the sake of simplicity we're going to use a `Counter` as our example application.

Our `CounterBloc` implementation will look like:

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

### UI

We're going to have 3 parts to our UI:

- App: the root application widget
- CounterPage: the container widget which will manage the `CounterBloc` and exposes `FloatingActionButtons` to `increment` and `decrement` the counter.
- CounterText: a text widget which is responsible for displaying the current `count`.

#### App

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CounterPage(),
    );
  }
}
```

There's nothing special about our `App` widget; it's just using a `MaterialApp` and passing our `CounterPage` as the home widget.

#### CounterPage

```dart
class CounterPage extends StatefulWidget {
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  CounterBloc _counterBloc;

  @override
  void initState() {
    super.initState();
    _counterBloc = CounterBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocProvider(
        bloc: _counterBloc,
        child: Center(
          child: CounterText(),
        ),
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

  @override
  void dispose() {
    _counterBloc.dispose();
    super.dispose();
  }
}
```

The `CounterPage` widget is a `StatefulWidget` which is responsible for creating and disposing the `CounterBloc`. It also makes the `CounterBloc` available to the `CounterText` child widget using a `BlocProvider`.

?> **Note:** When we wrap a widget with `BlocProvider` we can then provide a bloc to all widgets within that subtree. In this case, we can access the `CounterBloc` from within the `CounterText` widget and any children of the `CounterText` widget using `BlocProvider.of<CounterBloc>(context)`.

#### CounterText

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<CounterBloc>(context),
      builder: (BuildContext context, int count) {
        return Text('$count');
      },
    );
  }
}
```

Our `CounterText` widget is using a `BlocBuilder` to rebuild itself whenever the `CounterBloc` state changes. We use `BlocProvider.of<CounterBloc>(context)` in order to access the provided `CounterBloc` and return a `Text` widget with the current count.

That wraps up the local bloc access portion of this recipe and the full source code can be found [here](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

Next, we'll take a look at how to provide a bloc across multiple pages/routes.

## Route Access

> In this example, we're going to use `BlocProvider` to access a bloc across routes.

### Bloc

Again, we're going to use the `CounterBloc` for simplicity.

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

### UI

Again, we're going to have three parts to our application's UI:

- App: the root application widget
- HomePage: the container widget which will manage the `CounterBloc` and exposes `FloatingActionButtons` to `increment` and `decrement` the counter.
- CounterPage: a widget which is responsible for displaying the current `count` as a separate route.

#### App

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CounterPage(),
    );
  }
}
```

Again, our `App` widget is the same as before.

#### HomePage

```dart
class HomePage extends StatefulWidget {
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CounterBloc _counterBloc;

  @override
  void initState() {
    super.initState();
    _counterBloc = CounterBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocProvider(
        bloc: _counterBloc,
        child: Center(
          child: RaisedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return BlocProvider(
                      bloc: _counterBloc,
                      child: CounterPage(),
                    );
                  },
                ),
              );
            },
            child: Text('Counter'),
          ),
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              heroTag: 0,
              child: Icon(Icons.add),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              heroTag: 1,
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

  @override
  void dispose() {
    _counterBloc.dispose();
    super.dispose();
  }
}
```

The `HomePage` is similar to the `CounterPage` in the above example; however, instead of rendering a `CounterText` widget, it renders a `RaisedButton` in the center which allows the user to navigate to a new screen which displays the current count.

When the user taps the `RaisedButton`, we push a new `MaterialPageRoute` and return the `CounterPage`; however, we are wrapping the `CounterPage` in a `BlocProvider` in order to make the current `CounterBloc` instance available on the next page.

#### CounterPage

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: BlocBuilder(
        bloc: BlocProvider.of<CounterBloc>(context),
        builder: (BuildContext context, int count) {
          return Center(
            child: Text('$count'),
          );
        },
      ),
    );
  }
}
```

`CounterPage` is a super simple `StatelessWidget` which uses `BlocBuilder` to re-render a `Text` widget with the current count. Just like before, we are able to use `BlocProvider.of<CounterBloc>(context)` in order to access the `CounterBloc`.

That's all there is to this example and the full source can be found [here](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

Last, we'll look at how to make a bloc globally available to the widget tree.

## Global Access

> In this last example, we're going to demonstrate how to make a bloc instance available to the entire widget tree. This is useful for specific cases like an `AuthenticationBloc` or `ThemeBloc` because that state applies to all parts of the application.

### Bloc

As usual, we're going to use the `CounterBloc` as our example for simplicity.

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

### UI

We're going to follow the same application structure as in the "Local Access" example. As a result, we're going to have three parts to our UI:

- App: the root application widget which manages the global instance of our `CounterBloc`.
- CounterPage: the container widget which exposes `FloatingActionButtons` to `increment` and `decrement` the counter.
- CounterText: a text widget which is responsible for displaying the current `count`.

#### App

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  CounterBloc _counterBloc;

  @override
  void initState() {
    super.initState();
    _counterBloc = CounterBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _counterBloc,
      child: MaterialApp(
        title: 'Flutter Demo',
        home: CounterPage(),
      ),
    );
  }

  @override
  void dispose() {
    _counterBloc.dispose();
    super.dispose();
  }
}
```

In this case, since our `App` widget is responsible for maintaining our `CounterBloc` widget, it needs to be a `StatefulWidget`. We can initialize the `CounterBloc` in `initState` and `dispose` it in `dispose`.

The last thing to note is we are wrapping the entire `MaterialApp` in a `BlocProvider` which is the key to making our `CounterBloc` instance globally accessible. Now we can access our `CounterBloc` from anywhere in our application where we have a `BuildContext` using `BlocProvider.of<CounterBloc>(context);`

?> **Note:** This approach still works if you're using a `CupertinoApp` or `WidgetsApp`.

#### CounterPage

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: CounterText(),
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

Our `CounterPage` can now be a `StatelessWidget` because it doesn't need to manage any of its own state. Just as we mentioned above, it uses `BlocProvider.of<CounterBloc>(context)` to access the global instance of the `CounterBloc`.

#### CounterText

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<CounterBloc>(context),
      builder: (BuildContext context, int count) {
        return Text('$count');
      },
    );
  }
}
```

Nothing new here; the `CounterText` widget is the same as in the first example. It's just a `StatelessWidget` which uses a `BlocBuilder` to re-render when the `CounterBloc` state changes and accesses the global `CounterBloc` instance using `BlocProvider.of<CounterBloc>(context)`.

That's all there is to it! The full source can be found [here](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).
