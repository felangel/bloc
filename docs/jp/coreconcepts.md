# コアコンセプト

?> 下記の説明をよく読んで理解してから[bloc](https://pub.dev/packages/bloc)を使い始めてください。

Bloc を使いこなすにはいくつかコアとなるコンセプトを理解する必要があります。

下記のセクションではそれらのコアコンセプトを「カウンター」というアプリを作りながらを一つ一つ深掘りしていきます。

## Event

> event は Bloc のインプットとなるものです。event は主にボタンタップなどのユーザーアクションや、ページロードなどのライフサイクル event をきっかけに Bloc に送られます。

実際にアプリを作る時には一度立ち止まってユーザーがどのようにそのアプリを使用するかを考えなくてはなりません。カウンターの場合はボタンが二つあり、それぞれカウントを一つづつ増やすか減らします。

カウンターの値を変えるにはユーザーがボタンをタップした時に何かがアプリの「脳」に指令を送らなければなりません。これが event の役割です。

この場合はカウントを増やすケースと減らすケースの二つケースを「脳」に送る event を用意する必要があります。

[counter_event.dart](../_snippets/core_concepts/counter_event.dart.md ':include')

今回の場合はevent を`enum`を使って表現できますが、より複雑なevent やevent に乗せて情報を bloc に送る場合は`class`を作ります。

ここまでできたら人生最初の最初のevent 定義が終わりです！まだ Bloc も出てきてないですし、特に何も起こってないですよね。ただの Dart のコードです。

## State

> State は Bloc のアウトプットで、アプリのUIの一つの状態を表します。UIはこの state の変化を受けて再描画をします。

ここまででアプリ内で使われる `CounterEvent.increment` と `CounterEvent.decrement` の二つの event を定義しました。

今度はアプリ内の state (状態)を定義していきましょう。

今はカウンターアプリを作っているので、state はとてもシンプル： 今のカウントを示すただの int 型の値一つだけです。

後ほどより複雑な例を見ていきますが、今回のアプリではシンプルな値一つだけで十分です。

## Transition

> 一つの state から異なる別の state への変化を transition と呼びます。Transition は一つ前の state と後の state から成り立ちます。

ユーザーがアプリを操作し、`Increment` や `Decrement` event を発火させるとカウンターの state が変化します。このような state の変化は連続した transition で表すことができます。

例えば、もしユーザーがアプリを開き、値を増やすボタンを一回タップした時には下記のような `Transition` が発生します。

[counter_increment_transition.json](../_snippets/core_concepts/counter_increment_transition.json.md ':include')

全ての state の変化が記録されているので、アプリケーションの中で何が起こっているかを簡単に把握することができることに加え、「時を遡って」デバッグをすることも可能になります。

## Stream

?> `Stream`についてまだ詳しく知らない方はまず公式のドキュメンテーションを読むことをお勧めします [Dart Documentation](https://dart.dev/tutorials/language/streams)

> ストリームとは連続的な非同期データです。

Bloc は内部で[RxDart](https://pub.dev/packages/rxdart)を使って作られています。しかし、`RxDart`の詳細な部分は Bloc のAPIの中に内包されています。

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

> A Bloc (Business Logic Component) is a component which converts a `Stream` of incoming `Events` into a `Stream` of outgoing `States`. Think of a Bloc as being the "brains" described above.

> Every Bloc must extend the base `Bloc` class which is part of the core bloc package.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_class.dart.md ':include')

In the above code snippet, we are declaring our `CounterBloc` as a Bloc which converts `CounterEvents` into `ints`.

> Every Bloc must define an initial state which is the state before any events have been received.

In this case, we want our counter to start at `0`.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_initial_state.dart.md ':include')

> Every Bloc must implement a function called `mapEventToState`. The function takes the incoming `event` as an argument and must return a `Stream` of new `states` which is consumed by the presentation layer. We can access the current bloc state at any time using the `state` property.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_map_event_to_state.dart.md ':include')

At this point, we have a fully functioning `CounterBloc`.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

!> Blocs will ignore duplicate states. If a Bloc yields `State nextState` where `state == nextState`, then no transition will occur and no change will be made to the `Stream<State>`.

At this point, you're probably wondering _"How do I notify a Bloc of an event?"_.

> Every Bloc has a `add` method. `Add` takes an `event` and triggers `mapEventToState`. `Add` may be called from the presentation layer or from within the Bloc and notifies the Bloc of a new `event`.

We can create a simple application which counts from 0 to 3.

[main.dart](../_snippets/core_concepts/counter_bloc_main.dart.md ':include')

!> By default, events will always be processed in the order in which they were added and any newly added events are enqueued. An event is considered fully processed once `mapEventToState` has finished executing.

The `Transitions` in the above code snippet would be

[counter_bloc_transitions.json](../_snippets/core_concepts/counter_bloc_transitions.json.md ':include')

Unfortunately, in the current state we won't be able to see any of these transitions unless we override `onTransition`.

> `onTransition` is a method that can be overridden to handle every local Bloc `Transition`. `onTransition` is called just before a Bloc's `state` has been updated.

?> **Tip**: `onTransition` is a great place to add bloc-specific logging/analytics.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

Now that we've overridden `onTransition` we can do whatever we'd like whenever a `Transition` occurs.

Just like we can handle `Transitions` at the bloc level, we can also handle `Exceptions`.

> `onError` is a method that can be overriden to handle every local Bloc `Exception`. By default all exceptions will be ignored and `Bloc` functionality will be unaffected.

?> **Note**: The stacktrace argument may be `null` if the state stream received an error without a `StackTrace`.

?> **Tip**: `onError` is a great place to add bloc-specific error handling.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

Now that we've overridden `onError` we can do whatever we'd like whenever an `Exception` is thrown.

## BlocDelegate

One added bonus of using Bloc is that we can have access to all `Transitions` in one place. Even though in this application we only have one Bloc, it's fairly common in larger applications to have many Blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocDelegate`.

[simple_bloc_delegate.dart](../_snippets/core_concepts/simple_bloc_delegate.dart.md ':include')

?> **Note**: All we need to do is extend `BlocDelegate` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocDelegate`, we just need to tweak our `main` function.

[main.dart](../_snippets/core_concepts/simple_bloc_delegate_main.dart.md ':include')

If we want to be able to do something in response to all `Events` added, we can also override the `onEvent` method in our `SimpleBlocDelegate`.

[simple_bloc_delegate.dart](../_snippets/core_concepts/simple_bloc_delegate_on_event.dart.md ':include')

If we want to be able to do something in response to all `Exceptions` thrown in a Bloc, we can also override the `onError` method in our `SimpleBlocDelegate`.

[simple_bloc_delegate.dart](../_snippets/core_concepts/simple_bloc_delegate_complete.dart.md ':include')

?> **Note**: `BlocSupervisor` is a singleton which oversees all Blocs and delegates responsibilities to the `BlocDelegate`.
