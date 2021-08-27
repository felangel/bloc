# Erste Schritte

?> Um bloc verwenden zu können, müssen Sie das [Dart SDK] (https://dart.dev/get-dart) auf Ihrem Rechner installiert haben.

## Übersicht

Bloc besteht aus mehreren Pub-Paketen:

- [bloc](https://pub.dev/packages/bloc) - Kernstück der Block-Bibliothek
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Leistungsstarke Flutter-Widgets, die mit bloc zusammenarbeiten, um schnelle, reaktive mobile Anwendungen zu erstellen.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Leistungsstarke Angular-Komponenten, die für die Zusammenarbeit mit bloc entwickelt wurden, um schnelle, reaktive Webanwendungen zu erstellen.
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) - Eine Erweiterung der Bibliothek zur Verwaltung von Blockzuständen, die automatisch Blockzustände aufrechterhält und wiederherstellt.
- [replay_bloc](https://pub.dev/packages/replay_bloc) - Eine Erweiterung der bloc state management library, die Unterstützung für Undo und Redo bietet.

## Installation

Für eine [Dart](https://dart.dev/) Anwendung müssen wir das `bloc` Paket zu unserer `pubspec.yaml` als Abhängigkeit hinzufügen.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

Für eine [Flutter](https://flutter.dev/) Anwendung müssen wir das Paket `flutter_bloc` als Abhängigkeit zu unserer `pubspec.yaml` hinzufügen.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

Für eine [AngularDart](https://angulardart.dev/)-Anwendung müssen wir das Paket `angular_bloc` als Abhängigkeit zu unserer `pubspec.yaml` hinzufügen.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Als nächstes müssen wir bloc installieren.

!> Stellen Sie sicher, dass Sie den folgenden Befehl aus demselben Verzeichnis wie Ihre Datei `pubspec.yaml` ausführen.

- Für Dart oder AngularDart führen Sie `pub get` aus

- Für Flutter führen Sie `flutter packages get` aus

## Import

Nachdem wir bloc nun erfolgreich installiert haben, können wir unsere `main.dart` erstellen und `bloc` importieren.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Für eine Flutter-Anwendung können wir `flutter_bloc` importieren.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

Für eine AngularDart-Anwendung können wir angular_bloc importieren.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
