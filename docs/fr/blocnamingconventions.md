# Conventions d'appellation (Naming conventions)

!> Les conventions d'appellation sont simplements des recommandations et sont donc entièrement optionnelles. Sentez vous libre de choisir l'appellation qui vous convient le mieux. Vous pourriez trouvez certains exemples/documentation qui ne suivent pas les règles d'appellation mais il c'est par facilité/consicion. Ces conventions sont fortements recommandés pour des grands projets avec plusieurs développeurs.

## Convention pour Event (événement)

> Les Events devrait être conjugé au **passé** car les events sont des choses qui ont déjà eu lieu d'un point de vue du bloc.

### Anatomie

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Le chargement initial des events devrait suivre la convention: `BlocSubject` + `Started`

#### Exemples

✅ **Bon**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Mauvais**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## Convention pour State (état)

> Les states devraient être des noms car un state est juste un moment précis à un instant particulier dans le temps.

### Anatomie

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` devrait être comme suivant: `Initial` | `Success` | `Failure` | `InProgress` et initial state devrait toujours suivre la forme: `BlocSubject` + `Initial`.

#### Exemples

✅ **Bon**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Mauvais**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
