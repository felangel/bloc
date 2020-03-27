# Adlandırma Konvensiyaları

!> Aşağıdakı adlandırma konvensiyaları sadə və tamamilə buraxıla bilən məsləhətlərdir. İstənilən adlandıram qaydalarını istifadə etmək üçün özünüzü azad hiss edin. Ola bilər ki, siz sadəlik/dəqiqlik üçün adlandırma qaydalarını izləməyən nümunələr/dokumentasiyalar tapasınız. Bu konvensiyalar çoxlu sayda developerin birlikdə böyük proyektlərdə işləməsi zamanı ciddi olaraq tövsiyə olunur.

## Hadisə (Event) Konvensiyaları

> Hadisə adları ingilis dilində olan **keçmiş bitmiş** zamanda olan fellərlə adlandırılmalıdır, çünki bloc tərəfdən yanaşsaq, bu hadisələr artıq baş verdikdən sonra bloc-a daxil olur.

### Anatomiya

[event](../_snippets/bloc_naming_conventions/event_anatomy.md ':include')

?> Initial load events should follow the convention: `BlocSubject` + `Started`

#### Examples

✅ **Good**

[events_good](_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Bad**

[events_bad](_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## State Conventions

> States should be nouns because a state is just a snapshot at a particular point in time.

### Anatomy

[state](_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` should be one of the following: `Initial` | `Success` | `Failure` | `InProgress` and
initial states should follow the convention: `BlocSubject` + `Initial`.

#### Examples

✅ **Good**

[states_good](_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Bad**

[states_bad](_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
