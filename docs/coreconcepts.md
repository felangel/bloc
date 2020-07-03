# Core Concepts

?> Please make sure to carefully read and understand the following sections before working with [bloc](https://pub.dev/packages/bloc).

There are several core concepts that are critical to understanding how to use Bloc.

In the upcoming sections, we're going to discuss each of them in detail as well as work through how they would apply to a real-world application: a counter app.

## Events

> Events are the input to a Bloc. They are commonly added in response to user interactions such as button presses or lifecycle events like page loads.

When designing an app we need to step back and define how users will interact with it. In the context of our counter app we will have two buttons to increment and decrement our counter.

When a user taps on one of these buttons, something needs to happen to notify the "brains" of our app so that it can respond to the user's input; this is where events come into play.

We need to be able to notify our application's "brains" of both an increment and a decrement so we need to define these events.

[counter_event.dart](_snippets/core_concepts/counter_event.dart.md ':include')

In this case, we can represent the events using an `enum` but for more complex cases it might be necessary to use a `class` especially if it's necessary to pass information to the bloc.

At this point we have defined our first event! Notice that we have not used Bloc in any way so far and there is no magic happening; it's just plain Dart code.

## States

> States are the output of a Bloc and represent a part of your application's state. UI components can be notified of states and redraw portions of themselves based on the current state.

So far, we've defined the two events that our app will be responding to: `CounterEvent.increment` and `CounterEvent.decrement`.

Now we need to define how to represent the state of our application.

Since we're building a counter, our state is very simple: it's just an integer which represents the counter's current value.

We will see more complex examples of state later on but in this case a primitive type is perfectly suitable as the state representation.

## Transitions

> The change from one state to another is called a Transition. A Transition consists of the current state, the event, and the next state.

As a user interacts with our counter app they will trigger `Increment` and `Decrement` events which will update the counter's state. All of these state changes can be described as a series of `Transitions`.

For example, if a user opened our app and tapped the increment button once we would see the following `Transition`.

[counter_increment_transition.json](_snippets/core_concepts/counter_increment_transition.json.md ':include')

Because every state change is recorded, we are able to very easily instrument our applications and track all user interactions & state changes in one place. In addition, this makes things like time-travel debugging possible.

## Streams

?> Check out the official [Dart Documentation](https://dart.dev/tutorials/language/streams) for more information about `Streams`.

> A stream is a sequence of asynchronous data.

In order to use Bloc, it is criticial to have a solid understanding of `Streams` and how they work.

> If you're unfamiliar with `Streams` just think of a pipe with water flowing through it. The pipe is the `Stream` and the water is the asynchronous data.

We can create a `Stream` in Dart by writing an `async*` function.

[count_stream.dart](_snippets/core_concepts/count_stream.dart.md ':include')

By marking a function as `async*` we are able to use the `yield` keyword and return a `Stream` of data. In the above example, we are returning a `Stream` of integers up to the `max` integer parameter.

Every time we `yield` in an `async*` function we are pushing that piece of data through the `Stream`.

We can consume the above `Stream` in several ways. If we wanted to write a function to return the sum of a `Stream` of integers it could look something like:

[sum_stream.dart](_snippets/core_concepts/sum_stream.dart.md ':include')

By marking the above function as `async` we are able to use the `await` keyword and return a `Future` of integers. In this example, we are awaiting each value in the stream and returning the sum of all integers in the stream.

We can put it all together like so:

[main.dart](_snippets/core_concepts/streams_main.dart.md ':include')

## Blocs

> A Bloc (Business Logic Component) is a component which converts a `Stream` of incoming `Events` into a `Stream` of outgoing `States`. Think of a Bloc as being the "brains" described above.

> Every Bloc must extend the base `Bloc` class which is part of the core bloc package.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_class.dart.md ':include')

In the above code snippet, we are declaring our `CounterBloc` as a Bloc which converts `CounterEvents` into `ints`.

> Every Bloc must define an initial state which is the state before any events have been received.

In this case, we want our counter to start at `0`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_initial_state.dart.md ':include')

> Every Bloc must implement a function called `mapEventToState`. The function takes the incoming `event` as an argument and must return a `Stream` of new `states` which is consumed by the presentation layer. We can access the current bloc state at any time using the `state` property.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_map_event_to_state.dart.md ':include')

At this point, we have a fully functioning `CounterBloc`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc.dart.md ':include')

!> Blocs will ignore duplicate states. If a Bloc yields `State nextState` where `state == nextState`, then no transition will occur and no change will be made to the `Stream<State>`.

At this point, you're probably wondering _"How do I notify a Bloc of an event?"_.

> Every Bloc has a `add` method. `Add` takes an `event` and triggers `mapEventToState`. `Add` may be called from the presentation layer or from within the Bloc and notifies the Bloc of a new `event`.

We can create a simple application which counts from 0 to 3.

[main.dart](_snippets/core_concepts/counter_bloc_main.dart.md ':include')

!> By default, events will always be processed in the order in which they were added and any newly added events are enqueued. An event is considered fully processed once `mapEventToState` has finished executing.

The `Transitions` in the above code snippet would be

[counter_bloc_transitions.json](_snippets/core_concepts/counter_bloc_transitions.json.md ':include')

Unfortunately, in the current state we won't be able to see any of these transitions unless we override `onTransition`.

> `onTransition` is a method that can be overridden to handle every local Bloc `Transition`. `onTransition` is called just before a Bloc's `state` has been updated.

?> **Tip**: `onTransition` is a great place to add bloc-specific logging/analytics.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

Now that we've overridden `onTransition` we can do whatever we'd like whenever a `Transition` occurs.

Just like we can handle `Transitions` at the bloc level, we can also handle `Exceptions`.

> `onError` is a method that can be overriden to handle every local Bloc `Exception`. By default all exceptions will be ignored and `Bloc` functionality will be unaffected.

?> **Note**: The stackTrace argument may be `null` if the state stream received an error without a `StackTrace`.

?> **Tip**: `onError` is a great place to add bloc-specific error handling.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

Now that we've overridden `onError` we can do whatever we'd like whenever an `Exception` is thrown.

## BlocObserver

One added bonus of using Bloc is that we can have access to all `Transitions` in one place. Even though in this application we only have one Bloc, it's fairly common in larger applications to have many Blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocObserver`.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer.dart.md ':include')

?> **Note**: All we need to do is extend `BlocObserver` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocObserver`, we just need to tweak our `main` function.

[main.dart](_snippets/core_concepts/simple_bloc_observer_main.dart.md ':include')

If we want to be able to do something in response to all `Events` added, we can also override the `onEvent` method in our `SimpleBlocObserver`.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

If we want to be able to do something in response to all `Exceptions` thrown in a Bloc, we can also override the `onError` method in our `SimpleBlocObserver`.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_complete.dart.md ':include')
