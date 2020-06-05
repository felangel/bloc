# Para empezar

?> Para comenzar a usar bloc debes tener el [SDK de Dart](https://dart.dev/get-dart) instalado en tu computadora.

## Visión general

Bloc está compuesto por varios paquetes de pub:

- [bloc](https://pub.dev/packages/bloc) - Libreía central de bloc
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Potentes widgets de Flutter creados para trabajar con bloc para crear aplicaciones móviles rápidas y reactivas.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Potentes componentes de Angular diseñados para trabajar con bloc para crear aplicaciones web rápidas y reactivas.

## Instalación

Lo primero que debemos hacer es agregar el paquete de bloc a nuestro `pubspec.yaml` como dependencia.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

Para una aplicación [Flutter](https://flutter.dev/), también necesitamos agregar el paquete flutter_bloc a nuestro `pubspec.yaml` como dependencia.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

Para una aplicación [AngularDart](https://angulardart.dev/), también necesitamos agregar el paquete angular_bloc a nuestro `pubspec.yaml` como dependencia.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Luego necesitamos instalar bloc.

!> Asegúrese de ejecutar el siguiente comando desde el mismo directorio que su archivo `pubspec.yaml`.

- Para Dart o AngularDart, ejecute `pub get`

- Para Flutter ejecute `flutter packages get`

## Importar

Ahora que hemos instalado con éxito bloc, podemos crear nuestro `main.dart` e importar el bloc.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Para una aplicación Flutter también podemos importar flutter_bloc.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

Para una aplicación AngularDart también podemos importar angular_bloc.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
