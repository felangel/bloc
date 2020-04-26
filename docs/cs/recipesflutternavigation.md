# Recepty: Navigace

> V tomto receptu se podíváme na použítí `BlocBuilderu` a/nebo `BlocListeneru` k navigaci. Prozkoumáme dva přístupy: Přímou navigaci a Navigaci routami.

## Přímá navigace

> V tétu ukázce se podíváme na to, jak použít `BlocBuilder` k zobrazení dané stránky (widgetu) jako odezvu na změnu stavu v blocu bez použití routy.

![demo](../assets/gifs/recipes_flutter_navigation_direct.gif)

### Bloc

Pojďme si udělat `MyBloc`, který bude přijímat `MyEventy` a produkovat `MyStaty`.

#### MyEvent

Pro jednoduchost bude naše aplikace reagovat pouze na dva `MyEventy`: `eventA` a `eventB`.

[my_event.dart](../_snippets/recipes_flutter_navigation/my_event.dart.md ':include')

#### MyState

Náš `MyBloc` může mít jeden ze dvou `MyStavů`:

- `StateA` - stav blocu, když je vekreslena `PageA`.
- `StateB` - stav blocu, když je vekreslena `PageB`.

[my_state.dart](../_snippets/recipes_flutter_navigation/my_state.dart.md ':include')

#### MyBloc

Náš `MyBloc` by měl vypadat nějak takto:

[my_bloc.dart](../_snippets/recipes_flutter_navigation/my_bloc.dart.md ':include')

### UI vrstva

Nyní se pojďme podívat na to, jak propojit `MyBloc` k widgetu a zobrazit jinou stránku v závislosti na stavu blocu.

[main.dart](../_snippets/recipes_flutter_navigation/direct_navigation/main.dart.md ':include')

?> Používáme `BlocBuilder` widget abychom vykreslili správný widget v reakci na změnu stavu našeho `MyBlocu`.

?> Používáme `BlocProvider` widget abychom zpřístupnili naší instanci `MyBloc` celému stromu widgetů.

Celý zdrojový kód pro tento recept můžete najít [zde](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09).

## Navigace routami

> V této ukázce se podíváme na to, jak použít `BlocListener` k navigaci na danou stránku (widget) v reakci na změnu stavu v blocu použitím routy.

![demo](../assets/gifs/recipes_flutter_navigation_routes.gif)

### Bloc

Použijeme `MyBloc` z předešlého příkladu.

### UI vrstva

Podívejme se na to, jak routovat na jinou stránku v závislosti na stavu `MyBlocu`.

[main.dart](../_snippets/recipes_flutter_navigation/route_navigation/main.dart.md ':include')

?> Používáme `BlocListener` widget abychom přidali novou routu v reakci na změnu stavu v našem `MyBlocu`.

!> Pro jednoduchost přidáváme událost pouze pro navigaci. V reálné aplikaci byste však konkrétní události pro navigaci nevytvářeli. Pokud pro spuštění navigace není nutná žádná logika, měli byste vždy přímo navigovat v reakci na vstup uživatele (v `onPressed` callbacku atp.). Navigujte v závislosti na změně stavu pouze když je vyžadována nějaká logika k určení, kam navigovat.

Celý zdrojový kód pro tento recept můžete najít [zde](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd).
