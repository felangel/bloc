# Jmenné konvence

!> Následující jmenné konvence jsou pouze doporučením a jsou kompletně dobrovolné. Neváhejte použít libovolné, vámi preferované, jmenné konvence. Některé z příkladů/dokumentace nedodržují jmenné konvence zejména kvůli jednoduchosti/stručnosti. Tyto konvence jsou velmi doporučovány pro velké projekty s více vývojáři.

## Konvence pro Event

> Eventy by měly být pojmenovány v minulém čase, protože eventy jsou věci, které z pohledu blocu již nastaly.

### Anatomie

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Počáteční eventy by se měly řídit konvencí: `BlocSubject` + `Started`

#### Příklady

✅ **Správně**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Špatně**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## State Conventions

> Stavy by měly být podstatná jména, protože stav je jen snímek v určitém časovém okamžiku.

### Anatomy

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` by měl být jedním z následujících: `Initial` | `Success` | `Failure` | `InProgress` a
počáteční stavy by se měly řídit kovencí: `BlocSubject` + `Initial`.

#### Examples

✅ **Správně**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Špatně**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
