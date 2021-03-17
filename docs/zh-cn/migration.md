# 迁移指南

?> **提示**: 请参考 [发布日志](https://github.com/felangel/bloc/releases) 以获取有关每个版本中更改内容的更多信息。

## v6.1.0

### package:flutter_bloc

#### ❗context.bloc 和 context.repository 已不再推荐使用，目前推荐使用 context.read 和 context.watch

##### 基本原理

`context.read`, `context.watch`, and `context.select` 被添加，以与许多开发人员熟悉的现有[provider]（https://pub.dev/packages/provider）API保持一致，并解决社区提出的问题。为了提高代码的安全性并保持一致性，不赞成使用 `context.bloc`，因为可以将其替换为 `context.read` 或 `context.watch`，具体取决于是否直接在build中使用。

**context.watch**

`context.watch` 解决了拥有[MultiBlocBuilder]（https://github.com/felangel/bloc/issues/538）的请求，因为我们可以在单个 `Builder` 中观察多个bloc，以便基于多种状态：

```dart
Builder(
  builder: (context) {
    final stateA = context.watch<BlocA>().state;
    final stateB = context.watch<BlocB>().state;
    final stateC = context.watch<BlocC>().state;

    // 返回一个依赖于 BlocA，BlocB 和 BlocC 状态的 Widget
  }
);
```

**context.select**


`context.select` 允许开发人员根据整体状态的一部分来呈现/更新UI，并解决具有[更简单的buildWhen]（https://github.com/felangel/bloc/issues/1521）的请求。

```dart
final name = context.select((UserBloc bloc) => bloc.state.user.name);
```

上面的代码片段仅在当前用户名更改时允许我们访问和重建部件。

**context.read**

即使看起来 `context.read` 与 `context.bloc` 相同，也存在一些细微但重要的差异。两者都允许您使用`BuildContext` 访问 bloc，并且不会导致重建；但是，不能直接在 build 方法中调用 `context.read`。在`build` 中使用 `context.bloc` 的主要原因有两个：

1. **访问 Bloc 中的的状态**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

上面的用法容易出错，因为如果集团的状态发生变化，`Text` 部件将不会重建。在这种情况下，应该使用 ` BlocBuilder` 或 `context.watch`。

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

或者

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) => Text('$state'),
  );
}
```

!> 在 `build` 方法的根部使用 `context.watch` 会导致当状态改变时整个窗口部件被重建。如果不需要重建整个窗口小部件，请使用 `BlocBuilder` 包装应该重建的部分，或者将 `Builder` 和 `context.watch` 一起使用以限制重建范围，或者部件分解为较小的部件。

1. **访问 Bloc 以便可以添加事件**

```dart
@override
Widget build(BuildContext context) {
  final bloc = context.bloc<MyBloc>();
  return ElevatedButton(
    onPressed: () => bloc.add(MyEvent()),
    ...
  )
}
```

上面的用法效率低下，因为当仅在用户点击 `ElevatedButton` 时才需要该 `bloc` 时，这会导致在每次重建时对块进行查找。在这种情况下，最好使用 `context.read` 在需要的地方直接访问该块（在这种情况下，在 `onPressed` 回调中）。

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

**总结**

**v6.0.x**

```dart
@override
Widget build(BuildContext context) {
  final bloc = context.bloc<MyBloc>();
  return ElevatedButton(
    onPressed: () => bloc.add(MyEvent()),
    ...
  )
}
```

**v6.1.x**

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

?> 如果要访问 Bloc 添加事件，请在需要回调的回调中使用 `context.read` 执行 Bloc 访问。

**v6.0.x**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

**v6.1.x**

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

?> 访问 Bloc 的状态时，请使用 `context.watch`，以确保状态更改时重新构建部件。

## v6.0.0

### package:bloc

#### ❗BlocObserver onError 接受 Cubit

##### 基本原理

由于 `Cubit` 的集成，现在 `onBloc` 和 `Cubit` 实例之间共享 `onError`。由于 `Cubit` 是基础，因此 `onError` 替代中的 `BlocObserver` 将接受 `Cubit` 类型而不是 `Bloc` 类型。

**v5.x.x**

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}
```

**v6.0.0**

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    super.onError(cubit, error, stackTrace);
  }
}
```

#### ❗Bloc不会在订阅时发出最后状态

##### 基本原理

进行此更改是为了将 `Bloc` 和 `Cubit` 与` Dart` 中内置的 `Stream` 行为对齐。此外，在 `Cubit` 环境中遵循此旧行为会导致许多意想不到的副作用，并不必要地使其他软件包（例如 `Flutter_bloc` 和 `bloc_test`）的内部实现复杂化（要求 `skip(1)`，等等...）。

**v5.x.x**

```dart
final bloc = MyBloc();
bloc.listen(print);
```

以前，以上代码段将输出 Bloc 的初始状态，然后输出随后的状态更改。

**v6.x.x**

在 v6.0.0 中，以上代码段不输出初始状态，而仅输出后续状态更改。可以通过以下方式实现以前的行为：

```dart
final bloc = MyBloc();
print(bloc.state);
bloc.listen(print);
```

?> **注意**: 此更改将仅影响依赖于直接团体订阅的代码。使用 `BlocBuilder`，`BlocListener` 或 `BlocConsumer` 时，行为不会有明显变化。

### package:bloc_test

#### ❗MockBloc 只需要 State 类型

##### 基本原理


这是没有必要的，并且消除了多余的代码，同时还使 `MockBloc` 与 `Cubit` 兼容。

**v5.x.x**

```dart
class MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
```

**v6.0.0**

```dart
class MockCounterBloc extends MockBloc<int> implements CounterBloc {}
```

#### ❗whenListen 只需要 State 类型

##### 基本原理

这是没有必要的，并且消除了多余的代码，同时还使 `whenListen` 与 `Cubit` 兼容。

**v5.x.x**

```dart
whenListen<CounterEvent,int>(bloc, Stream.fromIterable([0, 1, 2, 3]));
```

**v6.0.0**

```dart
whenListen<int>(bloc, Stream.fromIterable([0, 1, 2, 3]));
```

#### ❗blocTest 不需要 Event 类型

##### 基本原理

这是没有必要的，并且消除了多余的代码，同时还使 `blocTest` 与 `Cubit` 兼容。

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [1] when increment is called',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[1],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [1] when increment is called',
  build: () => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[1],
);
```

#### ❗blocTest skip 默认为 0

##### 基本原理

由于 `bloc` 和 `cubit` 实例将不再为新订阅发出最新状态，因此不再需要将 `skip` 默认为 `1`。

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [0] when skip is 0',
  build: () async => CounterBloc(),
  skip: 0,
  expect: const <int>[0],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [] when skip is 0',
  build: () => CounterBloc(),
  skip: 0,
  expect: const <int>[],
);
```

`Bloc` 或 `Cubit` 的初始状态可以通过以下方式进行测试：

```dart
test('initial state is correct', () {
  expect(MyBloc().state, InitialState());
});
```

#### ❗blocTest 使构建同步

##### 基本原理

以前，将 `build` 设为 `async`，以便进行各种准备工作以将处于待测试状态的集团置于特定状态。由于内部版本和订阅之间增加了延迟，因此不再需要，并且还解决了一些问题。现在可以通过将 `emit` 与所需状态链接起来，而不是进行异步准备来使 bloc 处于所需状态，而无需设置异步状态。

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [2] when increment is added',
  build: () async {
    final bloc = CounterBloc();
    bloc.add(CounterEvent.increment);
    await bloc.take(2);
    return bloc;
  }
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[2],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [2] when increment is added',
  build: () => CounterBloc()..emit(1),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[2],
);
```

!> `emit` 仅在测试中可见，切勿在测试之外使用。

### package:flutter_bloc

#### ❗BlocBuilder bloc 参数重命名为 cubit

##### 基本原理


为了使 `BlocBuilder` 与 `bloc` 和 `cubit` 实例互操作，将 bloc 参数重命名为 cubit（因为 `Cubit` 是基类）。

**v5.x.x**

```dart
BlocBuilder(
  bloc: myBloc,
  builder: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocBuilder(
  cubit: myBloc,
  builder: (context, state) {...}
)
```

#### ❗BlocListener bloc 参数重命名为 cubit

##### 基本原理

为了使 `BlocListener` 与 `bloc` 和 `cubit` 实例互操作，将 bloc 参数重命名为 `cubit`（因为 `Cubit` 是基类）。

**v5.x.x**

```dart
BlocListener(
  bloc: myBloc,
  listener: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocListener(
  cubit: myBloc,
  listener: (context, state) {...}
)
```

#### ❗BlocConsumer bloc 参数重命名为 cubit

##### 基本原理

为了使 `BlocConsumer` 与 `bloc` 和 `cubit` 实例互操作，将 bloc 参数重命名为 `cubit`（因为 `Cubit` 是基类）。

**v5.x.x**

```dart
BlocConsumer(
  bloc: myBloc,
  listener: (context, state) {...},
  builder: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocConsumer(
  cubit: myBloc,
  listener: (context, state) {...},
  builder: (context, state) {...}
)
```

---

## v5.0.0

### package:bloc

#### ❗initialState 已被移除

##### 基本原理

作为开发人员，创建 bloc 时必须覆盖 `initialState` 存在两个主要问题：

- 群组的 `initialState` 可以是动态的，也可以在以后的某个时间点被引用（即使在群组本身之外）。在某些方面，这可以看作是将内部集团信息泄漏到UI层。
- 很冗长。

**v4.x.x**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  ...
}
```

**v5.0.0**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```

?> 想要了解更多请查看 [#1304](https://github.com/felangel/bloc/issues/1304)

#### ❗BlocDelegate 重命名为 BlocObserver

##### 基本原理

名称 `BlocDelegate` 不是该类所扮演角色的准确描述。 `BlocDelegate` 建议该类起积极作用，而实际上，`BlocDelegate` 的预期作用是使其成为一个被动组件，它仅观察应用程序中的所有 bloc。

!> 理想情况下，`BlocObserver` 中不应处理任何面向用户的功能。

**v4.x.x**

```dart
class MyBlocDelegate extends BlocDelegate {
  ...
}
```

**v5.0.0**

```dart
class MyBlocObserver extends BlocObserver {
  ...
}
```

#### ❗BlocSupervisor 已被移除

##### 基本原理

`BlocSupervisor` 是开发人员必须了解并与之交互的另一个组件，其唯一目的就是指定自定义的 `BlocDelegate`。通过更改为 `BlocObserver`，我们认为将观察者直接设置在 Bloc 本身上可以改善开发人员的体验。

?> 这一变化还使我们能够将其他类似` HydratedStorage` 的 bloc 附加组件与` BlocObserver` 分离。

**v4.x.x**

```dart
BlocSupervisor.delegate = MyBlocDelegate();
```

**v5.0.0**

```dart
Bloc.observer = MyBlocObserver();
```

### package:flutter_bloc

#### ❗BlocBuilder condition 重命名为 buildWhen

##### 基本原理

当使用 `BlocBuilder` 时，我们以前可以指定一个 `condition` 来确定 `builder` 是否应该重建。

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // 返回true / false，以确定是否调用构建器 builder
  },
  builder: (context, state) {...}
)
```

`condition` 这个名称不是很容易理解，也不是很明显，更重要的是，当与 `BlocConsumer` 交互时，API变得不一致，因为开发人员可以提供两个条件（一个用于 `builder`，一个用于 `listener`）。结果，`BlocConsumer` API暴露了 `buildWhen` 和 `listenWhen`。

```dart
BlocConsumer<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // 返回true / false，以确定是否调用侦听器
  },
  listener: (context, state) {...},
  buildWhen: (previous, current) {
    // 返回true / false，以确定是否调用构建器 builder
  },
  builder: (context, state) {...},
)
```

为了调整API并提供更一致的开发人员体验，将 `condition` 重命名为 `buildWhen`。

**v4.x.x**

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // 返回true / false，以确定是否调用构建器
  },
  builder: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) {
    // 返回true / false，以确定是否调用构建器 builder
  },
  builder: (context, state) {...}
)
```

#### ❗BlocListener condition 重命名为 listenWhen

##### 基本原理

由于与上述相同的原因，`BlocListener` condition 也被重命名。

**v4.x.x**

```dart
BlocListener<MyBloc, MyState>(
  condition: (previous, current) {
    // 返回true / false，以确定是否调用构建器
  },
  listener: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocListener<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // 返回true / false，以确定是否调用构建器 builder
  },
  listener: (context, state) {...}
)
```

### package:hydrated_bloc

#### ❗HydratedStorage 和 HydratedBlocStorage 被重命名

##### 基本原理

为了提高[hydrated_bloc]（https://pub.dev/packages/hydrated_bloc）和[hydrated_cubit]（https://pub.dev/packages/hydrated_cubit）之间的代码重用，将具体的默认存储实现从 `HydratedBlocStorage` 到 `HydratedStorage`。此外，`HydratedStorage` 界面从 `HydratedStorage` 重命名为 `Storage`。

**v4.0.0**

```dart
class MyHydratedStorage implements HydratedStorage {
  ...
}
```

**v5.0.0**

```dart
class MyHydratedStorage implements Storage {
  ...
}
```

#### ❗HydratedStorage 与 BlocDelegate 分离

##### 基本原理

As mentioned earlier, `BlocDelegate` was renamed to `BlocObserver` and was set directly as part of the `bloc` via:


如前所述，`BlocDelegate` 被重命名为 `BlocObserver`，并通过以下方式直接设置为 `bloc` 的一部分：

```dart
Bloc.observer = MyBlocObserver();
```
对以下内容进行了更改：

- 与新的 bloc 观察器API保持一致
- 保持存储范围为 `HydratedBloc`
- 将 `BlocObserver` 与 `Storage `解耦

**v4.0.0**

```dart
BlocSupervisor.delegate = await HydratedBlocDelegate.build();
```

**v5.0.0**

```dart
HydratedBloc.storage = await HydratedStorage.build();
```

#### ❗简化的初始化

##### 基本原理

以前，开发人员必须手动调用 `super.initialState ?? DefaultInitialState（）` 以设置其 ` HydratedBloc` 实例。这是笨拙且冗长的，并且与 `bloc` 中对 `initialState` 的重大更改不兼容。结果，在 v5.0.0 中， `HydratedBloc` 初始化与普通的 `Bloc` 初始化相同。

**v4.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  @override
  int get initialState => super.initialState ?? 0;
}
```

**v5.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```
