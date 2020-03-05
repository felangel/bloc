# 常见问题

## 状态（State) 没有更新

❔ **问题**: 我在自己的bloc中产生了一个状态（State)，但是用户界面却没有更新。我究竟做错了什么?

💡 **答案**: 如果你有用`Equatable`包的话，确保你已经将所有的属性都传入`props`的`getter`当中。

✅ **正确**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // 将所有属性传入props中
}
```

❌ **错误**

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

另外，请确保在您的bloc中产生状态（State) 的新实例。

✅ **正确**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // 始终创建要产生的状态（State) 的新实例
    yield state.copyWith(property: event.property);
}
```

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // 始终创建要产生的状态（State) 的新实例
    yield MyState(data: data);
}
```

❌ **错误**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // 永远不要修改/更改状态（State)
    state.property = event.property;
    // 永远不会产生相同的状态（State) 的实例
    yield state;
}
```

## 什么时候该用Equatable

❔**问题**: 我什么时候应该使用`Equatable`?

💡**答案**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

在上述情况下，如果`StateA`扩展为`Equatable`，则只会发生一个状态更改（第二个产生的将被忽略) 。
通常，如果您想优化代码以减少重建次数，则应使用`Equatable`。
如果您希望相同的状态(State)背对背触发多个转换，则不应使用`Equatable`。

另外，使用`Equatable`可以更容易地测试bloc，因为我们可以预期bloc的状态(State)的特定实例，而不是使用`Matchers`或`Predicates`。
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

没有`Equatable`的话，上述测试将失败，需要像下面这样重写：

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

❔ **问题**: Bloc和Redux有什么区别?

💡 **答案**:

BLoC是由以下规则定义的设计模式：

1. BLoC的输入和输出是简单的流（Stream) 和接收器（Sink) 。
2. 依赖性必须是可注入的，并且与平台无关。
3. 不允许平台分支。
4. 只要遵循上述规则，就可以得到您想要的。

UI的准则是:

1. 每个`足够复杂`的组件都有一个对应的BLoC。
2. 组件应按`原样`发送输入。
3. 组件应显示尽可能接近`原样`的输出。
4. 所有分支都应基于简单的BLoC的bool输出。

Bloc库实现BLoC设计模式，旨在抽象RxDart，以简化开发人员体验。

Redux的三个原则是：

1. 真实的单一来源
2. 状态为只读
3. 使用纯函数进行更改

Bloc库违反了第一个原则。具有bloc状态的产品分布在多个bloc中。
此外，在bloc中没有中间者的概念，并且bloc旨在使异步状态更改变得非常容易，从而允许您为单个事件发出多个状态。

## Bloc vs. Provider

❔ **问题**: Bloc和Provider之间有什么区别?

💡 **答案**: provider是为依赖注入而设计的（它包装了InheritedWidget) 。
您仍然需要弄清楚如何管理状态（通过`ChangeNotifier`，`Bloc`，`Mobx`等) 。
Bloc库在内部使用`provider`来简化在整个小部件树中提供和访问bloc的过程。

## 使用Bloc来导航

❔ **问题**: 如何使用Bloc导航?

💡 **答案**: 查看 [Flutter Navigation](recipesflutternavigation.md)

## BlocProvider.of() 找不到bloc

❔ **问题**: 当使用`BlocProvider.of（context)`时，它找不到该bloc。我该怎样才能解决这个问题?

💡 **答案**: 您无法从提供该context的context访问该bloc，因此必须确保在子`BuildContext`中调用`BlocProvider.of（)`。

✅ **正确**

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

❌ **错误**

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

## 项目结构

❔ **问题**: 我应该如何构架我的项目?

💡 **答案**: 尽管对于此问题确实没有对错只说，但是还是有一些推荐的参考文献：

- [Flutter架构样本 - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter购物车示例](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD 课程 - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

最重要的是要有一个**一致的**和**有意图的**项目结构。
