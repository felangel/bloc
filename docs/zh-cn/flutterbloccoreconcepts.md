# Flutter Bloc的核心理念

?> 使用前请确保仔细阅读并理解以下部分 [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** 是一个Flutter部件(`Widget`)，它需要`Bloc`和`builder`两个方法。处理构建部件用来响应新的状态(`State`)。`BlocBuilder` 与 `StreamBuilder`十分相像，但是它有一个简单的接口来减少一部分必须的模版代码。`builder`方法会被潜在的触发很多次并且应该是一个返回一个部件(`Widget`)以响应该状态(`State`)的[纯方法](https://en.wikipedia.org/wiki/Pure_function)

如果要响应状态(`State`)更改（例如导航，显示对话框等) 而执行任何操作，请参见`BlocListener`。

如果省略了bloc中的参数，则`BlocBuilder`将使用`BlocProvider`和当前的`BuildContext`自动执行查找。

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // 根据BlocA的状态（State) 在这里返回一个组件（widget)
  }
)
```
仅当您希望提供一个范围仅限于单个部件(widget)且无法通过父代`BlocProvider`和当前`BuildContext`访问的块时，才指定Bloc。

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // 提供一个本地的实例
  builder: (context, state) {
    // 根据BlocA的状态（State) 在这里返回一个部件（widget)
  }
)
```

如果您希望对何时调用builder函数的时间进行十分缜密的控制，可以向`BlocBuilder`提供可选的条件（condition) 。条件（condition)获取先前的Bloc的状态和当前的bloc的状态并返回bool值。如果condition返回true，将使用`state`调用`builder`，并且部件(widget)将重新构建。如果`condition`返回false，则不会用`state`调用`builder`，也不会进行重建。

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // 返回 true/false 来决定
    // 是否重建部件（widget) 和状态（state)
  },
  builder: (context, state) {
    // 在这里根据BlocA的状态（state) 来返回部件（widget)
  }
)
```

### BlocProvider

**BlocProvider** 是Flutter部件(widget)，可通过`BlocProvider.of <T>（context)`向其子级提bloc。它被作为依赖项注入（DI)部件(widget)，以便可以将一个bloc的单个实例提供给子树中的多个部件(widgets)。

在大多数情况下，应该使用`BlocProvider`来创建新的`blocs`，并将其提供给其余子树。在这种情况下，由于`BlocProvider`负责创建bloc，它将自动处理关闭bloc。
```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

在某些情况下，`BlocProvider`可用于向部件树(widget tree)的新部分提供现有的bloc。当需要将现有的`bloc`提供给新路线时，这将是最常用的。在这种情况下，`BlocProvider`不会自动关闭该bloc，因为它没有创建它。
```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

然后从`ChildA`或`ScreenA`中，我们可以通过以下方式检索`BlocA`：

```dart
// with extensions
context.bloc<BlocA>();

// without extensions
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider

**MultiBlocProvider** 是Flutter部件(widget)，将多个`BlocProvider`部件合并为一个。
`MultiBlocProvider`提高了可读性，并且消除了嵌套多个`BlocProviders`的需要。
通过使用`MultiBlocProvider`，我们可以从：

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

变为:

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

**BlocListener** 是Flutter部件（widget)，它接受一个`BlocWidgetListener`和一个可选的`Bloc`，并调用`listener`以响应该状态(state)的变化。它应用于每次状态更改都需要发生一次的功能，例如导航，显示`SnackBar`，显示`Dialog`等。

与`BlocBuilder`中的`builder`不同，每个状态(State)更改（**不包括** `initialState`在内的) 仅被调用一次`listener`，并且是一个`void`函数。

如果省略了bloc参数，则`BlocListener`将使用`BlocProvider`和当前的`BuildContext`自动执行查找。
```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // 在这里根据BlocA的状态（State) 来写
  },
  child: Container(),
)
```

仅当您无法通过`BlocProvider`和当前的`BuildContext`访问的bloc时，才指定bloc。

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // 根据BlocA的状态（State) 来写
  }
)
```

如果您希望对任何时候调用监听器的函数进行十分缜密的控制，则可以向`BlocListener`提供可选的条件（condition) 。 条件（condition) 获取先前的bloc的状态（State) 和当前的bloc的状态（State) 并返回bool值。如果条件（condition) 返回true，listener将被state调用。如果条件返回false，则不会使用状态调用`listener`。

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // 返回 true或者false来决定
    // 是否调用listener和状态（State)
  },
  listener: (context, state) {
    // 根据BlocA的状态（State) 来写
  }
  child: Container(),
)
```

### MultiBlocListener

**MultiBlocListener** 是Flutter的部件（widget)，将多个`BlocListener`部件合并为一个。
`MultiBlocListener`可以提高可读性，并且不需要嵌套多个`BlocListeners`。
通过使用`MultiBlocListener`，我们可以从：

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

变为:

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

**BlocConsumer** 公开一个`builder`和`listener`以便对新状态(State)做出反应。`BlocConsumer`与嵌套的`BlocListener`和`BlocBuilder`类似，但是减少了所需的样板代码的数量。仅在有必要重建UI并执行其他反应来声明`bloc`中的状态(State)更改时，才应使用`BlocConsumer`。 `BlocConsumer`需要一个必需的`BlocWidgetBuilder`和`BlocWidgetListener`，以及一个可选的`bloc`，`BlocBuilderCondition`和`BlocListenerCondition`。

如果省略`bloc`参数，则`BlocConsumer`将使用以下命令自动执行查找`BlocProvider`和当前的`BuildContext`。

```dart
BlocConsumer<BlocA, BlocAState>(
  listener: (context, state) {
    // 根据BlocA的状态（State) 来写
  },
  builder: (context, state) {
    // 根据BlocA的状态（State) 返回一个部件（widget)
  }
)
```

可以实现可选的`listenWhen`和`buildWhen`，以更精细地控制何时调用`listener`和`builder`。在每次`bloc`状态(State)改变时，都会调用`listenWhen`和`buildWhen`。它们各自采用先前的状态(`State`)和当前的状态(`State`)，并且必须返回“bool”，该bool确定是否将调用构建器和/或监听器功能。当初始化`BlocConsumer`时，先前的状态(`State`)将被初始化为`bloc`的状态(`State`)。 `listenWhen`和` buildWhen`是可选的，如果未实现，则默认为`true`。
```dart
BlocConsumer<BlocA, BlocAState>(
  listenWhen: (previous, current) {
    // 返回 true或者false来决定
    // 是否调用listener和状态（State)
  },
  listener: (context, state) {
    // 根据BlocA的状态（State) 来写
  },
  buildWhen: (previous, current) {
    // 返回 true或者false来决定
    // 是否重建部件（widget) 和状态（State)
   
  },
  builder: (context, state) {
    // 根据BlocA的状态（State) 返回一个部件（widget)
  }
)
```

### RepositoryProvider

**RepositoryProvider** 是Flutter部件(widget)，可通过`RepositoryProvider.of <T>（context)`向其子级提供存储库。它用作依赖项注入（DI) 部件（widget)，以便可以将存储库的单个实例提供给子树中的多个部件(widgets)。 `BlocProvider`用于提供bloc，而`RepositoryProvider`仅用于存储库。

```dart
RepositoryProvider(
  create: (context) => RepositoryA(),
  child: ChildA(),
);
```

然后，我们可以从`ChildA`检索以下内容的`Repository`实例:

```dart
// with extensions
context.repository<RepositoryA>();

// without extensions
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider** 是Flutter部件(widget)，将多个`RepositoryProvider`部件(widgets)合并为一个。
`MultiRepositoryProvider`可以提高可读性，并且不需要嵌套多个`RepositoryProvider`。

通过使用`MultiRepositoryProvider` 我们可以从原来的:

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

变为:

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

## 用例（Usage)

让我们看一下如何使用`BlocBuilder`将`CounterPage`部件(widget)连接到`CounterBloc`。

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

至此，我们已经成功地将表示层（Presentation) 与业务逻辑层分离了。请注意，`CounterPage`部件(widget)对用户点击按钮时会发生的情况一无所知。窗口小部件只是告诉`CounterBloc`用户已按下了加号或减号按钮。
