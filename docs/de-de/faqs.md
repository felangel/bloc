# Häufig gestellte Fragen

## Zustand nicht aktualisiert

❔ **Frage**: Ich erzeuge einen Zustand in meinem Bloc, aber die Benutzeroberfläche wird nicht aktualisiert. Was mache ich falsch?

💡 **Antwort**: Wenn Sie Equatable verwenden, stellen Sie sicher, dass Sie alle Eigenschaften an den Props Getter übergeben.

✅ **GUT**

[my_state.dart](../_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **SCHLECHT**

[my_state.dart](../_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](../_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

Stellen Sie außerdem sicher, dass Sie eine neue Instanz des Staates in Ihrem Bloc erzeugen.

✅ **GUT**

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **SCHLECHT**

[my_bloc.dart](../_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

!> Eigenschaften von `Equatable` sollten immer kopiert und nicht verändert werden. Wenn eine `Equatable`-Klasse eine `List` oder eine `Map` als Eigenschaften enthält, muss `List.from` bzw. `Map.from` verwendet werden, um sicherzustellen, dass die Gleichheit anhand der Werte der Eigenschaften und nicht anhand der Referenz ausgewertet wird.

## When to use Equatable

❔**Frage**: Wann sollte ich Equatable verwenden?

💡**Antwort**:

[my_bloc.dart](../_snippets/faqs/equatable_yield.dart.md ':include')

In dem obigen Szenario, in dem `StateA` `Equatable` erweitert, wird nur eine Zustandsänderung stattfinden (die zweite Ausgabe) wird ignoriert.
Im Allgemeinen sollten Sie `Equatable` verwenden, wenn Sie Ihren Code optimieren wollen, um die Anzahl der Neugenerierungen zu reduzieren.
Sie sollten `Equatable` nicht verwenden, wenn Sie wollen, dass derselbe Zustand mehrmals hintereinander mehrere Übergänge auslöst.

In addition, using `Equatable` makes it much easier to test blocs since we can expect specific instances of bloc states rather than using `Matchers` or `Predicates`.

Darüber hinaus macht die Verwendung von `Equatable` das Testen von Blocs viel einfacher, da wir bestimmte Instanzen von Blockzuständen erwarten können, anstatt `Matcher` oder `Prädikate` zu verwenden.

[my_bloc_test.dart](../_snippets/faqs/equatable_bloc_test.dart.md ':include')

Ohne `Equatable` würde der obige Test fehlschlagen und müsste wie folgt umgeschrieben werden:

[my_bloc_test.dart](../_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

## Fehlerbehandlung

❔ **Frage**: Wie kann ich einen Fehler behandeln und trotzdem die vorherigen Daten anzeigen?

💡 **Antwort**:

Dies hängt stark davon ab, wie der Zustand des Blocs modelliert wurde. In Fällen, in denen die Daten auch im Falle eines Fehlers erhalten bleiben sollen, ist die Verwendung einer einzigen Zustandsklasse zu erwägen.

```dart
enum Status { initial, loading, success, failure }

class MyState {
  const MyState({
    this.data = Data.empty,
    this.error = '',
    this.status = Status.initial,
  });

  final Data data;
  final String error;
  final Status status;

  MyState copyWith({Data data, String error, Status status}) {
    return MyState(
      data: data ?? this.data,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}
```

Dadurch können Widgets gleichzeitig auf die Eigenschaften `data` und `error` zugreifen, und der Block kann `state.copyWith` verwenden, um alte Daten beizubehalten, selbst wenn ein Fehler aufgetreten ist.

```dart
if (event is DataRequested) {
  try {
    final data = await _repository.getData();
    yield state.copyWith(status: Status.success, data: data);
  } on Exception {
    yield state.copyWith(status: Status.failure, error: 'Something went wrong!');
  }
}
```

## Bloc vs. Redux

❔ **Frage**: Worin liegt der Unterschied zwischen Bloc und Redux?

💡 **Antwort**:

BLoC ist ein Entwurfsmuster, das durch die folgenden Regeln definiert ist:

1. Eingang und Ausgang des BLoC sind einfache Ströme und Senken.
2. Abhängigkeiten müssen injectable und plattformunabhängig sein.
3. Eine Verzweigung von Plattformen ist nicht erlaubt.
4. Bei der Implementierung können Sie tun und lassen, was Sie wollen, solange Sie die oben genannten Regeln beachten.

Die UI-Leitlinien sind:

1. Jedes "ausreichend komplexe" Bauteil hat eine entsprechende BLoC.
2. Die Komponenten sollten Eingaben "so wie sie sind" senden.
3. Die Komponenten sollten so nah wie möglich am "Ist-Zustand" sein.
4. Alle Verzweigungen sollten auf einfachen booleschen BLoC-Ausgängen beruhen.

Die Bloc-Bibliothek implementiert das BLoC Design Pattern und zielt darauf ab, RxDart zu abstrahieren, um die Arbeit der Entwickler zu vereinfachen.

Die drei Grundsätze von Redux sind:

1. Single source of truth
2. Zustand ist schreibgeschützt
3. Änderungen werden mit reinen Funktionen vorgenommen

Die bloc-Bibliothek verstößt gegen den ersten Grundsatz; bei bloc wird der Zustand über mehrere Blocs verteilt.
Darüber hinaus gibt es in bloc kein Konzept der Middleware, und bloc ist darauf ausgelegt, asynchrone Zustandsänderungen sehr einfach zu machen, so dass Sie mehrere Zustände für ein einziges Ereignis ausgeben können.

## Bloc vs. Provider

❔ **Frage**: Worin liegt der Unterschied zwischen Bloc und Provider?

💡 **Antwort**: `provider` is designed for dependency injection (it wraps `InheritedWidget`).
You still need to figure out how to manage your state (via `ChangeNotifier`, `Bloc`, `Mobx`, etc...).
The Bloc Library uses `provider` internally to make it easy to provide and access blocs throughout the widget tree.

Der `provider` ist für die Injektion von Abhängigkeiten (dependency injection) konzipiert (er umgibt das `InheritedWidget`).
Sie müssen immer noch herausfinden, wie Sie Ihren Zustand verwalten (über `ChangeNotifier`, `Bloc`, `Mobx`, usw...).
Die Bloc-Bibliothek verwendet intern `provider`, um es einfach zu machen, Blocs im gesamten Widget-Baum bereitzustellen und darauf zuzugreifen.

## Navigation mit Bloc

❔ **Frage**: Wie funktioniert die Navigation mit Bloc?

💡 **Antwort**: Schauen Sie sich [Flutter Navigation](recipesflutternavigation.md) an

## BlocProvider.of() findet keinen Bloc

❔ **Frage**: Wenn ich `BlocProvider.of(context)` verwende, kann ich den Block nicht finden. Wie kann ich das beheben?

💡 **Antwort**: Sie können nicht auf einen Bloc aus demselben Kontext zugreifen, in dem er bereitgestellt wurde. Sie müssen also sicherstellen, dass `BlocProvider.of()` innerhalb eines untergeordneten `BuildContext` aufgerufen wird.

✅ **GUT**

[my_page.dart](../_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](../_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **SCHLECHT**

[my_page.dart](../_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## Aufbau eines Projekts

❔ **Frage**: Wie sollte ich mein Projekt strukturieren?

💡 **Antwort**: Es gibt zwar keine richtige oder falsche Antwort auf diese Frage, aber einige empfohlene Referenzen sind

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Das Wichtigste ist eine **konsistente** und **gezielte** Projektstruktur.
