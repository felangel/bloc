# Naming Conventions

!> The following naming conventions are simply recommendations and are completely optional. Feel free to use whatever naming conventions you prefer. You may find some of the examples/documentation do not follow the naming conventions mainly for simplicity/conciseness. These conventions are strongly recommended for large projects with multiple developers.

## Event Conventions

> Events should be named in the **past tense** because events are things that have already occurred from the bloc's perspective.

### Anatomy

`BlocSubject` + `Noun (optional)` + `Verb (event)`

?> Initial load events should follow the convention: `BlocSubject` + `Started`

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

> States should be nouns because a state is just a snapshot at a particular point in time.

### Anatomy

`BlocSubject` + `Verb (action)` + `State`

?> `State` should be one of the following: `Initial` | `Success` | `Failure` | `InProgress` and
initial states should follow the convention: `BlocSubject` + `Initial`.

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
