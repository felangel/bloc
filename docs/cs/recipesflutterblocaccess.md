# Recepty: Zpřístupnění Blocu

> V tomto receptu si ukážeme, jak používat `BlocProvider`, abychom zpřístupnili bloc skrz strom widgetů. Prozkoumáme tři scénáře: lokální přístup, přístup napříč routami a globální přístup.

## Lokální přístup

> V této ukázce is ukážeme, jak používat `BlocProvider`, abychom zpřístupnili bloc lokálnímu podstromu. V tomto kontextu lokální znameá, že nepracujeme s routami.

### Bloc

Pro jednoduchost jako ukázkovou aplikaci použijeme `Počítadlo`.

Naše implementace `CounterBlocu` bude vypadat takto:

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Budeme mít 3 části našeho UI:

- App: kořenový widget aplikace
- CounterPage: kontejnerový widget, který bude spravovat `CounterBloc` a odhalovat `FloatingActionButtony` pro `increment` a `decrement` počítadlu.
- CounterText: textový widget, který je odpovědný za zobrazení aktuálního `čísla`.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/local_access/main.dart.md ':include')

Náš widget `App` je `StatelessWidget`, který používá `MaterialApp` a nastavuje naši `CounterPage` jako home widget. Widget `App` je odpovědný za vytvoření a ukončení `CounterBlocu`, stejně za jeho poskytuní `CounterPage` pomocí `BlocProvideru`.

?> **Poznámka:** Když zabalíme widget `BlocProviderem`, můžeme poskytnout bloc všem widgetům v rámci daného podstromu. V tomto případě můžeme přistupovat k `CounterBlocu` z widgetu `CounterPage` a jakýchkoli potomků `CounterPage` widgetu pomocí `BlocProvider.of<CounterBloc>(context)`.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_page.dart.md ':include')

Widget `CounterPage` je `StatelessWidget`, který přistupuje k `CounterBlocu` pomocí `BuildContextu`.

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_text.dart.md ':include')

Náš `CounterText` widget používá `BlocBuilder` k opětovnému renderování sebe sama kdykoli se stav `CounterBlocu` změní. Abychom mohli přistoupit k poskytovanému `CounterBlocu`, používáme `BlocProvider.of<CounterBloc>(context)` a vracíme `Text` widget s aktuálním číslem.

To je vše k lokálnímu přístupu blocu tohoto receptu. Celý zdrojový kód najdete [zde](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

Jako další si ukážeme, jak poskytovat bloc napříč vícero stránkami/routami.

## Přístup napříč routy

> V této ukázce použijeme `BlocProvider` k přístupnění blocu napříč routami. Když se přidá nová routa, bude mít jiný `BuildContext`, který již nebude mít referenci na předešlé poskytované blocy. V důsledku toho musíme zaobalit novou routu do samostatného `BlocProvideru`.

### Bloc

Znovu pro jednoduchost použijeme `CounterBloc`.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Znovu budeme mít tři části UI aplikace:

- App: kořenový widget aplikace
- HomePage: kontejnerový widget, který bude spravovat `CounterBloc` a odhalovat `FloatingActionButtony` pro `increment` a `decrement` počítadlu.
- CounterPage: widget, který je odpovědný za zobrazení aktuálního `čísla` v samostatné routě.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/main.dart.md ':include')

Náš `App` widget bude stejný jako v předešlé ukázce.

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/home_page.dart.md ':include')

`HomePage` je podobná `CounterPage` z předešlé ukázky, avšak namísto renderování `CounterText` widgetu renderuje uprostřed `RaisedButton`, který umožní uživatelovi navigovat na novout obrazovku, která zobrazí aktuální číslo.

Když uživatel klepne na `RaisedButton`, přidáme novou `MaterialPageRoute` a vrátíme `CounterPage`, avšak musíme zabalit `CounterPage` v `BlocProvideru`, abychom zpřístupnili aktuální instanci `CounterBlocu` na další stránce.

!> Je důležité, abychom v tomto případě používali value konstruktor `BlocProvideru`, protože poskytujeme již existující instanci `CounterBlocu`. Hodnota konstruktoru `BlocProvideru` by měla být použita pouze v těch případech, kde chceme poskytovat existující blok do nového podstromu. Navíc, použitím value konstruktoru nebudeme ukončovat bloc automaticky, což je v tomto případě to, co chceme (jelikož potřebujeme, aby `CounterBloc` fungoval i v nadřazených widgetech). Namísto toho jednoduše předáme existující `CounterBloc` nové stránce jako existující hodnotu, a ne tedy předanou v builderu. To zajistí to, že když už `CounterBloc` není dále potřeba, pouze nejvyšší úroveň `BlocProvideru` zpracovává ukončení.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/counter_page.dart.md ':include')

`CounterPage` je super jednoduchý `StatelessWidget`, který používá `BlocBuilder` k překreslení `Text` widgetu s aktuálním číslem. Stejně jako předtím, můžeme použít `BlocProvider.of<CounterBloc>(context)` abychom přistoupili k `CounterBloc`.

To je vše k tomuto příkladu. Celý zdrojový kód najdete [zde](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

Nakonec se podíváme na to, jak globálně zpřístupnit bloc stromu widgetů.

## Globální přístup

> V této poslední ukázce demonstrujeme, jak zpřístupnit bloc celému stromu widgetů. To je užitečné pro specifické případy jako jsou `AuthenticationBloc` nebo `ThemeBloc`, protože se jejich stav vztahuje na všechny části aplikace.

### Bloc

Jako obvykle, pro jednoduchost použijeme pro náš příklad `CounterBloc`.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Budeme mít stejnou strukturu jako v příkladu o lokálním přístupu. V důsledku toho budeme mít tři části našeho UI:

- App: kořenový widget aplikace, který zpravuje globální instance našeho `CounterBlocu`.
- CounterPage: kontejnerový widget, který odhaluje `FloatingActionButtony` pro `increment` a `decrement` počítadlu.
- CounterText: textový widget, který je odpovědný za zobrazení aktuálního `čísla`.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/global_access/main.dart.md ':include')

Podobně jako ve výše uvedeném příkladu lokálního přístupu, `App` řídí vytváření, ukončování a poskytování `CounterBlocu` podstromu pomocí `BlocProvideru`. Hlavní rozdíl je v tomto případě je to, že `MaterialApp` je potomkem `BlocProvideru`.

Zabalení celé `MaterialApp` do `BlocProvideru` je klíčem k tomu, aby byla naše instance `CounterBlocu` globálně přístupná. Nyní můžeme přistupovat k našemu `CounterBlocu` odkudkoli v naší aplikaci, kde máme `BuildContext` pomocí `BlocProvider.of<CounterBloc>(context);`

?> **Poznámka:** Tento přístup funguje stejně dobře i pokud používáte `CupertinoApp` nebo `WidgetsApp`.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_page.dart.md ':include')

Naše `CounterPage` je `StatelessWidget`, protože nepotřebuje spravovat svůj stav. Jak jsme zmínili výše, k přístupu k globální instanci `CounterBlocu` používá `BlocProvider.of<CounterBloc>(context)`.

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_text.dart.md ':include')

Nic nového, `CounterText` widget je ten samý jako v naší první ukázce. Je to jen `StatelessWidget`, který používá `BlocBuilder` k překreslení když se stav `CounterBloc` změní a přistupuje k globální instanci `CounterBloc` pomocí `BlocProvider.of<CounterBloc>(context)`.

To je vše. Celý zdrojový kód můžete najít [zde](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).
