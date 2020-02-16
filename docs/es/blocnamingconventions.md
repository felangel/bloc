# Convención de nombres

> La siguiente convención de nombres son solamente recomendaciones y son completamente opcionales. Sientasé libre de usar cualquier convención de nombres que prefiera. Puede que encuentre algunos ejemplos o documentación que no sigan la nomenclatura principalmente por simplicidad / concisión.

## Nomenclatura de eventos

> Los eventos deben ser nombrados en **tiempo pasado** porque los eventos son cosas que ya han ocurrido desde la perspectiva del Bloc.

### Anatomía

`Sujeto del Bloc` + `Sustantivo (opcional)` + `Verbo (evento)`

> Los eventos de carga inicial deben seguir la siguiente nomenclatura: `Sujeto del Bloc` + `Started`

#### Ejemplos

✅ **Bien**

`CounterStarted`
`CounterIncremented`
`CounterDecremented`
`CounterIncrementRetried`

❌ **Mal**

`Initial`
`CounterInitialized`
`Increment`
`DoIncrement`
`IncrementCounter`

## Nomenclatura de estados

> Los estados deberían ser sustantivos debido a que un estado es solo una instantánea en un momento determinado de tiempo.

### Anatomía

`Sujeto del Bloc` + `Verbo (acción)` + `Estado`

> El valor de `Estado` deberían ser uno de los siguientes: `Initial` | `Success` | `Failure` | `InProgress` y el estado inicial deberia seguir la nomenclatura: `Sujeto del Bloc` + `Initial`.

#### Ejemplos

✅ **Bien**

`CounterInitial`
`CounterLoadInProgress`
`CounterLoadSuccess`
`CounterLoadFailure`

❌ **Mal**

`Initial`
`Loading`
`Success`
`Succeeded`
`Loaded`
`Failure`
`Failed`

