# Flutter Timer Tutorial

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> In the following tutorial we’re going to cover how to build a timer application using the bloc library. The finished application should look like this:

![demo](./assets/gifs/flutter_timer.gif)

## Key Topics

- Observe state changes with [BlocObserver](/coreconcepts?id=blocobserver).
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), Flutter widget which provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), Flutter widget that handles building the widget in response to new states.
- Prevent unnecessary rebuilds with [Equatable](/faqs?id=when-to-use-equatable).
- Learn to use `StreamSubscription` in a Bloc.
- Prevent unnecessary rebuilds with `buildWhen`.

## Setup

We’ll start off by creating a brand new Flutter project:

[script](_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

We can then replace the contents of pubspec.yaml with:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/pubspec.yaml ':include')

?> **Note:** We’ll be using the [flutter_bloc](https://pub.dev/packages/flutter_bloc) and [equatable](https://pub.dev/packages/equatable) packages in this app.

Next, run `flutter packages get` to install all the dependencies.

## Ticker

> The ticker will be our data source for the timer application. It will expose a stream of ticks which we can subscribe and react to.

Start off by creating `ticker.dart`.

[ticker.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/ticker.dart ':include')

All our `Ticker` class does is expose a tick function which takes the number of ticks (seconds) we want and returns a stream which emits the remaining seconds every second.

Next up, we need to create our `TimerBloc` which will consume the `Ticker`.

## Timer Bloc

### TimerState

We’ll start off by defining the `TimerStates` which our `TimerBloc` can be in.

Our `TimerBloc` state can be one of the following:

- TimerInitial — ready to start counting down from the specified duration.
- TimerRunInProgress — actively counting down from the specified duration.
- TimerRunPause — paused at some remaining duration.
- TimerRunComplete — completed with a remaining duration of 0.

Each of these states will have an implication on the user interface and actions that the user can perform. For example:

- if the state is `TimerInitial` the user will be able to start the timer.
- if the state is `TimerRunInProgress` the user will be able to pause and reset the timer as well as see the remaining duration.
- if the state is `TimerRunPause` the user will be able to resume the timer and reset the timer.
- if the state is `TimerRunComplete` the user will be able to reset the timer.

In order to keep all of our bloc files together, let’s create a bloc directory with `bloc/timer_state.dart`.

?> **Tip:** You can use the [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) or [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) extensions to autogenerate the following bloc files for you.

[timer_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/bloc/timer_state.dart ':include')

Note that all of the `TimerStates` extend the abstract base class `TimerState` which has a duration property. This is because no matter what state our `TimerBloc` is in, we want to know how much time is remaining. Additionally, `TimerState` extends `Equatable` to optimize our code by ensuring that our app does not trigger rebuilds if the same state occurs. 

Next up, let’s define and implement the `TimerEvents` which our `TimerBloc` will be processing.

### TimerEvent

Our `TimerBloc` will need to know how to process the following events:

- TimerStarted — informs the TimerBloc that the timer should be started.
- TimerPaused — informs the TimerBloc that the timer should be paused.
- TimerResumed — informs the TimerBloc that the timer should be resumed.
- TimerReset — informs the TimerBloc that the timer should be reset to the original state.
- TimerTicked — informs the TimerBloc that a tick has occurred and that it needs to update its state accordingly.

If you didn’t use the [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) or [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) extensions, then create `bloc/timer_event.dart` and let’s implement those events.

[timer_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/bloc/timer_event.dart ':include')

Next up, let’s implement the `TimerBloc`!

### TimerBloc

If you haven’t already, create `bloc/timer_bloc.dart` and create an empty `TimerBloc`.

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_empty.dart.md ':include')

The first thing we need to do is define the initial state of our `TimerBloc`. In this case, we want the `TimerBloc` to start off in the `TimerInitial` state with a preset duration of 1 minute (60 seconds).

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

Next, we need to define the dependency on our `Ticker`.

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

We are also defining a `StreamSubscription` for our `Ticker` which we will get to in a bit.

At this point, all that’s left to do is implement the event handlers. For improved readability, I like to break out each event handler into its own helper function. We’ll start with the `TimerStarted` event.

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

If the `TimerBloc` receives a `TimerStarted` event, it pushes a `TimerRunInProgress` state with the start duration. In addition, if there was already an open `_tickerSubscription` we need to cancel it to deallocate the memory. We also need to override the `close` method on our `TimerBloc` so that we can cancel the `_tickerSubscription` when the `TimerBloc` is closed. Lastly, we listen to the `_ticker.tick` stream and on every tick we add a `TimerTicked` event with the remaining duration.

Next, let’s implement the `TimerTicked` event handler.

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

Every time a `TimerTicked` event is received, if the tick’s duration is greater than 0, we need to push an updated `TimerRunInProgress` state with the new duration. Otherwise, if the tick’s duration is 0, our timer has ended and we need to push a `TimerRunComplete` state.

Now let’s implement the `TimerPaused` event handler.

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

In `_onPaused` if the `state` of our `TimerBloc` is `TimerRunInProgress`, then we can pause the `_tickerSubscription` and push a `TimerRunPause` state with the current timer duration.

Next, let’s implement the `TimerResumed` event handler so that we can unpause the timer.

[timer_bloc.dart](_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

The `TimerResumed` event handler is very similar to the `TimerPaused` event handler. If the `TimerBloc` has a `state` of `TimerRunPause` and it receives a `TimerResumed` event, then it resumes the `_tickerSubscription` and pushes a `TimerRunInProgress` state with the current duration.

Lastly, we need to implement the `TimerReset` event handler.

[timer_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/bloc/timer_bloc.dart ':include')

If the `TimerBloc` receives a `TimerReset` event, it needs to cancel the current `_tickerSubscription` so that it isn’t notified of any additional ticks and pushes a `TimerInitial` state with the original duration.

That’s all there is to the `TimerBloc`. Now all that’s left is implement the UI for our Timer Application.

## Application UI

### MyApp

We can start off by deleting the contents of `main.dart` and replacing it with the following.

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/main.dart ':include')

Next, let's create our 'App' widget in `app.dart`, which will be the root of our application.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/app.dart ':include')

Next, we need to implement our `Timer` widget.

### Timer

Our `Timer` widget (`/timer/view/timer_page.dart`) will be responsible for displaying the remaining time along with the proper buttons which will enable users to start, pause, and reset the timer.

[timer.dart](_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

So far, we’re just using `BlocProvider` to access the instance of our `TimerBloc`.

Next, we’re going to implement our `Actions` widget which will have the proper actions (start, pause, and reset).

### Barrel

In order to clean up our imports from the `Timer` section, we need to create a barrel file `timer/timer.dart`.

[timer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/timer.dart ':include')

### Actions

[actions.dart](_snippets/flutter_timer_tutorial/actions.dart.md ':include')

The `Actions` widget is just another `StatelessWidget` which uses a `BlocBuilder` to rebuild the UI every time we get a new `TimerState`. `Actions` uses `context.read<TimerBloc>()` to access the `TimerBloc` instance and returns different `FloatingActionButtons` based on the current state of the `TimerBloc`. Each of the `FloatingActionButtons` adds an event in its `onPressed` callback to notify the `TimerBloc`.

If you want fine-grained control over when the `builder` function is called you can provide an optional `buildWhen` to `BlocBuilder`. The `buildWhen` takes the previous bloc state and current bloc state and returns a `boolean`. If `buildWhen` returns `true`, `builder` will be called with `state` and the widget will rebuild. If `buildWhen` returns `false`, `builder` will not be called with `state` and no rebuild will occur.

In this case, we don’t want the `Actions` widget to be rebuilt on every tick because that would be inefficient. Instead, we only want `Actions` to rebuild if the `runtimeType` of the `TimerState` changes (TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, etc...).

As a result, if we randomly colored the widgets on every rebuild, it would look like:

![BlocBuilder buildWhen demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Notice:** Even though the `Text` widget is rebuilt on every tick, we only rebuild the `Actions` if they need to be rebuilt.

### Background

Lastly, add the background widget as follows:

[background.dart](_snippets/flutter_timer_tutorial/background.dart.md ':include')

### Putting it all together

That’s all there is to it! At this point we have a pretty solid timer application which efficiently rebuilds only widgets that need to be rebuilt.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
