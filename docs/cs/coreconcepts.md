# Základní koncepty

?> Prosím, ujistěte se, že si pečlivě přečtete a pochopíte následující sekce před tím, než budete pracovat s (https://pub.dev/packages/bloc).

Existuje několik základních konceptů, které jsou kritické pro pochopení, jak používat Bloc.

V následujících sekcích všechny podrobně probereme a také si ukážeme, jak se použijí v reálné aplikaci: v aplikaci počítadla.

## Události

*Poznámka:* v angličtině se používá slovo `event`.

> Události jsou vstupem do Blocu. Jsou běžně přidávány jako reakce na uživatelovu akci, jako je stisknutí tlačítka nebo události životního cyklu, jako je načítání stránky.

Při navrhování aplikace musíme udělat krok zpět a definovat si, jak s ní budou uživatelé interagovat. V kontextu naší aplikace počítadla budeme mít dvě tlačítka na inkrementaci a dekrementaci našeho počítadla.

Když uživatel klepne na jedno z těchto dvou tlačítek, musí se stát něco, co upozorní "mozek" naší aplikace, aby mohla reagovat na vstup uživatele. Tady přicházejí do hry události.

Musíme být schopni upozornit "mozek" naší aplikace o inkrementaci i dekrementaci, takže musíme tyto události definovat.

```dart
enum CounterEvent { increment, decrement }
```

V tomto případě můžeme reprezentovat tyto události s použitím `enum`, ale pro více složité případy může být potřebné použít `class`, zejména pokud je do bloc potřebné předat informaci.

V tomto bodě již máme definované naše první události! Všimněte si, že jsme zatím nikdě Bloc nepoužili a nikde se neděje magicky nic. Je to jen čistý Dart kód.

## Stavy

*Poznámka:* v angličtině se používá slovo `state`.

> Stavy jsou výstupem Blocu a reprezentují část stavu naší aplikace. UI komponenty mohou být upozorněny o stavech a překreslit své části na základně aktuálního stavu.

Zatím jsme definovaly dvě události, na které bude naše aplikace reagovat: `CounterEvent.increment` a `CounterEvent.decrement`.

Nyní potřebujeme definovat, jak reprezentovat stav naší aplikace.

Jelikož vytváříme počítadlo, náš stav bude je velmi jednoduchý: je to obyčejné celé číslo, které reprezentuje aktuální hodnotu počítadla.

Později si ukážeme složitější ukázky stavu, ale v tomto případně je primitivní typ zcela vhodný pro reprezentaci stavu.

## Přechody

*Poznámka:* v angličtině se používá slovo `transition`.

> Změna z jednoho stavu na jiný se nazývá přechod. Přechod se skládá z aktuálního stavu, události a dalšího stavu.

Jak uživatel interaguje s naší aplikací počítadla, spustí události `Increment` a `Decrement`, které aktualizují stav počítadla. Všechny tyto změny stavu mohou být popsány jako série `Transitions`.

Například, pokud uživatel otevře naší aplikaci a jednou klepne na tlačítko inkrementace, uvidíme následující `Transition`.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Jelikož je každá změna stavu zaznamenávána, jsme schopni jednoduše zpracovat a sledovat všechny uživatelské interakce a změny stavu na jednom míste. Kromě toho to také umožňuje věci jako ladění v čase.

## Streamy

?> Pro více informací o `Streams` se podívejte na oficiální [Dart dokumentaci](https://www.dartlang.org/tutorials/language/streams).

> Stream je sekvence asynchroních dat.

Bloc je postavený nad [RxDart](https://pub.dev/packages/rxdart), avšak abstrahuje všechny specifické `RxDart` implementační detaily.

Aby bylo možné používat Bloc, je nutné mít dobrou znalost o `Streams` a jak fungují.

> Pokud nemáte s `Streams` zkušenosti, představte si potrubí s vodou, které jím protéká. Potrubí je `Stream` a voda jsou asynchronní data.

`Stream` můžeme v Dartu vytvořit pomocí `async*` funkce.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

Pokud nějakou funkci označíme jako `async*`, můžeme používat klíčové slovo `yield` a vracet `Stream` dat. V ukázce výše vracíme `Stream` celých čísel až do parametru `max`.

Pokaždé když použijeme `yield` v `async*` funkci, protlačíme daný kus dat skrz `Stream`.

Výše uvedený `Stream` můžeme zpracovat několika způsoby. Pokud bychom chtěli napsat funkci, která vrací součet `Stream` celých čísel, vypadalo by to nějak takto:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

Označením funkce jako `async`, jsme schopni použít klíčové slovo `await` a vrátit `Future` celých čísel. V tomto případě čekáme na každou hodnotu ve streamu a vracíme součet všech celých čísel ve streamu.

Dohromady to můžeme použít nějak takto:

```dart
void main() async {
    /// Initialize a stream of integers 0-9
    Stream<int> stream = countStream(10);
    /// Compute the sum of the stream of integers
    int sum = await sumStream(stream);
    /// Print the sum
    print(sum); // 45
}
```

## Bloc

> A Bloc (Business Logic Component) is a component which converts a `Stream` of incoming `Events` into a `Stream` of outgoing `States`. Think of a Bloc as being the "brains" described above.

> Every Bloc must extend the base `Bloc` class which is part of the core bloc package.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

In the above code snippet, we are declaring our `CounterBloc` as a Bloc which converts `CounterEvents` into `ints`.

> Every Bloc must define an initial state which is the state before any events have been recieved.

In this case, we want our counter to start at `0`.

```dart
@override
int get initialState => 0;
```

> Every Bloc must implement a function called `mapEventToState`. The function takes the incoming `event` as an argument and must return a `Stream` of new `states` which is consumed by the presentation layer. We can access the current bloc state at any time using the `state` property.

```dart
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
```

At this point, we have a fully functioning `CounterBloc`.

```dart
import 'package:bloc/bloc.dart';

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

!> Blocs will ignore duplicate states. If a Bloc yields `State nextState` where `state == nextState`, then no transition will occur and no change will be made to the `Stream<State>`.

At this point, you're probably wondering _"How do I notify a Bloc of an event?"_.

> Every Bloc has a `add` method. `Add` takes an `event` and triggers `mapEventToState`. `Add` may be called from the presentation layer or from within the Bloc and notifies the Bloc of a new `event`.

We can create a simple application which counts from 0 to 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

The `Transitions` in the above code snippet would be

```json
{
    "currentState": 0,
    "event": "CounterEvent.increment",
    "nextState": 1
}
{
    "currentState": 1,
    "event": "CounterEvent.increment",
    "nextState": 2
}
{
    "currentState": 2,
    "event": "CounterEvent.increment",
    "nextState": 3
}
```

Unfortunately, in the current state we won't be able to see any of these transitions unless we override `onTransition`.

> `onTransition` is a method that can be overridden to handle every local Bloc `Transition`. `onTransition` is called just before a Bloc's `state` has been updated.

?> **Tip**: `onTransition` is a great place to add bloc-specific logging/analytics.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Now that we've overridden `onTransition` we can do whatever we'd like whenever a `Transition` occurs.

Just like we can handle `Transitions` at the bloc level, we can also handle `Exceptions`.

> `onError` is a method that can be overriden to handle every local Bloc `Exception`. By default all exceptions will be ignored and `Bloc` functionality will be unaffected.

?> **Note**: The stacktrace argument may be `null` if the state stream received an error without a `StackTrace`.

?> **Tip**: `onError` is a great place to add bloc-specific error handling.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Now that we've overridden `onError` we can do whatever we'd like whenever an `Exception` is thrown.

## BlocDelegate

One added bonus of using Bloc is that we can have access to all `Transitions` in one place. Even though in this application we only have one Bloc, it's fairly common in larger applications to have many Blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Note**: All we need to do is extend `BlocDelegate` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocDelegate`, we just need to tweak our `main` function.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```

If we want to be able to do something in response to all `Events` added, we can also override the `onEvent` method in our `SimpleBlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

If we want to be able to do something in response to all `Exceptions` thrown in a Bloc, we can also override the `onError` method in our `SimpleBlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('$error, $stacktrace');
  }
}
```

?> **Note**: `BlocSupervisor` is a singleton which oversees all Blocs and delegates responsibilities to the `BlocDelegate`.
