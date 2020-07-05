# Flutter Blocコアコンセプト

?> [flutter_bloc](https://pub.dev/packages/flutter_bloc)を使い始める前に下記の説明をきちんと読んで理解してください。

## Blocウィジェット

### BlocBuilder

**BlocBuilder**はFlutterのウィジェットで`Bloc`と`builder`関数を与える必要があります。`BlocBuilder`は新しい state がきた時にウィジェットを再描画してくれる役割を持ちます。`BlocBuilder`は`StreamBuilder`によく似ていますが、よりシンプルなAPIになっています。`builder`関数はstateの変化に応じてウィジェットを返し、何回でも呼ばれることがあります。また、[pure関数](https://en.wikipedia.org/wiki/Pure_function)である必要があります。

state が変わった時に１度だけ何かをしたい時には`BlocListener`を使います。例えばほかのページへのナビゲーションやダイアログの表示など

もし bloc 引数が省略されているときは`BlocBuilder`は自動的に`BlocProvider`とそこでの`BuildContext`を使って blocを探してくれます。

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

bloc 引数は特定のウィジェットにのみ特定の bloc を使いたく、かつそこの`BuildContext`の先祖ウィジェットに`BlocProvider`がない場合のみ指定します。

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

もし、 state　が変化するたびに毎回 builder 関数を呼ぶのではなく、特定の条件を満たした時のみ builder を呼び画面の再描画を行いたいときは`BlocBuilder`に`buildWhen` を設定します。`buildWhen`は一個前の state と今の state が引数として渡されていて、boolean を返すようになっています。もし`buildWhen`が true を返したら `builder` が呼ばれ画面の再描画が行われます。もし`buildWhen`が false を返したら`builder`は呼ばれず、再描画は起きません。

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** は`BlocProvider.of<T>(context)`を通じて子孫要素に bloc を渡す Flutter のウィジェットです。一つの Bloc インスタンスを複数の子孫要素に渡す役割があります。

大抵の場合`BlocProvider`は新しい`bloc`を生成し、それを子孫要素に与えるために使います。この場合`BlocProvider`は生成した Bloc の close を行ってくれます。

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

稀に`BlocProvider`を既存の Bloc を子孫要素に与えるために使われることがあります。大抵これが起きるのは既存の Bllc を新しい route に投げたい時です。この場合そのは`BlocProvider`は Bloc 生成を行なっていないためその Bloc の close を行ってくれません。

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

そうすると`ChildA`, や`ScreenA`からは`BlocA`を以下のどちらかの書き方で引っ張ってこれます:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider**とは複数の`BlocProvider`を一つにまとめてくれるウィジェットです。`MultiBlocProvider`を複数の Bloc を使う場面で使うとコードの可読性を高められ、`BlocProviders`を何層にも入れ子にしなくてよくなります。
`MultiBlocProvider`を使うとこれが:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

こうなります:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener**は Bloc での state の変化に応じて`listener`に定義したコードを実行してくれる Flutter のウィジェットで、`Bloc`を引数として渡すこともできます。このウィジェットは何か state の変化につき１度だけコードを実行したい時に（ナビゲーション、`SnackBar`や`Dialog`の表示など）使います。

`listener`は state の変化があるたびに1度呼ばれ(`initialState`は**含まない**)、`BlocBuilder`の中の`builder`と違い`void`型の関数です。

もし引数として bloc を渡さなかった時は`BlocListener`はその時の`BuildContext`から先祖要素にある`BlocProvider`を探し出します。

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

`BlocListener`に引数として bloc を渡すのはその時の`BuildContext`から`BlocProvider`にアクセスできない場合にしてください。

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

もし state が変わるたびにコードを実行するのではなく、コードを実行する条件をより詳細にコントロールしたい場合は`listenWhen`を`BlocListener`の引数として設定します。`listenWhen`は bloc の一個前の state と今の state が引数として用意されていて、booleanを返す関数になっています。もし true が返されたら`listener`が実行され、もし false が返されていたら`listener`は実行されません。

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener**は複数の`BlocListener`を一つにまとめてくれる Flutter のウィジェットです。
`MultiBlocListener`を使うと複数の`BlocListeners`を入れ子にしなくてよくなりコードの可読性が上がります。
`MultiBlocListener`を使うとこれが:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

こうなります:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer**には`builder`と`listener`あります。 `BlocConsumer`は内部で`BlocListener`と`BlocBuilder`を使っており、その両方を使いたい時は`BlocConsumer`を使うとコードを書く量を減らせます。`BlocConsumer`は state の変化に応じてUIを変更させたいかつ単発で何かコードも実行したい時のみ使うべきです。 `BlocConsumer`は必須で`BlocWidgetBuilder`と`BlocWidgetListener`を与えて、必要に応じて`bloc`, `BlocBuilderCondition`, `BlocListenerCondition`を与えることができます。

もし、`bloc`引数が省略されている場合は`BlocConsumer`はその時の`BuildContext`を使って先祖要素の`BlocProvider`を探し出します。

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

オプションで`listenWhen`と`buildWhen`を渡すことで特定の条件を満たした時のみ`listener`や`builder`を実行させることができます。`listenWhen`と`buildWhen`はその`bloc`の`state`が変化するたびに呼ばれます。それぞれ一個前の`state`と新しい`state`が引数として用意されていて、`bool`を返すことで`builder`や`listener`を実行するかどうかをコントロールできます。`listenWhen`は必須ではなく、`buildWhen`省略された場合は常にtrueをした場合と同じ挙動になります。

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider**は`RepositoryProvider.of<T>(context)`を使って子孫要素に repository を渡すことができる Flutter のウィジェットです。一つの repository インスタンスを複数の子孫要素に渡したい時に使います。`BlocProvider`は子孫要素に Bloc を渡したい時に使い、`RepositoryProvider`は子孫要素に repository を渡したい時に使います。

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

そうすると`ChildA`内でこのように`Repository`インスタンスを取得できます:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider**は複数の`RepositoryProvider`を一つにまとめた Flutter のウィジェットです。
`MultiRepositoryProvider`を使うと複数の`RepositoryProvider`を入れ子にする必要がなくなり、コードの可読性が上がります。
`MultiRepositoryProvider`を使うとこれが:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

こうなります:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## 使用法

Lets take a look at how to use `BlocBuilder` to hook up a `CounterPage` widget to a `CounterBloc`.
実際に`BlocBuilder`を使ってどのように`CounterPage`に`CounterBloc`を紐づけるかを見てみましょう。

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

ここまできたら完全にUI側のコードとロジック系のコードを分けることができました。注目して欲しいのは`CounterPage`ウィジェットにはユーザーがボタンを押した時に何が起こるかは一切定義されていません。ただ`CounterBloc`にユーザーが押したボタンに応じて event を送っているだけです。
