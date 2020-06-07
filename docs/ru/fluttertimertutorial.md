# Flutter Таймер

![начинающий](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы расскажем, как создать приложение таймера с помощью библиотеки `bloc`. Готовое приложение должно выглядеть так:

![демо](../assets/gifs/flutter_timer.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_timer_tutorial/pubspec.yaml.md ':include')

Затем запустить `flutter packages get`, чтобы установить все зависимости.

?> **Примечание:** В этом приложении мы будем использовать [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable) и [wave](https://pub.dev/packages/wave) пакеты.

## Тикер

> `Ticker` будет нашим источником данных для приложения таймера. Он создаст поток тиков, на которые мы можем подписаться и на которые будем реагировать.

Начнем с создания `ticker.dart`.

[ticker.dart](../_snippets/flutter_timer_tutorial/ticker.dart.md ':include')

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

[timer_state.dart](../_snippets/flutter_timer_tutorial/timer_state.dart.md ':include')

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

[timer_event.dart](../_snippets/flutter_timer_tutorial/timer_event.dart.md ':include')

Далее давайте реализуем `TimerBloc`!

### Блок

Если вы этого еще не сделали, создайте `bloc/timer_bloc.dart` и создайте пустой `TimerBloc`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_empty.dart.md ':include')

Первое, что нам нужно сделать, это определить `initialState` нашего `TimerBloc`. В этом случае мы хотим, чтобы `TimerBloc` запускался в состоянии `Ready` с заданной продолжительностью 1 минута (60 секунд).

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

Далее нам нужно определить зависимость от нашего `Ticker`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

Мы также определяем `StreamSubscription` для нашего `Ticker`, к которому мы скоро перейдем.

На данный момент все, что осталось сделать, это реализовать `mapEventToState`. Для улучшения читаемости мне нравится разбивать каждый обработчик событий на его собственную вспомогательную функцию. Начнем с события `Start`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

Если `TimerBloc` получает событие `Start`, он переводит состояние в `Running` с первоначальной продолжительностью. Кроме того, если уже была открытая `_tickerSubscription`, нам нужно отменить ее, чтобы освободить память. Нам также нужно переопределить метод `close` нашего `TimerBloc`, чтобы мы могли отменить `_tickerSubscription` когда `TimerBloc` закрыт. Наконец, мы слушаем поток `_ticker.tick` и на каждом тике мы добавляем событие `Tick` с оставшейся продолжительностью.

Теперь давайте реализуем обработчик событий `Tick`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

Каждый раз, когда получено событие `Tick`, если длительность тика больше 0, нам нужно выставить обновленное состояние `Running` с новой продолжительностью. В противном случае, если длительность тика равна 0, наш таймер закончился и нам нужно перейти в состояние `Finished`.

Теперь давайте реализуем обработчик событий `Pause`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

В `_mapPauseToState`, если `state` нашего `TimerBloc` равно `Running`, тогда мы можем приостановить `_tickerSubscription` и выставить состояние `Paused` с текущей длительностью таймера.

Далее, давайте реализуем обработчик событий `Resume`, чтобы мы могли отключать таймер.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

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
    print(transition);
    super.onTransition(transition);
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

[bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_barrel.dart.md ':include')

Это все, что есть в `TimerBloc`. Теперь осталось только реализовать пользовательский интерфейс для нашего приложения `Timer`.

## UI приложения

### MyApp

Мы можем начать с удаления содержимого файла `main.dart` и создания нашего виджета `MyApp`, который будет корнем нашего приложения.

[main.dart](../_snippets/flutter_timer_tutorial/main1.dart.md ':include')

`MyApp` - это `StatelessWidget`, который будет управлять инициализацией и закрытием экземпляра `TimerBloc`. Кроме того, он использует виджет `BlocProvider`, чтобы сделать наш экземпляр `TimerBloc` доступным для виджетов в нашем поддереве.

Далее нам нужно реализовать наш виджет `Timer`.

### Таймер

Наш виджет `Таймер` будет отвечать за отображение оставшегося времени вместе с соответствующими кнопками, которые позволят пользователям запускать, приостанавливать и сбрасывать таймер.

[timer.dart](../_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

Пока что мы просто используем `BlocProvider` для доступа к экземпляру нашего `TimerBloc` и используем виджет `BlocBuilder` для перестройки пользовательского интерфейса каждый раз, когда мы получаем новый `TimerState`.

Далее мы собираемся реализовать наш виджет `Actions`, который будет иметь соответствующие действия (запуск, пауза и сброс).

### Действия

[actions.dart](../_snippets/flutter_timer_tutorial/actions.dart.md ':include')

Виджет `Actions` - это просто еще один `StatelessWidget`, который использует `BlocProvider` для доступа к экземпляру `TimerBloc`, а затем возвращает различные `FloatingActionButtons` в зависимости от текущего состояния `TimerBloc`. Каждый из `FloatingActionButtons` добавляет событие в свой обратный вызов `onPressed`, чтобы уведомить `TimerBloc`.

Теперь нам нужно подключить `Actions` к нашему виджету `Timer`.

[timer.dart](../_snippets/flutter_timer_tutorial/timer2.dart.md ':include')

Мы добавили еще один `BlocBuilder`, который будет отображать виджет `Actions`, однако на этот раз мы используем недавно представленную функцию [flutter_bloc](https://pub.dev/packages/flutter_bloc), чтобы контролировать, как часто перестраивается виджет `Actions` (представлено в `v0.15.0`).

Если вам нужен детальный контроль над тем, когда вызывается функция `builder`, вы можете предоставить необязательное условие для `BlocBuilder`. Условие принимает предыдущее и текущее состояние блока и возвращает логическое значение. Если `condition` возвращает `true`, `builder` будет вызван со `state` и виджет будет перестроен. Если `condition` возвращает `false`, `builder` не будет вызван со `state` и перестройка не произойдет.

В данном случае мы не хотим, чтобы виджет `Actions` перестраивался на каждом тике, потому что это было бы неэффективно. Вместо этого мы хотим, чтобы `Actions` перестраивался только в том случае, если изменяется `runtimeType` `TimerState` (Ready => Running, Running => Paused и т.д. ...).

В результате, если мы случайно раскрасим виджеты при каждой перестройке, это будет выглядеть так:

![BlocBuilder condition demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Примечание:** Несмотря на то, что виджет `Text` перестраивается на каждом тике, мы перестраиваем `Actions` только в том случае, если их нужно перестроить.

Наконец, нам нужно добавить очень крутой фон волны, используя пакет [wave](https://pub.dev/packages/wave).

### Фон волны

[background.dart](../_snippets/flutter_timer_tutorial/background.dart.md ':include')

### Собираем все вместе

наш финальный `main.dart` должен выглядеть приблизительно так:

[main.dart](../_snippets/flutter_timer_tutorial/main2.dart.md ':include')

Вот и все, что нужно сделать! На данный момент у нас есть довольно солидное приложение таймера, которое эффективно перестраивает только те виджеты, для которых это действительно нужно.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
