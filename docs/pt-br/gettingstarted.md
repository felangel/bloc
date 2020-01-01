# Iniciando

?> Para começar a usar o bloc você precisa ter o [Dart SDK](https://www.dartlang.org/install) instalado na sua máquina.

## Visão geral

O Bloc consiste em vários packages disponíveis no pub:

- [bloc](https://pub.dev/packages/bloc) - Package principal para o bloc
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Poderosos Widgets para Flutter desenvolvidos para trabalhar com bloc e construir aplicações mobile rápidas e reativas.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Poderosos Componentes para Angular desenvolvidos para trabalhar com bloc e construir aplicações web rápidas e reativas.

## Instalação

A primeira coisa que precisamos fazer é adicionar o package bloc como uma dependência no `pubspec.yaml`.

```yaml
dependencies:
  bloc: ^3.0.0
```

Para uma aplicação [Flutter](https://flutter.io), também é necessário adicionar o package flutter_bloc como uma dependência no `pubspec.yaml`.

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.1.0
```

Para uma aplicação [AngularDart](https://webdev.dartlang.org/angular), também é necessário adicionar o package angular_bloc como uma dependência no `pubspec.yaml`.

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

Agora precisamos instalar o bloc.

!> Execute os comandos abaixo no mesmo diretório em que se encontra o arquivo `pubspec.yaml`.

- Para projetos Dart ou AngularDart execute `pub get`

- Para projetos Flutter execute `flutter packages get`

## Importações

Agora que instalamos o bloc, podemos criar o arquivo `main.dart` e importar o bloc.

```dart
import 'package:bloc/bloc.dart';
```

Para uma aplicação Flutter também podemos importar o flutter_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

Para uma aplicação AngularDart também podemos importar o angular_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
