# Flutter Таймер

![начинающий](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы расскажем, как создать приложение таймера с помощью библиотеки `bloc`. Готовое приложение должно выглядеть так:

![демо](../assets/gifs/flutter_timer.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```sh
flutter create flutter_timer
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_timer
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  equatable: ^1.0.0
  wave: ^0.0.8

flutter:
  uses-material-design: true
```

Затем запустить `flutter packages get`, чтобы установить все зависимости.

?> **Примечание:** В этом приложении мы будем использовать [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable) и [wave](https://pub.dev/packages/wave) пакеты.

## Тикер

> `Ticker` будет нашим источником данных для приложения таймера. Он создаст поток тиков, на которые мы можем подписаться и на которые будем реагировать.

Начнем с создания `ticker.dart`.

```dart
class Ticker {
  Stream<int> tick({int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
```

Все, что делает наш класс `Ticker` - предоставляет функцию tick, которая принимает желаемое количество тиков (секунд) и возвращает поток, который генерирует оставшиеся секунды каждую секунду.

Далее нам нужно создать наш `TimerBloc`, который будет использовать `Ticker`.

## Bloc таймера

### Состояние

Мы начнем с определения `TimerStates`, в котором может находиться наш `TimerBloc`.

Наше состояние `TimerBloc` может быть одним из следующих:

- Ready — готов начать обратный отсчет с указанной продолжительностью.
- Running — отсчитывает в обратном порядке указанную продолжительность.
- Paused — остановлен на одном из значений оставшейся продолжительности.
- Finished — завершен с оставшейся продолжительностью 0.

Каждое из этих состояний будет влиять на то, что видит пользователь. Например:

- если состояние `Ready`, пользователь сможет запустить таймер.
- если состояние `Running` пользователь сможет приостановить или сбросить таймер, а также увидеть оставшуюся продолжительность.
- если состояние `Paused`, пользователь может возобновить или сбросить таймер.
- если состояние `Finished`, пользователь может сбросить таймер.

Чтобы держать все наши файлы блоков вместе, давайте создадим каталог `bloc` c файлом `bloc/timer_state.dart`.

?> **Совет:** Вы можете использовать [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) расширения для автоматического создания следующих файлов блока.

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

Обратите внимание, что все `TimerStates` расширяют абстрактный базовый класс `TimerState`, который имеет свойство `duration`. Это потому, что независимо от того, в каком состоянии находится наш `TimerBloc`, мы хотим знать сколько времени осталось.

Далее, давайте определим и реализуем `TimerEvents`, который будет обрабатывать наш `TimerBloc`.

### События

Наш `TimerBloc` должен знать, как обрабатывать следующие события:

- Start — сообщает TimerBloc, что таймер должен быть запущен.
- Pause — сообщает TimerBloc, что таймер должен быть приостановлен.
- Resume — сообщает TimerBloc, что работа таймера должна быть возобновлена.
- Reset — сообщает TimerBloc, что таймер должен быть сброшен в исходное состояние.
- Tick — информирует TimerBloc о том, что произошел тик и что ему необходимо соответствующим образом обновить свое состояние.

Если вы не использовали [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), создадим файл `bloc/timer_event.dart` и реализуем эти события.

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

Далее давайте реализуем `TimerBloc`!

### Блок

Если вы этого еще не сделали, создайте `bloc/timer_bloc.dart` и создайте пустой `TimerBloc`.

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

Первое, что нам нужно сделать, это определить `initialState` нашего `TimerBloc`. В этом случае мы хотим, чтобы `TimerBloc` запускался в состоянии `Ready` с заданной продолжительностью 1 минута (60 секунд).

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

Далее нам нужно определить зависимость от нашего `Ticker`.

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

Мы также определяем `StreamSubscription` для нашего `Ticker`, к которому мы скоро перейдем.

На данный момент все, что осталось сделать, это реализовать `mapEventToState`. Для улучшения читаемости мне нравится разбивать каждый обработчик событий на его собственную вспомогательную функцию. Начнем с события `Start`.

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

Если `TimerBloc` получает событие `Start`, он переводит состояние в `Running` с первоначальной продолжительностью. Кроме того, если уже была открытая `_tickerSubscription`, нам нужно отменить ее, чтобы освободить память. Нам также нужно переопределить метод `close` нашего `TimerBloc`, чтобы мы могли отменить `_tickerSubscription` когда `TimerBloc` закрыт. Наконец, мы слушаем поток `_ticker.tick` и на каждом тике мы добавляем событие `Tick` с оставшейся продолжительностью.

Теперь давайте реализуем обработчик событий `Tick`.

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

Каждый раз, когда получено событие `Tick`, если длительность тика больше 0, нам нужно выставить обновленное состояние `Running` с новой продолжительностью. В противном случае, если длительность тика равна 0, наш таймер закончился и нам нужно перейти в состояние `Finished`.

Теперь давайте реализуем обработчик событий `Pause`.

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

В `_mapPauseToState`, если `state` нашего `TimerBloc` равно `Running`, тогда мы можем приостановить `_tickerSubscription` и выставить состояние `Paused` с текущей длительностью таймера.

Далее, давайте реализуем обработчик событий `Resume`, чтобы мы могли отключать таймер.

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

  Stream<TimerState> _mapResumeToState(Resume resume) async* {
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

Обработчик события `Resume` очень похож на обработчик события `Pause`. Если `TimerBloc` имеет `state` `Paused` и он получает событие `Resume`, то он возобновляет `_tickerSubscription` и выставляет состояние `Running` с текущей продолжительностью.

Наконец, нам нужно реализовать обработчик события `Reset`.

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

  Stream<TimerState> _mapResumeToState(Resume resume) async* {
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

Если `TimerBloc` получает событие `Reset`, ему необходимо отменить текущую `_tickerSubscription`, чтобы он не уведомлялся о каких-либо дополнительных тиках и выставить состояние `Ready` с первоначальной продолжительностью.

Если вы не использовали [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) расширения, обязательно создайте `bloc/bloc.dart` для того, чтобы экспортировать все файлы блока и для удобства использовать один импорт.

```dart
export 'timer_bloc.dart';
export 'timer_event.dart';
export 'timer_state.dart';
```

Это все, что есть в `TimerBloc`. Теперь осталось только реализовать пользовательский интерфейс для нашего приложения `Timer`.

## UI приложения

### MyApp

Мы можем начать с удаления содержимого файла `main.dart` и создания нашего виджета `MyApp`, который будет корнем нашего приложения.

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

`MyApp` - это `StatelessWidget`, который будет управлять инициализацией и закрытием экземпляра `TimerBloc`. Кроме того, он использует виджет `BlocProvider`, чтобы сделать наш экземпляр `TimerBloc` доступным для виджетов в нашем поддереве.

Далее нам нужно реализовать наш виджет `Timer`.

### Таймер

Наш виджет `Таймер` будет отвечать за отображение оставшегося времени вместе с соответствующими кнопками, которые позволят пользователям запускать, приостанавливать и сбрасывать таймер.

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

Пока что мы просто используем `BlocProvider` для доступа к экземпляру нашего `TimerBloc` и используем виджет `BlocBuilder` для перестройки пользовательского интерфейса каждый раз, когда мы получаем новый `TimerState`.

Далее мы собираемся реализовать наш виджет `Actions`, который будет иметь соответствующие действия (запуск, пауза и сброс).

### Действия

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

Виджет `Actions` - это просто еще один `StatelessWidget`, который использует `BlocProvider` для доступа к экземпляру `TimerBloc`, а затем возвращает различные `FloatingActionButtons` в зависимости от текущего состояния `TimerBloc`. Каждый из `FloatingActionButtons` добавляет событие в свой обратный вызов `onPressed`, чтобы уведомить `TimerBloc`.

Теперь нам нужно подключить `Actions` к нашему виджету `Timer`.

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

Мы добавили еще один `BlocBuilder`, который будет отображать виджет `Actions`, однако на этот раз мы используем недавно представленную функцию [flutter_bloc](https://pub.dev/packages/flutter_bloc), чтобы контролировать, как часто перестраивается виджет `Actions` (представлено в `v0.15.0`).

Если вам нужен детальный контроль над тем, когда вызывается функция `builder`, вы можете предоставить необязательное условие для `BlocBuilder`. Условие принимает предыдущее и текущее состояние блока и возвращает логическое значение. Если `condition` возвращает `true`, `builder` будет вызван со `state` и виджет будет перестроен. Если `condition` возвращает `false`, `builder` не будет вызван со `state` и перестройка не произойдет.

В данном случае мы не хотим, чтобы виджет `Actions` перестраивался на каждом тике, потому что это было бы неэффективно. Вместо этого мы хотим, чтобы `Actions` перестраивался только в том случае, если изменяется `runtimeType` `TimerState` (Ready => Running, Running => Paused и т.д. ...).

В результате, если мы случайно раскрасим виджеты при каждой перестройке, это будет выглядеть так:

![BlocBuilder condition demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Примечание:** Несмотря на то, что виджет `Text` перестраивается на каждом тике, мы перестраиваем `Actions` только в том случае, если их нужно перестроить.

Наконец, нам нужно добавить очень крутой фон волны, используя пакет [wave](https://pub.dev/packages/wave).

### Фон волны

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

### Собираем все вместе

наш финальный `main.dart` должен выглядеть приблизительно так:

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

Вот и все, что нужно сделать! На данный момент у нас есть довольно солидное приложение таймера, которое эффективно перестраивает только те виджеты, для которых это действительно нужно.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
