# まずはじめに

?> Blocを使って開発を始めるにはまず [Dart SDK](https://dart.dev/get-dart) をインストールする必要があります。

## 概要

Blocには３つのpubパッケージが含まれています：

- [bloc](https://pub.dev/packages/bloc) - コアなBlocライブラリー
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Blocを使って素早く、リアクティブなモバイルアプリケーションを作るためのFlutterウィジェット
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Blocを使って素早く、リアクティブなモバイルアプリケーションを作るためのAngularのコンポーネント

## インストール

[Flutter](https://flutter.dev/)のアプリケーションの場合は`pubspec.yaml`にflutter_blocを追加します。

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

[AngularDart](https://angulardart.dev/)の場合はblocとangular_blocの二つを`pubspec.yaml`に追加します。

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

次にblocをインストールします。

!> 以下のコマンドは`pubspec.yaml`ファイルと同じディレクトリー内で行うようにしてください。

- DartかAngularDartの場合は `pub get`を実行

- Flutterの場合は`flutter packages get`を実行

## インポート

blocのインストールが無事完了したら`main.dart`にblocをインポートしてみましょう。

Flutterの場合はflutter_blocをインポートします。

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

AngularDartの場合はblocとangular_blocをインポートします。

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
