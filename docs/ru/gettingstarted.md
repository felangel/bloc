# Начинаем

?> Для того, чтобы начать использовать блок, нам нужно иметь [Dart SDK](https://www.dartlang.org/install) установленный на наш компьютер.

## Обзор

Bloc состоит из нескольких `pub` пакетов:

- [bloc](https://pub.dev/packages/bloc) - Базовая библиотека `bloc`
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Мощные виджеты Flutter, созданные для работы с блоком по созданию быстрых, реактивных мобильных приложений.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Мощные компоненты Angular, созданные для работы с блоком по созданию быстрых, реактивных веб-приложений.

## Инсталляция

Первое, что нам нужно сделать, это добавить пакет `bloc` в наш `pubspec.yaml` в качестве зависимости.

```yaml
dependencies:
  bloc: ^3.0.0
```

Для [Flutter](https://flutter.io) приложения, нам также нужно добавить пакет `flutter_bloc` в наш `pubspec.yaml` в качестве зависимости.

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.2.0
```

Для [AngularDart](https://webdev.dartlang.org/angular) приложения, нам также нужно добавить пакет `angular_bloc` в наш `pubspec.yaml` в качестве зависимости.

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

Затем мы должны установить `bloc`.

!> Обязательно выполните следующую команду из той же директории, где находится наш `pubspec.yaml` файл.

- Для Dart или AngularDart - выполните `pub get`

- Для Flutter - выполните `flutter packages get`

## Импорт

Теперь, когда мы успешно установили `bloc`, мы можем создать наш `main.dart` и импортировать `bloc`.

```dart
import 'package:bloc/bloc.dart';
```

Для Flutter приложения нам нужно импортировать `flutter_bloc`.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

Для AngularDart приложения нам нужно импортировать `angular_bloc`.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
