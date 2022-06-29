# 核心思想 (package:bloc)

?> 使用前请确保仔细阅读并理解以下部分 [package:bloc](https://pub.dev/packages/bloc).

有几个核心概念对于理解如何使用 Bloc 至关重要。

在接下来的部分中，我们将详细讨论它们中的每一个，并逐步研究它们是如何应用于实际应用程序，例如：计数器应用程序。

## 流（Streams)

?> 查看官方文档 [Dart Documentation](https://dart.dev/tutorials/language/streams) 以获取更多关于流（`Streams`）的信息.

> 流（Stream) 是`一系列异步`的数据.

为了使用 Bloc，对 `Streams` 及其工作方式有扎实的了解是**十分必要的**。

> 如果您不熟悉 `Streams`，请试着想象一个_有水流过的管道_。管道是“流”（`Stream`），管道里的水是`异步的数据`.

我们可以通过编写 `async*`（异步生成器）方法在 Dart 中创建一个 `Stream`。

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

通过将一个函数标记为 `async*`，我们可以使用 `yield` 作为关键字并返回 `Stream` 数据。在上面的示例中，我们返回的是一个不超过整数 max 边界的整数流 Steam。

每次我们在 `async*` 函数中 `yield` 时，我们都会通过 `Stream` 推送该数据。

我们可以通过几种方式使用上面的 `Stream`。如果我们想编写一个函数来返回所有整数 `Stream` 的总和，则它可能类似于：

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

通过将上面的函数标记为 `async`，我们可以使用 `await` 关键字并返回整数的 `Future` 数据。在此示例中，我们先等待流(`Stream`)中的每个值然后再返回流(`Stream`)中所有整数的总和。

我们可以像这样将它们放在一起：

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

现在我们对 Dart 中的 `Stream` 已经有了一个基本的了解，下一步我们将学习更多关于 `bloc` 库中的核心模块: `Cubit`。

## Cubit

> `Cubit` 类继承自 `BlocBase` 的类，并且可以扩展到管理任何类型的状态。

![Cubit Architecture](../assets/cubit_architecture_full.png)

一个 `Cubit` 可以公开触发状态变化的函数。

> 状态是从 `Cubit` 中输出的，代表应用程序状态的一部分。可以通知 UI 组件状态，并根据当前状态重绘其自身的某些部分。

> **提示**: 有关 `Cubit` 来源的更多信息请查看 [以下 Github Issue](https://github.com/felangel/cubit/issues/69).

### 创建一个 Cubit

我们可以像这样创建一个 `CounterCubit`：

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit.dart.md ':include')

创建 `Cubit` 时，我们需要定义 `Cubit` 将要管理的状态类型。对于上面的 `CounterCubit`，状态可以通过 `int` 来表示，但在更复杂的情况下，可能有必要使用 `class`（类）而不是原始类型。

创建 `Cubit` 时，我们需要做的第二件事是指定初始状态。我们可以通过使用初始状态的值调用 `super` 来实现。在上面的代码段中，我们在内部将初始状态设置为 0，但我们也可以通过接受外部值来使 `Cubit` 更加灵活：

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_initial_state.dart.md ':include')

这将允许我们实例化具有不同初始状态的 `CounterCubit` 实例，例如：

[main.dart](../_snippets/core_concepts/counter_cubit_instantiation.dart.md ':include')

### 状态变化

> 每个 `Cubit` 都有能力通过 `emit` 输出一个新状态。

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_increment.dart.md ':include')

在上面的代码片段中，`CounterCubit` 公开了一个名为 `increment` 的公共方法，可以从外部调用该方法，以通知 `CounterCubit` 增加其状态。当调用 `increment` 时，我们可以通过 `state` 获取器访问 `Cubit` 的当前状态，并通过向当前状态加 `1` 来发出 `emit` 新状态。

!> `emit` 函数受到保护，这意味着它只能在 `Cubit` 内部使用。

### 使用 Cubit

现在，我们可以使用已经实现的 `CounterCubit`！

#### 基础用例

[main.dart](../_snippets/core_concepts/counter_cubit_basic_usage.dart.md ':include')

在上面的代码片段中，我们首先创建一个 `CounterCubit` 实例。然后，我们打印 `Cubit` 的当前状态，即初始状态（因为尚未发出新状态）。接下来，我们调用 `increment` 函数来触发状态更改。最后，我们再次打印从 `0` 到 `1` 的 `Cubit` 的状态，然后关闭 `Cubit` 以关闭内部状态流。

#### 流的用例

由于 `Cubit` 是 `Stream` 的一种特殊类型，我们还可以订阅 `Cubit` 来实时更新其状态：

[main.dart](../_snippets/core_concepts/counter_cubit_stream_usage.dart.md ':include')

在上面的代码段中，我们正在订阅 `CounterCubit`，并在每次状态更改时调用 `print` 函数。然后，我们调用 `increment` 函数，它将发出一个新状态。最后，当我们不再希望接收更新并关闭 `Cubit` 时，我们在 `subscription` 上调用 `cancel`。

> **提示**: 在此示例中，添加了 `await Future.delayed(Duration.zero)`，以避免立即取消订阅。

!> 在 `Cubit` 上调用 `listen` 时，将仅接收后续状态更改

### 观察 Cubit

>当 `Cubit` 发出新状态时，将有一个 `改变` 发生。我们可以通过重写 `onChange` 方法来观察给定 `Cubit` 的所有变化。

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_on_change.dart.md ':include')

然后，我们可以与 `Cubit` 交互并观察所有输出到控制台的改变。

[main.dart](../_snippets/core_concepts/counter_cubit_on_change_usage.dart.md ':include')

上面的示例将输出的结果：

[script](../_snippets/core_concepts/counter_cubit_on_change_output.sh.md ':include')

?> **注意**：在 `Cubit` 状态更新之前发生 `Change` 改变。一个 `改变` 由 `currentState` 和 `nextState` 组成。

#### BlocObserver (Bloc观察者)

使用 `bloc` 库的另一个好处是，我们可以在一处访问所有 `变化`。即使在此应用程序中只有一个 `Cubit`，在大型应用程序中也很常见，有许多 `Cubits` 管理应用程序状态的不同部分。

如果我们希望能够对所有 `变化` 做出响应，我们可以简单地创建自己的 `BlocObserve` (Bloc观察者)来观察改变。

[simple_bloc_observer_on_change.dart](../_snippets/core_concepts/simple_bloc_observer_on_change.dart.md ':include')

?> **注意**：我们要做的就是继承 `BlocObserver` 类并重写 `onChange` 方法。

为了使用 `SimpleBlocObserver`，我们只需要调整 `main` 函数：

[main.dart](../_snippets/core_concepts/simple_bloc_observer_on_change_usage.dart.md ':include')

上面的代码段将输出的结果：

[script](../_snippets/core_concepts/counter_cubit_on_change_usage_output.sh.md ':include')

?> **注意**：首先调用内部的 `onChange` 替代，然后在 `BlocObserver` 中调用 `onChange`。

?> **提示**: 在 `BlocObserver` 中，除了 `变化` 本身之外，我们还可以访问 `Cubit` 实例。

### 错误处理

> 每个 `Cubit` 都有一个` addError` 方法，该方法可用于指示发生了错误。

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_on_error.dart.md ':include')

?> **注意**：`onError` 方法可以在 `Cubit` 中被重写，以处理特定 `Cubit` 的所有错误。

也可以在 `BlocObserver` 中重写 `onError` 方法以全局处理所有报告的错误。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_error.dart.md ':include')

如果我们再次运行同一程序，我们应该看到以下输出结果：

[script](../_snippets/core_concepts/counter_cubit_on_error_output.sh.md ':include')

?> **注意**：与 `onChange` 一样，内部 `onError` 重写在全局 `BlocObserver` 重写之前被调用。

## Bloc

> `Bloc` 是一个更高级的类，它依赖`事件`来触发`状态`的改变而不是函数。 `Bloc` 也扩展了 `BlocBase` ，这意味着它有着类似于 `Cubit` 的API。然而， `Blocs` 不是在 `Bloc` 上调用`函数`然后直接发出一个新的`状态`，而是接收`事件`并且将传入的`事件`转换为`状态`传出。

![Bloc Architecture](../assets/bloc_architecture_full.png)

### 创建一个 Bloc

创建一个 `Bloc` 类似于创建一个 `Cubit`，除了定义我们将要管理的状态外，我们还必须定义 `Bloc` 使其能够处理事件。

> 事件是将输入进 `Bloc` 中。通常是为了响应用户交互（例如按钮按下）或生命周期事件（例如页面加载）而添加它们。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

就像创建 `CounterCubit` 一样，我们必须指定初始状态，方法是通过 `super` 方法将其传递给父类。

### 状态改变

`Bloc` 要求我们通过 `on<Event>` 上注册事件处理程序 API, 而不是在 `Cubit` 中的功能. 事件处理程序负责将任何传入事件转换为零或多个传出状态.

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_event_handler.dart.md ':include')

?> 💡 **提示**: `EventHandler` 可以访问添加的活动以及一个 `Emitter` 它可以用于响应传入事件而发出零个或多个状态.

然后我们可以更新 `EventHandler` 来处理 `CounterIncrementPressed` 事件：

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_increment.dart.md ':include')

在上面的代码段中，我们已经注册了一个 `EventHandler` 句柄管理所有的 `CounterIncrementPressed` 事件. 每个 `CounterIncrementPressed` 事件我们可以通过 `state` getter 方法访问 bloc 的当前状态和通过 `emit(state + 1)` 改变状态.

?> **注意**：由于 `Bloc` 类继承了 `BlocBase`，因此我们可以随时通过 `state` getter 来访问 `bloc` 的当前状态，就像使用 Cubit 一样。

!> Bloc 永远不要直接发出新状态。相反，必须响应 `EventHandler` 中的传入事件，输出每个状态更改。

!> Bloc 和 Cubits 都会忽略重复的状态。如果我们产生或发出状态 `State nextState` 当 `State == nextState` 时，则不会发生状态变化。

### 使用 Bloc

至此，我们可以创建 `CounterBloc` 的实例并将其使用！

#### 基础用例

[main.dart](../_snippets/core_concepts/counter_bloc_usage.dart.md ':include')

在上面的代码片段中，我们首先创建一个 `CounterBloc` 实例。然后，我们打印 `Bloc` 的当前状态，该状态为初始状态（因为尚未发出新状态）。接下来，我们添加 `CounterIncrementPressed` 事件来触发状态改变。最后，我们再次打印从 `0` 到 `1` 的 `Bloc` 状态，并且在 `Bloc` 上调用 `close` 关闭内部状态流。

?> **注意**：添加了 `await Future.delayed(Duration.zero)` 以确保我们等待下一个事件循环迭代（允许 `EventHandler` 处理增量事件）。

#### Stream 的用例

就像 `Cubit` 一样，`Bloc` 是 `Stream` 的一种特殊类型，这意味着我们还可以订阅 `Bloc` 来实时更新其状态：

[main.dart](../_snippets/core_concepts/counter_bloc_stream_usage.dart.md ':include')

在上面的片段中，我们订阅了 `CounterBloc` 并在每个状态改变时调用 print 。然后我们添加 `CounterIncrementPressed` 事件，该事件触发 `on<CounterIncrementPressed>` `EventHandler` 并且发出一个新的状态。最后，当我们不想再接收更新时，我们在订阅上调用 `cancel` ，并关闭 `Bloc`。

?> **注意**：在此示例中添加了 `await Future.delayed(Duration.zero)`，以避免立即取消订阅。

### 观察一个 Bloc

由于所有 `Bloc` 都扩展了 `BlocBase`，因此我们可以使用 `onChange` 观察 `Bloc` 的所有状态变化。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_change.dart.md ':include')

接下来我们可以将 `main.dart` 更新为：

[main.dart](../_snippets/core_concepts/counter_bloc_on_change_usage.dart.md ':include')

现在，如果我们运行上面的代码片段，输出将是：

[script](../_snippets/core_concepts/counter_bloc_on_change_output.sh.md ':include')

`Bloc` 和 `Cubit` 之间的主要区别因素是，由于 `Bloc` 是事件驱动的，因此我们也能够捕获有关触发状态更改的信息。

我们可以通过重写 `onTransition` 来做到这一点。

> 从一种状态到另一种状态的转换称为 `Transition`。`Transition` 由当前状态，事件和下一个状态组成

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

如果然后从前重新运行相同的 `main.dart` 代码段，则应看到以下输出：

[script](../_snippets/core_concepts/counter_bloc_on_transition_output.sh.md ':include')

?> **注意**：`onTransition` 在 `onChange` 之前被调用，并且包含触发从 `currentState` 到 `nextState` 改变的事件。

#### BlocObserver (Bloc观察者)

和以前一样，我们可以在自定义 `BlocObserver` 中重写` onTransition`，以观察从一个位置发生的所有过渡。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_transition.dart.md ':include')

我们可以像之前一样初始化 `SimpleBlocObserver`：

[main.dart](../_snippets/core_concepts/simple_bloc_observer_on_transition_usage.dart.md ':include')

现在，如果我们运行上面的代码片段，输出应如下所示：

[script](../_snippets/core_concepts/simple_bloc_observer_on_transition_output.sh.md ':include')

?> **注意**：首先调用 `onTransition`（在全局之前先于本地），然后调用 `onChange`。

`Bloc` 实例的另一个独特功能是，它们使我们能够重写 `onEvent`，无论何时将新事件添加到 `Bloc` 都会调用 `onEvent`。就像 `onChange` 和 `onTransition` 一样，`onEvent` 可以在本地或全局重写。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_event.dart.md ':include')

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

我们可以像以前一样运行相同的 `main.dart`，并且应该看到以下输出：

[script](../_snippets/core_concepts/simple_bloc_observer_on_event_output.sh.md ':include')

?> **注意**：一旦添加事件，就会调用 `onEvent`。本地 `onEvent` 在 `BlocObserver` 中的全局 `onEvent` 之前被调用。

### 错误处理

就像 `Cubit` 一样，每个 `Bloc` 都有一个 `addError` 和 `onError` 方法。我们可以通过从 `Bloc` 内部的任何地方调用 `addError` 来表明发生了错误。然后我们可以像重写 `Cubit` 一样通过重写 `onError` 来对所有错误做出反应。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

如果我们重新运行与以前相同的 `main.dart`，我们可以看到报告错误时的样子：

[script](../_snippets/core_concepts/counter_bloc_on_error_output.sh.md ':include')

?> **注意**：首先调用本地 `onError`，然后调用 `BlocObserver` 中的全局 `onError`。

?> **注意**：对于 `Bloc` 和 `Cubit` 实例，`onError` 和 `onChange` 的工作方式完全相同。

!> 在 `EventHandler` 中发生的任何未处理的异常也会报告给 `onError`。

## Cubit vs. Bloc

既然我们已经介绍了 `Cubit` 和 `Bloc` 类的基础知识，您可能想知道何时应该使用 `Cubit` 和何时使用 `Bloc`。

### Cubit 的优势

#### 简单

使用 `Cubit` 的最大优点之一就是简单。当创建一个 `Cubit` 时，我们只需要定义状态以及我们想要公开的改变状态的函数即可。相比之下，创建 `Bloc` 时，我们必须定义状态、事件和 `EventHandler` 实现。这使得 `Cubit` 更容易理解，并且涉及的代码更少。

现在让我们看一下两个计数器实现：

##### CounterCubit

[counter_cubit.dart](../_snippets/core_concepts/counter_cubit_full.dart.md ':include')

##### CounterBloc

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_full.dart.md ':include')

Cubit 实现更简洁，而不是单独定义事件，而是像事件一样。此外，在使用`Cubit`时，我们可以简单地从任何地方调用 `emit`，以便触发状态变化。

### Bloc 的优势

#### 可追溯性

使用 `Bloc` 的最大优势之一就是知道状态变化的顺序以及触发这些变化的确切原因。对于对于应用程序功能至关重要的状态，使用更多事件驱动的方法来捕获状态变化之外的所有事件可能会非常有益。

一个常见的用例可能是管理 `AuthenticationState`。为了简单起见，假设我们可以通过 `enum` 来表示 `AuthenticationState`：

[authentication_state.dart](../_snippets/core_concepts/authentication_state.dart.md ':include')

关于应用程序的状态可能从 `authenticated` 更改为 `unauthenticated `的原因可能有很多原因。例如，用户可能点击了一个注销按钮，并要求退出该应用程序。另一方面，也许用户的访问令牌已被撤消，并被强制注销。当使用 `Bloc` 时，我们可以清楚地跟踪应用程序状态如何达到特定状态。

[script](../_snippets/core_concepts/authentication_transition.sh.md ':include')

上面的 `Transition` 为我们提供了了解状态发生变化的所有信息。如果我们使用 `Cubit` 来管理 `AuthenticationState`，那么我们的日志将如下所示：

[script](../_snippets/core_concepts/authentication_change.sh.md ':include')

这告诉我们用户已注销，但没有说明为什么这对于调试和了解应用程序状态随时间的变化可能至关重要。

#### 高级的事件转换

`Bloc` 优于 `Cubit` 的另一个领域是我们需要利用反应性运算符，例如：`buffer`, `debounceTime`, `throttle` 等。

`Bloc` 有一个事件接收器，它使我们能够控制和转换事件的传入流。

例如，如果我们正在构建一个实时搜索，我们可能希望对避免后端的重复请求操作，以避免受到速率限制以及降低后端的成本/负载。

使用 `Bloc`，我们可以重写 `EventTransformer`，以改变 `Bloc` 处理传入事件的方式。

[counter_bloc.dart](../_snippets/core_concepts/debounce_event_transformer.dart.md ':include')

使用以上代码，我们可以用很少的其他代码轻松地实现事件防抖。

?> 💡 **提示**: 查看 [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) 对于一系列的一组活动事件变换器.

?> 💡 **提示**：如果仍然不确定要使用哪种，请从 `Cubit` 开始，然后可以根据需要将其重构或放大为 `Bloc`。
