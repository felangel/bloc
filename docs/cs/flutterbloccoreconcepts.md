# Základní koncepty Flutter Blocu

?> Ujistěte se, prosím, že si pečlivě přečtete a pochopíte následující sekce před tím, než budete pracovat s [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc widgety

### BlocBuilder

**BlocBuilder** je Flutter widget, který vyžaduje `Bloc` a `builder` funkci. `BlocBuilder` zpracovává sestavení widgetu v reakci na nové stavy. `BlocBuilder` je velmi podobný `StreamBuilderu`, ale má jednodušší API a tak není potřeba psát tolik kódu. Funkce `builder` může být zavolána vícekrát a měla by být bez vedlejších účinků ([pure funkce](https://en.wikipedia.org/wiki/Pure_function)); vrací widget v reakci na stav.

Pokud chcete "dělat" něco v závislosti na stavu, jako je navigace, zobrazování dialogu atp, podívejte se na `BlocListener`.

Pokud je parametr blocu vynechán, `BlocBuilder` automaticky provede lookup pomocí `BlocProvideru` a aktuálního `BuildContextu`.

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Specifikujte bloc pouze tehdy, pokud chcete poskytnout bloc, který bude zaměřený na jeden widget a není dostupný skrze rodičovský `BlocProvider` a aktuální `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // provide the local bloc instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Pokud chcete mít snadnou kontrolu nad tím, kdy se builder funkce zavolá, můžete poskytnout nepovinnou `condition` (podmínku) `BlocBuilderu`. `condition` přijímá předchozí stav blocu a aktuální stav blocu a vrací boolean. Pokud `condition` vrací true, `builder` bude zavolán s aktuálním `stavem` a widget bude znovu sestaven. Pokud `condition` vrací false, `builder` nebude zavolán s aktuálním `stavem` a nebude znovu sestaven.

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### BlocProvider

**BlocProvider** je Flutter widget, který poskytuje bloc svým potomkům skrze `BlocProvider.of<T>(context)`. Je používán jako dependency injection (DI) widget tak, že jedna instance blocu může být poskytnuta vícero widgetům uvnitř podstromu.

Ve většině případů by měl být `BlocProvider` použit k sestavení nových `bloců`, které budou dostupné ke zbytku podstromu. V tomto případě, jelikož `BlocProvider` je zodpovědný za vytváření blocu, bude automaticky zpracováno ukončení blocu.

```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

V některých případech může být `BlocProvider` použit k poskytnutí existujícího blocu nové části widget stromu. To bude nejvíce běžně použito když existující `bloc` potřebuje být dostupný nové routě. V tomto případě `BlocProvider` automaticky neukončí bloc, jelikož ho nevytvořil.

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

a pak buď z `ChildA` nebo `ScreenA` můžeme získat `BlocA` pomocí:

```dart
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider

**MultiBlocProvider** je Flutter widget, který pojí více `BlocProvider` widgetů do jednoho. `MultiBlocProvider` zlepšuje čitelnost a eliminuje potřebu zanořovat více `BlocProviderů` do sebe. Použitím `MultiBlocProvideru` můžeme z tohoto kódu:

```dart
BlocProvider<BlocA>(
  create: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

udělat toto:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

### BlocListener

**BlocListener** je Flutter widget, který přijímá `BlocWidgetListener` a nepovinný `Bloc` a vyvolá `listener` v závislosti na změně stavu v blocu. Měl by být použit pro funkcionalitu, která se potřebuje stát jednou za změnu stavu jako je navigace, zobrazení `SnackBaru`, zobrazení `Dialogu` atp.

`listener` je zavolán pouze jednou pro každý stav (**NE** pro `initialState`) na rozdíl od `builder` v `BlocBuilderu` a je to `void` funkce.

Pokud je parametr blocu vynechán, `BlocListener` automaticky provede lookup pomocí `BlockProvideru` a aktuálního `BuildContextu`.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```

Specifikujte bloc pouze tehdy, pokud chcete poskytnout bloc, který není jinak dostupný skrze rodičovský `BlocProvider` a aktuální `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

Pokud chcete mít snadnou kontrolu nad tím, kdy se listener funkce zavolá, můžete poskytnout nepovinnou `condition` (podmínku) `BlocListeneru`. `condition` přijímá předchozí stav blocu a aktuální stav blocu a vrací boolean. Pokud `condition` vrací true, `listener` bude zavolán s aktuálním `stavem`. Pokud `condition` vrací false, `listener` nebude zavolán s aktuálním `stavem`.

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
  child: Container(),
)
```

### MultiBlocListener

**MultiBlocListener** je flutter widget, který pojí více `BlocListener` widgetů do jednoho. `MultiBlocListener` zlepšuje čitelnost a eliminuje potřebu zanořovat více `BlocListenerů`. Použitím `MultiBlocListeneru` můžeme z tohoto kódu:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

udělat toto:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

### RepositoryProvider

**RepositoryProvider** je Flutter widget, který poskytuje repozitář jeho potomkům prostřednictvím `RepositoryProvider.of<T>(context)`. Je použit jako depencency injection (DI) widget tak, že jedna instance repozitáře může být poskytnuta vícero widgetům uvnitř podstromu. `BlocProvider` by měl být poskytnut blocům kdežto `RepositoryProvider` by měl být použit pro repozitáře.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

pak z `ChildA` můžeme získat instanci `Repozitáře` pomocí:

```dart
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider** je Flutter widget, který pojí více `RepositoryProvider` do jednoho. `MultiRepositoryProvider` zlepšuje čitelnost a eliminuje potřebu zanořovat více `RepositoryProviderů`. Použitím `MultiRepositoryProvider` můžeme z tohoto kódu:

```dart
RepositoryProvider<RepositoryA>(
  builder: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    builder: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

udělat toto:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      builder: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      builder: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## Použití

Podívejme se na to, jak použít `BlocBuilder` pro připojení `CounterPage` widgetu ke `CounterBloc`.

### counter_bloc.dart

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

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

V tomto bodě máme úspěšně oddělenou naší prezenční vrstvu od naší aplikační vrstvy. Všimněte si, že `CounterPage` widget neví nic o tom, co se děje když uživatel klepne na tlačítko. Widget jednoduše řekne `CounterBloc`, že uživatel stiskl tlačítko inkrementace nebo dekrementace.
