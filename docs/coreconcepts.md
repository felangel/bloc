# Core Concepts

?> Please make sure to carefully read and understand the following sections before working with Bloc.

There are several core concepts that are critical to understanding how to use Bloc.

In the upcoming sections, we're going to discuss each of them in detail as well as work through how they would apply to a real-world application: a counter app.

## Events

> Events are the input to a Bloc. They are commonly user interactions such as button presses or lifecycle events like page loads.

When designing an app we need step back and define how users will interact with it. In the context of our counter app we will have two buttons to increment and decrement our counter.

When a user taps on one of these buttons, something needs to happen to notify the "brains" of our app so that it can respond to the user's input; this is where events come into play.

We need to be able to notify our application's "brains" of both an increment and a decrement so we need to define these events.

```dart
abstract class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}
```

The `Increment` and `Decrement` events are related because they both are coupled to the counter functionality. In order to represent that relationship, we create a base class called `CounterEvent`.

At this point we have defined our first event! Notice that we have not used Bloc in any way so far and there is no magic happening; it's just plain Dart code.

## States

> States are the output of a Bloc and represent a part of your application's state. UI components can be notified of states and redraw portions of themselves based on the current state.

So far, we've defined the two events that our app will be responding to: `Increment` and `Decrement`.

Now we need to define how to represent the state of our application.

Since we're building a counter, our state is very simple: it's just an integer which represents the counter's current value.

We will see more complex examples of state later on but in this case a primitive type is perfectly suitable as the state representation.

## Transitions

> The change from one state to another is called a Transition. A Transition consists of the current state, the event, and the next state.

As a user interacts with our counter app they will trigger `Increment` and `Decrement` events which will update the counter's state. All of these state changes can be described as a series of `Transitions`.

For example, if a user opened our app and tapped the increment button once we would see the following `Transition`.

```json
{
    "currentState": 0,
    "event": "Increment",
    "nextState": 1
}
```

Because every state change is recorded, we are able to very easily instrument our applications and track all user interactions & state changes in one place. In addition, this makes things like time-travel debugging possible.

## Streams

?> Check out the official [Dart Documentation](https://www.dartlang.org/tutorials/language/streams) for more information about `Streams`.

> A stream is a sequence of asynchronous data.

Bloc is built on top of [RxDart](https://pub.dartlang.org/packages/rxdart); however, it abstracts all of the `RxDart` specific implementation details.

In order to use Bloc, it is criticial to have a solid understanding of `Streams` and how they work.

> If you're unfamiliar with `Streams` just think of a pipe with water flowing through it. The pipe is the `Stream` and the water is the asynchronous data.

We can create a `Stream` in Dart by writing an `async*` function.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

By marking a function as `async*` we are able to use the `yield` keyword and return a `Stream` of data. In the above example, we are returning a `Stream` of integers up to the `max` integer parameter.

Every time we `yield` in an `async*` function we are pushing that piece of data through the `Stream`.

We can consume the above `Stream` in several ways. If we wanted to write a function to return the sum of a `Stream` of integers it could look something like:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

By marking the above function as `async` we are able to use the `await` keyword and return a `Future` of integers. In this example, we are awaiting each value in the stream and returning the sum of all integers in the stream.

We can put it all together like so:

```dart
void main() async {
    /// Initialize a stream of integers 0-9
    Stream<int> stream = countStream(10);
    /// Compute the sum of the stream of integers
    int sum = await sumStream(stream);
    /// Print the sum
    print(sum); // 45
}
```

## Blocs

> A Bloc (Business Logic Component) is a component which converts a `Stream` of incoming `Events` into a `Stream` of outgoing `States`. Think of a Bloc as being the "brains" described above.

> Every Bloc must extend the base `Bloc` class which is part of the core bloc package.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

In the above code snippet, we are declaring our `CounterBloc` as a Bloc which converts `CounterEvents` into `ints`.

> Every Bloc must define an initial state which is the state before any events have been recieved.

In this case, we want our counter to start at `0`.

```dart
@override
int get initialState => 0;
```

> Every Bloc must implement a function called `mapEventToState`. The function takes two arguments: `currentState` and `event` and must return a `Stream` of new `states` which is consumed by the presentation layer.

```dart
@override
Stream<int> mapEventToState(int currentState, CounterEvent event) async* {
    if (event is Increment) {
        yield currentState + 1;
    }
    if (event is Decrement) {
        yield currentState - 1;
    }
}
```

At this point, we have a fully functioning `CounterBloc`.

```dart
import 'package:bloc/bloc.dart';

abstract class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

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

At this point, you're probably wondering _"How do I notify a Bloc of an event?"_.

> Every Bloc has a `dispatch` method. `Dispatch` takes an `event` and triggers `mapEventToState`. `Dispatch` may be called from the presentation layer or from within the Bloc and notifies the Bloc of a new `event`.

We can create a simple application which counts from 0 to 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.dispatch(Increment());
    }
}
```

The `Transitions` in the above code snippet would be

```json
{
    "currentState": 0,
    "event": "Increment",
    "nextState": 1
}
{
    "currentState": 1,
    "event": "Increment",
    "nextState": 2
}
{
    "currentState": 2,
    "event": "Increment",
    "nextState": 3
}
```

Unfortunately, in the current state we won't be able to see any of these transitions unless we override `onTransition`.

> `onTransition` is a method that can be overridden to handle every local Bloc `Transition`. `onTransition` is called just before a Bloc's `state` has been updated.

?> **Tip**: `onTransition` is a great place to add bloc-specific logging/analytics.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Now that we've overridden `onTransition` we can do whatever we'd like whenever a `Transition` occurs.

If you're following along, you might notice that the `Transitions` printed aren't very easy to read, particulary the `CounterEvent`. In order to resolve this we need to override `toString()` in our `Increment` and `Decrement` classes.

```dart
class Increment extends CounterEvent {
    @override
    String toString() => 'Increment';
}

class Decrement extends CounterEvent {
    @override
    String toString() => 'Decrement';
}
```

## BlocDelegate

One added bonus of using Bloc is that we can have access to all `Transitions` in one place. Even though in this application we only have one Bloc, it's fairly common in larger applications to have many Blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    print(transition.toString());
  }
}
```

?> **Note**: All we need to do is extend `BlocDelegate` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocDelegate`, we just need to tweak our `main` function.

```dart
void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.dispatch(Increment());
  }
}
```

?> **Note**: `BlocSupervisor` is a singleton which oversees all Blocs and delegates responsibilities to the `BlocDelegate`.
