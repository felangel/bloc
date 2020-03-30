# Flutter Bloc-un Əsas Konseptləri

?> Zəhmət olmasa, [flutter_bloc](https://pub.dev/packages/flutter_bloc) ilə işləməzdən əvvəl, aşağıdakı bölmələri diqqətli şəkildə oxuduğunuzdan və başa düşdüyünüzdən əmin olun.

## Bloc Widget-ləri

### BlocBuilder

**BlocBuilder** `Bloc` və `builder` funksiyasını tələb edən Flutter Widgetidir. `BlocBuilder` yeni vəziyyətlərə cavab olaraq, widgetin yaradılmasını idarə edir. `Bloc Builder` `StreamBuilder`-ə çox oxşardır, amma ondan fərqli olaraq, qarışıq kodun həcmini azaltmaq üçün daha sadə struktura malikdir. `Builder` funksiyası dəfələrlə çağrılan funksiyadır və gərəkdir ki, vəziyyətə uyğun olaraq, sadəcə widget-i geri qaytaran [xalis funksiya](https://en.wikipedia.org/wiki/Pure_function) olsun.

Əgər vəziyyət dəyişikliyinə cavab olaraq, müxtəlif şeylər - naviqasiya (bir səhifədən digərin keçid), dialoqun göstərilməsi və s kimi şeylər etmək istəyirsinizsə, `BlocListener`-ə baxın.

Əgər bloc parametri ötürülübsə, `BlocBuilder` `BlocProvider` və `BuildContext`-i istifadə edərək, avtomatik axtarışı həyata keçirəcək.

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Yalnız `BlocProvider` və hal-hazırki `BuildContext` ilə əlçatılmayan və yalnız bir widget üçün nəzərdə tutulduqda, bloc parametrini qeyd edin.

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // provide the local bloc instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Əgər builder funksiyası çağırılan zaman, nəzarət etmək istəyirsinizsə, ötürülə bilən `condition` parametrini `BlocBuilder`-ə əlavə edin. `Condition` parametri bir əvvəlki və cari vəziyyətləri qəbul edir və geriyə məntiqi dəyər (boolean) qaytarır. Əgər `condition` geriyə true qaytarırsa, bu zaman `builder` funksiyası cari vəziyyət ilə çağrılır və widget yenidən qurulur. Əgər `condition` false qaytarırsa, `builder` funksiyası çağrılmayacaq və `state`-ə görə heç bir dəyişiklik olmayacaq.

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### BlocProvider

**BlocProvider** bloc-u onun uşaqlarına (children) `BlocProvider.of<T>(context)` ilə təmin edən Flutter widget-idir.Bu dependency injection (DI) widget-i kimi istifadə olunur, belə ki, bloc-un tək obyekti, elan olunduğu yerdən aşağıda olan çoxlu sayda widget-ə təmin oluna bilər.

Çox hallarda, `BlocProvider` yeni `bloc`-ların yaradılması və onların alt hissədə olan widget-lərə çatdırılması üçün istifadə olunur. Bu halda, `BlocProvider` həm bloc-un yaradılması, həm də avtomatik olaraq, bloc-un bağlanmasını öz öhdəliyinə götürür.

```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

Bəzi hallarda, `BlocProvider` mövcud olan bloc-un widget ağacının yeni hissəsinə təmin edilməsi üçün istifadə oluna bilər. Əsasən, mövcud olan `bloc`-un yeni route-a çatdırılması üçün istifadə olunur. Bu halda, `BlocProvider` bloc-un yaradılmasını və avtomatik olaraq, bağlanmasını həyata keçirməyəcək.

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

Beləliklə, hər hansı `ChildA` və yaxud `ScreenA`-dan `BlocA`-nı aşağıdakı üsulla əldə edə bilərik:

```dart
// with extensions
context.bloc<BlocA>();

// without extensions
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider

**MultiBlocProvider**  çoxlu `BlocProvider` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocProvider` həm oxunaqlığı artırır, həm də  çoxlu sayda `BlocProvider`-ləri  iç-içə yazmağın qarşısını alır. 
`MultiBlocProvider` istifadə edərək, aşağıdakı formadan:

```dart
BlocProvider<BlocA>(
  create: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

bu formaya keçid edə bilərik:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

### BlocListener

**BlocListener** `BlocWidgetListener`-i və ötürülə bilən `Bloc`-u götürən, bloc-da olan vəziyyət dəyişikliklərinə cavab olaraq, `listener`-i tətikləyən Flutter widget-idir. Bu widget əsasən, vəziyyət dəyişikliyinə qarşı bir dəfə icra olunan şeylərdə - naviqasiya (bir səhifədən digər səhifəyə keçid, `Snackbar`-ın göstərilməsi, `Dialog`-un göstərilməsi və s kimi şeylərdə istifadə olunmalıdır.

`listener`, `BlocBuilder`-də `builder`-dən fərqli olaraq, hər vəziyyət dəyişikliyində bir dəfə (`initialState` istisna olmaqla) çağırılır və `void` funksiyadır.

Əgər bloc parametri ötürülübsə, `BlocListener` avtomatik olaraq, `BlocProvider`-i və cari `BuildContext`-i istifadə edərək, axtarış edəcək.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```
Yalnız `BlocProvider` və hal-hazırki `BuildContext` ilə əlçatılmayan bloc-u təmin etmək üçün, bloc parametrini qeyd edin.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

Əgər listener funksiyası çağırılan zaman, nəzarət etmək istəyirsinizsə, ötürülə bilən `condition` parametrini `BlocListener`-ə əlavə edin. `Condition` parametri bir əvvəlki və cari vəziyyətləri qəbul edir və geriyə məntiqi dəyər (boolean) qaytarır. Əgər `condition` geriyə true qaytarırsa, bu zaman `listener` funksiyası cari vəziyyət ilə çağrılır. Əgər `condition` false qaytarırsa, `listener` funksiyası çağrılmayacaq.

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
  child: Container(),
)
```

### MultiBlocListener

**MultiBlocListener**  çoxlu `BlocListener` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocListener` həm oxunaqlığı artırır, həm də  çoxlu sayda `BlocListener`-ləri  iç-içə yazmağın qarşısını alır. 
`MultiBlocListener` istifadə edərək, aşağıdakı formadan:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

bu formaya keçid edə bilərik:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

### BlocConsumer

**BlocConsumer**  yeni vəziyyətlərə reaksiya vermək üçün, `builder` və `listener` istifadə edir. `BlocConsumer` iç-içə yazılmış `BlocListener` və `BlocBuilder`-ə bərabərdir, amma onlardan fərqli olaraq, qarışıq kod yazılışını azaldır. `BlocConsumer` bloc-da baş verən vəziyyət dəyişiklərinə uyğun olaraq,  həm istifadəçi interfeysinin yenidən qurulması, həm də digər reaksiyaların edilməsi üçün istifadə edilməlidir. `BlocConsumer` üç buraxıla bilən - `bloc`, `BlocBuilderCondition` və `BlocListenerCondition` və iki tələb olunan `BlocWidgetBuilder` və `BlocWidgetListener`-i parametr olaraq götürür. 

Əgər bloc parametri ötürülübsə, `BlocConsumer` avtomatik olaraq, `BlocProvider`-i və cari `BuildContext`-i istifadə edərək, axtarış edəcək.

```dart
BlocConsumer<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

`listener` və `builder` çağırılan zaman nəzarət etmək istəyiriksə, ötürülə bilən `listenWhen` və `buildWhen` qeyd edilə bilər. `listenWhen` və `buildWhen` hər `bloc` `vəziyyət`-i dəyişə zaman çağırılır. Onlar həm cari, həm də əvvəldə `vəziyyət`-i götürüb, geriyə `bool` qaytarmalıdır, hansı ki, buna əsasən, `builder` və yaxud `listener`-in işləyib-işləməməsi müəyyən edilir. `BlocConsumer` başladılan zaman, əvvəlki vəziyyət, `bloc`-ı `vəziyyət`-inə uyğun olaraq başladılacaq. `listenWhen` və `buildWhen` ötürülə bilər və əgər ötürülübsə, o zaman susmaya görə, `true` qaytarılacaq.

```dart
BlocConsumer<BlocA, BlocAState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether or not
    // to invoke listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  buildWhen: (previous, current) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### RepositoryProvider

**RepositoryProvider** repository-ni onun uşaqlarına `RepositoryProvider.of<T>(context)` vasitəsilə təmin edən Flutter Widget-idir. Bu dependency injection (DI) widget-i kimi istifadə olunur, belə ki, repository-in tək obyekti, elan olunduğu yerdən aşağıda olan çoxlu sayda widget-ə təmin oluna bilər. `BlocProvider`-in təkcə bloc-ları təmin etdiyi kimi, `RepositoryProvider` də yalnız repository-lər üçün istifadə olunmalıdır.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

Beləliklə, hər hansı `ChildA`-dan `Repository` obyektini aşağıdakı üsulla əldə edə bilərik:

```dart
// with extensions
context.repository<RepositoryA>();

// without extensions
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider**  çoxlu `RepositoryProvider` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocProvider` həm oxunaqlığı artırır, həm də  çoxlu sayda `RepositoryProvider`-ləri  iç-içə yazmağın qarşısını alır. 
`MultiRepositoryProvider` istifadə edərək, aşağıdakı formadan:

```dart
RepositoryProvider<RepositoryA>(
  builder: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    builder: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

bu formaya keçid edə bilərik:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      builder: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      builder: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## İstifadəsi

İndi isə, `CounterPage` ilə `CounterBloc`-u `BlocBuilder` istifadə edərək, necə qoşacağımıza baxaq.

### counter_bloc.dart

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

Bu nöqtədə, biz müvəffəqiyyətlə dizayn kodları olan hissəni (presentation layer), məntiqi kodlar olan hissədən (business logic layer) ayırdıq. Diqqət yetirin ki, `CounterPage` widget-i, istifadəçi hər hansı düyməyə basan zaman nə baş verdiyi haqqında heç nə bilmir. Sadəcə, widget `CounterBloc`-a istifadəçinin artırma və yaxud azaltma düyməsinə basdığı haqqında məlumat verir.
