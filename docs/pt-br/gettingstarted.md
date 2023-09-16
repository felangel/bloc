# Iniciando

?> Para começar a usar o bloc você precisa ter o [Dart SDK](https://dart.dev/get-dart) instalado na sua máquina.

## Visão geral

O Bloc consiste em vários pacotes disponíveis no pub:

- [bloc](https://pub.dev/packages/bloc) - Biblioteca principal do bloc
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Poderosos Widgets para Flutter desenvolvidos para trabalhar com bloc e construir aplicações mobile rápidas e reativas.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Poderosos Componentes para Angular desenvolvidos para trabalhar com bloc e construir aplicações web rápidas e reativas.
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) - Uma extensão da biblioteca de gerenciamento de estado bloc que persiste e restaura automaticamente os estados do bloc.
- [replay_bloc](https://pub.dev/packages/replay_bloc) - Uma extensão da biblioteca de gerenciamento de estado bloc que adiciona suporte para desfazer e refazer.

## Instalação

Para uma aplicação [Dart](https://dart.dev/), precisamos adicionar o pacote `bloc` ao nosso `pubspec.yaml` como uma dependência.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

Para uma aplicação [Flutter](https://flutter.dev/), precisamos adicionar o pacote `flutter_bloc` ao nosso `pubspec.yaml` como uma dependência.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

Para uma aplicação [AngularDart](https://angulardart.dev/), precisamos adicionar o pacote `angular_bloc` ao nosso `pubspec.yaml` como uma dependência.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Em seguida, precisamos instalar o bloc.

!> Certifique-se de executar o seguinte comando no mesmo diretório do arquivo `pubspec.yaml`.

- Para Dart ou AngularDart execute `pub get`

- Para Flutter, execute `flutter packages get`

## Importações

Agora que instalamos o bloc com sucesso, podemos criar nosso `main.dart` e importar `bloc`.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Para uma aplicação Flutter podemos importar `flutter_bloc`.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

Para uma aplicação AngularDart podemos importar `angular_bloc`.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
