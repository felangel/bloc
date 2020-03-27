# Adlandırma Konvensiyaları

!> Aşağıdakı adlandırma konvensiyaları sadə və tamamilə buraxıla bilən məsləhətlərdir. İstənilən adlandırma qaydalarını istifadə etmək üçün özünüzü azad hiss edin. Ola bilər ki, siz sadəlik/dəqiqlik üçün adlandırma qaydalarını izləməyən nümunələr/dokumentasiyalar tapasınız. Bu konvensiyalar çoxlu sayda developerin birlikdə böyük proyektlərdə işləməsi zamanı ciddi olaraq tövsiyə olunur.

## Hadisə (Event) Konvensiyaları

> Hadisə adları ingilis dilində olan **keçmiş bitmiş** zamanda olan fellərlə adlandırılmalıdır, çünki bloc tərəfdən yanaşsaq, bu hadisələr artıq baş verdikdən sonra bloc-a daxil olur.

### Quruluşu

[event](../_snippets/bloc_naming_conventions/event_anatomy.md)

?> Başlanğıc yükləmə hadisələri bu konvensiyanı izləməlidir: `BlocSubject` + `Started`

#### Nümunələr

✅ **Yaxşı**

[events_good](../_snippets/bloc_naming_conventions/event_examples_good.md ':include')

❌ **Pis**

[events_bad](../_snippets/bloc_naming_conventions/event_examples_bad.md ':include')

## Vəziyyət (State) Konvensiyaları

> Vəziyyətlər isim olmalıdır, çünki onlar sadəcə müəyyən zamanda olan vəziyyət haqqında məlumat verən parçalardır.

### Quruluşu

[state](../_snippets/bloc_naming_conventions/state_anatomy.md ':include')

?> `State` bunlardan biri olmalıdır: `Initial` | `Success` | `Failure` | `InProgress` və 
başlanğıc vəziyyətlər bu konvensiyanı izləməlidir: `BlocSubject` + `Initial`.

#### Nümunələr

✅ **Yaxşı**

[states_good](../_snippets/bloc_naming_conventions/state_examples_good.md ':include')

❌ **Pis**

[states_bad](../_snippets/bloc_naming_conventions/state_examples_bad.md ':include')
