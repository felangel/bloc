# 构架

![Bloc的构架](../assets/bloc_architecture.png) 

使用Bloc可以将应用程序分为三层：

-  表现层（Presentation)
-  业务逻辑（Business Logic)
-  数据层（Data)
  - 数据源/库（Repository)
  - 数据提供者（Data Provider)

我们将从最低层（距离用户界面最远的层)开始，一直到表示层

## 数据层（Data Layer)

> 数据层的责任是从一个或多个数据源或库中检索/处理数据。

数据层可以被分为以下两部分：

- 数据源/库
- 数据提供者

该层是应用程序的最低层，并且与数据库，网络请求和其他异步数据源进行交互。

### 数据提供者（Data Provider)

> 数据提供者的责任是提供原始数据。数据提供者所提供的数据应该是能在各个语言间通用。

数据提供者通常会公开简单的API来执行[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) 操作。

作为数据层的一部分，我们可能有一个`createData`，`readData`，`updateData`和`deleteData`的方法。

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repository

> 存储库层是与Bloc层进行通信的一个或多个数据提供者的包装。

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

如您所见，我们的存储库层可以与多个数据提供者进行交互，并对数据执行转换，然后再将结果传递给业务逻辑层。

## Bloc 业务逻辑层 (Business Logic) Layer

> 业务逻辑层的职责是用新状态响应来自表示层的输入。这一层可以依赖一个或多个存储库来检索构建应用程序状态所需的数据。

可以将业务逻辑层看作是用户界面(表示层)和数据层之间的桥梁。业务逻辑层收到来自表示层的事件/操作通知，然后与存储库进行通信，以构建一个供表示层使用的新状态。

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Bloc和Bloc之间的交流

因为bloc会暴露stream，所以创建一个监听其它bloc的bloc可能是很有诱惑力的。但是你不应该这样做，有比使用下面的代码更好的选择:

[do_not_do_this_at_home.dart](../_snippets/architecture/do_not_do_this_at_home.dart.md ':include')

虽然上面的代码是没有错误的(甚至在自己清除之后)，但它有一个更大的问题:它在两个bloc之间创建了依赖关系。

通常，应该不惜一切代价避免同一体系架构层中两个实体之间的依赖关系，因为这会造成难以维护的紧密耦合。由于bloc位于业务逻辑体系结构层中，任何bloc都不应该知道任何其他bloc。

![Application Architecture Layers](../assets/architecture.png)

bloc应该只通过事件和注入的存储库接收信息(也就是在构造函数中给bloc的存储库)。

如果一个bloc需要对另一个bloc做出回应，那么你还有两个选择。您可以将问题向上推一层(进入表现层(presentation layer))，或者向下推一层(进入领域层(domain layer))。

#### 通过表现层连接bloc

你可以使用 `BlocListener` 监听一个bloc，并且在第一个bloc改变时添加一个消息到其它bloc。

[blocs_presentation.dart.md](../_snippets/architecture/blocs_presentation.dart.md ':include')

上面的代码阻止了 `SecondBloc` 需要知道 `FirstBloc`，从而鼓励松耦合。这个[天气](zh-cn/flutterweathertutorial.md)应用[使用这个技术](https://github.com/felangel/bloc/blob/b4c8db938ad71a6b60d4a641ec357905095c3965/examples/flutter_weather/lib/weather/view/weather_page.dart#L38-L42)根据接收到的天气信息改变应用主题(theme)。

在某些情况下，你可能不希望在表示层中耦合两个bloc。相反，两个bloc共享同一个数据源并在数据更改时进行更新通常是有意义的。

#### 通过领域层连接bloc

两个bloc能从存储库中监听流，并在存储库数据变化时独立的更新它们的状态。在大型企业应用程序中，使用响应式存储库来保持状态同步是很常见的。

首先创建或使用提供数据 `Stream` 的存储库。例如，下面的存储库展示了一直循环app创意的流:

[app_ideas_repo.dart.md](../_snippets/architecture/app_ideas_repo.dart.md ':include')

相同的存储库可以注入到每个需要对新app创意做出响应的bloc中。下面是一个 `AppIdeaRankingBloc` ，它为上面的库中每个传入的app创意产生一个状态:

[blocs_domain.dart.md](../_snippets/architecture/blocs_domain.dart.md ':include')

更多关于在Bloc中使用流的信息，查看[如何在Bloc使用流(stream)和并发(concurrency)](https://verygood.ventures/blog/how-to-use-bloc-with-streams-and-concurrency)。

## 表现层（也可理解为用户界面)

> 表示层的职责是弄清楚如何基于一个或多个bloc的状态（State) 进行渲染。另外，它应该处理用户输入和应用程序生命周期事件。

大多数应用程序流程将从`AppStart`事件开始，该事件触发应用程序获取一些数据以呈现给用户。

在这种情况下，表示层将添加一个`AppStart`事件。

另外，表示层将必须根据bloc层的状态(State)确定要在屏幕上呈现的内容。

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

到目前为止，我们有的一些代码片段都已经相当高级了。在教程部分，我们将在构建几个不同的示例应用程序时将所有这些内容放在一起。
