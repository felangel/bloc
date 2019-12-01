# Základní koncepty

?> Ujistěte se, prosím, že si pečlivě přečtete a pochopíte následující sekce před tím, než budete pracovat s [blocem](https://pub.dev/packages/bloc).

Existuje několik základních konceptů, které jsou kritické pro pochopení, jak používat Bloc.

V následujících sekcích všechny podrobně probereme a také si ukážeme, jak se použijí v reálné aplikaci: v aplikaci počítadla.

## Události

*Poznámka:* v angličtině se používá slovo `event`.

> Události jsou vstupem do Blocu. Jsou běžně přidávány jako reakce na akci uživatele, jako je stisknutí tlačítka, nebo události životního cyklu, jako je načítání stránky.

Při navrhování aplikace musíme udělat krok zpět a definovat si, jak s ní budou uživatelé pracovat. V kontextu naší aplikace počítadla budeme mít dvě tlačítka na inkrementaci a dekrementaci našeho počítadla.

Když uživatel klepne na jedno z těchto dvou tlačítek, musí se stát něco, co upozorní "mozek" naší aplikace, aby mohla reagovat na vstup uživatele. Tady přicházejí do hry události.

Musíme být schopni upozornit "mozek" naší aplikace o inkrementaci i dekrementaci, takže musíme tyto události definovat.

```dart
enum CounterEvent { increment, decrement }
```

V tomto případě můžeme reprezentovat tyto události s použitím `enum`, ale pro více složité případy může být potřebné použít `class`, zejména pokud je do bloc potřebné předat nějakou informaci.

V tomto bodě již máme definované naše první události! Všimněte si, že jsme zatím nikdě Bloc nepoužili a nikde se nic magicky neděje. Je to jen čistý Dart kód.

## Stavy

*Poznámka:* v angličtině se používá slovo `state`.

> Stavy jsou výstupem Blocu a reprezentují část stavu naší aplikace. UI komponenty mohou být o stavech upozorněny a překreslit své části na základně aktuálního stavu.

Zatím jsme definovaly dvě události, na které bude naše aplikace reagovat: `CounterEvent.increment` a `CounterEvent.decrement`.

Nyní potřebujeme definovat, jak reprezentovat stav naší aplikace.

Jelikož vytváříme počítadlo, náš stav bude velmi jednoduchý: obyčejné celé číslo, které reprezentuje aktuální hodnotu počítadla.

Později si ukážeme složitější ukázky stavu, ale v tomto případně je primitivní typ zcela vhodný pro reprezentaci stavu.

## Přechody

*Poznámka:* v angličtině se používá slovo `transition`.

> Změna z jednoho stavu na jiný se nazývá přechod. Přechod se skládá z aktuálního stavu, události a dalšího stavu.

Jak uživatel interaguje s naší aplikací počítadla, spustí události `Increment` a `Decrement`, které aktualizují stav počítadla. Všechny tyto změny stavu mohou být popsány jako série `Transitionů`.

Například, pokud uživatel otevře naší aplikaci a jednou klepne na tlačítko inkrementace, uvidíme následující `Transition`.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Jelikož je každá změna stavu zaznamenávána, jsme schopni jednoduše zpracovat a sledovat všechny uživatelské interakce a změny stavu na jednom místě. Kromě toho to také umožňuje věci jako ladění v čase.

## Streamy

?> Pro více informací o `Streamech` se podívejte na oficiální [Dart dokumentaci](https://www.dartlang.org/tutorials/language/streams).

> Stream je sekvence asynchroních dat.

Bloc je postavený nad [RxDart](https://pub.dev/packages/rxdart), avšak abstrahuje všechny specifické `RxDart` implementační detaily.

Aby bylo možné používat Bloc, je nutné mít dobrou znalost o `Streamech` a jak fungují.

> Pokud nemáte se `Streamy` zkušenosti, představte si potrubí s vodou, která jím protéká. Potrubí je `Stream` a voda jsou asynchronní data.

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

Výše uvedený `Stream` můžeme zpracovat několika způsoby. Pokud bychom chtěli napsat funkci, která vrací součet `Streamu` celých čísel, vypadalo by to nějak takto:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

Označením funkce jako `async` můžeme použít klíčové slovo `await` a vrátit `Future` celých čísel. V tomto případě čekáme na každou hodnotu ve streamu a vracíme součet všech celých čísel ve streamu.

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

## Blocy

> Bloc (Business Logic Component) je komponenta, která konvertuje `Stream` příchozích `Eventů` na `Stream` odchozích `Stavů`. Přemýšlejte o Blocu jako o "mozku" popisovaném výše.

> Každý Bloc musí rozšiřovat základní třídu `Bloc`, která je součástí základního balíčku bloc.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

V úryvku kódu výše deklarujeme náš `CounterBloc` jako Bloc, který konvertuje `CounterEventy` na `inty` (celá čísla).

> Každý Bloc musí definovat výchozí hodnotu, která je stavem předtím, než byla přijmuta jakákoli událost.

V tomto případě chceme, aby naše počítadlo začínalo na `0`.

```dart
@override
int get initialState => 0;
```

> Každý Bloc musí implementovat funkci `mapEventToState`. Tato funkce přijímá jako argument příchozí `událost` a musí vracet `Stream` nových `stavů`, který je využíván prezenční vrstvou. Můžeme přistoupit ke konkrétnímu stavu blocu v jakémkoli čase pomocí vlastnosti `state`.

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

V tomto bodě máme plně funkční `CounterBloc`.

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

!> Blocy budou ignorovat duplicitní stavy. Pokud Blok přidá stav `State nextState` kde `state == nextState`, nevyvolá se žádný přechod a nebude provedena žádná změna `Stream<State>`.

Teď si asi říkáte _"Jak upozorním Bloc na událost?"_.

> Každý Bloc má metodu `add`. `Add` přijímá `událost` a spouští `mapEventToState`. `Add` může být volána z prezenční vrstvy nebo zevnitř Blocu a upozorní Bloc na novou `událost`.

Můžeme vytvořit jednoduchou aplikaci, která počítá od 0 do 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

!> Ve výchozím nastavení budou události vždy zpracovány v pořadí, ve kterém byly přidány a každá nová přidaná událost je zařazena do fronty. Událost je považována za plně zpracovanout v momentě, kdy se dokončí provádění `mapEventToState`.

`Transitiony` ve výše zmíněném úryvku kódu bude následující:

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

Naneštěstí nebudeme v aktuálním stavu schopni vidět žádný z těchto přechodů, dokud nepřepíšeme `onTransition`.

> `onTransition` je metoda, který může být přepsána ke zpracování každého lokálního `Transitionu` Blocu. `onTransition` je zavolána těsně před tím, než byl `stav` Blocu aktualizován.

?> **Tip**: `onTransition` je skvělé místo pro přidání specifického logování/analytiky pro daný bloc.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Nyní, když jsme přepsali `onTransition` můžeme dělat cokoli chceme kdykoli se objeví `Transition`.

Stejně jako můžeme zpracovat `Transition` na úrovni blocu, můžeme také zpracovat `Exception` (vyjímky).

> `onError` je metoda, která může být přepsána ke zpracování lokálního `Exceptionu` Blocu. Defaultně jsou všechny vyjímky ignorovány a funkčnost `Bloc` bude nedotčena.

?> **Poznámka**: Argument stacktrace může být `null` pokud stav streamu přijal error bez `StackTrace`.

?> **Tip**: `onError` je skvělé místo na zpracování errorů specifických pro daný bloc.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Nyní, když jsme přepsali `onError`, můžeme dělat cokoli chceme kdykoli je vyvolána `Exception`.

## BlocDelegate

Jeden přidaný bonus používání Blocu je to, že můžeme míř přístup ke všem `Transitionům` na jednom místě. I když v této aplikaci máme pouze jeden Bloc, ve větších aplikacích je docela běžné mít více Bloců, které zpracovávají rozdílné části stavů aplikace.

Pokud chceme být schopni dělat něco v závislosti na všech `Transitionech`, můžeme jednoduše vytvořit náš vlastní `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Poznámka**: Všechno co potřebujeme udělat je rozšířit `BlocDelegate` a přepsat metodu `onTransition`.

Abychom Blocům řekli, aby používali `SimpleBlocDelegate`, musíme jenom poupravit naši `main` funkci.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```

Pokud chceme být schopni udělat něco v závislosti na všech přidaných `Eventech`, můžeme také přepsat metodu `onEvent` v našem `SimpleBlocDelegate`.

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

Pokud chceme být schopni udělat něco v závislosti na všech vyvolaných `Exceptionech` v Blocu, můžeme také přepsat metodu `onError` v našem `SimpleBlocDelegate`.

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

?> **Poznámka**: `BlocSupervisor` je singleton, který dohlíží na všechny Blocy a přenáší odpovědnost na `BlocDelegate`.
