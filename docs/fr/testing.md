# Tests

> Bloc a été conçu pour être extrêmement facile à tester.

Par souci de simplicité, écrivons des tests pour `CounterBloc` que nous avons créé dans [Concepts de base](coreconcepts.md).

Pour résumer, l'implémentation de `CounterBloc` ressemble à :

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Avant de commencer à écrire nos tests, nous allons devoir ajouter un cadre de test à nos dépendances.

Nous devons ajouter le package [test](https://pub.dev/packages/test) et [bloc_test](https://pub.dev/packages/bloc_test) à notre `pubspec.yaml`.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

Commençons par créer le fichier `counter_bloc_test.dart` pour nos Tests du `CounterBloc` et importons y le paquet test.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Ensuite, nous devons créer notre `main` ainsi que notre groupe de test.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Note**: Les groupes servent à organiser des tests individuels ainsi qu'à créer un contexte dans lequel vous pouvez partager un `setUp` et un `tearDown` communs à tous les tests individuels.

Commençons par créer une instance de notre `CounterBlocs` qui sera utilisée dans tous nos tests.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Maintenant, nous pouvons commencer à écrire nos tests individuels.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Note**: Nous pouvons exécuter tous nos tests avec la commande `pub run test`.

A ce stade, nous devrions avoir notre premier test de réussite ! Passons maintenant à un test plus complexe.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Nous devrions être en mesure d'effectuer les tests et de voir que tous réussissent.

C'est tout ce qu'il y a à faire, tester devrait être un jeu d'enfant et nous devrions nous sentir en confiance lorsque nous apportons des changements et remanions notre code.

Vous pouvez vous référer à [l'application Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) pour un exemple d'application entièrement testée.
