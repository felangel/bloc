# Tutoriel Flutter chronomètre

![débutant](https://img.shields.io/badge/level-beginner-green.svg)

> Dans ce tutoriel, nous allons expliquer comment construire une application de minuterie à l'aide de la bibliothèque bloc. L’application terminée devrait ressembler à ceci:

![demo](../assets/gifs/flutter_timer.gif)

## Configuration

Nous commencerons par créer un tout nouveau projet Flutter

```sh
flutter create flutter_timer
```

Nous pouvons alors remplacer le contenu de pubspec.yaml par:

```yaml
name: flutter_timer
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.2.2 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^2.0.0
  equatable: ^0.6.0
  wave: ^0.0.8

flutter:
  uses-material-design: true
```

?> **Note:** Nous utiliserons les paquets [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable), et [wave](https://pub.dev/packages/wave) dans cette application.

Ensuite, lancez `flutter packages get` pour installer toutes les dépendances.

## Ticker

> Le ticker (ou minuteur) sera notre source de données pour l'application de minuterie. Il exposera un flot de tick répititif auxquel nous pouvons nous abonner et auxquel nous pouvons réagir.

Commencez par créer `ticker.dart`.

```dart
class Ticker {
  Stream<int> tick({int ticks}) {
    return Stream.periodic(Duration(seconds: 1), (x) => ticks - x - 1)
        .take(ticks);
  }
}
```

Tout ce que fait notre classe `Ticker` est d'exposer une fonction de tick qui prend le nombre de ticks (secondes) que nous voulons et renvoie un flux qui émet les secondes restantes chaque seconde.

Ensuite, nous devons créer notre `TimerBloc` qui consommera le `Ticker`.

## Timer Bloc

### TimerState

Nous allons commencer par définir les `TimerStates` dans lesquels notre `TimerBloc` peut se trouver.

Nos états du `TimerBloc` peuvent être l'un des suivants :

- Ready — prêt à commencer le décompte à partir de la durée spécifiée.
- Running — compte à rebours actif à partir de la durée spécifiée.
- Paused — s'est arrêté à une certaine durée restante.
- Finished — complétée avec une durée restante de 0.

Chacun de ces états aura une implication sur ce que l'utilisateur voit. Par exemple :

- si l'État est “ready,” l'utilisateur pourra démarrer la minuterie.
- si l'État est “running,” l'utilisateur pourra faire une pause et réinitialiser la minuterie ainsi que voir la durée restante.
- si l'État est “paused,” l'utilisateur pourra reprendre la minuterie et la réinitialiser.
- si l'État est “finished,” l'utilisateur pourra réinitialiser la minuterie.

Afin de garder tous nos fichiers bloc ensemble, créons un répertoire bloc avec `bloc/timer_state.dart`.

?> **Tip:** Vous pouvez utiliser les extensions[IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) pour autogénérer les fichiers bloc suivants

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

Notez que tous les `TimerStates` étendent la classe abstraite de base `TimerState` qui a une propriété duration. C'est parce que quel que soit l'état dans lequel se trouve notre `TimerBloc`, nous voulons savoir combien de temps il nous reste.

Ensuite, définissons et implémentons les `TimerEvents` que notre `TimerBloc` va traiter.

### TimerEvent

Notre `TimerBloc` aura besoin de savoir comment traiter les événements suivants :

- Start — informe le TimerBloc que la minuterie doit être démarrée.
- Pause — informe le TimerBloc que la minuterie doit être mise en pause.
- Resume — informe le TimerBloc que la minuterie doit être reprise.
- Reset — informe le TimerBloc que la minuterie doit être remise à l'état d'origine.
- Tick — informe le TimerBloc qu'une coche s'est produite et qu'il doit mettre à jour son état en conséquence.

Si vous n'avez pas utilisé les extensions [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), alors créez `bloc/timer_event.dart` et implémentons ces événements.
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

Ensuite, implémentons le `TimerBloc` !

### TimerBloc

Si ce n'est pas déjà fait, créez `bloc/timer_bloc.dart` et créez un `TimerBloc` vide.
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

La première chose que nous devons faire est de définir l'"EtatInitial" de notre `TimerBloc`. Dans ce cas, nous voulons que le TimerBloc démarre à l'état " Prêt " avec une durée prédéfinie de 1 minute (60 secondes).
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

Ensuite, nous devons définir la dépendance par rapport à notre `Ticker`.

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

Nous sommes également en train de définir un `StreamSubscription` pour notre `Ticker` que nous allons voir dans un instant.


A ce stade, il ne reste plus qu'à implémenter `mapEventToState`. Pour une meilleure lisibilité, j'aime diviser chaque gestionnaire d'événement en sa propre fonction d'aide. Nous allons commencer par l'événement " Start ".
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

Si le `TimerBloc` reçoit un événement `Start`, il pousse un état `Running` avec la durée de départ. De plus, s'il y avait déjà un `_tickerSubscription` ouvert, nous devons l'annuler pour délocaliser la mémoire. Nous devons également remplacer la méthode `close` sur notre `TimerBloc` de sorte que nous puissions annuler le `_tickerSubscription` lorsque le `TimerBloc` est fermé. Enfin, nous écoutons le flux `_ticker.tick` et à chaque tick nous ajoutons un événement `Tick` avec la durée restante.

Ensuite, implémentons le gestionnaire d'événements `Tick`.

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

Chaque fois qu'un événement `Tick` est reçu, si la durée de la tick est supérieure à 0, nous devons pousser un état `Running` mis à jour avec la nouvelle durée. Sinon, si la durée du tick est 0, notre temporisateur est terminé et nous devons pousser un état "Terminé".

Maintenant, implémentons le gestionnaire d'événements `Pause`.


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

Dans `_mapPauseToState` si l'état de notre `TimerBloc` est `Running`, alors nous pouvons mettre en pause le `_tickerSubscription` et pousser un état `Paused` avec la durée du timer actuel.

Ensuite, implémentons le gestionnaire d'événements `Resume` pour que nous puissions désamorcer le timer.

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

Le gestionnaire d'événements `Resume` est très similaire au gestionnaire d'événements `Pause`. Si le `TimerBlocTemporisateur` a un état de `Paused` et qu'il reçoit un événement `Resume`, alors il reprend l'état `_tickerSubscription` et pousse un état `Running` avec la durée courante.

Enfin, nous devons implémenter le gestionnaire d'événements `Reset`.


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

Si le `TimerBloc` reçoit un événement `Reset`, il doit annuler l'abonnement `_tickerSubscription` en cours afin de ne pas être notifié du tick supplémentaire et pousser un état `Ready` avec la durée originale.

Si vous n'avez pas utilisé les extensions [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), assurez-vous de créer `bloc/bloc.dart` afin d'exporter tous les fichiers bloc et de permettre d'utiliser une seule importation par commodité.
```dart
export 'timer_bloc.dart';
export 'timer_event.dart';
export 'timer_state.dart';
```

C'est tout ce qu'il y a dans le `TimerBloc`. Il ne reste plus qu'à implémenter l'interface utilisateur pour notre application Timer.

## Interface de l'application

### MyApp

Nous pouvons commencer par supprimer le contenu de `main.dart` et créer notre widget `MyApp` qui sera la racine de notre application.

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

MyApp est un `StatelessWidget` qui gère l'initialisation et la fermeture d'une instance de `TimerBloc`. De plus, il utilise le widget `BlocProvider` afin de rendre notre instance `TimerBloc` disponible pour les widgets de notre sous-arbre.

Ensuite, nous devons implémenter notre widget `Timer`.


### Timer

Notre widget `Timer` sera responsable de l'affichage du temps restant ainsi que des boutons appropriés qui permettront aux utilisateurs de démarrer, de mettre en pause et de réinitialiser la minuterie.

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

Jusqu'à présent, nous utilisons simplement `BlocProvider` pour accéder à l'instance de notre `TimerBloc` et utilisons un widget `BlocBuilder` afin de reconstruire l'interface chaque fois que nous obtenons un nouvel `TimerState`.

Ensuite, nous allons implémenter notre widget `Actions` qui aura les actions appropriées (démarrage, pause et reset).

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

Le widget `Actions` n'est qu'un autre `StatelessWidget` qui utilise `BlocProvider` pour accéder à l'instance `TimerBloc` et retourne ensuite différents `FloatingActionButton` basés sur l'état actuel du `TimerBloc`. Chacun des boutons `FloatingActionButton` ajoute un événement dans son rappel `onPressed` pour notifier le `TimerBloc`.

Maintenant nous devons connecter les `Actions` à notre widget `Timer`.

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

Nous avons ajouté un autre `BlocBuilder` qui se charge du rendu du widget `Actions` ; cependant, cette fois-ci, nous utilisons une fonctionnalité nouvellement introduite [flutter_bloc](https://pub.dev/packages/flutter_bloc) pour contrôler à quelle fréquence le widget `Actions` est reconstruit (introduit dans `v0.15.0`).

Si vous voulez un contrôle fin sur le moment où la fonction `builder` est appelée, vous pouvez fournir une `condition` optionnelle à `BlocBuilder`. La `condition` prend l'état de bloc précédent et l'état de bloc courant et retourne un `boolean`. Si `condition` renvoie `true`, `builder` sera appelé avec `state` et le widget sera reconstruit. Si `condition` retourne `false`, `builder` ne sera pas appelé avec `state` et aucune reconstruction ne sera effectuée.

Dans ce cas, nous ne voulons pas que le widget `Actions` soit reconstruit à chaque tick parce que ce serait inefficace. Au lieu de cela, nous voulons seulement que `Actions` soit reconstruit si le `runtimeType` du `TimerState` change (Ready => Running, Running => Paused, etc...).

Par conséquent, si nous colorions au hasard les widgets sur chaque reconstruction, cela ressemblerait à :

![Démonstration de l'état du BlocBuilder](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Note:** Même si le widget `Text` est reconstruit à chaque tick, nous ne reconstruisons les `Actions` que si elles doivent être reconstruites.

Enfin, nous devons ajouter le fond d'onde super cool en utilisant le paquet [wave](https://pub.dev/packages/wave).

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

### Réunir le tout

Notre fichier fini, `main.dart` devrait ressembler à :

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

C'est tout ce qu'il y a à faire ! A ce stade, nous avons une application de minuterie assez solide qui ne reconstruit efficacement que les widgets qui ont besoin d'être reconstruits.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
