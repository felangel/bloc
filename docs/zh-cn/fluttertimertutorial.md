# 秒表

![开始](https://img.shields.io/badge/level-beginner-green.svg)

> 在下面的教程中，我们将介绍如何使用bloc库构建一个计时器应用程序。完成的应用程序应该是这样的:

![示例](../assets/gifs/flutter_timer.gif)

## 核心要点
- [BlocObserver](/coreconcepts?id=blocobserver) ：用于观察Bloc内状态变化。
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider)：为它的children提供Bloc。
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder)：根据新的state来绘制对应Widget。
- 使用[Equatable](/faqs?id=when-to-use-equatable)防止不必要的刷新。
- 学习在Bloc中使用`StreamSubscription`。
- 使用`buildWhen`防止不必要的刷新。

## 新建项目和配置文件yaml
我们先新建一个全新的flutter应用

[script](../_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

将下面代码复制粘贴到 `pubspec.yaml` 文件中

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/pubspec.yaml ':include')

?> **注意:** 我们将在app中使用[flutter_bloc](https://pub.dev/packages/flutter_bloc) 和[equatable](https://pub.dev/packages/equatable) 包._

接下来，运行`flutter packages get`安装依赖包

## 计时器
> 这个计时器是我们秒表app的数据源。它将公开一个流，我们可以订阅并且响应它。

开始创建 `ticker.dart`。

[ticker.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/ticker.dart ':include')

`Ticker`类公开了一个tick方法，它获取我们想要的秒数，并且返回一个每秒发送剩余秒数的流。

下一步我们需要创建`TimerBloc`来处理`Ticker`。

## Timer Bloc

### TimerState

我们先定义在`TimerBloc`中的`秒表状态`。

`TimerBloc`的状态可能是下面中的一种：

- TimerInitial：准备从指定的时间开始倒计时。
- TimerRunInProgress：正在倒计时中。
- TimerRunPause：暂停。
- TimerRunComplete：结束。

每个状态都会对用户界面和用户可执行的操作产生影响。例如：
- 如果状态是`TimerInitial`用户可以开始倒计时。
- 如果状态是`TimerRunInProgress`用户可以暂停和重置计时器并且可以看到剩余的时间。
- 如果状态是`TimerRunPause`用户可以恢复倒计时和重置计时器。
- 如果状态是`TimerRunComplete`用户可以重置计时器。

为了将所有bloc文件放在一起，我们创建bloc文件夹用并创建`timer_state.dart`bloc文件。

?> **提示:** 你可以使用[IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) 或[VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) 插件自动生成bloc文件。

[timer_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/bloc/timer_state.dart ':include')

注意所有的`TimerStates`都继承自抽象基类`TimerState`，它有一个duration属性。这是因为不管`TimerBloc`在哪里，我们都想知道还剩余多少时间。另外`TimerState`还继承了`Equatable`用于确保如果有相同状态不会再次触发重建。

下面我们定义和实现`TimerBloc`将要处理的`TimerEvent`。

### TimerEvent
我们的`TimerBloc`需要知道怎么处理下面的事件：

- TimerStarted：通知TimerBloc开始计时。
- TimerPaused：通知TimerBloc暂停。
- TimerResumed：通知TimerBloc恢复计时。
- TimerReset：通知TimerBloc重置计时器到原来的状态。
- TimerTicked：通知TimerBloc一个tick已经发生，需要更新它对应的状态。

如果你没有使用[IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) 或 [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) 插件。我们需要创建`bloc/timer_event.dart`路径下的文件，并且实现这些事件。

[timer_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/bloc/timer_event.dart ':include')

下一步，让我们实现`TimerBloc`!

### TimerBloc

如果你还没有创建bloc文件夹下的`timer_bloc.dart`，你需要创建此文件，并且创建一个空的`TimerBloc`。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

首先我们需要定义`TimerBloc`的初始状态。我们想`TimerBloc`从`TimerInitial`开始，默认时间1分钟（60秒）。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

接下来，我们需要定义对`Ticker`的依赖关系。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

我们也定义了一个`StreamSubscription`，一会儿会讲到。

现在剩下的就是实现事件的处理，为了增加可读性我喜欢将每个事件的处理放进它自己的帮助方法中。我们开始`TimerStarted`事件。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

如果`TimerBloc`收到`TimerStarted`事件，它会发送一个带有开始时间的`TimerRunInProgress`状态。此外，如果已经打开了`_tickerSubscription`我们需要取消它释放内存。我们也需要在`TimerBloc`中重载`close`方法，当`TimerBloc`被关闭的时候能取消`_tickerSubscription `。最后我们监听`_ticker.tick`流并且在每个触发时间我们添加一个包含剩余时间的`TimerTicked`事件。

下一步我们实现`TimerTicked`事件的处理。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

每次接收到`TimerTicked`事件，如果剩余时间大于0，我们需要发送一个带有新的剩余时间的`TimerRunInProgress`事件来更新状态。否则，如果剩余时间等于0，那么倒计时已经结束，我们需要发送`TimerRunComplete`状态。

现在让我们实现`TimerPaused`事件的处理。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

在`_onPaused`中如果我们`TimerBloc`中的状态是`TimerRunInProgress`，我们可以暂停`_tickerSubscription`并且发送一个带有当前时间的`TimerRunPause`状态。

下一步，我们实现`TimerResumed`事件的处理，这样我们就可以取消计时器的暂停。

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

`TimerResumed`事件处理和`TimerPaused`事件的处理非常相似。如果`TimerBloc`的`state`是`TimerRunPause`并且它接收到一个`TimerResumed`事件，它恢复`_tickerSubscription`并且发送一个带有当前时间的`TimerRunInProgress`状态。

最后我们需要实现`TimerReset`事件的处理。

[timer_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/bloc/timer_bloc.dart ':include')

如果`TimerBloc`接收到一个`TimerReset`事件，它需要取消当前的`_tickerSubscription`这样它就不会被计时器通知，并且发送一个带有初始时间的`TimerInitial`状态。

这就是全部的`TimerBloc`了。现在剩下为我们的秒表程序实现UI。

## Application UI

### MyApp

我们先删除`main.dart`中的内容，并替换成下面的代码。

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/main.dart ':include')

接下来，我们在`app.dart`中创建 ‘App’ 组件，作为我们app的根组件。

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/app.dart ':include')

接下来，我们需要实现我们的`Timer`组件。

### Timer

我们的`Timer`(`/timer/view/timer_page.dart `)组件将负责显示剩余时间和适当的按钮允许用户开始、暂停和重置秒表。

[timer.dart](../_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

到目前为止，我们只使用`BlocProvider`来访问我们的`TimerBloc`实例。

接下来，我们去实现有开始、暂停和重置按钮的`Actions`组件。

### Barrel
为了清理我们在`Timers`中的导入文件，我们需要创建一个桶文件`timer/timer.dart`。

[timer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_timer/lib/timer/timer.dart ':include')

### Actions

[actions.dart](../_snippets/flutter_timer_tutorial/actions.dart.md ':include')

`Actions`小部件只是另一个`StatelessWidget`，每当我们获取到一个新的TimerState时，它使用`BlocBuilder`来重建UI。`Actions`使用`context.read<TimerBloc>()`访问`TimerBloc`实例并且基于当前`TimerBloc`状态返回不同的`FloatingActionButtons`。每个`FloatingActionButtons`的`onPressed`回调中都添加一个事件通知`TimerBloc`。

如果你想细微的控制，当`builder`方法被调用的时候你可以提供一个可选的`buildWhen`到`BlocBuilder`。`buildWhen`携带前一个bloc状态和当前的bloc状态，并且返回一个`boolean`值。如果`buildWhen`返回`true`，将调用带有`state`的`builder`并且重建组件。如果`buildWhen`返回`false`，带有`state`的`builder`将不会被调用并且不会被重建。

这种情况下，我们不想每次都重新构建`Actions`组件，这样效率很低。我们只想在`TimeState`的`runtimeType`改变的时候(TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, 等…)重建 `Actions`。

因此，如果我们在每次重建时随机地给组件上色，它看起来会是这样:

![BlocBuilder buildWhen demo](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **注意:** 即使`Text`小部件每隔一秒都要重新构建，我们也只在需要重新构建时才重新构建`Actions`。

### Background

最后添加下面的背景组件：

[background.dart](../_snippets/flutter_timer_tutorial/background.dart.md ':include')

### 把它们结合起来

这就是所有的东西了！目前我们有一个相当可靠的计时器应用程序，它只高效地重建需要重建的小部件。

这个示例所有的源码在 [这里](https://github.com/felangel/bloc/tree/master/examples/flutter_timer)。

