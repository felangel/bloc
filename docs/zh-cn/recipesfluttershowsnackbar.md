# 配方：使用 BlocListener 显示 SnackBar

> 在这里，我们将展示如何使用 `BlocListener` 显示一个 `SnackBar` 来响应 bloc 的状态改变。

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

让我们构建一个基础的 `DataBloc`，它将处理 `DataEvents` 输入和 `DataStates` 输出。

### DataEvent

简单起见，`DataBloc` 只响应名为 `FetchData` 的 `DataEvent`。

[data_event.dart](../_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### DataState

`DataBloc` 可以是以下三种 `DataStates` 状态中的一种：

- `Initial` - 未添加任何事件之前的初始状态
- `Loading` - bloc 异步“获取数据”时的状态
- `Success` - bloc 成功“获取数据”后的状态

[data_state.dart](../_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### DataBloc

`DataBloc` 的实现如下：

[data_bloc.dart](../_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **注意：** 我们使用 `Future.delayed` 来模拟延迟。

## UI 层

现在我们将展示如何把 `DataBloc` 挂载到一个部件，并显示 一个`SnackBar` 来响应成功的状态。

[main.dart](../_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> 在 `DataBloc` 中，当状态改变时，我们使用了 `BlocListener` 部件来**做某些事情**。

?> 在 `DataBloc` 中，当状态改变时，我们使用了 `BlocBuilder` 部件来**渲染组件**。

!> 我们一定**不要**在 `BlocBuilder` 的 `builder` 方法中“做某些事情”来响应状态的改变，因为 Flutter 框架会多次调用该方法。 `builder` 方法应该是一个[纯方法](https://en.wikipedia.org/wiki/Pure_function)，它只是返回一个部件来响应 bloc 的状态改变。

您可以在[这里](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44)查看完整源代码。
