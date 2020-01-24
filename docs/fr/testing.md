# Tests

> Bloc a été conçu pour être extrêmement facile à tester.

Par souci de simplicité, écrivons des tests pour  `CounterBloc` que nous avons créé dans [Concepts de base](coreconcepts.md).

Pour résumer, l'implémentation de `CounterBloc` ressemble à :

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

Avant de commencer à écrire nos tests, nous allons devoir ajouter un cadre de test à nos dépendances.

Nous devons ajouter le package [test](https://pub.dev/packages/test) et [bloc_test](https://pub.dev/packages/bloc_test) à notre `pubspec.yaml`.

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```

Commençons par créer le fichier `counter_bloc_test.dart` pour nos Tests du `CounterBloc` et importons y le paquet test.

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

Ensuite, nous devons créer notre `main` ainsi que notre groupe de test.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **Note**: Les groupes servent à organiser des tests individuels ainsi qu'à créer un contexte dans lequel vous pouvez partager un `setUp` et un `tearDown` communs à tous les tests individuels.

Commençons par créer une instance de notre `CounterBlocs` qui sera utilisée dans tous nos tests.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Maintenant, nous pouvons commencer à écrire nos tests individuels.

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

?> **Note**: Nous pouvons exécuter tous nos tests avec la commande `pub run test`.

A ce stade, nous devrions avoir notre premier test de réussite ! Passons maintenant à un test plus complexe.

```dart
blocTest(
    'emits [0, 1] when CounterEvent.increment is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.increment),
    expect: [0, 1],
);

blocTest(
    'emits [0, -1] when CounterEvent.decrement is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.decrement),
    expect: [0, -1],
);
```

Nous devrions être en mesure d'effectuer les tests et de voir que tous réussissent.

C'est tout ce qu'il y a à faire, tester devrait être un jeu d'enfant et nous devrions nous sentir en confiance lorsque nous apportons des changements et remanions notre code.

Vous pouvez vous référer à [l'application Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) pour un exemple d'application entièrement testée.