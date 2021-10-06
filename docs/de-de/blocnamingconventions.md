# Namenskonventionen

!> Die folgenden Benennungskonventionen sind lediglich Empfehlungen und sind völlig freiwillig. Es steht Ihnen frei, die von Ihnen bevorzugten Benennungskonventionen zu verwenden. Sie werden feststellen, dass einige der Beispiele/Dokumentation nicht den Namenskonventionen folgen, hauptsächlich aus Gründen der Einfachheit/Konzisenheit. Diese Konventionen werden für große Projekte mit mehreren Entwicklern dringend empfohlen.

## Ereignis-Konventionen

> Ereignisse sollten in der **Vergangenheitsform** genannt werden, da es sich bei Ereignissen um Dinge handelt, die aus der Sicht des Blocks bereits eingetreten sind.

### Anatomie

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Die ersten Ladeereignisse sollten der Konvention folgen: `BlocSubject` + `Started`

#### Beispiele

✅ **Gut**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Schlecht**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## Zustandskonventionen

> Zustände sollten Substantive sein, denn ein Zustand ist nur eine Momentaufnahme zu einem bestimmten Zeitpunkt.

### Anatomie

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` should be one of the following: `Initial` | `Success` | `Failure` | `InProgress` and
initial states should follow the convention: `BlocSubject` + `Initial`.

#### Beispiele

✅ **Good**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Bad**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
