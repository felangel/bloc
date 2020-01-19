# Para empezar

?> Para comenzar a usar dart debes tener el [SDK de Dart](https://www.dartlang.org/install) instalado en tu computadora.

## Overview

Bloc está compuesto por varios paquetes Pub:

- [bloc](https://pub.dev/packages/bloc) - Core bloc library
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Potentes widgets de Flutter creados para trabajar con bloc con el fin de construir de forma rápida aplicaciones móviles reactivas.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Potentes componentes de Angular creados para trabajar con bloc con el fin de construir de forma rápida aplicaciones web reactivas.

## Instalación

Lo primero que debemo hacer es añadir el paquete bloc a nuestro archivo `pubspec.yaml` como una dependencia.

```yaml
dependencies:
  bloc: ^3.0.0
```

Para una aplicación de [Flutter](https://flutter.io), debemos añadir también el paquete flutter_bloc a nuestro archivo `pubspec.yaml` como una dependencia.

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.1.0
```

Para una aplicación de [AngularDart](https://webdev.dartlang.org/angular), debemos añadir también el paquete angular_bloc a nuestro archivo `pubspec.yaml` como una dependencia.

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

Seguidamente necesitamos instalar bloc.

!> Asegurate de ejecutar el siguiente comando desde el mismo directorio de tu archivo `pubspec.yaml`.

- Para Dart o AngularDart ejecutra `pub get`

- Para Flutter ejecuta `flutter packages get`

## Importación

Ahora que hemos instalado bloc correctamente, tenemos que crear nuestro `main.dart` e importar bloc.

```dart
import 'package:bloc/bloc.dart';
```

Para una aplicación Flutter tenemos que importar también  flutter_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

Para una aplicación AngularDart tenemos que importar también angular_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
