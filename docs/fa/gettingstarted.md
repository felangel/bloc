# Getting Started

?> In order to start using bloc you must have the [Dart SDK](https://dart.dev/get-dart) installed on your machine.

## Overview

Bloc consists of several pub packages:

- [bloc](https://pub.dev/packages/bloc) - Core bloc library
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Powerful Flutter Widgets built to work with bloc in order to build fast, reactive mobile applications.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Powerful Angular Components built to work with bloc in order to build fast, reactive web applications.
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) - An extension to the bloc state management library which automatically persists and restores bloc states.
- [replay_bloc](https://pub.dev/packages/replay_bloc) - An extension to the bloc state management library which adds support for undo and redo.

## Installation

For a [Dart](https://dart.dev/) application, we need to add the `bloc` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/bloc_pubspec.yaml.md ':include')

For a [Flutter](https://flutter.dev/) application, we need to add the `flutter_bloc` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

For an [AngularDart](https://angulardart.dev/) application, we need to add the `angular_bloc` package to our `pubspec.yaml` as a dependency.

[pubspec.yaml](_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Next we need to install bloc.

!> Make sure to run the following command from the same directory as your `pubspec.yaml` file.

- For Dart or AngularDart run `pub get`

- For Flutter run `flutter packages get`

## Import

Now that we have successfully installed bloc, we can create our `main.dart` and import `bloc`.

[main.dart](_snippets/getting_started/bloc_main.dart.md ':include')

For a Flutter application we can import `flutter_bloc`.

[main.dart](_snippets/getting_started/flutter_bloc_main.dart.md ':include')

For an AngularDart application we can import angular_bloc.

[main.dart](_snippets/getting_started/angular_bloc_main.dart.md ':include')
