# Základní koncepty Flutter Blocu

?> Ujistěte se, prosím, že si pečlivě přečtete a pochopíte následující sekce před tím, než budete pracovat s [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc widgety

### BlocBuilder

**BlocBuilder** je Flutter widget, který vyžaduje `Bloc` a `builder` funkci. `BlocBuilder` zpracovává sestavení widgetu v reakci na nové stavy. `BlocBuilder` je velmi podobný `StreamBuilderu`, ale má jednodušší API a tak není potřeba psát tolik kódu. Funkce `builder` může být zavolána vícekrát a měla by být bez vedlejších účinků ([pure funkce](https://en.wikipedia.org/wiki/Pure_function)); vrací widget v reakci na stav.

Pokud chcete "dělat" něco v závislosti na stavu, jako je navigace, zobrazování dialogu atp, podívejte se na `BlocListener`.

Pokud je parametr blocu vynechán, `BlocBuilder` automaticky provede lookup pomocí `BlocProvideru` a aktuálního `BuildContextu`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Specifikujte bloc pouze tehdy, pokud chcete poskytnout bloc, který bude zaměřený na jeden widget a není dostupný skrze rodičovský `BlocProvider` a aktuální `BuildContext`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Pokud chcete mít snadnou kontrolu nad tím, kdy se builder funkce zavolá, můžete poskytnout nepovinnou `buildWhen` (podmínku) `BlocBuilderu`. `buildWhen` přijímá předchozí stav blocu a aktuální stav blocu a vrací boolean. Pokud `buildWhen` vrací true, `builder` bude zavolán s aktuálním `stavem` a widget bude znovu sestaven. Pokud `buildWhen` vrací false, `builder` nebude zavolán s aktuálním `stavem` a nebude znovu sestaven.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** je Flutter widget, který poskytuje bloc svým potomkům skrze `BlocProvider.of<T>(context)`. Je používán jako dependency injection (DI) widget tak, že jedna instance blocu může být poskytnuta vícero widgetům uvnitř podstromu.

Ve většině případů by měl být `BlocProvider` použit k sestavení nových `bloců`, které budou dostupné ke zbytku podstromu. V tomto případě, jelikož `BlocProvider` je zodpovědný za vytváření blocu, bude automaticky zpracováno ukončení blocu.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

V některých případech může být `BlocProvider` použit k poskytnutí existujícího blocu nové části widget stromu. To bude nejvíce běžně použito když existující `bloc` potřebuje být dostupný nové routě. V tomto případě `BlocProvider` automaticky neukončí bloc, jelikož ho nevytvořil.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

a pak buď z `ChildA` nebo `ScreenA` můžeme získat `BlocA` pomocí:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider** je Flutter widget, který pojí více `BlocProvider` widgetů do jednoho. `MultiBlocProvider` zlepšuje čitelnost a eliminuje potřebu zanořovat více `BlocProviderů` do sebe. Použitím `MultiBlocProvideru` můžeme z tohoto kódu:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

udělat toto:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** je Flutter widget, který přijímá `BlocWidgetListener` a nepovinný `Bloc` a vyvolá `listener` v závislosti na změně stavu v blocu. Měl by být použit pro funkcionalitu, která se potřebuje stát jednou za změnu stavu jako je navigace, zobrazení `SnackBaru`, zobrazení `Dialogu` atp.

`listener` je zavolán pouze jednou pro každý stav (**NE** pro `initialState`) na rozdíl od `builder` v `BlocBuilderu` a je to `void` funkce.

Pokud je parametr blocu vynechán, `BlocListener` automaticky provede lookup pomocí `BlockProvideru` a aktuálního `BuildContextu`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Specifikujte bloc pouze tehdy, pokud chcete poskytnout bloc, který není jinak dostupný skrze rodičovský `BlocProvider` a aktuální `BuildContext`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Pokud chcete mít snadnou kontrolu nad tím, kdy se listener funkce zavolá, můžete poskytnout nepovinnou `listenWhen` (podmínku) `BlocListeneru`. `listenWhen` přijímá předchozí stav blocu a aktuální stav blocu a vrací boolean. Pokud `listenWhen` vrací true, `listener` bude zavolán s aktuálním `stavem`. Pokud `listenWhen` vrací false, `listener` nebude zavolán s aktuálním `stavem`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener** je flutter widget, který pojí více `BlocListener` widgetů do jednoho. `MultiBlocListener` zlepšuje čitelnost a eliminuje potřebu zanořovat více `BlocListenerů`. Použitím `MultiBlocListeneru` můžeme z tohoto kódu:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

udělat toto:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** je Flutter widget, který poskytuje repozitář jeho potomkům prostřednictvím `RepositoryProvider.of<T>(context)`. Je použit jako depencency injection (DI) widget tak, že jedna instance repozitáře může být poskytnuta vícero widgetům uvnitř podstromu. `BlocProvider` by měl být poskytnut blocům kdežto `RepositoryProvider` by měl být použit pro repozitáře.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

pak z `ChildA` můžeme získat instanci `Repozitáře` pomocí:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider** je Flutter widget, který pojí více `RepositoryProvider` do jednoho. `MultiRepositoryProvider` zlepšuje čitelnost a eliminuje potřebu zanořovat více `RepositoryProviderů`. Použitím `MultiRepositoryProvider` můžeme z tohoto kódu:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

udělat toto:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Použití

Podívejme se na to, jak použít `BlocBuilder` pro připojení `CounterPage` widgetu ke `CounterBloc`.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

V tomto bodě máme úspěšně oddělenou naší prezenční vrstvu od naší aplikační vrstvy. Všimněte si, že `CounterPage` widget neví nic o tom, co se děje když uživatel klepne na tlačítko. Widget jednoduše řekne `CounterBloc`, že uživatel stiskl tlačítko inkrementace nebo dekrementace.
