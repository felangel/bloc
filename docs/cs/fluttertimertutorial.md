# Tutoriál: Časovač ve Flutteru

?> **Poznámka:** Tento tutoriál ještě nemá překlad.

![beginner](https://img.shields.io/badge/úroveň-začátečník-green.svg)

> In the following tutorial we’re going to cover how to build a timer application using the bloc library. The finished application should look like this:

![demo](../assets/gifs/flutter_timer.gif)

## Setup

We’ll start off by creating a brand new Flutter project

```sh
flutter create flutter_timer
```

We can then replace the contents of pubspec.yaml with:

```yaml
name: flutter_timer
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.2.2 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  equatable: ^0.6.0
  wave: ^0.0.8

flutter:
  uses-material-design: true
```

?> **Note:** We’ll be using the [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable), and [wave](https://pub.dev/packages/wave) packages in this app.

Next, run `flutter packages get` to install all the dependencies.

## Ticker

> The ticker will be our data source for the timer application. It will expose a stream of ticks which we can subscribe and react to.

Start off by creating `ticker.dart`.

```dart
class Ticker {
  Stream<int> tick({int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
```

All our `Ticker` class does is expose a tick function which takes the number of ticks (seconds) we want and returns a stream which emits the remaining seconds every second.

Next up, we need to create our `TimerBloc` which will consume the `Ticker`.

## Timer Bloc

### TimerState

We’ll start off by defining the `TimerStates` which our `TimerBloc` can be in.

Our `TimerBloc` state can be one of the following:

- Ready — ready to start counting down from the specified duration.
- Running — actively counting down from the specified duration.
- Paused — paused at some remaining duration.
- Finished — completed with a remaining duration of 0.

Each of these states will have an implication on what the user sees. For example:

- if the state is “ready,” the user will be able to start the timer.
- if the state is “running,” the user will be able to pause and reset the timer as well as see the remaining duration.
- if the state is “paused,” the user will be able to resume the timer and reset the timer.
- if the state is “finished,” the user will be able to reset the timer.

In order to keep all of our bloc files together, let’s create a bloc directory with `bloc/timer_state.dart`.

?> **Tip:** You can use the [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) or [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) extensions to autogenerate the following bloc files for you.

```dart
import 'package:equatable/equatable.dart';

abstract class TimerState extends Equatable {
  final int duration;

  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class Ready extends TimerState {
  const Ready(int duration) : super(duration);

  @override
  String toString() => 'Ready { duration: $duration }';
}

class Paused extends TimerState {
  const Paused(int duration) : super(duration);

  @override
  String toString() => 'Paused { duration: $duration }';
}

class Running extends TimerState {
  const Running(int duration) : super(duration);

  @override
  String toString() => 'Running { duration: $duration }';
}

class Finished extends TimerState {
  const Finished() : super(0);
}
```

Note that all of the `TimerStates` extend the abstract base class `TimerState` which has a duration property. This is because no matter what state our `TimerBloc` is in, we want to know how much time is remaining.

Next up, let’s define and implement the `TimerEvents` which our `TimerBloc` will be processing.

### TimerEvent

Our `TimerBloc` will need to know how to process the following events:

- Start — informs the TimerBloc that the timer should be started.
- Pause — informs the TimerBloc that the timer should be paused.
- Resume — informs the TimerBloc that the timer should be resumed.
- Reset — informs the TimerBloc that the timer should be reset to the original state.
- Tick — informs the TimerBloc that a tick has occurred and that it needs to update its state accordingly.

If you didn’t use the [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) or [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) extensions, then create `bloc/timer_event.dart` and let’s implement those events.

```dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class Start extends TimerEvent {
  final int duration;

  const Start({@required this.duration});

  @override
  String toString() => "Start { duration: $duration }";
}

class Pause extends TimerEvent {}

class Resume extends TimerEvent {}

class Reset extends TimerEvent {}

class Tick extends TimerEvent {
  final int duration;

  const Tick({@required this.duration});

  @override
  List<Object> get props => [duration];

  @override
  String toString() => "Tick { duration: $duration }";
}
```

Next up, let’s implement the `TimerBloc`!

### TimerBloc

If you haven’t already, create `bloc/timer_bloc.dart` and create a empty `TimerBloc`.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  @override
  TimerState get initialState => // TODO: implement initialState;

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
```

The first thing we need to do is define the `initialState` of our `TimerBloc`. In this case, we want the `TimerBloc` to start off in the `Ready` state with a preset duration of 1 minute (60 seconds).

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final int _duration = 60;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
```

Next, we need to define the dependency on our `Ticker`.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
```

We are also defining a `StreamSubscription` for our `Ticker` which we will get to in a bit.

At this point, all that’s left to do is implement `mapEventToState`. For improved readability, I like to break out each event handler into its own helper function. We’ll start with the `Start` event.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
     yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }
}
```

If the `TimerBloc` receives a `Start` event, it pushes a `Running` state with the start duration. In addition, if there was already an open `_tickerSubscription` we need to cancel it to deallocate the memory. We also need to override the `close` method on our `TimerBloc` so that we can cancel the `_tickerSubscription` when the `TimerBloc` is closed. Lastly, we listen to the `_ticker.tick` stream and on every tick we add a `Tick` event with the remaining duration.

Next, let’s implement the `Tick` event handler.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
     yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }
}
```

Every time a `Tick` event is received, if the tick’s duration is greater than 0, we need to push an updated `Running` state with the new duration. Otherwise, if the tick’s duration is 0, our timer has ended and we need to push a `Finished` state.

Now let’s implement the `Pause` event handler.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
     yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  Stream<TimerState> _mapPauseToState(Pause pause) async* {
    if (state is Running) {
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }
}
```

In `_mapPauseToState` if the `state` of our `TimerBloc` is `Running`, then we can pause the `_tickerSubscription` and push a `Paused` state with the current timer duration.

Next, let’s implement the `Resume` event handler so that we can unpause the timer.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Resume) {
      yield* _mapResumeToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
     yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  Stream<TimerState> _mapPauseToState(Pause pause) async* {
    if (state is Running) {
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }
  }

  Stream<TimerState> _mapResumeToState(Resume pause) async* {
    if (state is Paused) {
      _tickerSubscription?.resume();
      yield Running(state.duration);
    }
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }
}
```

The `Resume` event handler is very similar to the `Pause` event handler. If the `TimerBloc` has a `state` of `Paused` and it receives a `Resume` event, then it resumes the `_tickerSubscription` and pushes a `Running` state with the current duration.

Lastly, we need to implement the `Reset` event handler.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => Ready(_duration);

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if (event is Pause) {
      yield* _mapPauseToState(event);
    } else if (event is Resume) {
      yield* _mapResumeToState(event);
    } else if (event is Reset) {
      yield* _mapResetToState(event);
    } else if (event is Tick) {
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
     yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  Stream<TimerState> _mapPauseToState(Pause pause) async* {
    final state = currentState;
    if (state is Running) {
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }
  }

  Stream<TimerState> _mapResumeToState(Resume pause) async* {
    final state = currentState;
    if (state is Paused) {
      _tickerSubscription?.resume();
      yield Running(state.duration);
    }
  }

  Stream<TimerState> _mapResetToState(Reset reset) async* {
    _tickerSubscription?.cancel();
    yield Ready(_duration);
  }

  Stream<TimerState> _mapTickToState(Tick tick) async* {
    yield tick.duration > 0 ? Running(tick.duration) : Finished();
  }
}
```

If the `TimerBloc` receives a `Reset` event, it needs to cancel the current `_tickerSubscription` so that it isn’t notified of any additional ticks and pushes a `Ready` state with the original duration.

If you didn’t use the [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) or [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) extensions be sure to create `bloc/bloc.dart` in order to export all the bloc files and make it possible to use a single import for convenience.

```dart
export 'timer_bloc.dart';
export 'timer_event.dart';
export 'timer_state.dart';
```

That’s all there is to the `TimerBloc`. Now all that’s left is implement the UI for our Timer Application.

## Application UI

### MyApp

We can start off by deleting the contents of `main.dart` and creating our `MyApp` widget which will be the root of our application.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Flutter Timer',
      home: BlocProvider(
        create: (context) => TimerBloc(ticker: Ticker()),
        child: Timer(),
      ),
    );
  }
}
```

`MyApp` is a `StatelessWidget` which will manage initializing and closing an instance of `TimerBloc`. In addition, it’s using the `BlocProvider` widget in order to make our `TimerBloc` instance available to the widgets in our subtree.

Next, we need to implement our `Timer` widget.

### Timer

Our `Timer` widget will be responsible for displaying the remaining time along with the proper buttons which will enable users to start, pause, and reset the timer.

```dart
class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Timer')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 100.0),
            child: Center(
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                  final String minutesStr = ((state.duration / 60) % 60)
                      .floor()
                      .toString()
                      .padLeft(2, '0');
                  final String secondsStr =
                      (state.duration % 60).floor().toString().padLeft(2, '0');
                  return Text(
                    '$minutesStr:$secondsStr',
                    style: Timer.timerTextStyle,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

So far, we’re just using `BlocProvider` to access the instance of our `TimerBloc` and using a `BlocBuilder` widget in order to rebuild the UI every time we get a new `TimerState`.

Next, we’re going to implement our `Actions` widget which will have the proper actions (start, pause, and reset).

### Actions

```dart
class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;
    if (currentState is Ready) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () =>
              timerBloc.add(Start(duration: currentState.duration)),
        ),
      ];
    }
    if (currentState is Running) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(Pause()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    if (currentState is Paused) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(Resume()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    if (currentState is Finished) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    return [];
  }
}
```

The `Actions` widget is just another `StatelessWidget` which uses `BlocProvider` to access the `TimerBloc` instance and then returns different `FloatingActionButtons` based on the current state of the `TimerBloc`. Each of the `FloatingActionButtons` adds an event in its `onPressed` callback to notify the `TimerBloc`.

Now we need to hook up the `Actions` to our `Timer` widget.

```dart
class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Timer')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 100.0),
            child: Center(
              child: BlocBuilder<TimerBloc, TimerState>(
                builder: (context, state) {
                  final String minutesStr = ((state.duration / 60) % 60)
                      .floor()
                      .toString()
                      .padLeft(2, '0');
                  final String secondsStr =
                      (state.duration % 60).floor().toString().padLeft(2, '0');
                  return Text(
                    '$minutesStr:$secondsStr',
                    style: Timer.timerTextStyle,
                  );
                },
              ),
            ),
          ),
          BlocBuilder<TimerBloc, TimerState>(
            condition: (previousState, state) =>
                state.runtimeType != previousState.runtimeType,
            builder: (context, state) => Actions(),
          ),
        ],
      ),
    );
  }
}
```

We added another `BlocBuilder` which will render the `Actions` widget; however, this time we’re using a newly introduced [flutter_bloc](https://pub.dev/packages/flutter_bloc) feature to control how frequently the `Actions` widget is rebuilt (introduced in `v0.15.0`).

If you want fine-grained control over when the `builder` function is called you can provide an optional `condition` to `BlocBuilder`. The `condition` takes the previous bloc state and current bloc state and returns a `boolean`. If `condition` returns `true`, `builder` will be called with `state` and the widget will rebuild. If `condition` returns `false`, `builder` will not be called with `state` and no rebuild will occur.

In this case, we don’t want the `Actions` widget to be rebuilt on every tick because that would be inefficient. Instead, we only want `Actions` to rebuild if the `runtimeType` of the `TimerState` changes (Ready => Running, Running => Paused, etc...).

As a result, if we randomly colored the widgets on every rebuild, it would look like:

![BlocBuilder condition demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Notice:** Even though the `Text` widget is rebuilt on every tick, we only rebuild the `Actions` if they need to be rebuilt.

Lastly, we need to add the super cool wave background using the [wave](https://pub.dev/packages/wave) package.

### Waves Background

```dart
import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [
            Color.fromRGBO(72, 74, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(184, 189, 245, 0.7)
          ],
          [
            Color.fromRGBO(72, 74, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(172, 182, 219, 0.7)
          ],
          [
            Color.fromRGBO(72, 73, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(190, 238, 246, 0.7)
          ],
        ],
        durations: [19440, 10800, 6000],
        heightPercentages: [0.03, 0.01, 0.02],
        gradientBegin: Alignment.bottomCenter,
        gradientEnd: Alignment.topCenter,
      ),
      size: Size(double.infinity, double.infinity),
      waveAmplitude: 25,
      backgroundColor: Colors.blue[50],
    );
  }
}
```

### Putting it all together

Our finished, `main.dart` should look like:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Flutter Timer',
      home: BlocProvider(
        create: (context) => TimerBloc(ticker: Ticker()),
        child: Timer(),
      ),
    );
  }
}

class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Timer')),
      body: Stack(
        children: [
          Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(
                  child: BlocBuilder<TimerBloc, TimerState>(
                    builder: (context, state) {
                      final String minutesStr = ((state.duration / 60) % 60)
                          .floor()
                          .toString()
                          .padLeft(2, '0');
                      final String secondsStr = (state.duration % 60)
                          .floor()
                          .toString()
                          .padLeft(2, '0');
                      return Text(
                        '$minutesStr:$secondsStr',
                        style: Timer.timerTextStyle,
                      );
                    },
                  ),
                ),
              ),
              BlocBuilder<TimerBloc, TimerState>(
                condition: (previousState, currentState) =>
                    currentState.runtimeType != previousState.runtimeType,
                builder: (context, state) => Actions(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        timerBloc: BlocProvider.of<TimerBloc>(context),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;
    if (currentState is Ready) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () =>
              timerBloc.add(Start(duration: currentState.duration)),
        ),
      ];
    }
    if (currentState is Running) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(Pause()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    if (currentState is Paused) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(Resume()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    if (currentState is Finished) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(Reset()),
        ),
      ];
    }
    return [];
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [
            Color.fromRGBO(72, 74, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(184, 189, 245, 0.7)
          ],
          [
            Color.fromRGBO(72, 74, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(172, 182, 219, 0.7)
          ],
          [
            Color.fromRGBO(72, 73, 126, 1),
            Color.fromRGBO(125, 170, 206, 1),
            Color.fromRGBO(190, 238, 246, 0.7)
          ],
        ],
        durations: [19440, 10800, 6000],
        heightPercentages: [0.03, 0.01, 0.02],
        gradientBegin: Alignment.bottomCenter,
        gradientEnd: Alignment.topCenter,
      ),
      size: Size(double.infinity, double.infinity),
      waveAmplitude: 25,
      backgroundColor: Colors.blue[50],
    );
  }
}
```

That’s all there is to it! At this point we have a pretty solid timer application which efficiently rebuilds only widgets that need to be rebuilt.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
