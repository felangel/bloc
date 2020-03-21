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

**MultiBlocProvider**  çoxlu `BlocProvider` widget-lərini bir yerə yığan Flutter widget-idir. `MultiBlocProvider` həm oxunaqlığı artırır, həm də  çoxlu sayda `BlocProvider`-ləri  iç-içə yazmağın qarşısını alır. `MultiBlocProvider` istifadə edərək, aşağıdakı formadan:

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

**BlocListener** is a Flutter widget which takes a `BlocWidgetListener` and an optional `Bloc` and invokes the `listener` in response to state changes in the bloc. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...
**BlocListener** is a Flutter widget which takes a `BlocWidgetListener` and an optional `Bloc` and invokes the `listener` in response to state changes in the bloc. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each state change (**NOT** including `initialState`) unlike `builder` in `BlocBuilder` and is a `void` function.

If the bloc parameter is omitted, `BlocListener` will automatically perform a lookup using `BlocProvider` and the current `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```

Only specify the bloc if you wish to provide a bloc that is otherwise not accessible via `BlocProvider` and the current `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

If you want fine-grained control over when the listener function is called you can provide an optional `condition` to `BlocListener`. The `condition` takes the previous bloc state and current bloc state and returns a boolean. If `condition` returns true, `listener` will be called with `state`. If `condition` returns false, `listener` will not be called with `state`.

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

**MultiBlocListener** is a Flutter widget that merges multiple `BlocListener` widgets into one.
`MultiBlocListener` improves the readability and eliminates the need to nest multiple `BlocListeners`.
By using `MultiBlocListener` we can go from:

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

to:

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

**BlocConsumer** exposes a `builder` and `listener` in order to react to new states. `BlocConsumer` is analogous to a nested `BlocListener` and `BlocBuilder` but reduces the amount of boilerplate needed. `BlocConsumer` should only be used when it is necessary to both rebuild UI and execute other reactions to state changes in the `bloc`. `BlocConsumer` takes a required `BlocWidgetBuilder` and `BlocWidgetListener` and an optional `bloc`, `BlocBuilderCondition`, and `BlocListenerCondition`.

If the `bloc` parameter is omitted, `BlocConsumer` will automatically perform a lookup using
`BlocProvider` and the current `BuildContext`.

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

An optional `listenWhen` and `buildWhen` can be implemented for more granular control over when `listener` and `builder` are called. The `listenWhen` and `buildWhen` will be invoked on each `bloc` `state` change. They each take the previous `state` and current `state` and must return a `bool` which determines whether or not the `builder` and/or `listener` function will be invoked. The previous `state` will be initialized to the `state` of the `bloc` when the `BlocConsumer` is initialized. `listenWhen` and `buildWhen` are optional and if they aren't implemented, they will default to `true`.

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

**RepositoryProvider** is a Flutter widget which provides a repository to its children via `RepositoryProvider.of<T>(context)`. It is used as a dependency injection (DI) widget so that a single instance of a repository can be provided to multiple widgets within a subtree. `BlocProvider` should be used to provide blocs whereas `RepositoryProvider` should only be used for repositories.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

then from `ChildA` we can retrieve the `Repository` instance with:

```dart
// with extensions
context.repository<RepositoryA>();

// without extensions
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider** is a Flutter widget that merges multiple `RepositoryProvider` widgets into one.
`MultiRepositoryProvider` improves the readability and eliminates the need to nest multiple `RepositoryProvider`.
By using `MultiRepositoryProvider` we can go from:

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

to:

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

## Usage

Lets take a look at how to use `BlocBuilder` to hook up a `CounterPage` widget to a `CounterBloc`.

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

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` widget knows nothing about what happens when a user taps the buttons. The widget simply tells the `CounterBloc` that the user has pressed either the increment or decrement button.
