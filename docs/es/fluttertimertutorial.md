# Flutter: Tutorial de temporizador

![beginner](https://img.shields.io/badge/nivel-principiante-green)

> En el siguiente tutorial veremos cómo construir una aplicación de temporizador utilizando la biblioteca de bloc. La aplicación final debería verse así:

![demo](../assets/gifs/flutter_timer.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

```sh
flutter create flutter_timer
```

Luego podemos reemplazar el contenido de pubspec.yaml con:

```yaml
name: flutter_timer
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  equatable: ^1.0.0
  wave: ^0.0.8

flutter:
  uses-material-design: true
```

?> **Nota:** Utilizaremos [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable) y [wave](https://pub.dev/packages/wave) como paquetes en esta aplicación.

A continuación, ejecute `flutter packages get` para instalar todas las dependencias.

## Ticker 

> La clase ticker será nuestra fuente de datos para la aplicación del temporizador. Expondrá un flujo de ticks a los que podemos suscribirnos y reaccionar.

Comienze creando `ticker.dart`.

```dart
class Ticker {
  Stream<int> tick({int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
```

Todo lo que hace nuestra clase `Ticker` es exponer una función de tick que toma el número de ticks (segundos) que queremos y devuelve una secuencia que emite los segundos restantes cada segundo.

A continuación, necesitamos crear un `TimerBloc` que consumirá el `Ticker`.

## TimerBloc

### TimerState

Comenzaremos definiendo los `TimerStates` en los que puede estar nuestro `TimerBloc`.

Nuestro estado `TimerBloc` puede ser uno de los siguientes:

- Ready: listo para comenzar la cuenta regresiva desde la duración especificada.
- Running: cuenta regresiva activa desde la duración especificada.
- Paused: en pausa en la duración restante.
- Finished: completado con una duración restante de 0.

Cada uno de estos estados tendrá una implicación en lo que ve el usuario. Por ejemplo:

- si el estado está "listo", el usuario podrá iniciar el temporizador.
- si el estado está "en ejecución", el usuario podrá pausar y restablecer el temporizador, así como ver la duración restante.
- si el estado está "en pausa", el usuario podrá resumir el temporizador y restablecerlo.
- si el estado está "completado", el usuario podrá restablecer el temporizador.

Para mantener todos nuestros archivos de bloc juntos, creamos un directorio de bloc con `bloc/timer_state.dart`.

?> **Consejo:** Puedes usar las extensiones de [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) para generar automáticamente los siguientes archivos de bloc para usted.

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

Tenga en cuenta que todos los `TimerStates` extienden la clase base abstracta `TimerState` que tiene una propiedad de duración. Esto se debe a que no importa en qué estado se encuentre nuestro `TimerBloc`, queremos saber cuánto tiempo nos queda.

A continuación, definamos e implementemos los `TimerEvents` que nuestro `TimerBloc` procesará.

### TimerEvent

Nuestro `TimerBloc` necesitará saber cómo procesar los siguientes eventos:

- Start: informa al TimerBloc que el temporizador debe iniciarse.
- Pause: informa al TimerBloc que el temporizador debe pausarse.
- Resume: informa al TimerBloc que se debe resumir el temporizador.
- Reset: informa al TimerBloc que el temporizador debe reiniciar al estado original.
- Tick: informa al TimerBloc que se ha producido un tick y que necesita actualizar su estado en consecuencia.

Sino usaste las extensiones de [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) luego cree `bloc/timer_event.dart` y implementemos esos eventos.

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

¡A continuación, implementemos el `TimerBloc`!

### TimerBloc

Si aún no lo ha hecho, cree `bloc/timer_bloc.dart` y cree un `TimerBloc` vacío.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_timer/bloc/bloc.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  @override
  TimerState get initialState => // TODO: implementar initialState;

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    // TODO: implementar mapEventToState
  }
}
```

Lo primero que debemos hacer es definir el `initialState` de nuestro `TimerBloc`. En este caso, queremos que el `TimerBloc` comience en el estado `Ready` con una duración predeterminada de 1 minuto (60 segundos).

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
    // TODO: implementar mapEventToState
  }
}
```

A continuación, necesitamos definir la dependencia de nuestro `Ticker`.

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
    // TODO: implementar mapEventToState
  }
}
```

También estamos definiendo un `StreamSubscription` para nuestro `Ticker` al que llegaremos en un momento.

En este punto, todo lo que queda por hacer es implementar `mapEventToState`. Para mejorar la legibilidad, me gusta dividir cada controlador de eventos en su propia función auxiliar. Comenzaremos con el evento `Start`.

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

Si el `TimerBloc` recibe un evento `Start`, empuja un estado `Running` con la duración de inicio. Además, si ya había una `_tickerSubscription` abierto, debemos cancelarla para desasignar la memoria. También tenemos que anular el método `close` en nuestro `TimerBloc` para que podamos cancelar la `_tickerSubscription` cuando el `TimerBloc` está cerrado. Por último, escuchamos la transmisión `_ticker.tick` y en cada tic agregamos un evento `Tick` con la duración restante.

A continuación, implementemos el controlador de eventos `Tick`.

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

Cada vez que se recibe un evento `Tick`, si la duración del tick es mayor que 0, debemos impulsar un estado actualizado `Running` con la nueva duración. De lo contrario, si la duración de la marca es 0, nuestro temporizador ha finalizado y debemos presionar un estado `Finished`.

Ahora implementemos el controlador de eventos `Pause`.

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

En `_mapPauseToState` si el `estado` de nuestro `TimerBloc` es `Running`, entonces podemos pausar la `_tickerSubscription` y presionar un estado `Paused` con la duración actual del temporizador.

A continuación, implementemos el controlador de eventos `Resume` para que podamos pausar el temporizador.

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

El controlador de eventos `Resume` es muy similar al controlador de eventos `Pause`. Si el `TimerBloc` tiene un `estado` de `Paused` y recibe un evento `Resume`, entonces resume la `_tickerSubscription` y empuja un estado `Running` con la duración actual.

Por último, necesitamos implementar el controlador de eventos `Reset`.

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

Si el `TimerBloc` recibe un evento `Reset`, necesita cancelar la `_tickerSubscription` actual para que no se le notifique ningún tick adicional y empuje un estado `Ready` con la duración original.

Si no usó [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) asegúrese de crear `bloc/bloc.dart` para exportar todos los archivos de bloque y hacer posible el uso de una sola importación por conveniencia.

```dart
export 'timer_bloc.dart';
export 'timer_event.dart';
export 'timer_state.dart';
```

Eso es todo lo que hay para el `TimerBloc`. Ahora todo lo que queda es implementar la interfaz de usuario para nuestra aplicación de temporizador.

## UI de la aplicación

### MyApp

Podemos comenzar eliminando el contenido de `main.dart` y creando nuestro widget `MyApp` que será la raíz de nuestra aplicación.

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

`MyApp` es un `StatelessWidget` que gestionará la inicialización y el cierre de una instancia de `TimerBloc`. Además, está utilizando el widget `BlocProvider` para que nuestra instancia `TimerBloc` esté disponible para los widgets de nuestro subárbol.

A continuación, necesitamos implementar nuestro widget `Timer`.

### Timer

Nuestro widget `Timer` será responsable de mostrar el tiempo restante junto con los botones adecuados que permitirán a los usuarios iniciar, pausar y restablecer el temporizador.

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

Hasta ahora, solo estamos usando `BlocProvider` para acceder a la instancia de nuestro `TimerBloc` y estamos usando un widget `BlocBuilder` para reconstruir la IU cada vez que recibimos un nuevo `TimerState`.

A continuación, implementaremos nuestro widget `Actions` que tendrá las acciones adecuadas (inicio, pausa y reinicio).

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

El widget `Actions` es solo otro `StatelessWidget` que utiliza `BlocProvider` para acceder a la instancia de `TimerBloc` y luego devuelve diferentes `FloatingActionButtons` en función del estado actual de `TimerBloc`. Cada uno de los `FloatingActionButtons` agrega un evento en su devolución de llamada `onPressed` para notificar al `TimerBloc`.

Ahora necesitamos conectar las `Acciones` a nuestro widget `Temporizador`.

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

Agregamos otro `BlocBuilder` que representará el widget `Actions`; sin embargo, esta vez estamos utilizando una función [flutter_bloc](https://pub.dev/packages/flutter_bloc) recientemente introducida para controlar con qué frecuencia se reconstruye el widget `Actions` (introducido en `v0.15.0`).

Si desea un control detallado sobre cuándo se llama a la función `constructor`, puede proporcionar una `condición` opcional a `BlocBuilder`. La `condición` toma el estado de bloc anterior y el estado de bloc actual y devuelve un `booleano`. Si la `condición` devuelve `verdadero`, se llamará el `constructor` con `estado` y el widget se reconstruirá. Si `condición` devuelve `falso`, no se llamará a `constructor` con `estado` y no se producirá ninguna reconstrucción.

En este caso, no queremos que el widget `Actions` se reconstruya en cada tick porque eso sería ineficiente. En cambio, solo queremos que las `Actions` se reconstruyan si el `runtimeType` del `TimerState` cambia (Ready => Running, Running => Paused, etc ...).

Como resultado, si coloreáramos aleatoriamente los widgets en cada reconstrucción, se vería así:

![Demo de condición de BlocBuilder](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Aviso:** Aunque el widget `Text` se reconstruye en cada tic, solo reconstruimos `Actions` si es necesario reconstruirlo.

Por último, necesitamos agregar el súper genial fondo de onda usando el paquete [wave](https://pub.dev/packages/wave).

### Fondo de olas

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

### Poniéndolo todo junto

Nuestro acabado, `main.dart` debería verse así:

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

¡Eso es todo al respecto! En este punto, tenemos una aplicación de temporizador bastante sólida que reconstruye eficientemente solo widgets que necesitan ser reconstruidos.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).