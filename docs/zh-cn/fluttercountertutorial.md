# Flutter 计数器教程

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> 在接下来的教程中，我们将使用 `Bloc` 库来构造一个计数器

![demo](../assets/gifs/flutter_counter.gif)

## 起步

我们将从创建一个全新的 `Flutter` 项目开始（在控制台中输入以下指令）

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

首先，我们需要将 `pubspec.yaml` 文件中的的内容替换为以下内容，

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

替换之后下一步就可以安装所有的依赖包了（在控制台中输入以下指令）

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

我们的计数器应用程序将只有两个按钮来 `增加` 和 `减少` 计数器的值，以及一个 `Text` 部件来显示当前计数器的值。 让我们开始设计 `CounterEvents` 吧。

## Counter Events 事件

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Counter States 状态

因为计数器的状态可以用整数表示，因此我们不需要创建新的类！

## Counter Bloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **提示**: 仅仅从类的声明中，我们就可以得知 `CounterBloc` 将以 `CounterEvents` 输入和输出整数。

## Counter App

现在我们已经完全实现了 `CounterBloc`，接下来就可以开始创建Flutter应用程序了。

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **提示**: 我们正在使用 `Flutter_bloc` 中的 `BlocProvider` 部件，使得 `CounterBloc` 的实例可用于整个子树（`CounterPage`）。 `BlocProvider` 还可以自动关闭 `CounterBloc`，因此在此我们不需要使用 `StatefulWidget`。

## Counter Page

最后剩下的步骤就是搭建我们的 `Counter` 页面了

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **提示**: 我们可以使用 `BlocProvider.of<CounterBloc>(context)` 访问 `CounterBloc` 实例，因为我们将 `CounterPage` 包装在 `BlocProvider` 中。

?> **提示**: 我们使用来自 `Flutter_bloc` 的 `BlocBuilder` 部件，以响应状态变化（计数器值的变化）重建UI。

?> **提示**: `BlocBuilder` 具有一个可选的 `bloc` 参数，但是我们可以指定块的类型和状态的类型，而 `BlocBuilder` 会自动找到该 `Bloc`，因此我们无需显式使用 `BlocProvider.of<CounterBloc>(context)`。

!> 仅当您的部件无法通过父类 `BlocProvider` 和当前 `BuildContext` 来访问的 `Bloc` 时，才在 ` BlocBuilder` 中指定该 `Bloc`。

仅此而已！ 我们已经将 `presentation layer` (表示层) 与 `business logic layer` (业务逻辑层) 分离了。 我们的 `CounterPage` 不知道当用户按下按钮时会发生什么。 它只是添加了一个事件来通知 `CounterBloc`。 此外，我们的 `CounterBloc` 也不知道状态（计数器值）发生了什么。 它只是将 `CounterEvents` 转换为整数。

我们可以使用 `Flutter Run` 来运行我们的应用程序，并可以在您的设备或模拟器或者模拟器上查看它。

您可以在此处找到示例的完整源代码[这里](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
