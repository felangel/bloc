# Counter Tutorial

> In the following tutorial, we're going to build a Counter in Flutter using the Bloc library.

Our counter app is just going to have two buttons to increment/decrement the counter value and a `Text` widget to display the current value. Let's get started designing the `CounterEvents`.

## Counter Events

```dart
abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  String toString() => 'Increment';
}

class Decrement extends CounterEvent {
  @override
  String toString() => 'Decrement';
}
```

## Counter States

Since our counter's state can be represented by an integer we don't need to create a custom class!

## Counter Bloc

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
    if (event is Increment) {
      yield currentState + 1;
    }
    if (event is Decrement) {
      yield currentState - 1;
    }
  }
}
```

?> **Note**: Just from the class declaration we can tell that our `CounterBloc` will be taking `CounterEvents` as input and outputting integers.

## Counter App

Now that we have our `CounterBloc` fully implemented, we can get started creating our Flutter application.

```dart
void main() => runApp(MyApp();

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        bloc: _counterBloc,
        child: CounterPage(),
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

?> **Note**: Our `MyApp` widget is a `StatefulWidget` so that it can manage creating and disposing the `CounterBloc`.

?> **Note**: We are using the `BlocProvider` widget from `flutter_bloc` in order to make the instance of `CounterBloc` available to the entire subtree (`CounterPage`).

## Counter Page

Finally, all that's left is to build our Counter Page.

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
                _counterBloc.dispatch(Increment());
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(Decrement());
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

?> **Note**: We are able to access the `CounterBloc` instance using `BlocProvider.of<CounterBloc>(context)` because we wrapped our `CounterPage` in a `BlocProvider`.

?> **Note**: We are using the `BlocBuilder` widget from `flutter_bloc` in order to rebuild out UI in response to state changes (changes in the counter value).

That's it! We've separated our presentation layer from our business logic layer. Our `CounterPage` has no idea what happens when a user presses a button; it just dispatches an event to notify the `CounterBloc`. Furthermore, our `CounterBloc` has no idea what is happening with the state (counter value); it's simply converting the `CounterEvents` into integers.
