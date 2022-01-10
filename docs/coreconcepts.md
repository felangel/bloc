# Core Concepts (package:bloc)

?> Please make sure to carefully read the following sections before working with [package:bloc](https://pub.dev/packages/bloc).

There are several core concepts that are critical to understanding how to use the bloc package.

In the upcoming sections, we're going to discuss each of them in detail as well as work through how they would apply to a counter app.

## Streams

?> Check out the official [Dart Documentation](https://dart.dev/tutorials/language/streams) for more information about `Streams`.

> A stream is a sequence of asynchronous data.

In order to use the bloc library, it is critical to have a basic understanding of `Streams` and how they work.

> If you're unfamiliar with `Streams` just think of a pipe with water flowing through it. The pipe is the `Stream` and the water is the asynchronous data.

We can create a `Stream` in Dart by writing an `async*` (async generator) function.

[count_stream.dart](_snippets/core_concepts/count_stream.dart.md ':include')

By marking a function as `async*` we are able to use the `yield` keyword and return a `Stream` of data. In the above example, we are returning a `Stream` of integers up to the `max` integer parameter.

Every time we `yield` in an `async*` function we are pushing that piece of data through the `Stream`.

We can consume the above `Stream` in several ways. If we wanted to write a function to return the sum of a `Stream` of integers it could look something like:

[sum_stream.dart](_snippets/core_concepts/sum_stream.dart.md ':include')

By marking the above function as `async` we are able to use the `await` keyword and return a `Future` of integers. In this example, we are awaiting each value in the stream and returning the sum of all integers in the stream.

We can put it all together like so:

[main.dart](_snippets/core_concepts/streams_main.dart.md ':include')

Now that we have a basic understanding of how `Streams` work in Dart we're ready to learn about the core component of the bloc package: a `Cubit`.

## Cubit

> A `Cubit` is a class which extends `BlocBase` and can be extended to manage any type of state.

![Cubit Architecture](assets/cubit_architecture_full.png)

A `Cubit` can expose functions which can be invoked to trigger state changes.

> States are the output of a `Cubit` and represent a part of your application's state. UI components can be notified of states and redraw portions of themselves based on the current state.

> **Note**: For more information about the origins of `Cubit` checkout [the following issue](https://github.com/felangel/cubit/issues/69).

### Creating a Cubit

We can create a `CounterCubit` like:

[counter_cubit.dart](_snippets/core_concepts/counter_cubit.dart.md ':include')

When creating a `Cubit`, we need to define the type of state which the `Cubit` will be managing. In the case of the `CounterCubit` above, the state can be represented via an `int` but in more complex cases it might be necessary to use a `class` instead of a primitive type.

The second thing we need to do when creating a `Cubit` is specify the initial state. We can do this by calling `super` with the value of the initial state. In the snippet above, we are setting the initial state to `0` internally but we can also allow the `Cubit` to be more flexible by accepting an external value:

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_initial_state.dart.md ':include')

This would allow us to instantiate `CounterCubit` instances with different initial states like:

[main.dart](_snippets/core_concepts/counter_cubit_instantiation.dart.md ':include')

### State Changes

> Each `Cubit` has the ability to output a new state via `emit`.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_increment.dart.md ':include')

In the above snippet, the `CounterCubit` is exposing a public method called `increment` which can be called externally to notify the `CounterCubit` to increment its state. When `increment` is called, we can access the current state of the `Cubit` via the `state` getter and `emit` a new state by adding 1 to the current state.

!> The `emit` method is protected, meaning it should only be used inside of a `Cubit`.

### Using a Cubit

We can now take the `CounterCubit` we've implemented and put it to use!

#### Basic Usage

[main.dart](_snippets/core_concepts/counter_cubit_basic_usage.dart.md ':include')

In the above snippet, we start by creating an instance of the `CounterCubit`. We then print the current state of the cubit which is the initial state (since no new states have been emitted yet). Next, we call the `increment` function to trigger a state change. Finally, we print the state of the `Cubit` again which went from `0` to `1` and call `close` on the `Cubit` to close the internal state stream.

#### Stream Usage

`Cubit` exposes a `Stream` which allows us to receive real-time state updates:

[main.dart](_snippets/core_concepts/counter_cubit_stream_usage.dart.md ':include')

In the above snippet, we are subscribing to the `CounterCubit` and calling print on each state change. We are then invoking the `increment` function which will emit a new state. Lastly, we are calling `cancel` on the `subscription` when we no longer want to receive updates and closing the `Cubit`.

?> **Note**: `await Future.delayed(Duration.zero)` is added for this example to avoid canceling the subscription immediately.

!> Only subsequent state changes will be received when calling `listen` on a `Cubit`.

### Observing a Cubit

> When a `Cubit` emits a new state, a `Change` occurs. We can observe all changes for a given `Cubit` by overriding `onChange`.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_on_change.dart.md ':include')

We can then interact with the `Cubit` and observe all changes output to the console.

[main.dart](_snippets/core_concepts/counter_cubit_on_change_usage.dart.md ':include')

The above example would output:

[script](_snippets/core_concepts/counter_cubit_on_change_output.sh.md ':include')

?> **Note**: A `Change` occurs just before the state of the `Cubit` is updated. A `Change` consists of the `currentState` and the `nextState`.

#### BlocObserver

One added bonus of using the bloc library is that we can have access to all `Changes` in one place. Even though in this application we only have one `Cubit`, it's fairly common in larger applications to have many `Cubits` managing different parts of the application's state.

If we want to be able to do something in response to all `Changes` we can simply create our own `BlocObserver`.

[simple_bloc_observer_on_change.dart](_snippets/core_concepts/simple_bloc_observer_on_change.dart.md ':include')

?> **Note**: All we need to do is extend `BlocObserver` and override the `onChange` method.

In order to use the `SimpleBlocObserver`, we just need to tweak the `main` function:

[main.dart](_snippets/core_concepts/simple_bloc_observer_on_change_usage.dart.md ':include')

The above snippet would then output:

[script](_snippets/core_concepts/counter_cubit_on_change_usage_output.sh.md ':include')

?> **Note**: The internal `onChange` override is called first, followed by `onChange` in `BlocObserver`.

?> 💡 **Tip**: In `BlocObserver` we have access to the `Cubit` instance in addition to the `Change` itself.

### Error Handling

> Every `Cubit` has an `addError` method which can be used to indicate that an error has occurred.

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_on_error.dart.md ':include')

?> **Note**: `onError` can be overridden within the `Cubit` to handle all errors for a specific `Cubit`.

`onError` can also be overridden in `BlocObserver` to handle all reported errors globally.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_error.dart.md ':include')

If we run the same program again we should see the following output:

[script](_snippets/core_concepts/counter_cubit_on_error_output.sh.md ':include')

?> **Note**: Just as with `onChange`, the internal `onError` override is invoked before the global `BlocObserver` override.

## Bloc

> A `Bloc` is a more advanced class which relies on `events` to trigger `state` changes rather than functions. `Bloc` also extends `BlocBase` which means it has a similar public API as `Cubit`. However, rather than calling a `function` on a `Bloc` and directly emitting a new `state`, `Blocs` receive `events` and convert the incoming `events` into outgoing `states`.

![Bloc Architecture](assets/bloc_architecture_full.png)

### Creating a Bloc

Creating a `Bloc` is similar to creating a `Cubit` except in addition to defining the state that we'll be managing, we must also define the event that the `Bloc` will be able to process.

> Events are the input to a Bloc. They are commonly added in response to user interactions such as button presses or lifecycle events like page loads.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc.dart.md ':include')

Just like when creating the `CounterCubit`, we must specify an initial state by passing it to the superclass via `super`.

### State Changes

`Bloc` requires us to register event handlers via the `on<Event>` API, as opposed to functions in `Cubit`. An event handler is responsible for converting any incoming events into zero or more outgoing states.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_event_handler.dart.md ':include')

?> 💡 **Tip**: an `EventHandler` has access to the added event as well as an `Emitter` which can be used to emit zero or more states in response to the incoming event.

We can then update the `EventHandler` to handle the `CounterIncrementPressed` event:

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_increment.dart.md ':include')

In the above snippet, we have registered an `EventHandler` to manage all `CounterIncrementPressed` events. For each incoming `CounterIncrementPressed` event we can access the current state of the bloc via the `state` getter and `emit(state + 1)`.

?> **Note**: Since the `Bloc` class extends `BlocBase`, we have access to the current state of the bloc at any point in time via the `state` getter just like in `Cubit`.

!> Blocs should never directly `emit` new states. Instead every state change must be output in response to an incoming event within an `EventHandler`.

!> Both blocs and cubits will ignore duplicate states. If we emit `State nextState` where `state == nextState`, then no state change will occur.

### Using a Bloc

At this point, we can create an instance of our `CounterBloc` and put it to use!

#### Basic Usage

[main.dart](_snippets/core_concepts/counter_bloc_usage.dart.md ':include')

In the above snippet, we start by creating an instance of the `CounterBloc`. We then print the current state of the `Bloc` which is the initial state (since no new states have been emitted yet). Next, we add the `CounterIncrementPressed` event to trigger a state change. Finally, we print the state of the `Bloc` again which went from `0` to `1` and call `close` on the `Bloc` to close the internal state stream.

?> **Note**: `await Future.delayed(Duration.zero)` is added to ensure we wait for the next event-loop iteration (allowing the `EventHandler` to process the event).

#### Stream Usage

Just like with `Cubit`, a `Bloc` is a special type of `Stream`, which means we can also subscribe to a `Bloc` for real-time updates to its state:

[main.dart](_snippets/core_concepts/counter_bloc_stream_usage.dart.md ':include')

In the above snippet, we are subscribing to the `CounterBloc` and calling print on each state change. We are then adding the `CounterIncrementPressed` event which triggers the `on<CounterIncrementPressed>` `EventHandler` and emits a new state. Lastly, we are calling `cancel` on the subscription when we no longer want to receive updates and closing the `Bloc`.

?> **Note**: `await Future.delayed(Duration.zero)` is added for this example to avoid canceling the subscription immediately.

### Observing a Bloc

Since `Bloc` extends `BlocBase`, we can observe all state changes for a `Bloc` using `onChange`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_change.dart.md ':include')

We can then update `main.dart` to:

[main.dart](_snippets/core_concepts/counter_bloc_on_change_usage.dart.md ':include')

Now if we run the above snippet, the output will be:

[script](_snippets/core_concepts/counter_bloc_on_change_output.sh.md ':include')

One key differentiating factor between `Bloc` and `Cubit` is that because `Bloc` is event-driven, we are also able to capture information about what triggered the state change.

We can do this by overriding `onTransition`.

> The change from one state to another is called a `Transition`. A `Transition` consists of the current state, the event, and the next state.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

If we then rerun the same `main.dart` snippet from before, we should see the following output:

[script](_snippets/core_concepts/counter_bloc_on_transition_output.sh.md ':include')

?> **Note**: `onTransition` is invoked before `onChange` and contains the event which triggered the change from `currentState` to `nextState`.

#### BlocObserver

Just as before, we can override `onTransition` in a custom `BlocObserver` to observe all transitions that occur from a single place.

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_transition.dart.md ':include')

We can initialize the `SimpleBlocObserver` just like before:

[main.dart](_snippets/core_concepts/simple_bloc_observer_on_transition_usage.dart.md ':include')

Now if we run the above snippet, the output should look like:

[script](_snippets/core_concepts/simple_bloc_observer_on_transition_output.sh.md ':include')

?> **Note**: `onTransition` is invoked first (local before global) followed by `onChange`.

Another unique feature of `Bloc` instances is that they allow us to override `onEvent` which is called whenever a new event is added to the `Bloc`. Just like with `onChange` and `onTransition`, `onEvent` can be overridden locally as well as globally.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_event.dart.md ':include')

[simple_bloc_observer.dart](_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

We can run the same `main.dart` as before and should see the following output:

[script](_snippets/core_concepts/simple_bloc_observer_on_event_output.sh.md ':include')

?> **Note**: `onEvent` is called as soon as the event is added. The local `onEvent` is invoked before the global `onEvent` in `BlocObserver`.

### Error Handling

Just like with `Cubit`, each `Bloc` has an `addError` and `onError` method. We can indicate that an error has occurred by calling `addError` from anywhere inside our `Bloc`. We can then react to all errors by overriding `onError` just as with `Cubit`.

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

If we rerun the same `main.dart` as before, we can see what it looks like when an error is reported:

[script](_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **Note**: The local `onError` is invoked first followed by the global `onError` in `BlocObserver`.

?> **Note**: `onError` and `onChange` work the exact same way for both `Bloc` and `Cubit` instances.

!> Any unhandled exceptions that occur within an `EventHandler` are also reported to `onError`.

## Cubit vs. Bloc

Now that we've covered the basics of the `Cubit` and `Bloc` classes, you might be wondering when you should use `Cubit` and when you should use `Bloc`.

### Cubit Advantages

#### Simplicity

One of the biggest advantages of using `Cubit` is simplicity. When creating a `Cubit`, we only have to define the state as well as the functions which we want to expose to change the state. In comparison, when creating a `Bloc`, we have to define the states, events, and the `EventHandler` implementation. This makes `Cubit` easier to understand and there is less code involved.

Now let's take a look at the two counter implementations:

##### CounterCubit

[counter_cubit.dart](_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](_snippets/core_concepts/counter_bloc_full.dart.md ':include')

The `Cubit` implementation is more concise and instead of defining events separately, the functions act like events. In addition, when using a `Cubit`, we can simply call `emit` from anywhere in order to trigger a state change.

### Bloc Advantages

#### Traceability

One of the biggest advantages of using `Bloc` is knowing the sequence of state changes as well as exactly what triggered those changes. For state that is critical to the functionality of an application, it might be very beneficial to use a more event-driven approach in order to capture all events in addition to state changes.

A common use case might be managing `AuthenticationState`. For simplicity, let's say we can represent `AuthenticationState` via an `enum`:

[authentication_state.dart](_snippets/core_concepts/authentication_state.dart.md ':include')

There could be many reasons as to why the application's state could change from `authenticated` to `unauthenticated`. For example, the user might have tapped a logout button and requested to be signed out of the application. On the other hand, maybe the user's access token was revoked and they were forcefully logged out. When using `Bloc` we can clearly trace how the application state got to a certain state.

[script](_snippets/core_concepts/authentication_transition.sh.md ':include')

The above `Transition` gives us all the information we need to understand why the state changed. If we had used a `Cubit` to manage the `AuthenticationState`, our logs would look like:

[script](_snippets/core_concepts/authentication_change.sh.md ':include')

This tells us that the user was logged out but it doesn't explain why which might be critical to debugging and understanding how the state of the application is changing over time.

#### Advanced Event Transformations

Another area in which `Bloc` excels over `Cubit` is when we need to take advantage of reactive operators such as `buffer`, `debounceTime`, `throttle`, etc.

`Bloc` has an event sink that allows us to control and transform the incoming flow of events.

For example, if we were building a real-time search, we would probably want to debounce the requests to the backend in order to avoid getting rate-limited as well as to cut down on cost/load on the backend.

With `Bloc` we can provide a custom `EventTransformer` to change the way incoming events are processed by the `Bloc`.

[counter_bloc.dart](_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

With the above code, we can easily debounce the incoming events with very little additional code.

?> 💡 **Tip**: Check out [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) for an opinionated set of event transformers.

?> 💡 **Tip**: If you are still unsure about which to use, start with `Cubit` and you can later refactor or scale-up to a `Bloc` as needed.
