# Grundlegende Konzepte (package:bloc)

?> Bitte lesen Sie die folgenden Abschnitte sorgfältig durch, bevor Sie mit [package:bloc](https://pub.dev/packages/bloc) arbeiten.

Es gibt mehrere Kernkonzepte, die für das Verständnis der Verwendung des bloc-Pakets entscheidend sind.

In den folgenden Abschnitten werden wir jedes von ihnen im Detail besprechen und durcharbeiten, wie sie auf eine Counter-Anwendung angewendet werden können.

## Streams

?> In der offiziellen [Dart-Dokumentation](https://dart.dev/tutorials/language/streams) finden Sie weitere Informationen über `Streams`.

> Ein Stream ist eine Folge von asynchronen Daten.

Um die bloc-Bibliothek nutzen zu können, ist es wichtig, ein grundlegendes Verständnis von `Streams` und deren Funktionsweise zu haben.

> Wenn Sie mit `Streams` nicht vertraut sind, stellen Sie sich einfach ein Rohr vor, durch das Wasser fließt. Das Rohr ist der `Stream` und das fließende Wasser sind die asynchronen Daten.

Wir können einen `Stream` in Dart erstellen, indem wir eine `async*`-Funktion (asynchroner Generator) schreiben.

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

Indem wir eine Funktion als `async*` kennzeichnen, können wir das Schlüsselwort `yield` verwenden und einen `Stream` von Daten zurückgeben. In dem obigen Beispiel geben wir einen `Stream` von Ganzzahlen bis zum Parameter `max` zurück.

Jedes Mal, wenn wir das Schlüsselwort `yield` in einer `async*`-Funktion verwenden, schieben wir diese Dateneinheit durch den `Stream`.

Wir können den obigen `Stream` auf verschiedene Arten nutzen. Wenn wir eine Funktion schreiben wollten, die die Summe eines `Streams` von Ganzzahlen zurückgibt, könnte sie etwa so aussehen:

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

Indem wir die obige Funktion als `async` kennzeichnen, können wir das Schlüsselwort `await` verwenden und eine `Future` mit ganzen Zahlen zurückgeben. In diesem Beispiel warten wir auf jeden Wert im Stream und geben die Summe aller Ganzzahlen im Stream zurück.

Wir können das alles so zusammensetzen:

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

Nachdem wir nun ein grundlegendes Verständnis davon haben, wie `Streams` in Dart funktionieren, sind wir bereit, etwas über die Kernkomponente des bloc-Pakets zu lernen: einen `Cubit`.

## Cubit

> Ein `Cubit` ist eine Klasse, die `BlocBase` erweitert und zur Verwaltung jeder Art von Zustand erweitert werden kann.

![Cubit Architecture](assets/cubit_architecture_full.png)

Ein `Cubit` kann Funktionen bereitstellen, die aufgerufen werden können, um Zustandsänderungen auszulösen.

> Zustände sind die Ausgaben eines `Cubits` und stellen einen Teil des Zustands Ihrer Anwendung dar. UI-Komponenten können über Zustände benachrichtigt werden und Teile von sich selbst, basierend auf dem aktuellen Zustand, neu zeichnen.

> **Hinweis**: Weitere Informationen über die Ursprünge von `Cubit` finden Sie [im folgenden Link](https://github.com/felangel/cubit/issues/69).

### Erstellen eines Cubits

Wir können ein `CounterCubit` wie folgt erstellen:

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit.dart.md ':include')

Bei der Erstellung eines `Cubits` müssen wir den Typ des Zustands definieren, den der `Cubit` verwalten wird. Im Fall des obigen `CounterCubit` kann der Zustand durch einen `int` dargestellt werden, aber in komplexeren Fällen könnte es notwendig sein, eine Klasse `class` anstelle eines primitiven Typs zu verwenden.

Die zweite Sache, die wir tun müssen, wenn wir einen `Cubit` erstellen, ist, den Anfangszustand festzulegen. Wir können dies tun, indem wir `super` mit dem Wert des Anfangszustandes aufrufen. Im obigen Schnipsel setzen wir den Anfangszustand intern auf `0`, aber wir können dem `Cubit` auch erlauben, flexibler zu sein, indem wir einen externen Wert akzeptieren:

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_initial_state.dart.md ':include')

Dies würde es uns ermöglichen, `CounterCubit`-Instanzen mit verschiedenen Ausgangszuständen zu instanziieren:

[main.dart](../_snippets/core_concepts/counter_cubit_instantiation.dart.md ':include')

### Zustandsänderungen

> Jeder `Cubit` hat die Fähigkeit, einen neuen Zustand über `emit` auszugeben.

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_increment.dart.md ':include')

Im obigen Ausschnitt stellt der `CounterCubit` eine öffentliche Methode namens `increment` zur Verfügung, die von außen aufgerufen werden kann, um dem `CounterCubit` mitzuteilen, dass sein Zustand erhöht werden soll. Wenn `increment` aufgerufen wird, können wir über den Getter `state` auf den aktuellen Zustand des `Cubit` zugreifen und einen neuen Zustand emittieren `emit`, indem wir eine 1 zum aktuellen Zustand addieren.

!> Die Methode `emit` ist geschützt, d.h. sie sollte nur innerhalb eines `Cubits` verwendet werden.

### Verwendung eines Cubits

Jetzt können wir den `CounterCubit`, den wir implementiert haben, verwenden!

#### Grundlegende Verwendung

[main.dart](../_snippets/core_concepts/counter_cubit_basic_usage.dart.md ':include')

Im obigen Ausschnitt wird zunächst eine Instanz des `CounterCubits` erstellt. Dann geben wir den aktuellen Zustand des Cubits aus, der den Anfangszustand darstellt, da noch keine neuen Zustände emittiert wurden. Als nächstes rufen wir die Funktion `increment` auf, um eine Zustandsänderung auszulösen. Zum Schluss geben wir den Zustand des Cubits aus, der von `0` auf `1` gewechselt hat und schließen den Cubit, um den internen Zustandsstrom zu schließen.

#### Stream Verwendung

Da ein `Cubit` ein spezieller Typ von `Stream` ist, können wir auch einen `Cubit` abonnieren bzw. subscriben, um seinen Zustand in Echtzeit zu aktualisieren:

[main.dart](../_snippets/core_concepts/counter_cubit_stream_usage.dart.md ':include')

In dem obigen Ausschnitt abonnieren wir den `CounterCubit` und rufen bei jeder Zustandsänderung `print` auf. Dann rufen wir die Funktion `increment` auf, die einen neuen Zustand ausgibt. Schließlich rufen wir die Methode `cancel` von der `subscription` auf, wenn wir keine Aktualisierungen mehr erhalten wollen und schließen den `Cubit`.

?> **Hinweis**: `await Future.delayed(Duration.zero)` wird für dieses Beispiel hinzugefügt, um zu vermeiden, dass die `subscription` sofort gekündigt wird.

!> Nur nachfolgende Zustandsänderungen werden beim Aufruf von `listen` auf einem `Cubit` empfangen.

### Beobachten eines Cubits

> Wenn ein `Cubit` einen neuen Zustand ausgibt, findet eine `Change` statt. Wir können alle Änderungen für einen bestimmten `Cubit` beobachten, indem wir `onChange` überschreiben.

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_on_change.dart.md ':include')

Wir können dann mit dem `Cubit` interagieren und alle Änderungen auf der Konsole beobachten.

[main.dart](../_snippets/core_concepts/counter_cubit_on_change_usage.dart.md ':include')

Das obige Beispiel würde folgendes ausgeben:

[script](../_snippets/core_concepts/counter_cubit_on_change_output.sh.md ':include')

?> **Hinweis**: Eine `Change` erfolgt kurz bevor der Zustand des `Cubits` aktualisiert wird. Eine `Change` besteht aus dem `currentState` und dem `nextState`.

#### BlocObserver

Ein zusätzlicher Bonus bei der Verwendung der bloc-Bibliothek ist, dass wir an einer Stelle Zugriff auf alle `Changes` haben. Auch wenn wir in dieser Anwendung nur einen `Cubit` haben, ist es in größeren Anwendungen üblich, viele `Cubits` zu haben, die verschiedene Teile des Anwendungsstatus verwalten.

Wenn wir in der Lage sein wollen, etwas als Reaktion auf alle `Changes` zu tun, können wir einfach unseren eigenen `BlocObserver` erstellen.

[simple_bloc_observer_on_change.dart](../_snippets/core_concepts/simple_bloc_observer_on_change.dart.md ':include')

?> **Hinweis**: Alles, was wir tun müssen, ist den `BlocObserver` zu erweitern bzw. extenden und die Methode `onChange` überschreiben bzw. overriden.

Um den `SimpleBlocObserver` zu verwenden, müssen wir nur die `main` Funktion anpassen:

[main.dart](../_snippets/core_concepts/simple_bloc_observer_on_change_usage.dart.md ':include')

Das obige Snippet würde dann folgendes ausgeben:

[script](../_snippets/core_concepts/counter_cubit_on_change_usage_output.sh.md ':include')

?> **Hinweis**: Die interne `onChange`-Überschreibung (override) wird zuerst aufgerufen, gefolgt von `onChange` in `BlocObserver`.

?> 💡 **Tipp**: In `BlocObserver` haben wir Zugriff auf die `Cubit`-Instanz, zusätzlich zur `Change` selbst.

### Fehlerbehandlung

> Jeder `Cubit` hat eine `addError`-Methode, die verwendet werden kann, um anzuzeigen, dass ein Fehler aufgetreten ist.

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_on_error.dart.md ':include')

?> **Hinweis**: `onError` kann innerhalb des `Cubits` überschrieben werden, um alle Fehler für einen bestimmten `Cubit` zu behandeln.

Die Option `onError` kann auch in `BlocObserver` überschrieben werden, um alle gemeldeten Fehler global zu behandeln.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_error.dart.md ':include')

Wenn wir das gleiche Programm noch einmal ausführen, sollten wir die folgende Ausgabe sehen:

[script](../_snippets/core_concepts/counter_cubit_on_error_output.sh.md ':include')

?> **Hinweis**: Genau wie bei `onChange` wird die interne `onError`-Überschreibung vor der globalen `BlocObserver`-Überschreibung aufgerufen.

## Bloc

> Ein `Bloc` ist eine fortgeschrittenere Klasse, die sich auf Ereignisse `events` stützt, um Zustandsänderungen `states` auszulösen, anstatt auf Funktionen. `Bloc` erweitert auch `BlocBase`, was bedeutet, dass es eine ähnliche öffentliche API wie `Cubit` hat. Anstatt jedoch eine Funktion `function` auf einem `Bloc` aufzurufen und direkt einen neuen Zustand `state` auszugeben, empfangen `Blocs` Ereignisse `events` und wandeln die eingehenden Ereignisse `events` in ausgehende Zustände `states` um.

![Bloc Architecture](assets/bloc_architecture_full.png)

### Einen Bloc erstellen

Die Erstellung eines `Blocs` ähnelt der Erstellung eines `Cubits`, mit dem Unterschied, dass wir nicht nur den Zustand definieren, den wir verwalten, sondern auch das Ereignis `event`, damit der `Bloc` weiter verarbeiten kann.

> Ereignisse sind Inputs für einen Bloc. Sie werden in der Regel als Reaktion auf Benutzerinteraktionen wie das Drücken von Schaltflächen oder Lebenszyklusereignisse wie das Laden von Seiten hinzugefügt.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

Genau wie bei der Erstellung des `CounterCubits` müssen wir einen Anfangszustand angeben, indem wir ihn über `super` an die Superklasse übergeben.

### Zustandsänderungen

`Bloc` erfordert die Registrierung von Event-Handlern über die `on<Event>` API, im Gegensatz zu Funktionen in` cubit`.Ein Ereignishandler ist dafür verantwortlich, alle eingehenden Ereignisse in null oder mehr ausgehende Zustände zu konvertieren.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_event_handler.dart.md ':include')

?> 💡 **Tipp**: Ein `EventHandler` hat Zugriff auf das zusätzliche Ereignis sowie einen `Emitter` , der verwendet werden kann, um Null- oder mehr Zustände als Reaktion auf das eingehende Ereignis auszusetzen.

Wir können dann den `Event-Handler` aktualisieren, um das `CounterIncrementPressed` Ereignis zu behandeln:

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_increment.dart.md ':include')

In the above snippet, we have registered an `EventHandler` to manage all `CounterIncrementPressed` events. For each incoming `CounterIncrementPressed` event we can access the current state of the bloc via the `state` getter and `emit(state + 1)`.

?> **Hinweis**: Da die Klasse `Bloc` die Klasse `BlocBase` erweitert, haben wir über den Getter `state` zu jedem Zeitpunkt Zugriff auf den aktuellen Zustand des Blocs.

!> Blocs sollten niemals direkt neue Zustände emittieren `emit`. Stattdessen muss jede Zustandsänderung als Reaktion auf ein eingehendes Ereignis innerhalb eines `EventHandlers` ausgegeben werden.

!> Sowohl Blocs als auch Cubits ignorieren doppelte Zustände. Wenn wir `State nextState` ausgeben oder emittieren, obwohl `state == nextState` bereits wahr ist, wird kein Zustandswechsel stattfinden.

### Verwendung eines Blocs

An dieser Stelle können wir eine Instanz unseres `CounterBlocs` erstellen und ihn verwenden!

#### Grundlegende Verwendung

[main.dart](../_snippets/core_concepts/counter_bloc_usage.dart.md ':include')

In dem obigen Ausschnitt wird zunächst eine Instanz des `CounterBlocs` erstellt. Dann geben wir den aktuellen Zustand des `Blocs` aus, der den Anfangszustand darstellt, da noch keine neuen Zustände emittiert wurden. Als nächstes fügen wir das Inkrement-Ereignis hinzu, um eine Zustandsänderung auszulösen. Schließlich geben wir den Zustand des `Blocs` wieder aus, der den Wert von 0 auf 1 geändert hat, und schließen den Block `Bloc`, um den internen Zustandsstrom zu schließen.

?> **Hinweis**: Die Option `await Future.delayed(Duration.zero)` wird hinzugefügt, um sicherzustellen, dass auf die nächste Iteration der Ereignisschleife gewartet wird(Erlaube dem `EventHandler`, um das Ereignis zu verarbeiten).

#### Stream-Nutzung

Genau wie bei `Cubit` ist ein `Bloc` ein spezieller Typ von `Stream`, was bedeutet, dass wir auch einen `Bloc` abonnieren können, um seinen Zustand in Echtzeit zu aktualisieren:

[main.dart](../_snippets/core_concepts/counter_bloc_stream_usage.dart.md ':include')

Im obigen Ausschnitt abonnieren wir den `CounterBloc` und rufen print bei jeder Zustandsänderung auf. Wir fügen dann das `CounterIncrementPressed` Ereignis hinzu, das auf `on<CounterIncrementPressed>` `EventHandler` löst und einen neuen Zustand emittiert. Schließlich rufen wir `cancel()` bei der `subscription` auf, wenn wir keine Aktualisierungen mehr erhalten wollen, und schließen den `Bloc`.

?> **Hinweis**: Für dieses Beispiel wurde `await Future.delayed(Duration.zero)` hinzugefügt, um zu vermeiden, dass das Subscription sofort abgebrochen wird.

### Ein Bloc observieren

Da `Bloc` `BlocBase` erweitert, können wir alle Zustandsänderungen für einen `Bloc` mit `onChange` beobachten.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_change.dart.md ':include')

Wir können dann `main.dart` aktualisieren zu:

[main.dart](../_snippets/core_concepts/counter_bloc_on_change_usage.dart.md ':include')

Wenn wir nun das obige Snippet ausführen, wird die Ausgabe folgendes sein:

[script](../_snippets/core_concepts/counter_bloc_on_change_output.sh.md ':include')

Ein wichtiger Unterschied zwischen `Bloc` und `Cubit` besteht darin, dass `Bloc` ereignisgesteuert (event-driven) ist und daher auch Informationen über den Auslöser der Zustandsänderung erfasst werden können

Wir können dies tun, indem wir `onTransition` überschreiben.

> Der Übergang von einem Zustand in einen anderen wird als `Transition` bezeichnet. Ein `Transition` besteht aus dem aktuellen Zustand, dem Ereignis und dem nächsten Zustand.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

Wenn wir dann denselben `main.dart`-Schnipsel wie zuvor erneut ausführen, sollten wir die folgende Ausgabe sehen:

[script](../_snippets/core_concepts/counter_bloc_on_transition_output.sh.md ':include')

?> **Note**: `onTransition` is invoked before `onChange` and contains the event which triggered the change from `currentState` to `nextState`.

#### BlocObserver

Genau wie zuvor können wir `onTransition` in einem benutzerdefinierten `BlocObserver` überschreiben, um alle Übergänge zu beobachten, die an einem einzigen Ort stattfinden.

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_transition.dart.md ':include')

Wir können den `SimpleBlocObserver` genau wie zuvor initialisieren:

[main.dart](../_snippets/core_concepts/simple_bloc_observer_on_transition_usage.dart.md ':include')

Wenn wir nun das obige Snippet ausführen, sollte die Ausgabe wie folgt aussehen:

[script](../_snippets/core_concepts/simple_bloc_observer_on_transition_output.sh.md ':include')

?> **Hinweis**: Die Funktion `onTransition` wird zuerst aufgerufen (lokal vor global), gefolgt von `onChange`.

Ein weiteres einzigartiges Merkmal von `Bloc`-Instanzen ist, dass sie uns erlauben, `onEvent` zu überschreiben, das immer dann aufgerufen wird, wenn ein neues Ereignis zum `Bloc` hinzugefügt wird. Genau wie bei `onChange` und `onTransition` kann `onEvent` sowohl lokal als auch global überschrieben werden.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_event.dart.md ':include')

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

Wir können dieselbe `main.dart` wie zuvor ausführen und sollten die folgende Ausgabe sehen:

[script](../_snippets/core_concepts/simple_bloc_observer_on_event_output.sh.md ':include')

?> **Hinweis**: `onEvent` wird aufgerufen, sobald das Ereignis hinzugefügt wird. Das lokale `onEvent` wird vor dem globalen `onEvent` in `BlocObserver` aufgerufen.

### Fehlerbehandlung

Genau wie bei `Cubit` hat jeder `Bloc` eine `addError` und `onError` Methode. Wir können anzeigen, dass ein Fehler aufgetreten ist, indem wir `addError` von überall innerhalb unseres `Bloc` aufrufen. Wir können dann auf alle Fehler reagieren, indem wir `onError` genau wie bei `Cubit` überschreiben.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

Wenn wir dieselbe `main.dart` wie zuvor erneut ausführen, können wir sehen, wie es aussieht, wenn ein Fehler gemeldet wird:

[script](../_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **Hinweis**: Das lokale `onError` wird zuerst aufgerufen, gefolgt von dem globalen `onError` in `BlocObserver`.

?> **Hinweis**: `onError` und `onChange` funktionieren für `Bloc` und `Cubit` Instanzen genau gleich.

!> Alle unbehandelten Ausnahmen, die innerhalb von `EventHandler` auftreten, werden auch an `onError` gemeldet.

## Cubit vs. Bloc

Nachdem wir nun die Grundlagen der Klassen `Cubit` und `Bloc` behandelt haben, fragen Sie sich vielleicht, wann Sie `Cubit` und wann Sie `Bloc` verwenden sollten.

### Vorteile von Cubit

#### Einfachheit

Einer der größten Vorteile bei der Verwendung von `Cubit` ist die Einfachheit. Bei der Erstellung eines `Cubits` müssen wir nur den Zustand sowie die Funktionen definieren, die wir zur Änderung des Zustands bereitstellen wollen. Im Vergleich dazu müssen wir bei der Erstellung eines `Blocs` die Zustände, Ereignisse und die Implementierung von `EventHandler` definieren. Das macht `Cubit` leicht verständlich und es ist weniger Code erforderlich.

Werfen wir nun einen Blick auf die beiden Zählerimplementierungen:

##### CounterCubit

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_full.dart.md ':include')

Die Implementierung von `Cubit` ist präziser und anstatt Ereignisse separat zu definieren, fungieren die Funktionen wie Ereignisse. Bei Verwendung eines `Cubit`, können wir einfach `emit` von überall anrufen, um eine Zustandsänderung auszulösen.

### Vorteile von Bloc

#### Rückverfolgbarkeit

Einer der größten Vorteile bei der Verwendung von `Bloc` ist die Kenntnis der Abfolge von Zustandsänderungen sowie der genauen Auslöser dieser Änderungen. Bei Zuständen, die für die Funktionalität einer Anwendung von entscheidender Bedeutung sind, kann es sehr vorteilhaft sein, einen stärker ereignisorientierten Ansatz zu verwenden, um alle Ereignisse zusätzlich zu den Zustandsänderungen zu erfassen.

Ein häufiger Anwendungsfall könnte die Verwaltung von `AuthenticationState` sein. Der Einfachheit halber nehmen wir an, dass wir `AuthenticationState` durch ein `enum` darstellen können:

[authentication_state.dart](../_snippets/core_concepts/authentication_state.dart.md ':include')

Es kann viele Gründe geben, warum der Status der Anwendung von authentifiziert `authenticated` zu nicht authentifiziert `unauthenticated` wechselt. Zum Beispiel könnte der Benutzer auf eine Abmeldeschaltfläche getippt haben, um eine Abmeldung von der Anwendung durchzuführen. Andererseits kann es auch sein, dass dem Benutzer das Zugriffstoken (access token) entzogen wurde und er zwangsweise abgemeldet wurde. Wenn wir`Bloc` verwenden, können wir eindeutig nachvollziehen, wie der Zustand der Anwendung zu einem bestimmten Zustand passiert ist.

[script](../_snippets/core_concepts/authentication_transition.sh.md ':include')

Die obige `Transition` gibt uns alle Informationen, die wir brauchen, um zu verstehen, warum sich der Zustand geändert hat. Hätten wir ein `Cubit` zur Verwaltung des `AuthenticationState` verwendet, würden unsere Logs wie folgt aussehen:

[script](../_snippets/core_concepts/authentication_change.sh.md ':include')

Dies sagt uns, dass der Benutzer abgemeldet wurde, aber es erklärt nicht die Ursache, was für die Fehlersuche und das Verständnis, wie sich der Zustand der Anwendung im Laufe der Zeit verändert hat, entscheidend sein könnte.

#### AdvanErweiterteced Ereignistransformationen

Ein weiterer Bereich, in dem sich `Bloc` gegenüber `Cubit` auszeichnet, ist, wenn wir die Vorteile reaktiver Operatoren wie `buffer`, `debounceTime`, `throttle`, usw. nutzen müssen.

`Bloc` hat eine Ereignissenke (event sink), die es uns erlaubt, den eingehenden Fluss von Ereignissen zu kontrollieren und zu transformieren.

Wenn wir zum Beispiel eine Echtzeit-Suche aufbauen würden, würden wir wahrscheinlich die Anfragen an das Backend entschleunigen wollen, um eine Ratenbeschränkung zu vermeiden und um die Kosten/Last auf dem Backend zu reduzieren.

Mit `Bloc` können wir `EventTransformer` überschreiben, um die Art und Weise zu ändern, wie eingehende Ereignisse von `Bloc` verarbeitet werden.

[counter_bloc.dart](../_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

Mit dem obigen Code können wir die eingehenden Ereignisse mit sehr wenig zusätzlichem Code leicht entschleunigen.

?> 💡 **Tipp**: Kasse [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) Für einen anhaltenden Satz von `EventTransformers`.

?> 💡 **Tipp**: Wenn Sie noch unsicher sind, was Sie verwenden sollen, beginnen Sie mit `Cubit` und Sie können später je nach Bedarf auf `Bloc` umstellen oder skalieren.
