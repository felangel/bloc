# Getting Started

?> In order to start using bloc you must have the [Dart SDK](https://www.dartlang.org/install) installed on your machine.

## Overview

Bloc consists of several pub packages:

- [bloc](https://pub.dev/packages/bloc) - Core bloc library
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Powerful Flutter Widgets built to work with bloc in order to build fast, reactive mobile applications.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Powerful Angular Components built to work with bloc in order to build fast, reactive web applications.

## Installation

The first thing we need to do is add the bloc package to our `pubspec.yaml` as a dependency.

```yaml
dependencies:
  bloc: ^3.0.0
```

For a [Flutter](https://flutter.io) application, we also need to add the flutter_bloc package to our `pubspec.yaml` as a dependency.

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.1.0
```

For an [AngularDart](https://webdev.dartlang.org/angular) application, we also need to add the angular_bloc package to our `pubspec.yaml` as a dependency.

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

Next we need to install bloc.

!> Make sure to run the following command from the same directory as your `pubspec.yaml` file.

- For Dart or AngularDart run `pub get`

- For Flutter run `flutter packages get`

## Import

Now that we have successfully installed bloc, we can create our `main.dart` and import bloc.

```dart
import 'package:bloc/bloc.dart';
```

For a Flutter application we can also import flutter_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

For an AngularDart application we can also import angular_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
