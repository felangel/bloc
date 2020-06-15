# Flutter 无限列表教程

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

>在这个教程中, 我们会使用Flutter和bloc库实现无限长列表的应用程序. 它会从网络请求数据, 并且随着用户的滚动载入列表.

![demo](../assets/gifs/flutter_infinite_list.gif)

## 项目的建立

我们可以从建立一个Flutter项目开始

[script](../_snippets/flutter_infinite_list_tutorial/flutter_create.sh.md ':include')

我们可以用以下的代码替换pubspec.yaml中的内容

[pubspec.yaml](../_snippets/flutter_infinite_list_tutorial/pubspec.yaml.md ':include')

然后安装所有依赖和项目

[script](../_snippets/flutter_infinite_list_tutorial/flutter_packages_get.sh.md ':include')

## REST API

我们会使用[jsonplaceholder](http://jsonplaceholder.typicode.com)作为我们这个示例项目的数据源.

?> **jsonplaceholder**是一个在线的REST API. 它可以生成用于测试的虚假数据, 正好可以用于我们的原型应用开发.

你可以打开一个新的浏览器页面, 访问 https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2, 
看看API会返回什么.

[posts.json](../_snippets/flutter_infinite_list_tutorial/posts.json.md ':include')

?> **附注:** 在url中我们设定了start和limit作为GET请求的查询参数

好的, 现在我们知道数据长的是什么样子了. 让我们来建立数据模型吧

## 数据模型

创建`post.dart`. 我们会在这里创建Post的对象模型.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post.dart.md ':include')

`Post` 就只是一个记录了 `id`, `title` 和 `body` 的类.

?> 我们重写了`toString`方法, 因为这样可以自定义`Post`对象的字符串表示. 我们之后会用到它.

?> 我们继承了[`Equatable`](https://pub.dev/packages/equatable), 这样我们就可以比较`Post`对象了. 默认状态下, 相等运算符只有在被比较对象是同一对象时返回true.

现在我们有了`Post`对象的模型. 下一步让我们开始写**业务逻辑组件(bloc)**

## Post 事件(Events)

在我们开始实现bloc前, 我们需要思考`PostBloc`要完成什么任务.

总体来看, 它会响应用户的输入(滚动屏幕)和请求更多的Post数据, 并且送给表现层显示给用户. 让我们先创建我们的`Event`

我们的`PostBloc`每次只响应一个Event(事件); 当表现层需要更多Post展示时, 他将会创建和添加`PostFetched`事件. 
因为我们的`PostFetched`事件是一种`PostEvent`, 所以我们可以像这样实现`bloc/post_event.dart`.

[post_event.dart](../_snippets/flutter_infinite_list_tutorial/post_event.dart.md ':include')

复习一下之前说过的内容, `PostBloc`会接收`PostEvents(Post事件)`, 并且把他们转化成`PostStates(Post状态)`. 
我们已经定义了所有我们需要用到的`PostEvents`(只有一个PostFetched), 接下来让我们定义我们的`PostState`.

## Post 状态(States)

我们的表现层需要以下的几部分信息:

- `PostInitial`(Post 未初始化) - 会告诉表现层需要渲染加载进度条. 加载一批新的post的时候会是这种状态.

- `PostSuccess`(Post 已加载) - 会告诉表现层已经有了可以渲染的内容.
  - `posts`- 是之后会显示在屏幕上的`List<Post>`
  - `hasReachedMax`- 会告诉表现层它是否达到了最大数量的posts
- `PostFailure`- 会告诉表现层在请求posts的时候遇到了错误

我们现在可以创建`bloc/post_state.dart`并且实现它了, 像这样

[post_state.dart](../_snippets/flutter_infinite_list_tutorial/post_state.dart.md ':include')

?> 我们实现了`copyWith`, 这样我们就可以从已有的`PostSuccess`对象复制一个实例, 并且还能很方便的修改其中任意个属性(之后用起来很方便).

现在我们的`Events`和`States`都实现好了, 接下来我们可以创建`PostBloc`.

为了更方便的在一条语句中引入`States`和`Events`, 我们可以在`bloc/bloc.dart`中把他们都export出来. (在下一章会把`post_bloc.dart`也在这里export出去)

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc_initial.dart.md ':include')

## Post Bloc

简单起见, `PostBloc`会直接依赖`http client`; 然而, 在生产应用中, 你可能希望注入一个客户端api同时使用repository设计模式[相关文档]](./architecture.md).

让我们新建`post_bloc.dart`然后在里面写一个空的`PostBloc`类吧.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial.dart.md ':include')

?> **附注:**  只是从类的声明看, 我们就可以知道PostBloc会接受`PostEvents`的输入, 并输出`PostStates`.

我们可以开始实现`initialState`了. 在接收到任何事件(Event)之前, `initialState`将会成为`PostBloc`的默认状态(default State).

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial_state.dart.md ':include')

下一步, 我们需要实现`mapEventToState`方法. 每次加入新的`PostEvent`的时候我们都会调用这个函数.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_map_event_to_state.dart.md ':include')

当一个新的state出现的时候, 我们的`PostBloc`会`yield`(生成一个新的值), 因为函数返回了一个`Stream<PostState>`.
你可以参考[核心概念](https://bloclibrary.dev/#/coreconcepts?id=streams)来了解更多关于`Streams`和其他核心概念知识.

现在, 每次加入新的`PostEvent`时, 如果这个event(事件)是`PostFetched`并且还有更多可加载的post的话,
`PostBloc`就会请求接下来的20个post.

如果我们的请求数量超过了post的最大数量(100)的话, 这个API会返回一个空数组. 所以如果我们收到了一个空数组的话, bloc会`yield`当前的状态并把`hasReachedMax`设成true.

如果收不到post的话, 这里就会抛出一个异常, 函数就会随之`yield`一个`PostFailure()`.

如果能收到post的话, 函数就会返回保存着所有post的`PostSuccess`对象.

这里我们可以做一个优化: 我们可以给`Event(事件)``debounce(消除抖动)`, 从而防止给API发出过多的请求.
通过重写`PostBloc`的`transform`方法达成这一点.

?> **附注:** 重写`transform`让我们能在调用`mapEventToState`前对`Stream<Event>`进行变换. 这些变换包括`distinct()`, `debounceTime()`等等.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_transform_events.dart.md ':include')

`PostBloc`的完成品应该看起来像是这样

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc.dart.md ':include')

别忘了在`bloc/bloc.dart`加入我们刚写的`PostBloc`!

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc.dart.md ':include')

太好了! 现在我们已经完成了业务逻辑的实现. 接下来我们就只要实现表现层就好了.

## 表现层

在`main.dart`中, 我们可以先在主函数调用`runApp`来渲染我们的root(根) widget.

在`App`widget中, 我们使用`BlocProvider`来创建 和 给subtree(指`BlocProvider`下的子widgets)提供`PostBloc`的实例.
我们给bloc添加了一个`PostFetched`事件, 这样当应用载入的时候, 它就会请求最开始的一批post了.

[main.dart](../_snippets/flutter_infinite_list_tutorial/main.dart.md ':include')

接下来, 我们需要实现`HomePage`widget. `HomePage`会展示加载好的post并与`PostBloc`进行交互.

[home_page.dart](../_snippets/flutter_infinite_list_tutorial/home_page.dart.md ':include')

?> `HomePage`是一个`StatefulWidget`(有状态的widget), 因为它需要维护`ScrollController`. 在`initState`, 我们给`ScrollController`添加了监听器, 这样我们就可以响应滚动事件了. 我们可以通过`BlocProvider.of<PostBloc>(context)`来访问`PostBloc`实例.

继续下去, 我们的build方法会返回一个`BlocBuilder`. `BlocBuilder`是[flutter_bloc 包](https://pub.dev/packages/flutter_bloc)中提供的一个flutter widget. 当bloc的状态更新时, `BlocBuilder`会build(搭建)一个widget. 任何`PostBloc`的状态改变都会导致`BlocBuilder`的build函数被调用, 相应的`PostState`也会被当做参数传入这个build函数.

!> 记得在StatefulWidget声明周期结束时释放`ScrollController`.

当有任何用户滚动时, 我们会计算现在距离页面底部还有多远. 如果 距离≤`_scrollThreshold` 的话, 我们
就添加一个`PostFetched`事件来加载更多post.

接下来, 我们需要实现`BottomLoader` widget. 它会告诉用户我们正在加载更多posts.

[bottom_loader.dart](../_snippets/flutter_infinite_list_tutorial/bottom_loader.dart.md ':include')

最后, 我们需要实现`PostWidget`来渲染每个单独的post的内容.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post_widget.dart.md ':include')

到此为止, 我们的应用应该可以正确的运行了; 但是除此之外, 我们还可以做一个优化.

作为使用bloc库的额外好处, 我们可以在同一个地方操作所有的`Transitions(状态转移)`

> 从一个状态转变成另一个状态的过程叫做`Transition(状态转移)`

?> 一个`Transition(转变)`由 `当前状态`, `事件`, 和`下一个状态` 组成.

虽然在这个应用中我们只有一个bloc, 但是在真正的大型应用程序中, 使用多个bloc管理应用的不同部分的`state(状态)`也很常见

如果我们在每次`Transition(状态转移)`时都做一些事情来响应这些状态转移的话, 我们只需要创建自己的`BlocDelegate`就可以了.

[simple_bloc_delegate.dart](../_snippets/flutter_infinite_list_tutorial/simple_bloc_delegate.dart.md ':include')

?> 我们只需要继承`BlocDelegate`并重写`onTransition`方法.

为了让bloc知道我们刚写的`SimpleBlocDelegate`我们只需要像这样稍微改动main函数

[main.dart](../_snippets/flutter_infinite_list_tutorial/bloc_delegate_main.dart.md ':include')

现在, 当我们运行应用, 每次`Transition(状态转移)`发生时我们都可以在终端看到打印出的文本.

?> 实践中, 你可以创建多个`BlocDelegates`. 因为每个state(状态)改变都会被记录下来, 我们能很容易的在**同一个地方**让应用程序记录**所有**来自用户的交互和状态改变

这就是我要介绍的所有事情了! 我们已经成功的用[bloc](https://pub.dev/packages/bloc)和[flutter_bloc](https://pub.dev/packages/flutter_bloc)实现了无限列表, 并将表现层和业务逻辑分离开来.

`HomePage(主页面)`完全不知道`Post`从哪里来, 也完全不知道`Post`的数据是怎么加载到的. `PostBloc`也同样不知道`State(状态)`是怎么被渲染到屏幕的, 他只是很简单的把`Event(事件)`转化成`State(事件)`

在[这里](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list)你可以找到这个例子的完整代码
