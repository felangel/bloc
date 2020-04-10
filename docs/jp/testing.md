# テスト

> Bloc はとても簡単にテストができるように設計されています。

例として[コアコンセプト](coreconcepts.md)の中で作った`CounterBloc`のテストを書いていきましょう。

まずはおさらいです。`CounterBloc`は下記のようになっていましたね：

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

テストコードを書き始める前にまずテスト用のフレームワークを追加する必要があります。

We need to add [test](https://pub.dev/packages/test) and [bloc_test](https://pub.dev/packages/bloc_test) to our `pubspec.yaml`.
[test](https://pub.dev/packages/test)と[bloc_test](https://pub.dev/packages/bloc_test)を`pubspec.yaml`に追加します。

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```

まず`CounterBloc`に関するテストコードを記述する`counter_bloc_test.dart`ファイルを作り、テスト用のパッケージをインポートするところから始めましょう。

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

次に`main`関数とテストグループを作ります。

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **メモ**: グループは一つ一つの単体テストをまとめ、一つの`setUp`と`tearDown`を共有するために作ります。

まず`CounterBloc`今回のテストグループの中で使われるのインスタンスを作るところから始めましょう。

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

これで単体テストを書き始められます。

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('初期 state は 0', () {
        expect(counterBloc.initialState, 0);
    });
});
```

?> **メモ**: `pub run test`コマンドでテストを走らせることができます。

ここまできたら最初の通過するテストが書けたと思います！次にもっと複雑なテストを[bloc_test](https://pub.dev/packages/bloc_test)を使って書いていきましょう。

```dart
blocTest(
    'CounterEvent.increment が追加されたら[0, 1]を返す',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.increment),
    expect: [0, 1],
);

blocTest(
    'CounterEvent.decrement が追加されたら[0, -1]を返す',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.decrement),
    expect: [0, -1],
);
```

ここまで書き、テストを走らせると全てのテストが通ることがわかると思います。

これでテストは終わりです。自信を持ってテストコードを書けるようになったことでしょう。

[Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)を開くとより詳細なテストコードの例が見つかります。
