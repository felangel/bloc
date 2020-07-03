# Flutter Bloc-un Əsas Konseptləri

?> Zəhmət olmasa, [flutter_bloc](https://pub.dev/packages/flutter_bloc) ilə işləməzdən əvvəl, aşağıdakı bölmələri diqqətli şəkildə oxuduğunuzdan və başa düşdüyünüzdən əmin olun.

## Bloc Widget-ləri

### BlocBuilder

**BlocBuilder** `Bloc` və `builder` funksiyasını tələb edən Flutter Widgetidir. `BlocBuilder` yeni vəziyyətlərə cavab olaraq, widgetin yaradılmasını idarə edir. `Bloc Builder` `StreamBuilder`-ə çox oxşardır, amma ondan fərqli olaraq, qarışıq kodun həcmini azaltmaq üçün daha sadə struktura malikdir. `Builder` funksiyası dəfələrlə çağrılan funksiyadır və gərəkdir ki, vəziyyətə uyğun olaraq, sadəcə widget-i geri qaytaran [xalis funksiya](https://en.wikipedia.org/wiki/Pure_function) olsun.

Əgər vəziyyət dəyişikliyinə cavab olaraq, müxtəlif şeylər - naviqasiya (bir səhifədən digərin keçid), dialoqun göstərilməsi və s kimi şeylər etmək istəyirsinizsə, `BlocListener`-ə baxın.

Əgər bloc parametri ötürülübsə, `BlocBuilder` `BlocProvider` və `BuildContext`-i istifadə edərək, avtomatik axtarışı həyata keçirəcək.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Yalnız `BlocProvider` və hal-hazırki `BuildContext` ilə əlçatılmayan və yalnız bir widget üçün nəzərdə tutulduqda, bloc parametrini qeyd edin.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Əgər builder funksiyası çağırılan zaman, nəzarət etmək istəyirsinizsə, ötürülə bilən `buildWhen` parametrini `BlocBuilder`-ə əlavə edin. `buildWhen` parametri bir əvvəlki və cari vəziyyətləri qəbul edir və geriyə məntiqi dəyər (boolean) qaytarır. Əgər `buildWhen` geriyə true qaytarırsa, bu zaman `buildWhen` funksiyası cari vəziyyət ilə çağrılır və widget yenidən qurulur. Əgər `buildWhen` false qaytarırsa, `builder` funksiyası çağrılmayacaq və `state`-ə görə heç bir dəyişiklik olmayacaq.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** bloc-u onun uşaqlarına (children) `BlocProvider.of<T>(context)` ilə təmin edən Flutter widget-idir.Bu dependency injection (DI) widget-i kimi istifadə olunur, belə ki, bloc-un tək obyekti, elan olunduğu yerdən aşağıda olan çoxlu sayda widget-ə təmin oluna bilər.

Çox hallarda, `BlocProvider` yeni `bloc`-ların yaradılması və onların alt hissədə olan widget-lərə çatdırılması üçün istifadə olunur. Bu halda, `BlocProvider` həm bloc-un yaradılması, həm də avtomatik olaraq, bloc-un bağlanmasını öz öhdəliyinə götürür.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

Bəzi hallarda, `BlocProvider` mövcud olan bloc-un widget ağacının yeni hissəsinə təmin edilməsi üçün istifadə oluna bilər. Əsasən, mövcud olan `bloc`-un yeni route-a çatdırılması üçün istifadə olunur. Bu halda, `BlocProvider` bloc-un yaradılmasını və avtomatik olaraq, bağlanmasını həyata keçirməyəcək.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

Beləliklə, hər hansı `ChildA` və yaxud `ScreenA`-dan `BlocA`-nı aşağıdakı üsulla əldə edə bilərik:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider**  çoxlu `BlocProvider` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocProvider` həm oxunaqlığı artırır, həm də  çoxlu sayda `BlocProvider`-ləri  iç-içə yazmağın qarşısını alır. 
`MultiBlocProvider` istifadə edərək, aşağıdakı formadan:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

bu formaya keçid edə bilərik:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** `BlocWidgetListener`-i və ötürülə bilən `Bloc`-u götürən, bloc-da olan vəziyyət dəyişikliklərinə cavab olaraq, `listener`-i tətikləyən Flutter widget-idir. Bu widget əsasən, vəziyyət dəyişikliyinə qarşı bir dəfə icra olunan şeylərdə - naviqasiya (bir səhifədən digər səhifəyə keçid, `Snackbar`-ın göstərilməsi, `Dialog`-un göstərilməsi və s kimi şeylərdə istifadə olunmalıdır.

`listener`, `BlocBuilder`-də `builder`-dən fərqli olaraq, hər vəziyyət dəyişikliyində bir dəfə (`initialState` istisna olmaqla) çağırılır və `void` funksiyadır.

Əgər bloc parametri ötürülübsə, `BlocListener` avtomatik olaraq, `BlocProvider`-i və cari `BuildContext`-i istifadə edərək, axtarış edəcək.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Yalnız `BlocProvider` və hal-hazırki `BuildContext` ilə əlçatılmayan bloc-u təmin etmək üçün, bloc parametrini qeyd edin.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Əgər listener funksiyası çağırılan zaman, nəzarət etmək istəyirsinizsə, ötürülə bilən `listenWhen` parametrini `BlocListener`-ə əlavə edin. `listenWhen` parametri bir əvvəlki və cari vəziyyətləri qəbul edir və geriyə məntiqi dəyər (boolean) qaytarır. Əgər `listenWhen` geriyə true qaytarırsa, bu zaman `listener` funksiyası cari vəziyyət ilə çağrılır. Əgər `listenWhen` false qaytarırsa, `listener` funksiyası çağrılmayacaq.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener**  çoxlu `BlocListener` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocListener` həm oxunaqlığı artırır, həm də  çoxlu sayda `BlocListener`-ləri  iç-içə yazmağın qarşısını alır. 
`MultiBlocListener` istifadə edərək, aşağıdakı formadan:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

bu formaya keçid edə bilərik:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer**  yeni vəziyyətlərə reaksiya vermək üçün, `builder` və `listener` istifadə edir. `BlocConsumer` iç-içə yazılmış `BlocListener` və `BlocBuilder`-ə bərabərdir, amma onlardan fərqli olaraq, qarışıq kod yazılışını azaldır. `BlocConsumer` bloc-da baş verən vəziyyət dəyişiklərinə uyğun olaraq,  həm istifadəçi interfeysinin yenidən qurulması, həm də digər reaksiyaların edilməsi üçün istifadə edilməlidir. `BlocConsumer` üç buraxıla bilən - `bloc`, `BlocBuilderCondition` və `BlocListenerCondition` və iki tələb olunan `BlocWidgetBuilder` və `BlocWidgetListener`-i parametr olaraq götürür. 

Əgər bloc parametri ötürülübsə, `BlocConsumer` avtomatik olaraq, `BlocProvider`-i və cari `BuildContext`-i istifadə edərək, axtarış edəcək.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

`listener` və `builder` çağırılan zaman nəzarət etmək istəyiriksə, ötürülə bilən `listenWhen` və `buildWhen` qeyd edilə bilər. `listenWhen` və `buildWhen` hər `bloc` `vəziyyət`-i dəyişə zaman çağırılır. Onlar həm cari, həm də əvvəldə `vəziyyət`-i götürüb, geriyə `bool` qaytarmalıdır, hansı ki, buna əsasən, `builder` və yaxud `listener`-in işləyib-işləməməsi müəyyən edilir. `BlocConsumer` başladılan zaman, əvvəlki vəziyyət, `bloc`-ı `vəziyyət`-inə uyğun olaraq başladılacaq. `listenWhen` və `buildWhen` ötürülə bilər və əgər ötürülübsə, o zaman susmaya görə, `true` qaytarılacaq.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** repository-ni onun uşaqlarına `RepositoryProvider.of<T>(context)` vasitəsilə təmin edən Flutter Widget-idir. Bu dependency injection (DI) widget-i kimi istifadə olunur, belə ki, repository-in tək obyekti, elan olunduğu yerdən aşağıda olan çoxlu sayda widget-ə təmin oluna bilər. `BlocProvider`-in təkcə bloc-ları təmin etdiyi kimi, `RepositoryProvider` də yalnız repository-lər üçün istifadə olunmalıdır.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

Beləliklə, hər hansı `ChildA`-dan `Repository` obyektini aşağıdakı üsulla əldə edə bilərik:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider**  çoxlu `RepositoryProvider` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocProvider` həm oxunaqlığı artırır, həm də  çoxlu sayda `RepositoryProvider`-ləri  iç-içə yazmağın qarşısını alır. 
`MultiRepositoryProvider` istifadə edərək, aşağıdakı formadan:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

bu formaya keçid edə bilərik:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## İstifadəsi

İndi isə, `CounterPage` ilə `CounterBloc`-u `BlocBuilder` istifadə edərək, necə qoşacağımıza baxaq.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

Bu nöqtədə, biz müvəffəqiyyətlə dizayn kodları olan hissəni (presentation layer), məntiqi kodlar olan hissədən (business logic layer) ayırdıq. Diqqət yetirin ki, `CounterPage` widget-i, istifadəçi hər hansı düyməyə basan zaman nə baş verdiyi haqqında heç nə bilmir. Sadəcə, widget `CounterBloc`-a istifadəçinin artırma və yaxud azaltma düyməsinə basdığı haqqında məlumat verir.
