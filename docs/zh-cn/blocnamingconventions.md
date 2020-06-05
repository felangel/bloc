# 命名惯例

!> 以下命名约定仅是建议，并且是完全自选的。随意使用您喜欢的任何命名约定。您可能会发现某些示例/文档不遵循命名约定，主要是出于简化的目的。对于具有多个开发人员的大型项目，还是强烈建议使用这些约定。

## 事件惯例 （Event Conventions)

> 事件应以**过去时**来命名，因为从bloc的角度来看，事件是已经发生的事情.

### 构成

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> 初始加载事件应遵循以下约定：`BlocSubject` +`Started`

#### 例子

✅ **推荐的命名**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **不推荐的命名**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## 命名状态（State)

> 状态应该是名词，因为状态只是特定时间点的快照。

### 构成

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> 状态（`State`) 应为以下之一： `成功`| `失败`| `在过程中`和初始状态应遵循以下约定：`BlocSubject` +`Initial`。

#### 例子

✅ **推荐的命名**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **不推荐的命名**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
