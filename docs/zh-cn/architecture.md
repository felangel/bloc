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

数据提供者通常会公开简单的API来执行[CRUD]（https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) 操作。

作为数据层的一部分，我们可能有一个`createData`，`readData`，`updateData`和`deleteData`的方法。

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repository

> 存储库层是与Bloc层进行通信的一个或多个数据提供程序的包装。

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

如您所见，我们的存储库层可以与多个数据提供者进行交互，并对数据执行转换，然后再将结果传递给业务逻辑层。

## Bloc 业务逻辑层 (Business Logic) Layer

> Bloc层的职责是以新状态（State) 响应表示层(Presentation)的事件(Event)。Bloc层可以依赖一个或多个存储库来检索建立应用程序状态(State)所需的数据。

将块层视为用户界面（表示层) 和数据层之间的桥梁。Bloc层接受由用户输入生成的事件(Event)，然后与存储库进行通信，以建立供表示层使用的新状态(State)。

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Bloc和Bloc之间的交流

> 每个bloc都有一个状态流（Stream)，其他bloc可以订阅该状态流，以便对bloc内部的变化做出反应。

`MyBloc`可以依赖于`其他Bloc`，以便对它们的状态(State)变化做出反应。在下面的示例中，`MyBloc`依赖于`OtherBloc`，并且可以响应` OtherBloc`中的状态(State)更改而`添加`事件(Event)。为了避免内存泄漏，在`MyBloc`的`close`替代中关闭了`StreamSubscription`。

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## 表现层（也可理解为用户界面)

> 表示层的职责是弄清楚如何基于一个或多个bloc的状态（State) 进行渲染。另外，它应该处理用户输入和应用程序生命周期事件。

大多数应用程序流程将从`AppStart`事件开始，该事件触发应用程序获取一些数据以呈现给用户。

在这种情况下，表示层将添加一个`AppStart`事件。

另外，表示层将必须根据bloc层的状态(State)确定要在屏幕上呈现的内容。

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

到目前为止，我们有的一些代码片段都已经相当高级了。在教程部分，我们将在构建几个不同的示例应用程序时将所有这些内容放在一起。
