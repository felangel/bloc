# Commencer

?> Pour commencer à utiliser bloc, vous devez avoir installé [Dart SDK](https://www.dartlang.org/install) sur votre machine.

## Vue d'ensemble

Bloc se compose de plusieurs paquets:

- [bloc](https://pub.dev/packages/bloc) - bibliothèque Bloc de base
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - de puissants Widgets Flutter conçus pour fonctionner avec bloc afin de construire des applications mobiles rapides et réactives.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Composants Angular puissants conçus pour travailler avec Bloc afin de construire des applications web rapides et réactives.

## Installation
La première chose que nous devons faire est d'ajouter le paquet Bloc à notre `pubspec.yaml` comme dépendance.

```yaml
dependencies:
  bloc: ^0.15.0
```

Pour une application [Flutter](https://flutter.io), nous devons aussi ajouter le paquet flutter_bloc à notre `pubspec.yaml` comme dépendance.

```yaml
dependencies:
  bloc: ^0.15.0
  flutter_bloc: ^0.21.0
```

Pour une application [AngularDart](https://webdev.dartlang.org/angular), nous devons aussi ajouter le paquet angular_bloc à notre `pubspec.yaml' comme dépendance.

```yaml
dependencies:
  bloc: ^0.15.0
  angular_bloc: ^0.10.0
```

Ensuite, nous avons besoin d'installer bloc.

!> Assurez-vous d'exécuter la commande suivante à partir du même répertoire que votre fichier `pubspec.yaml`.

- Pour Dart ou AngularDart executez `pub get`

- Pour Flutter executez `flutter packages get`

## Importation

Maintenant que nous avons installé Bloc avec succès, nous pouvons créer notre bloc `main.dart` et l'importer.

```dart
import 'package:bloc/bloc.dart';
```

Pour une application Flutter nous pouvons aussi importer flutter_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

Pour une application AngularDart nous pouvons aussi importer angular_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
