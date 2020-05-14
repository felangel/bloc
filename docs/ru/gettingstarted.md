# Начинаем

?> Для того, чтобы начать использовать блок, нам нужно иметь [Dart SDK](https://dart.dev/get-dart) установленный на наш компьютер.

## Обзор

Bloc состоит из нескольких `pub` пакетов:

- [bloc](https://pub.dev/packages/bloc) - Базовая библиотека `bloc`
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Мощные виджеты Flutter, созданные для работы с блоком по созданию быстрых, реактивных мобильных приложений.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Мощные компоненты Angular, созданные для работы с блоком по созданию быстрых, реактивных веб-приложений.

## Инсталляция

Первое, что нам нужно сделать, это добавить пакет `bloc` в наш `pubspec.yaml` в качестве зависимости.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

Для [Flutter](https://flutter.dev/) приложения, нам также нужно добавить пакет `flutter_bloc` в наш `pubspec.yaml` в качестве зависимости.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

Для [AngularDart](https://angulardart.dev/) приложения, нам также нужно добавить пакет `angular_bloc` в наш `pubspec.yaml` в качестве зависимости.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Затем мы должны установить `bloc`.

!> Обязательно выполните следующую команду из той же директории, где находится наш `pubspec.yaml` файл.

- Для Dart или AngularDart - выполните `pub get`

- Для Flutter - выполните `flutter packages get`

## Импорт

Теперь, когда мы успешно установили `bloc`, мы можем создать наш `main.dart` и импортировать `bloc`.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Для Flutter приложения нам нужно импортировать `flutter_bloc`.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

Для AngularDart приложения нам нужно импортировать `angular_bloc`.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
