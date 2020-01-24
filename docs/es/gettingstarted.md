# Para empezar

?> Para comenzar a usar bloc debes tener el [SDK de Dart](https://www.dartlang.org/install) instalado en tu computadora.

## Visión general

Bloc está compuesto por varios paquetes pub:

- [bloc](https://pub.dev/packages/bloc) - Libreía central de bloc
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Potentes widgets de Flutter creados para trabajar con bloc para crear aplicaciones móviles rápidas y reactivas.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Potentes componentes de Angular diseñados para trabajar con bloc para crear aplicaciones web rápidas y reactivas.

## Instalación

Lo primero que debemos hacer es agregar el paquete de bloc a nuestro `pubspec.yaml` como dependencia.

```yaml
dependencies:
  bloc: ^3.0.0
```

Para una aplicación [Flutter] (https://flutter.io), también necesitamos agregar el paquete flutter_bloc a nuestro `pubspec.yaml` como dependencia.

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.1.0
```

Para una aplicación [AngularDart] (https://webdev.dartlang.org/angular), también necesitamos agregar el paquete angular_bloc a nuestro `pubspec.yaml` como dependencia.

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

Luego necesitamos instalar bloc.

!> Asegúrese de ejecutar el siguiente comando desde el mismo directorio que su archivo `pubspec.yaml`.

- Para Dart o AngularDart, ejecute `pub get`

- Para Flutter ejecute `flutter packages get`

## Importar

Ahora que hemos instalado con éxito bloc, podemos crear nuestro `main.dart` e importar el bloc.

```dart
import 'package:bloc/bloc.dart';
```

Para una aplicación Flutter también podemos importar flutter_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

Para una aplicación AngularDart también podemos importar angular_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
