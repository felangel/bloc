# 네이밍 컨벤션

!> Naming convention을 따르는 것은 단순히 추천하는 사항이며 완전히 선택적입니다. 선호하시는 naming convention을 따르셔도 좋습니다. Example이나 문서에서 단순함과 간결함을 위해 naming convention을 따르지 않을 수도 있습니다. 이 convention은 많은 개발자가 있는 큰 프로젝트에 강력히 추천합니다.

## Event Conventions

> Event는 bloc 관점에서는 이미 발생한 것들이기 때문에 **과거형**으로 작성해주세요.

### Anatomy

`BlocSubject` + `Noun (optional)` + `Verb (event)`

?> Inition load event는 다음과 같이 표기될 수 있습니다: `BlocSubject` + `Started`

#### Examples

✅ **Good**

`CounterStarted`
`CounterIncremented`
`CounterDecremented`
`CounterIncrementRetried`

❌ **Bad**

`Initial`
`CounterInitialized`
`Increment`
`DoIncrement`
`IncrementCounter`

## State Conventions

> State는 한 시점의 스냅샷이기 때문에 명사로 표현해주세요.

### Anatomy

`BlocSubject` + `Verb (action)` + `State`

?> `State`는 다음 중 하나입니다: `Initial` | `Success` | `Failure` | `InProgress`.
초기 state는 다음과 같이 표기 될 수 있습니다: `BlocSubject` + `Initial`.

#### Examples

✅ **Good**

`CounterInitial`
`CounterLoadInProgress`
`CounterLoadSuccess`
`CounterLoadFailure`

❌ **Bad**

`Initial`
`Loading`
`Success`
`Succeeded`
`Loaded`
`Failure`
`Failed`
