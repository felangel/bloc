# Flutter Counter Tutorial

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> In the following tutorial, we're going to build a Counter in Flutter using the Bloc library.

![demo](./assets/gifs/flutter_counter.gif)

## Setup

We'll start off by creating a brand new Flutter project

```bash
flutter create flutter_counter
```

We can then go ahead and replace the contents of `pubspec.yaml` with

```yaml
name: flutter_counter
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  meta: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

and then install all of our dependencies

```bash
flutter packages get
```

Our counter app is just going to have two buttons to increment/decrement the counter value and a `Text` widget to display the current value. Let's get started designing the `CounterEvents`.

## Counter Events

```dart
enum CounterEvent { increment, decrement }
```

## Counter States

Since our counter's state can be represented by an integer we don't need to create a custom class!

## Counter Bloc

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

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

?> **Note**: Just from the class declaration we can tell that our `CounterBloc` will be taking `CounterEvents` as input and outputting integers.

## Counter App

Now that we have our `CounterBloc` fully implemented, we can get started creating our Flutter application.

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

?> **Note**: We are using the `BlocProvider` widget from `flutter_bloc` in order to make the instance of `CounterBloc` available to the entire subtree (`CounterPage`). `BlocProvider` also handles closing the `CounterBloc` automatically so we don't need to use a `StatefulWidget`.

## Counter Page

Finally, all that's left is to build our Counter Page.

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
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
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

?> **Note**: We are using the `BlocBuilder` widget from `flutter_bloc` in order to rebuild our UI in response to state changes (changes in the counter value).

?> **Note**: `BlocBuilder` takes an optional `bloc` parameter but we can specify the type of the bloc and the type of the state and `BlocBuilder` will find the bloc automatically so we don't need to explicity use `BlocProvider.of<CounterBloc>(context)`.

!> Only specify the bloc in `BlocBuilder` if you wish to provide a bloc that will be scoped to a single widget and isn't accessible via a parent `BlocProvider` and the current `BuildContext`.

That's it! We've separated our presentation layer from our business logic layer. Our `CounterPage` has no idea what happens when a user presses a button; it just adds an event to notify the `CounterBloc`. Furthermore, our `CounterBloc` has no idea what is happening with the state (counter value); it's simply converting the `CounterEvents` into integers.

We can run our app with `flutter run` and can view it on our device or simulator/emulator.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
