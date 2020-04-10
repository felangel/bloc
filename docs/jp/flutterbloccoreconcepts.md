# Flutter Blocコアコンセプト

?> [flutter_bloc](https://pub.dev/packages/flutter_bloc)を使い始める前に下記の説明をきちんと読んで理解してください。

## Blocウィジェット

### BlocBuilder

**BlocBuilder**はFlutterのウィジェットで`Bloc`と`builder`関数を与える必要があります。`BlocBuilder`は新しい state がきた時にウィジェットを再描画してくれる役割を持ちます。`BlocBuilder`は`StreamBuilder`によく似ていますが、よりシンプルなAPIになっています。`builder`関数はstateの変化に応じてウィジェットを返し、何回でも呼ばれることがあります。また、[pure関数](https://en.wikipedia.org/wiki/Pure_function)である必要があります。

state が変わった時に１度だけ何かをしたい時には`BlocListener`を使います。例えばほかのページへのナビゲーションやダイアログの表示など

もし bloc 引数が省略されているときは`BlocBuilder`は自動的に`BlocProvider`とそこでの`BuildContext`を使って blocを探してくれます。

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // ここで state に応じたウィジェットを出し分ける
  }
)
```

bloc 引数は特定のウィジェットにのみ特定の bloc を使いたく、かつそこの`BuildContext`の先祖ウィジェットに`BlocProvider`がない場合のみ指定します。

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // ローカルの bloc インスタンスを渡す
  builder: (context, state) {
    // ここで blocA の state に応じたウィジェットを出し分ける
  }
)
```

もし、 state　が変化するたびに毎回 builder 関数を呼ぶのではなく、特定の条件を満たした時のみ builder を呼び画面の再描画を行いたいときは`BlocBuilder`に`condition` を設定します。`condition`は一個前の state と今の state が引数として渡されていて、boolean を返すようになっています。もし`condition`が true を返したら `builder` が呼ばれ画面の再描画が行われます。もし`condition`が false を返したら`builder`は呼ばれず、再描画は起きません。

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // 今の state で再描画を行いたいかどうかによって
    // true/false を返す
  },
  builder: (context, state) {
    // ここで blocA の state に応じたウィジェットを出し分ける
  }
)
```

### BlocProvider

**BlocProvider** は`BlocProvider.of<T>(context)`を通じて子孫要素に bloc を渡す Flutter のウィジェットです。一つの Bloc インスタンスを複数の子孫要素に渡す役割があります。

大抵の場合`BlocProvider`は新しい`bloc`を生成し、それを子孫要素に与えるために使います。この場合`BlocProvider`は生成した Bloc の close を行ってくれます。


```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

稀に`BlocProvider`を既存の Bloc を子孫要素に与えるために使われることがあります。大抵これが起きるのは既存の Bllc を新しい route に投げたい時です。この場合そのは`BlocProvider`は Bloc 生成を行なっていないためその Bloc の close を行ってくれません。

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

そうすると`ChildA`, や`ScreenA`からは`BlocA`を以下のどちらかの書き方で引っ張ってこれます:

```dart
// extensionを使った書き方
context.bloc<BlocA>();

// extensionを使わない書き方
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider

**MultiBlocProvider**とは複数の`BlocProvider`を一つにまとめてくれるウィジェットです。`MultiBlocProvider`を複数の Bloc を使う場面で使うとコードの可読性を高められ、`BlocProviders`を何層にも入れ子にしなくてよくなります。
`MultiBlocProvider`を使うとこれが:

```dart
BlocProvider<BlocA>(
  create: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

こうなります:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

### BlocListener

**BlocListener**は Bloc での state の変化に応じて`listener`に定義したコードを実行してくれる Flutter のウィジェットで、`Bloc`を引数として渡すこともできます。このウィジェットは何か state の変化につき１度だけコードを実行したい時に（ナビゲーション、`SnackBar`や`Dialog`の表示など）使います。

`listener`は state の変化があるたびに1度呼ばれ(`initialState`は**含まない**)、`BlocBuilder`の中の`builder`と違い`void`型の関数です。

もし引数として bloc を渡さなかった時は`BlocListener`はその時の`BuildContext`から先祖要素にある`BlocProvider`を探し出します。

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // BlocA の state に応じて何かを実行する
  },
  child: Container(),
)
```

`BlocListener`に引数として bloc を渡すのはその時の`BuildContext`から`BlocProvider`にアクセスできない場合にしてください。

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // BlocA の state に応じて何かを実行する
  }
)
```

もし state が変わるたびにコードを実行するのではなく、コードを実行する条件をより詳細にコントロールしたい場合は`condition`を`BlocListener`の引数として設定します。`condition`は bloc の一個前の state と今の state が引数として用意されていて、booleanを返す関数になっています。もし true が返されたら`listener`が実行され、もし false が返されていたら`listener`は実行されません。

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // listener を実行したいかしたくないかで
    // true/false を出し分ける
  },
  listener: (context, state) {
    // BlocA の state に応じて何かを実行する
  },
  child: Container(),
)
```

### MultiBlocListener

**MultiBlocListener**は複数の`BlocListener`を一つにまとめてくれる Flutter のウィジェットです。
`MultiBlocListener`を使うと複数の`BlocListeners`を入れ子にしなくてよくなりコードの可読性が上がります。
`MultiBlocListener`を使うとこれが:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

こうなります:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

### BlocConsumer

**BlocConsumer**には`builder`と`listener`あります。 `BlocConsumer`は内部で`BlocListener`と`BlocBuilder`を使っており、その両方を使いたい時は`BlocConsumer`を使うとコードを書く量を減らせます。`BlocConsumer`は state の変化に応じてUIを変更させたいかつ単発で何かコードも実行したい時のみ使うべきです。 `BlocConsumer`は必須で`BlocWidgetBuilder`と`BlocWidgetListener`を与えて、必要に応じて`bloc`, `BlocBuilderCondition`, `BlocListenerCondition`を与えることができます。

もし、`bloc`引数が省略されている場合は`BlocConsumer`はその時の`BuildContext`を使って先祖要素の`BlocProvider`を探し出します。

```dart
BlocConsumer<BlocA, BlocAState>(
  listener: (context, state) {
    // BlocAの state に応じてコードを実行
  },
  builder: (context, state) {
    // BlocA の state に応じてUIを変更
  }
)
```

オプションで`listenWhen`と`buildWhen`を渡すことで特定の条件を満たした時のみ`listener`や`builder`を実行させることができます。`listenWhen`と`buildWhen`はその`bloc`の`state`が変化するたびに呼ばれます。それぞれ一個前の`state`と新しい`state`が引数として用意されていて、`bool`を返すことで`builder`や`listener`を実行するかどうかをコントロールできます。`listenWhen`は必須ではなく、`buildWhen`省略された場合は常にtrueをした場合と同じ挙動になります。

```dart
BlocConsumer<BlocA, BlocAState>(
  listenWhen: (previous, current) {
    // true/false を返して
    // listener を実行させるかをコントロールする
  },
  listener: (context, state) {
    // BlocA の state に応じて何かを実行する
  },
  buildWhen: (previous, current) {
    // true/false を返して
    // 再描画を行うかどうかをコントロールする
  },
  builder: (context, state) {
    // BlocA の state に応じてUIを変える
  }
)
```

### RepositoryProvider

**RepositoryProvider**は`RepositoryProvider.of<T>(context)`を使って子孫要素に repository を渡すことができる Flutter のウィジェットです。一つの repository インスタンスを複数の子孫要素に渡したい時に使います。`BlocProvider`は子孫要素に Bloc を渡したい時に使い、`RepositoryProvider`は子孫要素に repository を渡したい時に使います。

```dart
RepositoryProvider(
  create: (context) => RepositoryA(),
  child: ChildA(),
);
```

そうすると`ChildA`内でこのように`Repository`インスタンスを取得できます:

```dart
// extension を使った場合の記法
context.repository<RepositoryA>();

// extension を使わない場合の記法
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider**は複数の`RepositoryProvider`を一つにまとめた Flutter のウィジェットです。
`MultiRepositoryProvider`を使うと複数の`RepositoryProvider`を入れ子にする必要がなくなり、コードの可読性が上がります。
`MultiRepositoryProvider`を使うとこれが:

```dart
RepositoryProvider<RepositoryA>(
  create: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    create: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      create: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

こうなります:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      create: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      create: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      create: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## 使用法

Lets take a look at how to use `BlocBuilder` to hook up a `CounterPage` widget to a `CounterBloc`.
実際に`BlocBuilder`を使ってどのように`CounterPage`に`CounterBloc`を紐づけるかを見てみましょう。

### counter_bloc.dart

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

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

ここまできたら完全にUI側のコードとロジック系のコードを分けることができました。注目して欲しいのは`CounterPage`ウィジェットにはユーザーがボタンを押した時に何が起こるかは一切定義されていません。ただ`CounterBloc`にユーザーが押したボタンに応じて event を送っているだけです。
