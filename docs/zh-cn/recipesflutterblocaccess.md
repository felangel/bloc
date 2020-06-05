# 配方: 访问 Bloc

> 在这里，我们将展示如何使用 `BlocProvider` 让整个部件树都可以访问 bloc。我们将探索三种情况：本地访问、路由访问和全局访问。

## 本地访问

> 在这个例子中，我们将使用 `BlocProvider` 让本地子树可以访问 bloc。在这里，本地的意思是没有路由的入栈和出栈。

### Bloc

简单起见，我们将使用 `Counter` 作为例子。

`CounterBloc` 的实现如下所示：

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

UI 由三部分组成：

- App: 应用程序的根部件。
- CounterPage: 作为容器的部件，它将管理 `CounterBloc`，并暴露 `FloatingActionButtons` 用于 `递增` 和 `递减` 计数的值。
- CounterText: 用于显示当前 `count` 的文本部件。

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/local_access/main.dart.md ':include')

`App` 部件是一个使用 `MaterialApp` 的 `StatelessWidget`，它将 `CounterPage` 作为主部件。`App` 负责创建和关闭 `CounterBloc`，并使用 `BlocProvider` 让它可以被 `CounterPage` 访问。

?> **注意：** 当使用 `BlocProvider` 包装一个部件时，可以给该子树的所有部件提供一个 bloc。在这个例子中，我们可以在 `CounterPage` 部件 和 `CounterPage` 部件的任意子部件中使用 `BlocProvider.of<CounterBloc>(context)` 访问 `CounterBloc`。

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_page.dart.md ':include')

`CounterPage` 部件是一个 `StatelessWidget`，它通过 `BuildContext` 访问 `CounterBloc`。

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_text.dart.md ':include')

`CounterText` 部件使用 `BlocBuilder` ，在 `CounterBloc` 状态改变时重新构建自己。我们使用 `BlocProvider.of<CounterBloc>(context)` 访问 `CounterBloc`，并在 `Text` 部件中返回当前的计数。

以上就是本地 bloc 访问部分，您可以在[这里](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35)查看完整源代码。

接下来，我们将展示如何在多个页面（路由）之间提供 bloc。

## 匿名路由访问

> 这个例子中，我们将使用 `BlocProvider` 跨越路由访问 bloc。当一个新路由入栈后，它将拥有一个不同的 `BuildContext`，该 `BuildContext` 没有之前提供的 blocs 的引用。因此，我们必须把新路由包装在单独的 `BlocProvider` 中。

### Bloc

同样的，我们将使用 `CounterBloc`。

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

同样的，UI 由三部分组成：

- App: 应用程序的根部件。
- HomePage: 作为容器的部件，它将管理 `CounterBloc`，并暴露 `FloatingActionButtons` 用于 `递增` 和 `递减` 计数的值。
- CounterPage: 在另一个路由中显示当前计数值的部件。

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/main.dart.md ':include')

同样的，`App` 部件跟之前的一样。

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/home_page.dart.md ':include')

`HomePage` 跟上面例子中的 `CounterPage` 类似；但它在中间渲染了一个 `RaisedButton`，而不是 `CounterText` 部件。该 `RaisedButton` 可以让用户导航到一个显示当前计数的新页面。

当用户点击 `RaisedButton`，我们将一个新的 `MaterialPageRoute` 入栈，并返回 `CounterPage`；为了让下一个页面可以访问当前的 `CounterBloc` 实例，我们把 `CounterPage` 包装在 `BlocProvider` 中。

!> 值得注意的是，在这里我们使用了 `BlocProvider` 的 `value` 构造函数，因为我们提供的是一个已经存在的 `CounterBloc` 实例。只有在为子树提供一个已经存在的 bloc 时，才使用 `BlocProvider` 的 `value` 构造函数。另外，使用 `value` 构造函数不会自动关闭 bloc，这就是我们想在这个例子中实现的效果（因为我们仍然需要在祖先部件中使用 `CounterBloc`）。我们只需要将现有的 `CounterBloc` 实例作为已经存在的值（而不是在构建器中创建的值）传递给新页面。这就保证了不再需要 `CounterBloc` 时，只有顶层的 `BlocProvider` 负责关闭它。

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/counter_page.dart.md ':include')

`CounterPage` 是一个超级简单的 `StatelessWidget`，它使用 `BlocBuilder` 重新渲染当前计数值的 `Text` 部件。跟上面一样，我们可以使用 `BlocProvider.of<CounterBloc>(context)` 访问 `CounterBloc`。

这就是示例的全部内容，您可以在[这里](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21)查看完整源代码。

接下来，我们将展示如何把 bloc 的访问范围限定在一个或多个命名路由。

## 命名路由访问

> 在这个例子中，我们将使用 `BlocProvider` 跨越多个命名路由访问 bloc。当一个新的命名路由入栈后，它将拥有一个不同的 `BuildContext`（跟之前一样），该 `BuildContext` 没有之前提供的 blocs 的引用。在这种情况下，我们将在父部件中管理想要限定范围的 bloc，并有选择地将他们提供给要访问的路由。

## Bloc

同样的，我们将使用 `CounterBloc`。

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

同样的，UI 由三部分组成：

- App: 应用程序的根部件，它管理 `CounterBloc`，并把它提供给适当的命名路由。
- HomePage: 访问 `CounterBloc`的容器部件，并暴露 `FloatingActionButtons` 用于 `递增` 和 `递减` 计数的值。
- CounterPage: 在另一个路由中显示当前计数值的部件。

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/main.dart.md ':include')

`App` 组件负责管理 `CounterBloc` 实例，并把它提供给 root（`/`）和 counter（`/counter`）路由。

!> 需要注意的是，因为 `_AppState` 创建了 `CounterBloc` 实例，所以它应该在 `dispose` 方法中关闭它。

!> 提供 `CounterBloc` 实例给路由时，我们使用了 `BlocProvider.value`，因为我们不想让 `BlocProvider` 负责销毁 bloc（因为这是 `_AppState` 的工作）。

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/home_page.dart.md ':include')

`HomePage` 跟上个例子很相似；区别在于，当用户点击 `RaisedButton` 时，通过把一个新的命名路由入栈，来导航到之前定义的 `/counter` 路由。

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/counter_page.dart.md ':include')

`CounterPage` 是一个超级简单的 `StatelessWidget`，它使用 `BlocBuilder` 重新渲染当前计数值的 `Text` 部件。跟之前一样，我们可以使用 `BlocProvider.of<CounterBloc>(context)` 访问 `CounterBloc`。

这就是该示例的全部内容，您可以在[这里](https://gist.github.com/felangel/8d143cf3b7da38d80de4bcc6f65e9831)查看完整源代码。

接下来，我们将展示如何创建一个 `Router` 来管理 bloc，并将它的范围限定为一个或多个生成的路由。

## 生成的路由访问

> 在这里例子中，我们将创建一个 `Router`，并使用 `BlocProvider` 跨越多个生成的路由访问 bloc。我们将在 `Router` 中管理要限定访问范围的 blocs，并有选择地将它提供给要访问的路由。

### Bloc

同样的，我们将使用 `CounterBloc`。

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

同样的，UI 由三部分组成，同时还增加了 `AppRouter`：

- App: 负责管理 `AppRouter` 的应用程序的根部件。
- AppRouter: 一个管理 `CounterBloc` 的类，并为相应的生成路由提供 `CounterBloc`。
- HomePage: 访问 `CounterBloc` 的容器部件，并暴露 `FloatingActionButtons` 用于 `递增` 和 `递减` 计数的值。
- CounterPage: 在另一个路由中显示当前计数值的部件。

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/main.dart.md ':include')

`App` 组件负责管理 `AppRouter` 实例，并使用 route 的 `onGenerateRoute` 方法决定当前路由。

!> `App` 部件销毁时，我们需要销毁 `_router` 来关闭 `AppRouter` 中的所有 blocs。

#### App Router

[app_router.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/app_router.dart.md ':include')

`AppRouter` 负责管理 `CounterBloc` 实例，还有一个根据 `RouteSettings` 参数返回正确路由的 `onGenerateRoute` 方法。

!> 因为 `AppRouter` 创建了 `CounterBloc` 实例，所以它必须暴露 `dispose` 方法来关闭 `CounterBloc` 实例。`dispose` 在 `_AppState` 部件的 `dispose` 方法中被调用。

!> 当给路由提供 `CounterBloc` 实例时，我们使用了 `BlocProvider.value`。这是因为我们不希望 `BlocProvider` 负责销毁 bloc（因为这个 `AppRouter` 的工作）。

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/home_page.dart.md ':include')

`HomePage` 跟上面的例子一样。当用户点击 `RaisedButton`时，通过把一个新的命名路由入栈，来导航到之前定义的 `/counter` 路由。

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/counter_page.dart.md ':include')

`CounterPage` 是一个超级简单的 `StatelessWidget`，它使用 `BlocBuilder` 重新渲染当前计数值的 `Text` 部件。跟之前一样，我们可以使用 `BlocProvider.of<CounterBloc>(context)` 访问 `CounterBloc`。

这就是该示例的全部内容，您可以在[这里](https://gist.github.com/felangel/354f9499dc4573699c62fc90c6bb314e)查看完整源代码。

最后，我们将展示如何让 bloc 在部件树中全局可访问。

## 全局访问

> 在最后这个例子中，我们将演示如何让一个 bloc 实例 可以在整个部件树中可访问。对于某些特定情况，例如 `AuthenticationBloc` 或 `ThemeBloc` 很有用，因为该状态在应用程序的所有部分都会用到。

### Bloc

跟之前一样，我们使用在示例中使用 `CounterBloc`。

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

我们的应用程序结果跟“本地访问”中的例子一致。所以，我们的 UI 会有三个部分：

- App: 应用程序的根部件，它管理 `CounterBloc` 的全局实例。
- CounterPage: 容器的部件，它暴露 `FloatingActionButtons` 用于 `递增` 和 `递减` 计数的值。
- CounterText: 用于显示当前 `count` 的文本部件。

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/global_access/main.dart.md ':include')

跟上面本地访问示例非常类似，`App` 使用 `BlocProvider` 负责创建、关闭，以及提供 `CounterBloc` 给子树。主要的区别在于，`MaterialApp` 是 `BlocProvider` 的一个孩子。

让 `CounterBloc` 实例全局可访问的关键是把整个 `MaterialApp` 包装在 `BlocProvider` 中。现在，只要在有 `BuildContext` 的地方使用 `BlocProvider.of<CounterBloc>(context)` 就能访问 `CounterBloc`。

?> **注意：** 该方法同样适用于 `CupertinoApp` 或 `WidgetsApp`。

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_page.dart.md ':include')

`CounterPage` is a `StatelessWidget`，因为它不需要管理任何本身的状态。跟之前一样，使用 `BlocProvider.of<CounterBloc>(context)` 访问全局的 `CounterBloc` 实例。

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_text.dart.md ':include')

这里没有新的知识点；`CounterText` 部件跟第一个例子一样。它只是一个 `StatelessWidget`，当 `CounterBloc` 的状态改变时，使用 `BlocBuilder` 重新渲染，并使用 `BlocProvider.of<CounterBloc>(context)` 访问全局的 `CounterBloc` 实例。

您可以在[这里](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d)查看完整源代码。