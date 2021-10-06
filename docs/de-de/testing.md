# Testen

> Bloc wurde so konzipiert, dass es extrem einfach zu testen ist.

Der Einfachheit halber schreiben wir Tests für den `CounterBloc`, den wir in [Grundlegende Konzepte](coreconcepts.md) erstellt haben.

Zusammenfassend sieht die Implementierung von `CounterBloc` wie folgt aus

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Bevor wir mit dem Schreiben unserer Tests beginnen, müssen wir ein Test-Framework zu unseren Abhängigkeiten hinzufügen.

Wir müssen [test](https://pub.dev/packages/test) und [bloc_test](https://pub.dev/packages/bloc_test) zu unserer `pubspec.yaml` hinzufügen.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

Beginnen wir mit der Erstellung der Datei für unsere `CounterBloc`-Tests, `counter_bloc_test.dart`, und importieren das Testpaket (test package).

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Als Nächstes müssen wir unsere `main` und unsere Testgruppe (test group) erstellen.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Hinweis**: Gruppen dienen dazu, einzelne Tests zu organisieren und einen Kontext zu schaffen, in dem Sie ein gemeinsames `setUp` und `tearDown` für alle einzelnen Tests verwenden können.

Beginnen wir mit der Erstellung einer Instanz unseres `CounterBloc` whi die in allen unseren Tests verwendet werden soll.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Jetzt können wir mit dem Schreiben unserer individuellen Tests beginnen.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Hinweis**: Wir können alle unsere Tests mit dem Befehl `pub run test` ausführen.

An diesem Punkt sollten wir unseren ersten erfolgreichen Test haben! Nun wollen wir einen komplexeren Test mit dem Paket [bloc_test](https://pub.dev/packages/bloc_test) schreiben.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Wir sollten in der Lage sein, die Tests laufen zu lassen und zu sehen, dass sie alle erfolgreich sind.

Das ist alles. Das Testen sollte ein Kinderspiel sein und wir sollten uns sicher fühlen, wenn wir Änderungen vornehmen und unseren Code umgestalten.

Ein Beispiel für eine vollständig getestete Anwendung finden Sie in der [Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library).
