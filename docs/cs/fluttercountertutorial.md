# Tutoriál: Počítadlo ve Flutteru

![začátečník](https://img.shields.io/badge/úroveň-začátečník-green.svg)

> V tomto tutoriálu vytvoříme počítadlo ve Flutteru pomocí Bloc knihovny.

![demo](../assets/gifs/flutter_counter.gif)

## Nastavení

Začneme vytvořením nového Flutter projektu.

```bash
flutter create flutter_counter
```

Potom nahradíme obsah `pubspec.yaml` tímto

```yaml
name: flutter_counter
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  meta: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

a pak nainstalujeme všechny závislosti

```bash
flutter packages get
```

Naše aplikace počítadla bude mít pouze dvě tlačítka na inkrementaci/dekrementaci hodnoty počítadla a `Text` widget, který zobrazí aktuální hodnotu. Pojďme začít navrhovat `CounterEventy`.

## Události Počátadla

```dart
enum CounterEvent { increment, decrement }
```

## Stavy Počítadla

Protože stav našeho počítadla může být reprezentován celým číslem, nemusíme vytvářet vlastní třídu!

## Counter Bloc

```dart
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

?> **Poznámka**: Jen z deklarace třídy můžeme vidět, že náš `CounterBloc` bude přijímat `CounterEventy` jako vstup a produkovat celá čísla.

## Counter App

Nyní když máme náš `CounterBloc` plně implementován, můžeme začít vytvářet naší Flutter aplikaci.

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

?> **Poznámka**: Používáme `BlocProvider` widget z `flutter_bloc`, abychom zpřístupnili instanci `CounterBloc` celému podstromu (`CounterPage`). `BlocProvider` také automaticky zpracovává ukončení `CounterBlocu`, takže nemusíme použít `StatefulWidget`.

## Counter Page

Finally, all that's left is to build our Counter Page.

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

?> **Poznámka**: Jsme schopni přistoupit k `CounterBloc` instanci pomocí `BlocProvider.of<CounterBloc>(context)`, protože jsme zabalili náš `CounterPage` do `BlocProvideru`.

?> **Poznámka**: Používáme `BlocBuilder` widget z `flutter_bloc`, abychom překreslili naši UI v reakci na změny stavu (změny v stavu počítadla).

?> **Poznámka**: `BlocBuilder` přijímá nepovinný parametr `bloc`, ale můžeme specifikovat typ blocu a typ stavu a `BlocBuilder` najde bloc automaticky, takže nemusíme explicitně používat `BlocProvider.of<CounterBloc>(context)`.

!> Pouze specifikujte bloc v `BlocBuilderu` pokud chcete poskytnout bloc, který bude použit v jednom widgetu a nebude přístupný pomocí rodičovského `BlocProvider` a aktuálního `BuildContextu`.

To je vše! Oddělili jsme naši prezenční vrstvu od aplikační vrstvy. Naše `CounterPage` neví, co se stane, když uživatel zmáčkne tlačítko. Jenom přidá událost a upozorní `CounterBloc`. Navíc, náš `CounterBloc` neví co se děje se stavem (hodnotou počítadla), jen jednoduše převádí `CounterEventy` na celá čísla.

Můžeme spustit naší aplikaci pomocí `flutter run` a zobrazit ji na našem zařízení nebo simulátoru/emulátoru.

Celý zdrojový kód tohoto příkladu můžete najít [zde](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
