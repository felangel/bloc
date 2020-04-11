# Tutoriál: Počítadlo ve Flutteru

![začátečník](https://img.shields.io/badge/úroveň-začátečník-green.svg)

> V tomto tutoriálu vytvoříme počítadlo ve Flutteru pomocí Bloc knihovny.

![demo](../assets/gifs/flutter_counter.gif)

## Nastavení

Začneme vytvořením nového Flutter projektu.

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

Potom nahradíme obsah `pubspec.yaml` tímto

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

a pak nainstalujeme všechny závislosti

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Naše aplikace počítadla bude mít pouze dvě tlačítka na inkrementaci/dekrementaci hodnoty počítadla a `Text` widget, který zobrazí aktuální hodnotu. Pojďme začít navrhovat `CounterEventy`.

## Události Počátadla

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Stavy Počítadla

Protože stav našeho počítadla může být reprezentován celým číslem, nemusíme vytvářet vlastní třídu!

## Counter Bloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Poznámka**: Jen z deklarace třídy můžeme vidět, že náš `CounterBloc` bude přijímat `CounterEventy` jako vstup a produkovat celá čísla.

## Counter App

Nyní když máme náš `CounterBloc` plně implementován, můžeme začít vytvářet naší Flutter aplikaci.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Poznámka**: Používáme `BlocProvider` widget z `flutter_bloc`, abychom zpřístupnili instanci `CounterBloc` celému podstromu (`CounterPage`). `BlocProvider` také automaticky zpracovává ukončení `CounterBlocu`, takže nemusíme použít `StatefulWidget`.

## Counter Page

Finally, all that's left is to build our Counter Page.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Poznámka**: Jsme schopni přistoupit k `CounterBloc` instanci pomocí `BlocProvider.of<CounterBloc>(context)`, protože jsme zabalili náš `CounterPage` do `BlocProvideru`.

?> **Poznámka**: Používáme `BlocBuilder` widget z `flutter_bloc`, abychom překreslili naši UI v reakci na změny stavu (změny v stavu počítadla).

?> **Poznámka**: `BlocBuilder` přijímá nepovinný parametr `bloc`, ale můžeme specifikovat typ blocu a typ stavu a `BlocBuilder` najde bloc automaticky, takže nemusíme explicitně používat `BlocProvider.of<CounterBloc>(context)`.

!> Pouze specifikujte bloc v `BlocBuilderu` pokud chcete poskytnout bloc, který bude použit v jednom widgetu a nebude přístupný pomocí rodičovského `BlocProvider` a aktuálního `BuildContextu`.

To je vše! Oddělili jsme naši prezenční vrstvu od aplikační vrstvy. Naše `CounterPage` neví, co se stane, když uživatel zmáčkne tlačítko. Jenom přidá událost a upozorní `CounterBloc`. Navíc, náš `CounterBloc` neví co se děje se stavem (hodnotou počítadla), jen jednoduše převádí `CounterEventy` na celá čísla.

Můžeme spustit naší aplikaci pomocí `flutter run` a zobrazit ji na našem zařízení nebo simulátoru/emulátoru.

Celý zdrojový kód tohoto příkladu můžete najít [zde](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
