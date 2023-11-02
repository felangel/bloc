# AngularDart 计数器教程

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> 在下面的教程中，我们将在AngularDart中使用Bloc库开发一个计数器应用。

![demo](../assets/gifs/angular_counter.gif)

## 设置

我们使用 [stagehand](https://github.com/dart-lang/stagehand) 创建一个新的AngularDart项目。

[script](../_snippets/angular_counter_tutorial/stagehand.sh.md ':include')

!> 通过运行`dart pub global activate stagehand`激活stagehand。

然后我们继续替换`pubspec.yaml`的内容：

[pubspec.yaml](../_snippets/angular_counter_tutorial/pubspec.yaml.md ':include')

然后安装所有依赖

[script](../_snippets/angular_counter_tutorial/install.sh.md ':include')

我们的计数器应用将只有2个按钮来增加或减少计数器的值，并且有一个element来显示当前计数器的值。让我们开始设计`CounterEvents`。

## Counter Events

[counter_event.dart](../_snippets/angular_counter_tutorial/counter_event.dart.md ':include')

## Counter States

因为计数器的状态可以用整数表示，所以我们不需要创建自定义类!

## Counter Bloc

[counter_bloc.dart](../_snippets/angular_counter_tutorial/counter_bloc.dart.md ':include')

?> **注意**: 从类声明中我们可以看出，我们的`CounterBloc`将接受`CounterEvents`作为输入并且输出整数。

## Counter App

现在我们已经完全实现了我们的`CounterBloc`，我们可以开始创建我们的AngularDart应用组件了。

我们的`app.component.dart`应该看起来像这样：

[app.component.dart](../_snippets/angular_counter_tutorial/app_component.dart.md ':include')

我们的`app.component.html`应该看起来像这样：

[app.component.html](../_snippets/angular_counter_tutorial/app_component.html.md ':include')

## Counter Page

最后，剩下的就是构建我们的计数器页面组件。

我们的 `counter_page_component.dart`应该像这样：

[counter_page_component.dart](../_snippets/angular_counter_tutorial/counter_page_component.dart.md ':include')

?> **注意**: 我们能使用AngularDart的依赖注入系统访问`CounterBloc`。因为我们已经把它作为`Provider`注册，AngularDart能正确的解析`CounterBloc`。 

?> **注意**: 我们在`ngOnDestroy`中关闭`CounterBloc`。

?> **注意**: 我们导入`BlocPipe`以便我们可以在模板中使用它。

最后我们的`counter_page_component.html`应该像这样：

[counter_page_component.html](../_snippets/angular_counter_tutorial/counter_page_component.html.md ':include')

?> **注意**: 我们正在使用`BlocPipe`，以便我们可以显示`CounterBloc`更新之后的状态。

就是这样！我们从业务逻辑层分离了展示层。我们的`CounterPageComponent`不知道当用户按下按钮后会发生什么，它只是添加一个事件通知`CounterBloc`。而且我们的`CounterBloc`不知道状态(计数器的值)会发生什么，它只是简单的转换`CounterEvents`到整数值。

我们使用`webdev serve`运行我们的应用并且能在[本地](http://localhost:8080)浏览。

这个示例的全部源码在[这里](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).
