# 核心思想

?> 使用前请确保仔细阅读并理解以下部分 [bloc](https://pub.dev/packages/bloc).

有几个核心概念对于理解如何使用Bloc至关重要。

在接下来的部分中，我们将详细讨论它们中的每一个，并逐步研究它们是如何应用于实际应用程序，例如：计数器应用程序。

## 流（Streams)

?> 查看官方文档 [Dart Documentation](https://dart.dev/tutorials/language/streams) 以获取更多关于流（`Streams`) 的信息.

> 流（Stream) 是`一系列异步`的数据.

为了使用Bloc，对 `Streams` 及其工作方式有扎实的了解是`十分必要的`。

> 如果您不熟悉`Streams`，请试着想象一个_有水流过的管道_。管道是“流”（`Stream`)，管道里的水是`异步的数据`.

We can create a `Stream` in Dart by writing an `async*` (async generator) function.

我们可以通过编写 `async *` (异步生成器) 方法在Dart中创建一个 `Stream`。

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

通过将一个函数标记为 `async *`，我们可以使用 `yield` 作为关键字并返回 `Stream` 数据。在上面的示例中，我们返回的是一个不超过整数Int边界的整数Stream。

每次我们在 `async *` 函数中 `yield` 时，我们都会通过 `Stream` 推送该数据。

我们可以通过几种方式使用上面的`Stream`。如果我们想编写一个函数来返回所有整数 `Stream` 的总和，则它可能类似于：

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

通过将上面的函数标记为 `async`，我们可以使用 `await` 关键字并返回整数的 `Future` 数据。在此示例中，我们先等待流(`Stream`)中的每个值然后再返回流(`Stream`)中所有整数的总和。

我们可以像这样将它们放在一起：

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

现在我们对 Dart 中的 `Stream` 已经有了一个基本的了解，下一步我们将学习更多关于 `bloc` 库中的核心模块: `Cubit`。

## Cubit

> `Cubit` 是 `Stream` 的一种特殊类型，用作 `Bloc` 类的基础（稍后将做详细介绍）。

![Cubit Architecture](../assets/cubit_architecture_full.png)

一个 `Cubit` 可以公开触发状态变化的函数。

>状态是从 `Cubit` 中输出的，代表应用程序状态的一部分。可以通知UI组件状态，并根据当前状态重绘其自身的某些部分。
> States are the output of a `Cubit` and represent a part of your application's state. UI components can be notified of states and redraw portions of themselves based on the current state.

> **提示**: 有关 `Cubit` 来源的更多信息请查看 [以下 Github Issue](https://github.com/felangel/cubit/issues/69).

### 创建一个 Cubit

我们可以像这样创建一个 `CounterCubit`：

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
}
```

创建 `Cubit` 时，我们需要定义 `Cubit` 将要管理的状态类型。对于上面的 `CounterCubit`，状态可以通过 `int` 来表示，但在更复杂的情况下，可能有必要使用 `class`（类）而不是原始类型。

创建 `Cubit` 时，我们需要做的第二件事是指定初始状态。我们可以通过使用初始状态的值调用 `super` 来实现。在上面的代码段中，我们在内部将初始状态设置为0，但我们也可以通过接受外部值来使 `Cubit` 更加灵活：

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit(int initialState) : super(initialState);
}
```

这将允许我们实例化具有不同初始状态的 `CounterCubit` 实例，例如：

```dart
final cubitA = CounterCubit(0); // 状态从 0 开始
final cubitB = CounterCubit(10); // 状态从 10 开始
```

### 状态变化

> 每个 `Cubit` 都有能力通过 `emit` 输出一个新状态。

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
```

在上面的代码片段中，`CounterCubit` 公开了一个名为 `increment` 的公共方法，可以从外部调用该方法，以通知`CounterCubit` 增加其状态。当调用 `increment` 时，我们可以通过 `state` 获取器访问 `Cubit` 的当前状态，并通过向当前状态加 `1` 来发出 `emit` 新状态。

!> `emit` 函数受到保护，这意味着它只能在 `Cubit` 内部使用。

### 使用 Cubit

现在，我们可以使用已经实现的 `CounterCubit`！

#### 基础用例

```dart
void main() {
  final cubit = CounterCubit();
  print(cubit.state); // 0
  cubit.increment();
  print(cubit.state); // 1
  cubit.close();
}
```

在上面的代码片段中，我们首先创建一个 `CounterCubit` 实例。然后，我们打印 `Cubit` 的当前状态，即初始状态（因为尚未发出新状态）。接下来，我们调用 `increment` 函数来触发状态更改。最后，我们再次打印从 `0` 到 `1` 的 `Cubit` 的状态，然后关闭 `Cubit` 以关闭内部状态流。

#### 流的用例

由于 `Cubit` 是 `Stream` 的一种特殊类型，我们还可以订阅 `Cubit` 来实时更新其状态：

```dart
Future<void> main() async {
  final cubit = CounterCubit();
  final subscription = cubit.listen(print); // 1
  cubit.increment();
  await Future.delayed(Duration.zero);
  await subscription.cancel();
  await cubit.close();
}
```

在上面的代码段中，我们正在订阅 `CounterCubit`，并在每次状态更改时调用 `print` 函数。然后，我们调用 `increment` 函数，它将发出一个新状态。最后，当我们不再希望接收更新并关闭 `Cubit` 时，我们在 `subscription` 上调用 `cancel`。

> **提示**: 在此示例中，添加了 `await Future.delayed（Duration.zero)`，以避免立即取消订阅。

！>在 `Cubit` 上调用 `listen` 时，将仅接收后续状态更改

### 观察 Cubit

>当 `Cubit` 发出新状态时，将有一个 `改变` 发生。我们可以通过覆盖 `onChange` 来观察给定 `Cubit` 的所有变化。

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print(change);
  }
}
```

然后，我们可以与 `Cubit` 交互并观察所有输出到控制台的更改。

```dart
void main() {
  CounterCubit()
    ..increment()
    ..close();
}
```

上面的示例将输出的结果：

```sh
Change { currentState: 0, nextState: 1 }
```

？> **注意**：在 `Cubit` 状态更新之前发生 `Change` 更改。一个 `变更` 由 `currentState` 和 `nextState` 组成。

#### BlocObserver (Bloc观察者)

使用 `bloc` 库的另一个好处是，我们可以在一处访问所有 `变化`。即使在此应用程序中只有一个 `Cubit`，在大型应用程序中也很常见，有许多 `Cubits` 管理应用程序状态的不同部分。

如果我们希望能够对所有 `变化` 做出响应，我们可以简单地创建自己的 `BlocObserve` (Bloc观察者)来观察变化。

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
```

？> **注意**：我们要做的就是扩展 `BlocObserver` 并覆盖 `onChange` 方法。

为了使用 `SimpleBlocObserver`，我们只需要调整 `main` 函数：

```dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  CounterCubit()
    ..increment()
    ..close();
}
```

上面的代码段将输出的结果：

```sh
Change { currentState: 0, nextState: 1 }
CounterCubit Change { currentState: 0, nextState: 1 }
```

？> **注意**：首先调用内部的 `onChange` 替代，然后在 `BlocObserver` 中调用 `onChange`。


?> **提示**: 在 `BlocObserver` 中，除了 `变化` 本身之外，我们还可以访问 `Cubit` 实例。


### 错误处理

> 每个 `Cubit` 都有一个` addError` 方法，该方法可用于指示发生了错误。

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() {
    addError(Exception('increment error!'), StackTrace.current);
    emit(state + 1);
  }

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
```

?> **注意**：`onError` 可以在 `Cubit` 中被覆盖，以处理特定 `Cubit` 的所有错误。

也可以在 `BlocObserver` 中覆盖 `onError` 以全局处理所有报告的错误。

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
```

如果我们再次运行同一程序，我们应该看到以下输出结果：

```sh
Exception: increment error!, #0      CounterCubit.increment (file:///main.dart:21:56)
#1      main (file:///main.dart:41:7)
#2      _startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:301:19)
#3      _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:168:12)

CounterCubit Exception: increment error! #0      CounterCubit.increment (file:///main.dart:21:56)
#1      main (file:///main.dart:41:7)
#2      _startIsolate.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:301:19)
#3      _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:168:12)

Change { currentState: 0, nextState: 1 }
CounterCubit Change { currentState: 0, nextState: 1 }
```

?> **注意**：与 `onChange` 一样，内部 `onError` 覆盖在全局 `BlocObserver` 覆盖之前被调用。

## Bloc

> `Bloc` 是 `Cubit` 的一种特殊类型，可将传入事件转换为传出状态。

![Bloc 构架](../assets/bloc_architecture_full.png)

### 创建一个 Bloc

创建一个 `Bloc` 类似于创建一个 `Cubit`，除了定义我们将要管理的状态外，我们还必须定义 `Bloc` 使其能够处理事件。

> 事件是将输入进 `Bloc` 中。通常是为了响应用户交互（例如按钮按下）或生命周期事件（例如页面加载）而添加它们。

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}
```

就像创建 `CounterCubit` 一样，我们必须指定初始状态，方法是通过 `super` 将其传递给 `superclass` (超类)。

### 状态改变

与创建 `CounterCubit` 时不同，我们不需要覆盖 `mapEventToState`，而是定义触发状态变化的函数。这将负责将任何传入事件转换为一个或多个传出状态。

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {}
}
```

?> **提示**：`async *`表示该函数是一个[异步生成器]（https://dart.dev/guides/language/language-tour#generators），可以通过 `yield发出状态` 关键字。

然后我们可以更新 `mapEventToState` 来处理 `CounterEvent.increment` 事件：

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

在上面的代码片段中，我们打开了传入事件，如果它是一个增量事件，我们将产生一个新状态（类似于 `emit` ）。

?> **注意**：由于 `Bloc` 类扩展了 `Cubit`，因此我们可以随时通过 `state` getter 来访问 `bloc` 的当前状态。

!> Bloc 永远不要直接发出新状态。相反，必须响应 `mapEventToState` 中的传入事件，输出每个状态更改。

!> Bloc 和 Cubits 都会忽略重复的状态。如果我们产生或发出状态 `State nextState` 当 `State == nextState` 时，则不会发生状态变化。

### 使用 Bloc

至此，我们可以创建 `CounterBloc` 的实例并将其使用！

#### 基础用例

```dart
Future<void> main() async {
  final bloc = CounterBloc();
  print(bloc.state); // 0
  bloc.add(CounterEvent.increment);
  await Future.delayed(Duration.zero);
  print(bloc.state); // 1
  await bloc.close();
}
```

在上面的代码片段中，我们首先创建一个 `CounterBloc` 实例。然后，我们打印` Bloc` 的当前状态，该状态为初始状态（因为尚未发出新状态）。接下来，我们添加增量事件以触发状态更改。最后，我们再次打印从 0 到 1 的 Bloc 状态，然后关闭 Bloc 以关闭内部状态流。

?> **注意**：添加了` await Future.delayed（Duration.zero` 以确保我们等待下一个事件循环迭代（允许 `mapEventToState` 处理增量事件）。

#### Stream（流）的用例

就像 `Cubit` 一样，`Bloc` 是 `Stream` 的一种特殊类型，这意味着我们还可以订阅 `Bloc` 来实时更新其状态：

```dart
Future<void> main() async {
  final bloc = CounterBloc();
  final subscription = bloc.listen(print); // 1
  bloc.add(CounterEvent.increment);
  await Future.delayed(Duration.zero);
  await subscription.cancel();
  await bloc.close();
}
```

在以上代码段中，我们正在订阅 `CounterBloc`，并在每次状态更改时调用 print 函数。然后，我们添加增量事件，该事件触发 `mapEventToState` 并产生一个新状态。最后，当我们不再希望接收更新并关闭` Bloc` 时，我们在订阅上调用了 `cancel`。

?> **注意**：在此示例中添加了 `await Future.delayed（Duration.zero`，以避免立即取消订阅。

### 观察 Bloc

由于所有 `Bloc` 都扩展了` Cubit` （意味着所有 `Bloc` 也是 `Cubit`），因此我们可以使用 `onChange` 观察` Bloc` 的所有状态变化。

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print(change);
  }
}
```

接下来我们可以将 `main.dart` 更新为：

```dart
void main() {
  CounterBloc()
    ..add(CounterEvent.increment)
    ..close();
}
```

现在，如果我们运行上面的代码片段，输出将是：

```sh
Change { currentState: 0, nextState: 1 }
```

`Bloc` 和 `Cubit` 之间的主要区别因素是，由于 `Bloc` 是事件驱动的，因此我们也能够捕获有关触发状态更改的信息。

我们可以通过覆盖 `onTransition` 来做到这一点。

> 从一种状态到另一种状态的转换称为 `Transition`。`Transition` 由当前状态，事件和下一个状态组成

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print(change);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    print(transition);
  }
}
```

如果然后从前重新运行相同的 `main.dart` 代码段，则应看到以下输出：

```sh
Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
Change { currentState: 0, nextState: 1 }
```

?> **注意**：`onTransition` 在 `onChange` 之前被调用，并且包含触发从 `currentState` 到 `nextState` 改变的事件。

#### BlocObserver (Bloc观察者)

和以前一样，我们可以在自定义 `BlocObserver` 中覆盖` onTransition`，以观察从一个位置发生的所有过渡。

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
```

我们可以像之前一样初始化 `SimpleBlocObserver`：

```dart
void main() {
  Bloc.observer = SimpleBlocObserver();
  CounterBloc()
    ..add(CounterEvent.increment)
    ..close();
}
```

现在，如果我们运行上面的代码片段，输出应如下所示：

```sh
Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
CounterBloc Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
Change { currentState: 0, nextState: 1 }
CounterBloc Change { currentState: 0, nextState: 1 }
```

?> **注意**：首先调用 `onTransition`（在全局之前先于本地），然后调用 `onChange`。

`Bloc` 实例的另一个独特功能是，它们使我们能够覆盖 `onEvent`，无论何时将新事件添加到 `Bloc` 都会调用 `onEvent`。就像 `onChange` 和 `onTransition` 一样，`onEvent` 可以在本地或全局覆盖。

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onEvent(CounterEvent event) {
    super.onEvent(event);
    print(event);
  }

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print(change);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    print(transition);
  }
}
```

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }
}
```

我们可以像以前一样运行相同的 `main.dart`，并且应该看到以下输出：

```sh
CounterEvent.increment
CounterBloc CounterEvent.increment
Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
CounterBloc Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
Change { currentState: 0, nextState: 1 }
CounterBloc Change { currentState: 0, nextState: 1 }
```

?> **注意**：一旦添加事件，就会调用 `onEvent`。本地 `onEvent` 在 `BlocObserver``中的全局 `onEvent` 之前被调用。

### 错误处理

就像 `Cubit` 一样，每个 `Bloc` 都有一个 `addError` 和 `onError` 方法。我们可以通过从 `Bloc` 内部的任何地方调用 `addError` 来表明发生了错误。然后我们可以像覆盖 `Cubit` 一样通过覆盖 `onError` 来对所有错误做出反应。

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        addError(Exception('increment error!'), StackTrace.current);
        yield state + 1;
        break;
    }
  }

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print(change);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}
```

如果我们重新运行与以前相同的 `main.dart`，我们可以看到报告错误时的样子：

```sh
Exception: increment error!, #0      CounterBloc.mapEventToState (file:///main.dart:55:60)
<asynchronous suspension>
#1      Bloc._bindEventsToStates.<anonymous closure> (package:bloc/src/bloc.dart:232:20)
#2      Stream.asyncExpand.onListen.<anonymous closure> (dart:async/stream.dart:579:30)
#3      _RootZone.runUnaryGuarded (dart:async/zone.dart:1374:10)
#4      _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:339:11)
#5      _DelayedData.perform (dart:async/stream_impl.dart:594:14)
#6      _StreamImplEvents.handleNext (dart:async/stream_impl.dart:710:11)
#7      _PendingEvents.schedule.<anonymous closure> (dart:async/stream_impl.dart:670:7)
#8      _microtaskLoop (dart:async/schedule_microtask.dart:43:21)
#9      _startMicrotaskLoop (dart:async/schedule_microtask.dart:52:5)
#10     _runPendingImmediateCallback (dart:isolate-patch/isolate_patch.dart:118:13)
#11     _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:169:5)

CounterBloc Exception: increment error! #0      CounterBloc.mapEventToState (file:///main.dart:55:60)
<asynchronous suspension>
#1      Bloc._bindEventsToStates.<anonymous closure> (package:bloc/src/bloc.dart:232:20)
#2      Stream.asyncExpand.onListen.<anonymous closure> (dart:async/stream.dart:579:30)
#3      _RootZone.runUnaryGuarded (dart:async/zone.dart:1374:10)
#4      _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:339:11)
#5      _DelayedData.perform (dart:async/stream_impl.dart:594:14)
#6      _StreamImplEvents.handleNext (dart:async/stream_impl.dart:710:11)
#7      _PendingEvents.schedule.<anonymous closure> (dart:async/stream_impl.dart:670:7)
#8      _microtaskLoop (dart:async/schedule_microtask.dart:43:21)
#9      _startMicrotaskLoop (dart:async/schedule_microtask.dart:52:5)
#10     _runPendingImmediateCallback (dart:isolate-patch/isolate_patch.dart:118:13)
#11     _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:169:5)

Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
CounterBloc Transition { currentState: 0, event: CounterEvent.increment, nextState: 1 }
Change { currentState: 0, nextState: 1 }
CounterBloc Change { currentState: 0, nextState: 1 }
```

?> **注意**：首先调用本地 `onError`，然后调用 `BlocObserver` 中的全局​​ `onError`。

?> **注意**：对于 `Bloc` 和 `Cubit` 实例，`onError` 和 `onChange` 的工作方式完全相同。

!> 在 `mapEventToState` 中发生的任何未处理的异常也会报告给 `onError`。

## Cubit vs. Bloc

既然我们已经介绍了 `Cubit` 和 `Bloc` 类的基础知识，您可能想知道何时应该使用 `Cubit` 和何时使用 `Bloc`。

### Cubit 的优势

#### 简单

使用 `Cubit` 的最大优点之一就是简单性。当创建一个 `Cubit` 时，我们只需要定义状态以及我们想要公开的改变状态的函数即可。相比之下，创建 `Bloc` 时，我们必须定义状态，事件和 `mapEventToState` 实现。这使得 `Cubit` 更容易理解，并且涉及的代码更少。

现在让我们看一下两个计数器实现：

##### CounterCubit

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
```

##### CounterBloc

```dart
enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

`Cubit` 的实现更加简洁，这些函数就像事件一样，而不是分别定义事件。另外，当使用 `Cubit` 时，我们不必使用异步生成器（`async *`）或对 `yield` 和 `yield *` 关键字有深入的了解，因为我们可以简单地从在任何地方触发状态更改

### Bloc 的优势

#### 可追溯性

使用 `Bloc` 的最大优势之一就是知道状态变化的顺序以及触发这些变化的确切原因。对于对于应用程序功能至关重要的状态，使用更多事件驱动的方法来捕获状态变化之外的所有事件可能会非常有益。

一个常见的用例可能是管理 `AuthenticationState`。为了简单起见，假设我们可以通过 `enum` 来表示 `AuthenticationState`：

```dart
enum AuthenticationState { unknown, authenticated, unauthenticated }
```

关于应用程序的状态可能从 `authenticated` 更改为 `unauthenticated `的原因可能有很多原因。例如，用户可能点击了一个注销按钮，并要求退出该应用程序。另一方面，也许用户的访问令牌已被撤消，并被强制注销。当使用 `Bloc` 时，我们可以清楚地跟踪应用程序状态如何达到特定状态。

```sh
Transition {
  currentState: AuthenticationState.authenticated,
  event: LogoutRequested,
  nextState: AuthenticationState.unauthenticated
}
```

上面的 `转换` 为我们提供了了解状态发生变化的所有信息。如果我们使用 `Cubit` 来管理 `AuthenticationState`，那么我们的日志将如下所示：

```sh
Change {
  currentState: AuthenticationState.authenticated,
  nextState: AuthenticationState.unauthenticated
}
```

这告诉我们用户已注销，但没有说明为什么这对于调试和了解应用程序状态随时间的变化可能至关重要。

#### 高级ReactiveX操作

`Bloc` 优于 `Cubit` 的另一个领域是我们需要利用反应性运算符，例如 `buffer，debounceTime，throttle` 等。

`Bloc` 有一个事件接收器，它使我们能够控制和转换事件的传入流。

例如，如果我们正在构建一个实时搜索，我们可能希望对后端的请求进行反跳操作，以避免受到速率限制以及降低后端的成本/负载。

使用 `Bloc`，我们可以覆盖 `transformEvents`，以改变 `Bloc` 处理传入事件的方式。

```dart
@override
Stream<Transition<CounterEvent, int>> transformEvents(
  Stream<CounterEvent> events,
  TransitionFunction<CounterEvent, int> transitionFn,
) {
  return super.transformEvents(
    events.debounceTime(const Duration(milliseconds: 300)),
    transitionFn,
  );
}
```

使用以上代码，我们可以用很少的其他代码轻松地对进入的事件进行反跳。

?> **提示**：如果仍然不确定要使用哪种，请从 `Cubit` 开始，然后可以根据需要将其重构或放大为 `Bloc`。