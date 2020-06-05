# 常见问题

## 状态（State) 没有更新

❔ **问题**: 我在自己的bloc中产生了一个状态（State)，但是用户界面却没有更新。我究竟做错了什么?

💡 **答案**: 如果你有用 `Equatable` 包的话，确保你已经将所有的属性都传入`props`的`getter`当中。

✅ **正确**

[my_state.dart](../_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **错误**

[my_state.dart](../_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](../_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

另外，请确保在您的bloc中产生状态（State) 的新实例。

✅ **正确**

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](../_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **错误**

[my_bloc.dart](../_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

!> `Equatable` 属性应该被复制而非被修改。如果一个 `Equatable` 类中含有 `List` 或者 `Map` 作为其属性, 确保使用 `List.from` 或者 `Map.from` 以确保根据属性的值来衡量是否等价而非地址而引用地址。

## 什么时候该用Equatable

❔**问题**: 我什么时候应该使用`Equatable`?

💡**答案**:

[my_bloc.dart](../_snippets/faqs/equatable_yield.dart.md ':include')

在上述情况下，如果`StateA`扩展为`Equatable`，则只会发生一个状态更改（第二个产生的将被忽略) 。
通常，如果您想优化代码以减少重建次数，则应使用`Equatable`。
如果您希望相同的状态(State)背对背触发多个转换，则不应使用`Equatable`。

另外，使用`Equatable`可以更容易地测试bloc，因为我们可以预期bloc的状态(State)的特定实例，而不是使用`Matchers`或`Predicates`。
[my_bloc_test.dart](../_snippets/faqs/equatable_bloc_test.dart.md ':include')

没有`Equatable`的话，上述测试将失败，需要像下面这样重写：

[my_bloc_test.dart](../_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

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

[my_page.dart](../_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](../_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **错误**

[my_page.dart](../_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## 项目结构

❔ **问题**: 我应该如何构架我的项目?

💡 **答案**: 尽管对于此问题确实没有对错只说，但是还是有一些推荐的参考文献：

- [Flutter架构样本 - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter购物车示例](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD 课程 - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

最重要的是要有一个**一致的**和**有意图的**项目结构。
