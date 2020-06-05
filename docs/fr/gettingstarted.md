# Commencer

?> Pour commencer à utiliser bloc, vous devez avoir installé [Dart SDK](https://dart.dev/get-dart) sur votre machine.

## Vue d'ensemble

Bloc se compose de plusieurs paquets:

- [bloc](https://pub.dev/packages/bloc) - bibliothèque Bloc de base
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - de puissants Widgets Flutter conçus pour fonctionner avec bloc afin de construire des applications mobiles rapides et réactives.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Composants Angular puissants conçus pour travailler avec Bloc afin de construire des applications web rapides et réactives.

## Installation

La première chose que nous devons faire est d'ajouter le paquet Bloc à notre `pubspec.yaml` comme dépendance.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

Pour une application [Flutter](https://flutter.dev/), nous devons aussi ajouter le paquet flutter_bloc à notre `pubspec.yaml` comme dépendance.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

Pour une application [AngularDart](https://angulardart.dev/), nous devons aussi ajouter le paquet angular_bloc à notre `pubspec.yaml' comme dépendance.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Ensuite, nous avons besoin d'installer bloc.

!> Assurez-vous d'exécuter la commande suivante à partir du même répertoire que votre fichier `pubspec.yaml`.

- Pour Dart ou AngularDart executez `pub get`

- Pour Flutter executez `flutter packages get`

## Importation

Maintenant que nous avons installé Bloc avec succès, nous pouvons créer notre bloc `main.dart` et l'importer.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Pour une application Flutter nous pouvons aussi importer flutter_bloc.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

Pour une application AngularDart nous pouvons aussi importer angular_bloc.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
