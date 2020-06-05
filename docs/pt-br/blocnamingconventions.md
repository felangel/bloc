# Convenções de nomenclatura

!> As seguintes convenções de nomenclatura são simplesmente recomendações e são completamente opcionais. Sinta-se livre para usar as convenções de nomenclatura que você preferir. Você pode achar que alguns dos exemplos / documentação não seguem as convenções de nomenclatura, principalmente por simplicidade/concisão. Essas convenções são altamente recomendadas para projetos grandes com vários desenvolvedores.

## Convenções de eventos

> Os eventos devem ser nomeados no **passado**, porque eventos são coisas que já ocorreram da perspectiva do bloco.

### Anatomia

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Os eventos de carregamento inicial devem seguir a convenção: `BlocSubject` + `Started`

#### Exemplos

✅ **Bom**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Ruim**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## Convenções de Estado

> Os estados devem ser substantivos porque um estado é apenas um instantâneo em um determinado momento.

### Anatomia

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` deve ser um dos seguintes: `Inicial` | "Sucesso" | Falha `InProgress` e
os estados iniciais devem seguir a convenção: `BlocSubject` + `Initial`.

#### Exemplos

✅ **Bom**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Ruim**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
