# 配方: 导航

> 在这里，我们将展示如何使用 `BlocBuilder` 和 `BlocListener` 进行导航。我们将使用两种方式：直接导航和路由导航。

## 直接导航

> 在这个例子中，我们不使用路由，而是使用 `BlocBuilder` 显示一个特定页面（部件）来响应 bloc 的状态改变。

![demo](../assets/gifs/recipes_flutter_navigation_direct.gif)

### Bloc

我们构建 `MyEvents` 作为输入，`MyStates` 作为输出的 `MyBloc`。

#### MyEvent

简单起见，`MyBloc` 只响应两种 `MyEvents`：`eventA` 和 `eventB`。

[my_event.dart](../_snippets/recipes_flutter_navigation/my_event.dart.md ':include')

#### MyState

`MyBloc` 可以有两种不同的 `DataStates`：

- `StateA` - `PageA` 被渲染时的状态。
- `StateB` - `PageB` 被渲染时的状态。

[my_state.dart](../_snippets/recipes_flutter_navigation/my_state.dart.md ':include')

#### MyBloc

`MyBloc` 的实现如下：

[my_bloc.dart](../_snippets/recipes_flutter_navigation/my_bloc.dart.md ':include')

### UI 层

现在，我们将展示如何将 `MyBloc` 挂载到一个部件，并根据 bloc 的状态显示不同的页面。

[main.dart](../_snippets/recipes_flutter_navigation/direct_navigation/main.dart.md ':include')

?> 在 `MyBloc` 中，我们使用 `BlocBuilder` 部件渲染相应的部件来响应状态改变。

?> 我们使用 `BlocProvider` 部件让 `MyBloc` 的实例在整个部件树上可用。

您可以在[这里](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09)查看完整源代码。


## 路由导航

> 在这个例子中，我们将通过路由，在 bloc 状态改变时使用 `BlocListener` 导航到特定页面（部件）。

![demo](../assets/gifs/recipes_flutter_navigation_routes.gif)

### Bloc

我们将重用上个例子中的 `MyBloc`。

### UI 层

我们将展示如何根据 `MyBloc` 的状态导航到不同的页面。

[main.dart](../_snippets/recipes_flutter_navigation/route_navigation/main.dart.md ':include')

?> 当 `MyBloc` 的状态改变时，我们使用 `BlocListener` 部件将一个新路由入栈。

!> 为了展示用法，我们添加了一个仅用于导航的事件。在实际的应用程序中，您不应该创建显式的导航事件。如果不需要“业务逻辑”来触发导航，则应该直接响应用户输入（例如在 `onPressed` 回调方法中等等）。只有在需要“业务逻辑”来决定导航到某个页面时，才根据状态改变进行导航。

您可以在[这里](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd)查看完整源代码。
