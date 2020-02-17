# Často kladené otázky

## Stav se neupdatuje

❔ **Otázka**: Yielduji stav v mém blocu, ale UI se neupdatuje. Co dělám špatně?

💡 **Odpověď**: Pokud používáte Equatable, ujistěte se, že předáváte všechny vlastnosti do props getteru.

✅ **SPRÁVNĚ**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // pass all properties to props
}
```

❌ **ŠPATNĚ**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [];
}
```

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => null;
}
```

Také se ujistěte, že v blocu yieldujete novou instancu stavu.

✅ **SPRÁVNĚ**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // always create a new instance of the state you are going to yield
    yield state.copyWith(property: event.property);
}
```

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // always create a new instance of the state you are going to yield
    yield MyState(data: data);
}
```

❌ **ŠPATNĚ**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // never modify/mutate state
    state.property = event.property;
    // never yield the same instance of state
    yield state;
}
```

## Kdy použít Equatable

❔**Otázka**: Kdy používat Equatable?

💡**Odpověď**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

V ukázce výše, pokud `StateA` rozšiřuje `Equatable`, nastane pouze jeden stav (druhý yield bude ignorován).
Obecně, pokud chcete optimalizovat váš kód, byste měli používat `Equatable` k redukování počtu znovusestavení.
Neměli byste používat `Equatable`, pokud chcete, aby stejný stav spouštěl více transakcí.

Navíc, použitím `Equatable` si ulehčíte testování bloců, jelikož můžeme očekávat specifické instance stavů bloku spíše než pomocí `Matchers` nebo `Predicates`.

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        MyStateA(),
        MyStateB(),
    ],
)
```

Bez `Equatable` by test výše selhal a musel by být přepsán takto:

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```

## Bloc vs. Redux

❔ **Otázka**: Jaký je rozdíl mezi Blocem a Reduxem?

💡 **Odpověď**:

BLoC je návrhový vzor, který je definovaný následujícími pravidly:

1. Vstup a výstup z blocu jsou jednoduché streamy a sinky.
2. Závislosti musí být injektovatelné a nezávislé na platformě.
3. Není povoleno žádné větvení kvůli platformě.
4. Implementace může být cokoli co chcete, pokud budete dodržovat výše uvedená pravidla.

UI pokyny jsou:

1. Každá "dostatečně komplexní" komponenta má příslušný BLoC.
2. Komponenty by měly posílat vstupy "jak jsou".
3. Komponenty by měly zobrazovat výstupy co nejblíže tomu, "jaké jsou".
4. Všechno větvění by mělo být založeno na jednoduchých BLoC boolean hodnotách.

Knihovna Bloc implementuje BLoC návrhový vzor a klade si za cíl abstrahovat RxDart a zjednodušit vývojářský zážitek. 

Tři principy Reduxu jsou:

1. Jeden zdroj pravdy
2. Stav je pouze ke čtení
3. Změny se provádějí pomocí pure funkcí

Knihovna Bloc porušuje první princip; v blocu je stav distrubován napříč několika blocy.
Kromě toho neexistuje v blocu žádný koncept middlewaru a bloc je navržen tak, aby byly asynchronního změny stavu velmi snadné, což umožňuje emitovat více stavů pro jednu událost.

## Bloc vs. Provider

❔ **Otázka**: Jaký je rozdíl mezi Blocem a Providerem?

💡 **Odpověď**: `provider` je navržen pro dependency injection (obaluje `InheritedWidget`).
Pořád potřebujete vyřešit jak spravovat váš stav (pomocí `ChangeNotifier`, `Bloc`, `Mobx`, atp...).
Knihovna Bloc vnitřně používá `provider` pro snadné poskytnutí a přístup k blocům skrze strom widgetů.

## Navigace s Blocem

❔ **Otázka**: Jak udělám navigaci s Blocem?

💡 **Odpověď**: Mrkněte na [Flutter Navigaci](recipesflutternavigation.md)

## BlocProvider.of() nezvládá najít Bloc

❔ **Otázka**: Použitím `BlocProvider.of(context)` nenajdu bloc. Jak to vyřešit? 

💡 **Odpověď**: Nemůžete přistupovat k bloku ve stejném kontextu, ve kterém byl poskytnut, takže musíte zajistit, aby `BlocProvider.of()` byl zavolán v `BuildContext` potomka.

✅ **SPRÁVNĚ**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      },
    )
    ...
  }
}
```

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          final blocA = BlocProvider.of<BlocA>(context);
          ...
        },
      ),
    ),
  );
}
```

❌ **ŠPATNĚ**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      }
    )
  );
}
```

## Struktura projektu

❔ **Otázka**: Jak mám strukturovat svůj projekt?

💡 **Odpověď**: Ikdyž na tuto otázku opravdu není žádná správná/špatná odpověď, některá doporučení jsou

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Nejdůležitější věc je mít stukturu projektu konzisentní a úmyslnou.
