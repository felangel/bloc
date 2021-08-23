# Grundlegende Konzepte (package:flutter_bloc)

?> Bitte lesen Sie die folgenden Abschnitte sorgfältig durch, bevor Sie mit [package:flutter_bloc](https://pub.dev/packages/flutter_bloc) beginnen.

?> **Hinweis**: Alle Widgets, die vom Paket `flutter_bloc` exportiert werden, lassen sich sowohl in `Cubit`- als auch in `Bloc`-Instanzen integrieren.

## Bloc Widgets

### BlocBuilder

**BlocBuilder** ist ein Flutter-Widget, das einen `Bloc` und eine `Builder`-Funktion benötigt. Der `BlocBuilder` baut das Widget als Reaktion auf neue Zustände auf. Der `BlocBuilder` ist dem `StreamBuilder` sehr ähnlich, hat aber eine einfachere API, um die Menge des benötigten Boilerplate-Codes zu reduzieren. Die `builder` Funktion wird potentiell viele Male aufgerufen werden und sollte eine [pure function](https://en.wikipedia.org/wiki/Pure_function) sein, die ein Widget als Antwort auf den Zustand zurückgibt.

Benutzen Sie `BlocListener`, wenn Sie etwas als Reaktion auf Zustandsänderungen wie Navigation, Anzeigen eines Dialogs usw. durchführen wollen.

Wenn der Parameter `bloc` weggelassen wird, führt `BlocBuilder` automatisch eine Suche unter Verwendung von `BlocProvider` und dem aktuellen `BuildContext` durch.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Geben Sie den Bloc nur an, wenn Sie einen Bloc bereitstellen möchten, der auf ein einzelnes Widget beschränkt ist und nicht über einen übergeordneten `BlocProvider` und den aktuellen `BuildContext` zugänglich ist.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Für eine fein granulierte Kontrolle darüber, wann die Funktion `builder` aufgerufen wird, kann ein optionales `buildWhen` angegeben werden. `buildWhen` nimmt den vorherigen und den aktuellen Bloc-Zustand und gibt einen booleschen Wert zurück. Wenn `buildWhen` true zurückgibt, wird `builder` mit `state` aufgerufen und das Widget wird neu aufgebaut. Wenn `buildWhen` false zurückgibt, wird `builder` nicht mit `state` aufgerufen und es findet kein Neuaufbau statt.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** ist ein Flutter-Widget, das seinen Kindelementen über `BlocProvider.of<T>(context)` einen Bloc zur Verfügung stellt. Es wird als Dependency Injection (DI) Widget verwendet, so dass eine einzelne Instanz eines Blocs an mehrere Widgets innerhalb eines Sub-Trees bereitgestellt werden kann.

In den meisten Fällen sollte `BlocProvider` verwendet werden um neue Blocs zu erstellen die dem Rest des Sub-Trees zur Verfügung gestellt werden. Da `BlocProvider` in diesem Fall für die Erstellung des Blocs verantwortlich ist, wird er automatisch das Schließen des Blocs übernehmen.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

Standardmäßig erstellt `BlocProvider` den Bloc verzögert (lazily), d.h. `create` wird ausgeführt, wenn der Bloc über `BlocProvider.of<BlocA>(context)` nachgeschaut wird.

Um dieses Verhalten außer Kraft zu setzen und zu erzwingen, dass `create` sofort ausgeführt wird, kann `lazy` auf `false` gesetzt werden.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lazy.dart.md ':include')

In einigen Fällen kann `BlocProvider` verwendet werden, um einen bestehenden Bloc einem neuen Teil des Widget-Baums zur Verfügung zu stellen. Dies wird am häufigsten verwendet, wenn ein bestehender Bloc einer neuen Route zur Verfügung gestellt werden soll. In diesem Fall wird `BlocProvider` den Bloc nicht automatisch schließen, da er ihn nicht erstellt hat.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

dann können wir entweder von `ChildA` oder von `ScreenA` `BlocA` abrufen mit:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider** ist ein Flutter-Widget, das mehrere `BlocProvider`-Widgets zu einem einzigen zusammenfasst.
`MultiBlocProvider` verbessert die Lesbarkeit und beseitigt die Notwendigkeit, mehrere `BlocProvider` zu verschachteln.
Durch die Verwendung von `MultiBlocProvider` können wir statt:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

folgendes implementieren:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** ist ein Flutter-Widget, das einen `BlocWidgetListener` und einen optionalen `Bloc` nimmt und den `listener` als Reaktion auf Zustandsänderungen im Bloc aufruft. Es sollte für Funktionen verwendet werden, die einmal pro Zustandsänderung auftreten müssen, wie z.B. Navigation, Anzeigen einer `SnackBar`, Anzeigen eines `Dialogs`, etc.

`listener` wird im Gegensatz zu `builder` in `BlocBuilder` nur einmal pro Zustandsänderung (NICHT einschließlich des Anfangszustands) aufgerufen und ist eine void-Funktion.

Wenn der `Bloc`-Parameter weggelassen wird, führt `BlocListener` automatisch eine Suche mit `BlocProvider` und dem aktuellen `BuildContext` durch.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Geben Sie den Block nur an, wenn Sie einen Block bereitstellen wollen, der sonst nicht über `BlocProvider` und den aktuellen `BuildContext` zugänglich ist.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Für eine fein granulierte Kontrolle darüber, wann die Funktion `listener` aufgerufen wird, kann ein optionales `listenWhen` angegeben werden. `listenWhen` nimmt den vorherigen Bloc-Zustand und den aktuellen Bloc-Zustand und gibt einen booleschen Wert zurück. Wenn `listenWhen` true zurückgibt, wird `listener` mit `state` aufgerufen. Wenn `listenWhen` false zurückgibt, wird `listener` nicht mit `state` aufgerufen.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener** ist ein Flutter-Widget, das mehrere `BlocListener`-Widgets zu einem einzigen zusammenfasst.
`MultiBlocListener` verbessert die Lesbarkeit und eliminiert die Notwendigkeit, mehrere `Blocklistener` zu verschachteln.
Durch die Verwendung von `MultiBlocListener` können wir statt:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

folgendes implementieren:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer** stellt einen `Builder` und `Listener` zur Verfügung, um auf neue Zustände zu reagieren. `BlocConsumer` ist analog zu einem verschachtelten `BlocListener` und `BlocBuilder`, reduziert aber die Menge des benötigten Boilerplates. `BlocConsumer` sollte nur verwendet werden, wenn es notwendig ist, sowohl die Benutzeroberfläche neu zu erstellen als auch andere Reaktionen auf Zustandsänderungen im `Bloc` auszuführen. `BlocConsumer` nimmt einen erforderlichen `BlocWidgetBuilder` und `BlocWidgetListener` und einen optionalen `Bloc`, `BlocBuilderCondition`, und `BlocListenerCondition`.

Wenn der Parameter `bloc` weggelassen wird, führt `BlocConsumer` automatisch einen Lookup unter Verwendung von
`BlocProvider` und dem aktuellen `BuildContext`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

An optional `listenWhen` and `buildWhen` can be implemented for more granular control over when `listener` and `builder` are called. The `listenWhen` and `buildWhen` will be invoked on each `bloc` `state` change. They each take the previous `state` and current `state` and must return a `bool` which determines whether or not the `builder` and/or `listener` function will be invoked. The previous `state` will be initialized to the `state` of the `bloc` when the `BlocConsumer` is initialized. `listenWhen` and `buildWhen` are optional and if they aren't implemented, they will default to `true`.

Ein optionales `listenWhen` und `buildWhen` können implementiert werden, um eine genauere Kontrolle darüber zu haben, wann `listener` und `builder` aufgerufen werden. Die `listenWhen` und `buildWhen` werden bei jeder `bloc` `state` Änderung aufgerufen. Sie nehmen jeweils den vorherigen `state` und den aktuellen `state` und müssen ein `bool` zurückgeben, das bestimmt, ob die `builder` und/oder `listener` Funktion aufgerufen wird oder nicht. Der vorherige `state` wird auf den `state` des `bloc` initialisiert, wenn der `BlocConsumer` initialisiert wird. `listenWhen` und `buildWhen` sind optional und wenn sie nicht implementiert sind, werden sie standardmäßig auf `true` gesetzt.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** ist ein Flutter-Widget, das seinen Kindelementen ein Repository über `RepositoryProvider.of<T>(context)` zur Verfügung stellt. Es wird als Dependency Injection (DI) Widget verwendet, so dass eine einzelne Instanz eines Repositorys mehreren Widgets innerhalb eines Sub-Trees zur Verfügung gestellt werden kann. `BlocProvider` sollte verwendet werden, um Blöcke bereitzustellen, während `RepositoryProvider` nur für Repositories verwendet werden sollte.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

dann können wir von `ChildA` die `Repository`-Instanz abrufen mit:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider** ist ein Flutter-Widget, das mehrere `RepositoryProvider`-Widgets zu einem einzigen zusammenfasst.
`MultiRepositoryProvider` verbessert die Lesbarkeit und eliminiert die Notwendigkeit, mehrere `RepositoryProvider` zu verschachteln.
Durch die Verwendung von `MultiRepositoryProvider` können wir von:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

folgendes implementieren:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Verwendung

Schauen wir uns an, wie man mit dem `BlocBuilder` ein `CounterPage`-Widget an einen `CounterBloc` anschließt.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

An diesem Punkt haben wir unsere Präsentationsschicht erfolgreich von unserer Geschäftslogikschicht getrennt. Beachten Sie, dass das Widget `CounterPage` nichts darüber weiß, was passiert, wenn ein Benutzer auf die Schaltflächen tippt. Das Widget teilt dem `CounterBloc` lediglich mit, dass der Benutzer entweder die Schaltfläche `increment` oder `decrement` gedrückt hat.
