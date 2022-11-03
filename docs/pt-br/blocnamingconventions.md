# Convenções de Nomenclatura

!> As seguintes convenções de nomenclatura são simplesmente recomendações e são completamente opcionais. Sinta-se livre para usar as convenções de nomenclatura que você preferir. Você pode achar que alguns dos exemplos / documentação não seguem as convenções de nomenclatura, principalmente por simplicidade/concisão. Essas convenções são altamente recomendadas para projetos grandes com vários desenvolvedores.

## Convenções de Eventos

> Os eventos devem ser nomeados no **passado**, porque eventos são coisas que já ocorreram da perspectiva do bloc.

### Anatomia

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Os eventos de carregamento inicial devem seguir a convenção: `BlocSubject` + `Started`

!> A classe de evento base deve ser nomeada: `BlocSubject` + `Event`.

#### Exemplos

✅ **Bom**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Ruim**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## Convenções de Estado

> Os estados devem ser substantivos porque um estado é apenas um snapshot em um determinado momento. Existem duas maneiras comuns de representar o estado: usando subclasses ou usando uma classe única.

### Anatomia

#### Subclasses

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> Ao representar o estado como várias subclasses, `State` deve ser um dos seguintes: `Initial` | `Success` | `Failure` | `InProgress` e os estados iniciais devem seguir a convenção: `BlocSubject` + `Initial`.

#### Classe Única

[state](../_snippets/bloc_naming_conventions/single_state_anatomy.md ':include')

?> Ao representar o estado como uma classe base única, um enum nomeado `BlocSubject` + `Status` deve ser usado para representar o status do estado: `initial` | `success` | `failure` | `loading`.

!> A classe de estado base deve sempre ser nomeada: `BlocSubject` + `State`.

#### Exemplos

✅ **Bom**

##### Subclasses

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

##### Classe Única

[states_good](../_snippets/bloc_naming_conventions/single_state_examples_good.md ':include')

❌ **Ruim**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
