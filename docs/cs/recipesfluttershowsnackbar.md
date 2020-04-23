# Recepty: Zobrazení SnackBaru s BlocListenerem

> V tomto receptu se podíváme na to, jak použít `BlocListener` k zobrazení `SnackBaru` v reakci na změnu stavu blocu.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

Pojďme si udělat základní `DataBloc`, který bude zpracovávat `DataEventy` a produkovat `DataStaty`.

### DataEvent

Pro jednoduchost bude náš `DataBloc` reagovat pouze na jeden `DataEvent`, který pojmenujeme `FetchData`.

[data_event.dart](../_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### DataState

Náš `DataBloc` může mít jeden z tří různých `DataStatů`:

- `Initial` - počáteční stav před přidáním jakýchkoli událostí
- `Loading` - stav blocu zatímco se asynchroně "načítají data"
- `Success` - stav blocu když se data úspěšně "načetla"

[data_state.dart](../_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### DataBloc

Náš `DataBloc` by měl vypadat nějak takto:

[data_bloc.dart](../_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **Poznámka:** Používáme `Future.delayed` abychom simulovali latenci.

## UI vrstva

Nyní se pojďme podívat jak připojit `DataBloc` wiget a zobrazit `Snackbar` v reakci na stav úspěchu.

[main.dart](../_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> Používáme `BlocListener` widget abychom **DĚLALI VĚCI** v reakci na změny stavu našeho `DataBlocu`.

?> Používáme `BlocBuilder` widget abychom **VYKRESLOVALI WIDGETY** v závislosti na změně stavu našeho `DataBlocu`.

!> **NIKDY** bychom neměli "dělat věci" v závislosti na změně stavu v `builder` metodě `BlocBuilderu`, protože tato metoda může být zavolána Flutter frameworkem mnohokrát. `builder` metoda by měla být vez vedlejších účinků ([pure funkce](https://en.wikipedia.org/wiki/Pure_function)), která vrací widget v reakci na stav blocu.

Celý zdrojový kód pro tento recept můžete najít [zde](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).
