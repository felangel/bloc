# Jmenné konvence

!> Následující jmenné konvence jsou pouze doporučením a jsou kompletně dobrovolné. Neváhejte použít libovolné, vámi preferované, jmenné konvence. Některé z příkladů/dokumentace nedodržují jmenné konvence zejména kvůli jednoduchosti/stručnosti. Tyto konvence jsou velmi doporučovány pro velké projekty s více vývojáři.

## Konvence pro Event

> Eventy by měly být pojmenovány v minulém čase, protože eventy jsou věci, které z pohledu blocu již nastaly.

### Anatomie

`BlocSubject` + `Noun (optional)` + `Verb (event)`

?> Počáteční eventy by se měly řídit konvencí: `BlocSubject` + `Started`

#### Příklady

✅ **Správně**

`CounterStarted`
`CounterIncremented`
`CounterDecremented`
`CounterIncrementRetried`

❌ **Špatně**

`Initial`
`CounterInitialized`
`Increment`
`DoIncrement`
`IncrementCounter`

## State Conventions

> Stavy by měly být podstatná jména, protože stav je jen snímek v určitém časovém okamžiku.

### Anatomy

`BlocSubject` + `Verb (action)` + `State`

?> `State` by měl být jedním z následujících: `Initial` | `Success` | `Failure` | `InProgress` a
počáteční stavy by se měly řídit kovencí: `BlocSubject` + `Initial`.

#### Examples

✅ **Správně**

`CounterInitial`
`CounterLoadInProgress`
`CounterLoadSuccess`
`CounterLoadFailure`

❌ **Špatně**

`Initial`
`Loading`
`Success`
`Succeeded`
`Loaded`
`Failure`
`Failed`
