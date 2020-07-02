# 核心思想

?> 使用前请确保仔细阅读并理解以下部分 [bloc](https://pub.dev/packages/bloc).

有几个核心概念对于理解如何使用Bloc至关重要。

在接下来的部分中，我们将详细讨论它们中的每一个，并逐步研究它们是如何应用于实际应用程序，例如：计数器应用程序。

## 事件（Events)

> 事件(`Event`)会被输入到Bloc中，通常是为了响应用户交互（例如按下按钮)或者是生命周期事件（例如页面加载) 而添加它们。

在设计应用程序时，我们需要退一步考虑，定义用户如何与之交互。例如，在计数器程序中，我们将有两个按钮来增加和减少计数器的值。

当用户点击这两个按钮中的任何一个时，就会通知我们的程序的`"大脑"`，以便它可以响应用户的输入，这是事件起作用的地方。

我们需要能够将递增事件（按加号按钮) 和递减事件（按减号按钮) 通知我们程序的`"大脑"`，因此我们需要定义这些事件(`Event`)。

[counter_event.dart](../_snippets/core_concepts/counter_event.dart.md ':include')

在这种情况下，我们可以使用`enum`表示事件，但是对于更复杂的情况，就会可能需要使用类(也就是我们常说的`class`)，尤其是在要将信息传递给Bloc的情况下。

至此，我们已经定义了我们的第一个事件(`Event`)！注意，到目前为止我们还没有使用过Bloc，也没有任何魔术发生。这些都只是普通的Dart代码而已。

## 状态（States)

> 状态(`State`)是Bloc所输出的东西，是程序状态的一部分。它可以通知UI组件，并根据当前状态(`State`)重建（`build`) 其自身的某些部分。

到目前为止，我们已经定义了我们的应用将会响应的两个事件：`CounterEvent.increment`和`CounterEvent.decrement`。

现在，我们需要定义如何表示应用程序的状态状态(`State`)。

由于我们正在构建的只是一个计数器，因此我们的状态就非常的简单：它只是一个整数，代表了计数器的当前值。

稍后我们将看到拥有更复杂的状态状态(`State`)的示例，但是在现在这种情况下基本的数据类型`Int`就非常适合作为状态状态(`State`)表示。

## 转换（Transitions)

> 从一种状态状态(`State`)到另一种状态状态(`State`)的变动称之为转换（`Transitions`) 。转换是由当前状态，事件和下一个状态组成。

当用户与我们的计数器应用程序进行交互时，他们将触发`递增`（加号按键)和`递减`（减号按键) 事件，这将更新计数器的状态。所有这些状态变化都可以描述为一系列的“转换”。

例如，如果用户打开我们的应用并点击了加号按钮，我们将看到以下`转换`。

[counter_increment_transition.json](../_snippets/core_concepts/counter_increment_transition.json.md ':include')

由于记录了每个状态的更改，所以我们能够非常轻松地对我们的应用程序进行检测，并在任何位置跟踪所有的用户交互和状态更改。此外，这使像时间旅行调试之类的事情成为可能。

## 流（Streams)

?> 查看官方文档 [Dart Documentation](https://dart.dev/tutorials/language/streams) 以获更多关于流（`Streams`) 的信息.

> 流（Stream) 是`一系列非同步`的数据.

Bloc建立在[RxDart]的基础之上(https://pub.dev/packages/rxdart); 然而，Bloc抽象出了所有特定于RxDart的实现细节。

为了使用Bloc，对`Streams`及其工作方式有扎实的了解是`十分必要的`。

> 如果您不熟悉`Streams`，请试着想象一个_有水流过的管道_。管道是“流”（`Stream`)，管道里的水是`非同步的数据`.

我们可以通过编写`async *`函数在Dart中创建一个`Stream`。

[count_stream.dart](../_snippets/core_concepts/count_stream.dart.md ':include')

通过将一个函数标记为`async *`，我们可以使用`yield`作为关键字并返回`Stream`数据。在上面的示例中，我们返回的是一个不超过整数Int边界的整数Stream。

每次我们在`async *`函数中`yield`时，我们都会通过`Stream`推送该数据。

我们可以通过几种方式使用上面的`Stream`。如果我们想编写一个函数来返回所有整数`Stream`的总和，则它可能类似于：

[sum_stream.dart](../_snippets/core_concepts/sum_stream.dart.md ':include')

通过将上面的函数标记为`async`，我们可以使用`await`关键字并返回整数的`Future`数据。在此示例中，我们先等待流(`Stream`)中的每个值然后并返回流(`Stream`)中所有整数的总和。

我们可以像这样将它们放在一起：

[main.dart](../_snippets/core_concepts/streams_main.dart.md ':include')

## Blocs

> Bloc（业务逻辑组件) 是将传入事件的流（`Stream`) 转换为传出状态（`State`) 的流（`Stream`) 的组件。Bloc可以被视为是整个业务逻辑组件的`大脑`。

> 每个Bloc必须扩展（`extend`) 基本Bloc类，因为它是bloc核心包中的一部分。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_class.dart.md ':include')

在上面的代码中，我们把CounterBloc声明为将`CounterEvents`转换为`int`的Bloc。(简单的来说就是我们的大脑Bloc把传进来的事件转换成对应的状态输出了出来， 只是这里的状态是`int`整数，如果不理解可以回看一遍)

> 每个Bloc必须定义一个`初始状态`，该状态是接收任何事件之前的状态(`State`)。

在这种情况下，我们总是希望计数器可以从`0`开始，所以`0`就是我们的初始状态。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_initial_state.dart.md ':include')

> 每个Bloc都必须实现一个名为`mapEventToState`的函数。该函数将传入的事件(`Event`)作为参数，并且必须返回(`return`)被表现层(`Presentation`)所用的新状态(`State`)的流(`Stream`)。我们可以随时使用`state`属性来访问当前的状态. （简单的说就是返回的这状态`State`记住它是一个流`Stream`，要被表现层 _例如前端_ 所用)

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_map_event_to_state.dart.md ':include')

至此，我们就有了一个功能齐全的`CounterBloc`。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc.dart.md ':include')

!> Bloc将会忽略重复的状态（`State`) 。如果Bloc产生`state nextState`状态，并且其中`state == nextState`，则不会发生任何转换，并且不会对流的状态（Stream <State>) 进行任何更改。


此时，您可能想知道`如何将事件通知Bloc?`

> 每个Bloc都有一个`add`方法。 `Add`接受一个事件(`Event`)并触发`mapEventToState`。可以从表示层(`Presentaion`)或在Bloc内部调用`Add`，并通知Bloc新的事件(`Event`)。

我们可以创建一个从0到3的简单应用程序。

[main.dart](../_snippets/core_concepts/counter_bloc_main.dart.md ':include')

!> 默认情况下，将始终按照事件(`Event`)添加的顺序处理事件(`Event`)，并将所有新添加的事件(`Event`)排队。一旦`mapEventToState`执行完毕，就认为事件已被完全处理。

上面的代码中的`Transitions'将会是

[counter_bloc_transitions.json](../_snippets/core_concepts/counter_bloc_transitions.json.md ':include')

不幸的是，在当前状态下，除非覆盖onTransition，否则我们将看不到任何这些转换

> `onTransition`是一种可以被重写以处理每个本地Bloc `Transition`的方法。在更新Bloc的状态（`State`) 之前，将调用`onTransition`。

?> **提示**: `ontransition`是添加特定Bloc的日志记录以及分析的好地方。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_transition.dart.md ':include')

既然我们已经重写了`onTransition`，那么只要有`Transition`发生，我们就可以作出相应。

就像我们可以在Bloc级中处理转换(`Transitions`)一样，我们也可以处理抛出的异常(`Exceptions`)。

> `onError`是一个可以重写以处理每个本地Bloc抛出的`Exception`的方法。默认情况下，所有异常都将被忽略，而`Bloc`功能将不受影响。

?> **注意**: 如果状态流（`Stream`) 收到一个没有`StackTrace`的错误，则stackTrace的参数可能为空`null`。

?> **提示**: `onError`是添加特定Bloc处理错误的好地方。

[counter_bloc.dart](../_snippets/core_concepts/counter_bloc_on_error.dart.md ':include')

既然我们已经覆盖了`onError`，那么只要有异常(`Exception`)抛出，我们就可以对异常作出响应。

## BlocObserver

使用Bloc的另一个好处是，我们可以在一处访问所有的`Transitions`。虽然在这个应用程序中只有一个Bloc，但是在大型应用程序却中常见有许多Blocs管理不同部分的应用程序的状态。

如果我们希望能够对所有转换`Transitions`做出响应，我们可以简单地创建自己的`BlocObserver`。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer.dart.md ':include')

?> **注意**: 我们需要做的就是扩展（`extend`) `BlocObserver`这个类并重写(`override`)其中的`onTransition`方法。

为了让Bloc使用我们的`SimpleBlocObserver`，我们只需要调整我们的`main`函数。

[main.dart](../_snippets/core_concepts/simple_bloc_observer_main.dart.md ':include')

如果我们希望能够对所有添加的事件（`Event`) 做出响应，那么我们也可以在`SimpleBlocObserver`中重写`onEvent`方法。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_on_event.dart.md ':include')

如果我们希望能够对Bloc中抛出的所有异常（`Exceptions`) 做出响应，那么我们也可以在`SimpleBlocObserver`中重写`onError`方法。

[simple_bloc_observer.dart](../_snippets/core_concepts/simple_bloc_observer_complete.dart.md ':include')