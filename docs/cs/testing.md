# Testování

> Bloc byl navržen tak, aby byl velmi lehce testovatelný.

Pro jednoduchost si napíšeme testy pro `CounterBloc`, který jsme vytvořili v [Základních konceptech](cs/coreconcepts.md)

Pro rekapitulaci, implementace `CounterBlocu` vypadá takto

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

Před tím, než začneme psát naše testy, budeme potřebovat přidat testovací framework do našich závislostí.

Potřebujeme přidat [test](https://pub.dev/packages/test) do našeho `pubspec.yaml`.

```yaml
dev_dependencies:
  test: ">=1.3.0 <2.0.0"
```

Začneme vytvořením souboru pro náš `CounterBloc` test, `counter_bloc_test.dart`, a importujeme balíček test.

```dart
import 'package:test/test.dart';
```

Jako další si vytvoříme náš `main` stejně jako naši skupinu testů.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **Poznámka**: skupiny jsou pro organizaci jednotlivých testů stejně jako pro vytváření kontextu, ve kterém můžete sdílet společný `setUp` a `tearDown` napříč všemi jednotlivými testy.

Začneme vytvořením instance našeho `CounterBlocu`, který bude použit napříč všemi testy.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Nyní můžeme začít psát naše jednotlivé testy.

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

?> **Poznámka**: Můžeme spustit všechny naše testy pomocí příkazu `pub run test`.

V tomto bodě bychom měli mít náš první průchozí test! Nyní si napíšeme složitější test.

```dart
test('single Increment event updates state to 1', () {
    final List<int> expected = [0, 1];

    expectLater(
        counterBloc,
        emitsInOrder(expected),
    );

    counterBloc.add(CounterEvent.increment);
});

test('single Decrement event updates state to -1', () {
    final List<int> expected = [0, -1];

    expectLater(
        counterBloc,
        emitsInOrder(expected),
    );

    counterBloc.add(CounterEvent.decrement);
});
```

Měli bychom být schopni spustit testy a vidět, že prochází.

To je všechno, testování by mělo být hračkou a měli bychom se cítit sebejistě, když děláme změny a refaktorujeme náš kód.
