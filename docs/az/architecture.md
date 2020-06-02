# Arxitektura

![Bloc Arxitekturası](../assets/bloc_architecture.png)

Bloc-un istifadəsi bizə tətbiqimizi 3 təbəqəyə bölməyə imkan verir:

- Presentation
- Business Logic
- Data
  - Repository
  - Data Provider

Ən aşağı təqəbədən (istifadəçi interfeysinə ən uzaq olan) başlayırıq və yolumuzu presentation təbəqəsinə qədər davam etdirəcəyik.

## Data Təbəqəsi

> Data təbəqəsinin öhdəliyi bir və yaxud çox mənbədən gələn dataların əldə edilməsi və manipulyasiya edilməsidir.

Data təbəqəsi 2 hissəyə bölünə bilər:

- Repository
- Data Provider

Bu təbəqə tətbiqin ən aşağı səviyyəsidir və database-lər, şəbəkə sorğuları və başqa asinxron data mənbələri ilə əlaqə yaradır.

### Data Provider

> Data provider-in öhdəliyi xam datanı (raw data) təmin etməkdir. Data provider ümumi və çox yönlü olmalıdır.

Data provider adətən [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) əməliyyatlarını yerinə yetirmək üçün sadə API-lar təmin edir.
Data layer-in bir hissəsi kimi, `createData`, `readData`, `updateData`, və `deleteData` kimi metodlarımız ola bilər.

[data_provider.dart](../_snippets/architecture/data_provider.dart.md ':include')

### Repository

> Repository təbəqəsi Bloc layer-in əlaqə saxladığı və içərisində bir və ya daha çox data provider-i əhatə edən təbəqədir.

[repository.dart](../_snippets/architecture/repository.dart.md ':include')

Gördüyünüz kimi, repository təbəqəsi çoxlu sayda data provider-lərlə əlaqə saxlaya və data-ları məntiqi kodlar olan hissəyə (Bloc-a) ötürməmişdən əvvəl onlar üzərində dəyişikliklər apara bilər.

## Bloc (Business Logic) Təbəqəsi

> Bloc təbəqəsinin öhdəliyi presentation təbəqəsindən gələn hadisələrə (events)-ə yeni vəziyyətlər (states) ilə cavab verməkdir. Bloc təbəqəsi tətbiqin vəziyyətini quran zaman istifadə ediləcək data-ları göndərmək üçün bir və ya daha çox repository istifadə edə bilər.

Bloc təbəqəsini istifadəçi interfeysi (presentation təbəqəsi) və data təbəqəsi arasındakı körpü kimi düşünə bilərsiniz. Bloc təbəqəsi istifadəçinin inputları əsasında yaranan hadisələri (events) qəbul edir və presentation təbəqəsinə lazım olan yeni vəziyyətin qurulması üçün repository ilə əlaqə yaradır.

[business_logic_component.dart](../_snippets/architecture/business_logic_component.dart.md ':include')

### Bloc-un-Bloc-a rabitəsi

> Hər bir bloc-un vəziyyət stream-i var, digər bloc-lar həmin bloc-da olan dəyişikliyə reaksiya vermək üçün stream-ə abunə ola (subscribe) bilərlər.

Bloc-ların digər bloc-larda olan vəziyyət dəyişikliklərindən asılılığı ola bilər. Aşağıdakı nümunədə, `MyBloc`-un `OtherBloc`-dan asılılığı vardır və `OtherBloc`-da baş verən vəziyyət dəyişikliklərinə cavab olaraq, hadisələri `add` edə bilər. Yaddaş çatışmazlığı problemlərinin qarşısını almaq üçün `StreamSubsctiption`-ı `MyBloc`-da olan `close` metodunu əlavə edərək bağlanılır.

[bloc_to_bloc_communication.dart](../_snippets/architecture/bloc_to_bloc_communication.dart.md ':include')

## Presentation Təbəqəsi

> Presentation təbəqəsinin öhdəliyi bloc-da baş verən bir və yaxud daha çox vəziyyətlərə uyğun olaraq, özünü necə render etməsini bilməsidir. Əlavə olaraq, istifadəçinin input-larını və tətbiqinin həyat hadisələrini (lifestyle events) idarə etməlidir.

Əksər tətbiqlər istifadəçiyə göstərməyə lazım olan data-nı əldə etmək üçün tətbiqi tətikləyən `AppStart` hadisəsi ilə başlayır.

Bu mənzərəyə əsasən, presentation təbəqəsi `AppStart` hadisəsini əlavə etməlidir.

Əlavə olaraq, presentation təbəqəsi bloc təbəqəsindən gələn vəziyyət əsasında nəyi render etməli olduğunu bilməlidir.

[presentation_component.dart](../_snippets/architecture/presentation_component.dart.md ':include')

İndiyə qədər bir neçə kod parçası olsa da, bütün bunlar kifayət qədər yüksək səviyyədədir. Dərslik bölməsində bir neçə fərqli nümunə tətbiqini qurduğumuz zaman bunları bir araya gətirəcəyik.
