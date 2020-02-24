# 命名惯例

!> 以下命名约定仅是建议，并且是完全自选的。随意使用您喜欢的任何命名约定。您可能会发现某些示例/文档不遵循命名约定，主要是出于简化的目的。对于具有多个开发人员的大型项目，还是强烈建议使用这些约定。

## 事件惯例 （Event Conventions）

> 事件应以**过去时**来命名，因为从bloc的角度来看，事件是已经发生的事情.

### 构成

`Bloc主题` + `名词 (可选)` + `动词 (event)`

?> 初始加载事件应遵循以下约定：`BlocSubject` +`Started`

#### 例子

✅ **推荐的命名**

`CounterStarted`
`CounterIncremented`
`CounterDecremented`
`CounterIncrementRetried`

❌ **不推荐的命名**

`Initial`
`CounterInitialized`
`Increment`
`DoIncrement`
`IncrementCounter`

## 命名状态（State）

> 状态应该是名词，因为状态只是特定时间点的快照。

### 构成

`BlocSubject` + `Verb (action)` + `State`

?> 状态（`State`）应为以下之一： `成功`| `失败`| `在过程中`和初始状态应遵循以下约定：`BlocSubject` +`Initial`。

#### 例子

✅ **推荐的命名**

`CounterInitial`
`CounterLoadInProgress`
`CounterLoadSuccess`
`CounterLoadFailure`

❌ **不推荐的命名**

`Initial`
`Loading`
`Success`
`Succeeded`
`Loaded`
`Failure`
`Failed`
