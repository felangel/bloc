# 命名约定

!> 以下命名约定仅是建议，并且是完全自选的。随意使用您喜欢的任何命名约定。您可能会发现某些示例/文档不遵循命名约定，主要是出于简化的目的。对于具有多个开发人员的大型项目，还是强烈建议使用这些约定。

## 事件约定 （Event Conventions)

> 事件应以**过去时**来命名，因为从bloc的角度来看，事件是已经发生的事情.

### 构成

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> 初始加载事件应遵循以下约定：`BlocSubject` +`Started`

!> 基本的事件类应该被命名为：`BlocSubject` + `Event`

#### 例子

✅ **推荐的命名**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **不推荐的命名**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## 状态名约定（State)

> 状态应该是名词，因为状态只是特定时间点的快照。有两种常见的方式来表示状态:使用子类或使用单个类。

### 构成

#### 子类

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> 当将状态表示为多个子类时，`State` 应该是以下其中之一：`Initial` | `Success` | `Failure` | `InProgress` 并且初始状态应该遵循约定：`BlocSubject` + `Initial`。

#### 单个类

[state](../_snippets/bloc_naming_conventions/single_state_anatomy.md ':include')

?> 当将状态表示为单个基类时，应该使用名为 `BlocSubject` + `Status` 的 enum 来表示状态的这些状态: `initial` | `success` | `failure` | `loading` 。

!> 状态基类应该总是被命名为： `BlocSubject` + `State`。

#### 例子

✅ **推荐的命名**

##### 子类

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

##### 单个类

[states_good](../_snippets/bloc_naming_conventions/single_state_examples_good.md ':include')

❌ **不推荐的命名**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
