# Convención de nombres

> La siguiente convención de nombres son solamente recomendaciones y son completamente opcionales. Sientasé libre de usar cualquier convención de nombres que prefiera. Puede que encuentre algunos ejemplos o documentación que no sigan la nomenclatura principalmente por simplicidad / concisión.

## Nomenclatura de eventos

> Los eventos deben ser nombrados en **tiempo pasado** porque los eventos son cosas que ya han ocurrido desde la perspectiva del Bloc.

### Anatomía

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Los eventos de carga inicial deben seguir la siguiente nomenclatura: `Sujeto del Bloc` + `Started`

#### Ejemplos

✅ **Bien**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Mal**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## Nomenclatura de estados

> Los estados deberían ser sustantivos debido a que un estado es solo una instantánea en un momento determinado de tiempo.

### Anatomía

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> El valor de `Estado` deberían ser uno de los siguientes: `Initial` | `Success` | `Failure` | `InProgress` y el estado inicial deberia seguir la nomenclatura: `Sujeto del Bloc` + `Initial`.

#### Ejemplos

✅ **Bien**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Mal**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
