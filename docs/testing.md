# Testing

> Bloc was designed to be extremely easy to test.

For the sake of simplicity, let's write tests for the `CounterBloc` we created in [Core Concepts](coreconcepts.md).

To recap, the `CounterBloc` implementation looks like

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

Before we start writing our tests we're going to need to add a testing framework to our dependencies.

We need to add [test](https://pub.dartlang.org/packages/test) to our `pubspec.yaml`.

```yaml
dev_dependencies:
  test: ">=1.3.0 <2.0.0"
```

Let's get started by creating the file for our `CounterBloc` Tests, `counter_bloc_test.dart` and importing the test package.

```dart
import 'package:test/test.dart';
```

Next, we need to create our `main` as well as our test group.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **Note**: groups are for organizing individual tests as well as for creating a context in which you can share a common `setUp` and `tearDown` across all of the individual tests.

Let's start by creating an instance of our `CounterBloc` which will be used across all of our tests.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Now we can start writing our individual tests.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
    });
});
```

?> **Note**: We can run all of our tests with the `pub run test` command.

At this point we should have our first passing test! Now let's write a more complex test.

```dart
test('single Increment event updates state to 1', () {
    final List<int> expected = [0, 1];

    expectLater(
        counterBloc.state,
        emitsInOrder(expected),
    );

    counterBloc.dispatch(CounterEvent.increment);
});

test('single Decrement event updates state to -1', () {
    final List<int> expected = [0, -1];

    expectLater(
        counterBloc.state,
        emitsInOrder(expected),
    );

    counterBloc.dispatch(CounterEvent.decrement);
});
```

We should be able to run the tests and see that all are passing.

That's all there is to it, testing should be a breeze and we should feel confident when making changes and refactoring our code.
