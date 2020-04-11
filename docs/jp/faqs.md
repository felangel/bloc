# よくある質問

## State が更新されない

❔ **質問**: State を yield しても UI 側が更新されません。何が原因ですか？

💡 **答え**: もし Equatable を使っているならきちんと state のプロパティ一覧を props に渡してあげてください。

✅ **正解**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // 全てのプロパティを props に渡す
}
```

❌ **間違い**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [];
}
```

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => null;
}
```

それともう一つ、毎回新しい　 state のインスタンスを yield するようにしてください。

✅ **正解**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // 常に新しい state インスタンスを yield する
    yield state.copyWith(property: event.property);
}
```

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // 常に新しい state インスタンスを yield する
    yield MyState(data: data);
}
```

❌ **間違い**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // state のプロパティのみ変更するのはだめ
    state.property = event.property;
    // 同じインスタンスの state を yield するのはだめ
    yield state;
}
```

## Equatable を使うのはどんな時？

❔**質問**: Equatable はどんな時に使うべき？

💡**答え**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

`StateA`が`Equatable`を継承している上のような場合では一度しか state は変化しません（２回目の yield は無視される）。
一般的には再描画を最低限にしコードを最適化したい場合は`Equatable`を使うべきです。
もし同じ state を返して transition を発生させたい場合は`Equatable`は使うべきではありません。

加えて`Equatable` を使うとテストに置いて特定のプロパティを持った state を predict できるのでテストが楽になります。

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        MyStateA(),
        MyStateB(),
    ],
)
```

`Equatable`なしでは上記のテストコードは通らず、下記のように書かなくてはなりません：

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```

## Bloc vs. Redux

❔ **質問**: Bloc と Redux の違いは何？

💡 **答え**:

BLoC は下記のルールを元に設計されたデザインパターンです:

1. Bloc の入力と出力はシンプルな Stream と Sink であるべき。
2. 依存性は注入可能で、プラットフォームに依存しない。
3. プラットフォームに分岐してはならない。
4. 上記のルールを守っている限り実装方法はどのような形でも良い。

UI のガイドラインは:

1. 一つ一つの「それなりに複雑な」コンポーネントは Bloc を持つべき。
2. コンポーネントは入力をありのまま送るべき。
3. コンポーネントは出力を出来るだけありのまま表示するべき。
4. state ごとの UI の出し分けはの並べくシンプルな条件分岐で行うべき

Bloc ライブラリーは上記の BloC デザインパターンを RxDart を内包的に使って簡単に実装するツールを目指しています。

Redux の３つの原則は:

1.  真となるものは一つ
2. State は読み込みのみ
3. 変更は pure 関数によってのみ加えられる

Bloc ライブラリーは一つ目の原則を犯しています。Bloc の場合は真となるデータはあちこちの bloc に分散されています。
さらに、bloc にはミドルウェアという概念はなく、bloc を使うと簡単に一つの event に対して複数の非同期データを state として返すことができます。

## Bloc vs. Provider

❔ **質問**: Bloc と Provider の違いは？

💡 **答え**: `provider`は依存性の注入をするためのものです(`InheritedWidget`のラッパー)。
これだけでは自分で状態管理をどのようにするかを考えなければなりません(例えば`ChangeNotifier`, `Bloc`, `Mobx`, など...)。
Bloc ライブラリーは内部で`provider`を使い bloc が子孫要素たちからアクセスできるようにしています。

## Bloc を使ったナビゲーション

❔ **質問**: Blco を使った場合ナビゲーションはどのようにしたらいい？

💡 **答え**: [Flutter Navigation](recipesflutternavigation.md)を見てみてください。

## BlocProvider.of() が Bloc を見つけてくれません

❔ **質問**: `BlocProvider.of(context)`を使っているのに Bloc を取ってきてくれません。どうしたらいい？

💡 **答え**: Bloc provider と同じ`BuildContext`では bloc にアクセスできないので`BlocProvider.of()`を provider の子孫要素の中で呼ぶ必要があります。

✅ **正解**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      },
    )
    ...
  }
}
```

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          final blocA = BlocProvider.of<BlocA>(context);
          ...
        },
      ),
    ),
  );
}
```

❌ **間違い**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      }
    )
  );
}
```

## Project Structure

## プロジェクトの構造

❔ **質問**: プロジェクトはどのような構造にしたらいい？

💡 **答え**: 明確に正解・不正解はありませんが、いくつか参考になる例はこちらにあります。

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

一番大切なのは**一貫**して**意図的な**プロジェクト構造にすることです。
