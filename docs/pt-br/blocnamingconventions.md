# Convenções de nomenclatura

!> As seguintes convenções de nomenclatura são simplesmente recomendações e são completamente opcionais. Sinta-se livre para usar as convenções de nomenclatura que você preferir. Você pode achar que alguns dos exemplos / documentação não seguem as convenções de nomenclatura, principalmente por simplicidade/concisão. Essas convenções são altamente recomendadas para projetos grandes com vários desenvolvedores.

## Convenções de eventos

> Os eventos devem ser nomeados no **passado**, porque eventos são coisas que já ocorreram da perspectiva do bloco.

### Anatomia

`BlocSubject` + `Substantivo(opcional)` + `Verbo(evento)`

?> Os eventos de carregamento inicial devem seguir a convenção: `BlocSubject` + `Started`

#### Exemplos

✅ **Bom**

`CounterStarted`
`CounterIncremented`
`CounterDecremented`
`CounterIncrementRetried`

❌ **Ruim**

`Initial`
`CounterInitialized`
`Increment`
`DoIncrement`
`IncrementCounter`


## Convenções de Estado

> Os estados devem ser substantivos porque um estado é apenas um instantâneo em um determinado momento.

### Anatomia

`BlocSubject` + `Verbo(ação)` + `State`

?> `State` deve ser um dos seguintes: `Inicial` | "Sucesso" | Falha `InProgress` e
os estados iniciais devem seguir a convenção: `BlocSubject` + `Initial`.

#### Exemplos

✅ **Bom**

`CounterInitial`
`CounterLoadInProgress`
`CounterLoadSuccess`
`CounterLoadFailure`

❌ **Ruim**

`Initial`
`Loading`
`Success`
`Succeeded`
`Loaded`
`Failure`
`Failed`