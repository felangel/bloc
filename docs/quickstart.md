# Quick Start

?> In order to start using bloc you must have the [Dart SDK](https://www.dartlang.org/install) installed on your machine.

## Installation

Bloc is available as a pub package and can be found [here](https://pub.dartlang.org/packages/bloc).

The first thing we need to do is add the bloc package to our `pubspec.yaml` as a dependency.

```yaml
dependencies:
  bloc: ^0.7.5
```

Next we need to install bloc.

!> Make sure to run the following command from the same directory as your `pubspec.yaml` file.

- For Dart `pub get`

- For Flutter `flutter packages get`

## Import

Now that we have successfully installed bloc, we can create our `main.dart` and import bloc.
```dart
import 'package:bloc/bloc.dart';
```