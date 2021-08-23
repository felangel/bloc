# Architektur

![Bloc Architecture](../assets/bloc_architecture_full.png)

Durch die Verwendung der Bloc-Bibliothek können wir unsere Anwendung in drei Schichten (Layers) aufteilen:

- Darstellung bzw. Präsentationsschicht (Presentation)
- Geschäftslogik (Business Logic)
- Daten (Data)
  - Ablage (Repository)
  - Datenlieferant (Data provider)

Wir beginnen mit der untersten Ebene (am weitesten von der Benutzeroberfläche entfernt) und arbeiten uns bis zur Präsentationsschicht vor.

## Datenschicht

> Die Datenschicht hat die Aufgabe, Daten aus einer oder mehreren Quellen abzurufen bzw. zu manipulieren.

Die Datenschicht kann in zwei Teile aufgeteilt werden:

- Repository
- Datenlieferant

Diese Schicht ist die unterste Ebene der Anwendung und interagiert mit Datenbanken, Netzwerkanforderungen und anderen asynchronen Datenquellen.

### Datenlieferant

> Die Verantwortung des Datenlieferanten besteht darin, Rohdaten bereitzustellen. Der Datenlieferant sollte generisch und vielseitig sein.

Der Datenanbieter stellt in der Regel einfache APIs zur Durchführung von [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)-Operationen zur Verfügung.
Wir könnten eine Methode `createData`, `readData`, `updateData` und `deleteData` als Teil unserer Datenschicht haben.

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Ablage (Repository)

> Die Repository-Schicht ist ein Wrapper um einen oder mehrere Datenlieferanten, mit denen die Bloc-Schicht kommuniziert.

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

Wie Sie sehen, kann unsere Repository-Schicht mit mehreren Datenlieferanten interagieren und die Daten umwandeln, bevor das Ergebnis an die Geschäftslogik-Schicht weitergegeben wird.

## Geschäftslogik-Schicht

> Die Geschäftslogikschicht hat die Aufgabe, auf Eingaben der Präsentationsschicht mit neuen Zuständen zu reagieren. Diese Schicht kann von einem oder mehreren Repositories abhängen, um die für den Aufbau des Anwendungsstatus erforderlichen Daten abzurufen.

Stellen Sie sich die Geschäftslogikschicht als die Brücke zwischen der Benutzeroberfläche (Präsentationsschicht) und der Datenschicht vor. Die Geschäftslogikschicht wird von der Präsentationsschicht über Ereignisse/Aktionen benachrichtigt und kommuniziert dann mit dem Repository, um einen neuen Zustand zu erstellen, den die Präsentationsschicht nutzen kann.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Bloc-to-Bloc Kommunikation

> ​Jeder Bloc hat einen Zustandsstrom. Andere Blocs können diese abonnieren bzw. subscriben, um auf Veränderungen innerhalb des Blocks zu reagieren.

Blocs können Abhängigkeiten von anderen Blocs haben, um auf deren Zustandsänderungen zu reagieren. Im folgenden Beispiel hat `MyBloc` eine Abhängigkeit von `OtherBloc` und kann als Reaktion auf Zustandsänderungen in `OtherBloc` Ereignisse `hinzufügen`. Die `StreamSubscription` wird in der `close`-Überschreibung in `MyBloc` geschlossen, um Speicherlecks zu vermeiden.

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## Präsentationsschicht

> Die Präsentationsschicht hat die Aufgabe herauszufinden, wie sie sich selbst auf der Grundlage eines oder mehrerer Bloc-Zustände darstellen soll. Darüber hinaus sollte sie Benutzereingaben und Ereignisse im Lebenszyklus der Anwendung verarbeiten.

Die meisten Anwendungsabläufe beginnen mit einem "AppStart"-Ereignis, das die Anwendung dazu veranlasst, einige Daten abzurufen, um sie dem Benutzer zu präsentieren.

In diesem Szenario würde die Präsentationsschicht ein "AppStart"-Ereignis hinzufügen.

Außerdem muss die Präsentationsschicht auf der Grundlage des Zustands der Bloc-Schicht herausfinden, was auf dem Bildschirm dargestellt werden soll.

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

Bisher haben wir zwar schon einige Codeschnipsel gezeigt, aber das war alles noch recht allgemein gehalten. Im Abschnitt "Tutorial" werden wir all dies zusammenführen, indem wir mehrere verschiedene Beispielanwendungen erstellen.
