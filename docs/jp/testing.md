# テスト

> Bloc はとても簡単にテストができるように設計されています。

例として[コアコンセプト](coreconcepts.md)の中で作った`CounterBloc`のテストを書いていきましょう。

まずはおさらいです。`CounterBloc`は下記のようになっていましたね：

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

テストコードを書き始める前にまずテスト用のフレームワークを追加する必要があります。

We need to add [test](https://pub.dev/packages/test) and [bloc_test](https://pub.dev/packages/bloc_test) to our `pubspec.yaml`.
[test](https://pub.dev/packages/test)と[bloc_test](https://pub.dev/packages/bloc_test)を`pubspec.yaml`に追加します。

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

まず`CounterBloc`に関するテストコードを記述する`counter_bloc_test.dart`ファイルを作り、テスト用のパッケージをインポートするところから始めましょう。

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

次に`main`関数とテストグループを作ります。

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **メモ**: グループは一つ一つの単体テストをまとめ、一つの`setUp`と`tearDown`を共有するために作ります。

まず`CounterBloc`今回のテストグループの中で使われるのインスタンスを作るところから始めましょう。

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

これで単体テストを書き始められます。

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **メモ**: `pub run test`コマンドでテストを走らせることができます。

ここまできたら最初の通過するテストが書けたと思います！次にもっと複雑なテストを[bloc_test](https://pub.dev/packages/bloc_test)を使って書いていきましょう。

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

ここまで書き、テストを走らせると全てのテストが通ることがわかると思います。

これでテストは終わりです。自信を持ってテストコードを書けるようになったことでしょう。

[Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)を開くとより詳細なテストコードの例が見つかります。
