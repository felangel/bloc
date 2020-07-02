# コアコンセプト

?> 下記の説明をよく読んで理解してから[bloc](https://pub.dev/packages/bloc)を使い始めてください。

Bloc を使いこなすにはいくつかコアとなるコンセプトを理解する必要があります。

下記のセクションではそれらのコアコンセプトを「カウンター」というアプリを作りながらを一つ一つ深掘りしていきます。

## Event

> event は Bloc のインプットとなるものです。Event は主にボタンタップなどのユーザーアクションや、ページロードなどのライフサイクルイベントをきっかけに Bloc に送られます。

実際にアプリを作る時には一度立ち止まってユーザーがどのようにそのアプリを使用するかを考えなくてはなりません。カウンターの場合はボタンが二つあり、それぞれカウントを一つづつ増やすか減らします。

カウンターの値を変えるにはユーザーがボタンをタップした時に何かがアプリの「脳」に指令を送らなければなりません。これが event の役割です。

この場合はカウントを増やすケースと減らすケースの二つケースを「脳」に送る event を用意する必要があります。

[counter_event.dart](../_snippets/core_concepts/counter_event.dart.md ':include')

今回の場合はevent を`enum`を使って表現できますが、より複雑なevent やevent に乗せて情報を bloc に送る場合は`class`を作ります。

ここまでできたら人生最初の最初のevent 定義が終わりです！まだ Bloc も出てきてないですし、特に何も起こってないですよね。ただの Dart のコードです。

## State

> State は Bloc のアウトプットで、アプリのUIの一つの状態を表します。UIはこの state の変化を受けて再描画されます。

ここまででアプリ内で使われる `CounterEvent.increment` と `CounterEvent.decrement` の二つの event を定義しました。

今度はアプリ内の state (状態)を定義していきましょう。

今はカウンターアプリを作っているので、state はとてもシンプル： 今のカウントを示すただの int 型の値一つだけです。

後ほどより複雑な例を見ていきますが、今回のアプリではシンプルな値一つだけで十分です。

## Transition

> 一つの state から異なる別の state への変化を transition と呼びます。Transition は一つ前の state と新しくやってきた state の二つから成り立ちます。

ユーザーがアプリを操作し、`Increment` や `Decrement` event を発火させるとカウンターの state が変化します。このような state の変化は連続した transition で表すことができます。

例えば、もしユーザーがアプリを開き、値を増やすボタンを一回タップした時には下記のような `Transition` が発生します。

[counter_increment_transition.json](../_snippets/core_concepts/counter_increment_transition.json.md ':include')

全ての state の変化が記録されているので、アプリケーションの中で何が起こっているかを簡単に把握することができることに加え、「時を遡って」デバッグをすることも可能になります。

## Stream

?> `Stream`についてまだ詳しく知らない方はまず公式のドキュメンテーションを読むことをお勧めします [Dart Documentation](https://dart.dev/tutorials/language/streams)

> ストリームとは連続的な非同期データです。

Bloc を使いこなすには`Stream`とは何かをきちんと理解していることが重要になります。

> もし`Stream`についてあまり知らないのであれば、シンプルに水が流れているパイプをイメージしてください。この場合のパイプは`Stream`で、水が非同期データです。

Dartでは`async*`を使って`Stream`を返す関数を作ることができます。

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

関数名の後に`async*`をつけることで関数の内部で`yield`を使って`Stream`を返すことができるようになります。上記の例では引数である`max`の値まで連続したの int 型の`Stream`を返しています。

`async*`がついている関数の中で`yield`をするたびに新しいデータを`Stream`に流しています。

`Stream`のデータの取り出し方は何パターンかあります。例えば、上記の`Stream`に流れてきた値の合計値を計算したい場合はこのようになります：

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

上記の関数名の後に`async`をつけることで関数の中で`await`を使うことができるようになり、`Future`型の int を返すことができます。この例では毎回やってくる値を await して合計値を最後に返しています。

全部くっつけるとこのようになります：

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

## Bloc

> Bloc (Business Logic Component)とは`Stream`に乗ってやってくる`Event`を`State`を乗せた`Stream`に変換して返してあげるコンポーネントのことです。この Bloc が上の例で度々出てきた「脳」に当たる部分です。

> 全ての Bloc は bloc ライブラリー上で定義されている`Bloc`クラスを継承しなくてはなりません。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_class.dart.md ':include')

上記のコードでは`CounterBloc`を定義し`CounterEvents`を`int`型に変換しています。

> 全ての Bloc は初期 state を定義しなければなりません。この初期 state はまだ一回も state がきていない時に使われます。

この場合の初期 state は`0`です。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_initial_state.dart.md ':include')

> 全ての Bloc は`mapEventToState`という関数を備えていなければいけません。この関数は Bloc に入ってきた`event`を引数としてとり、`state`の`stream`を戻り値として返します。Bloc内ではいつでも state プロパティーにアクセスすることでその時の state を取得することができます。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_map_event_to_state.dart.md ':include')

ここまでくれば完全に動作する`CounterBloc`の完成です。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

!> Bloc は同一の state を無視します。もし、Bloc が yield した state が`State nextState`で、`state == nextState`が true の場合、その transition は起こらず、`Stream<State>`にも何の変化も起こりません。

ここまで来るときっと「どうやって Bloc に新しい event が来たことを知らせるの？」と思っていませんか？

> 全ての Bloc は`add`という関数を持っています。`Add`は`event`を引数として取り、その event を`mapEventToState`に渡してくれます。`Add`はUI側からでもBlocの中からでも呼び出すことができます。

0から3まで数えてくれるアプリはこのように作れます。

[main.dart](../_snippets/core_concepts/counter_bloc_main.dart.md ':include')

!> デフォルトでは event は常に来た順に処理されます。Event は`mapEventToState`が完了すると処理完了とみなされます。

上記のコードでの`Transition`はこのようになります：

[counter_bloc_transitions.json](../_snippets/core_concepts/counter_bloc_transitions.json.md ':include')

残念ながら今の状態では`onTransition`を上書きしないと transition を見ることができません。

> `onTransition`を上書きすることでその Bloc の`Transition`を観測することができます。`onTransition`は Bloc の state が更新される直前に呼ばれます。

?> **豆知識**: `onTransition`はその Bloc 特有のアナリティクスやログ用のコードを書くのに最適な場所です。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

`onTransition`を上書きしたので`Transition`が起こるたびに好きなコードを実行できます。

Bloc 内で`Transition`を観測できたのと同じように Bloc 内の`Exception`も観測することができます。

> `onError`を上書きするとそのBloc内で起こった`Exception`を観測することができます。デフォルトでは Bloc 内で起こった全ての`Exception`は無視され、Bloc の動作には影響を及ぼしません。

?> **メモ**: `StackTrace`が含まれないエラーの場合は StackTrace プロパティは`null`の場合があります。

?> **豆知識**: `onError`はその Bloc 特有のエラー処理を行うのにうってつけのところです。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

`onError`を上書きしたので`Exception`が発生した時に好きなように処理することができます。

## BlocObserver

Bloc を使うことで一個ついてくるボーナスが一箇所で全ての`Transition`にアクセスできるということです。今回のアプリでは一個しか Bloc がなかったものの、もう少し複雑なアプリになったら Bloc も複数出てきてアプリ内の様々な箇所で状態管理をするようになります。

もし、アプリ内の全ての`Transition`を監視したい場合は`BlocObserver`を作ります。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer.dart.md ':include')

?> **メモ**: `BlocObserver`を継承し`onTransition`を上書きするだけです。

Bloc にこの`SimpleBlocObserver`を使うように指示するにはただ`main`をいじるだけです。

[main.dart](../_snippets/core_concepts/simple_bloc_observer_main.dart.md ':include')

もし全ての`Event`に対して何かを実行したい場合は`SimpleBlocObserver`内で`onEvent`を上書きします。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

もし全ての`Exception`に対して何かを実行したい場合は`SimpleBlocObserver`の`onError`を上書きします。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_complete.dart.md ':include')