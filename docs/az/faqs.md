# Tez-tez soruşulan suallar

## Vəziyyət yenilənmir

❔ **Sual**: Mən bloc-da vəziyyəti (state) yield edirəm, amma istifadəçi interfeysi (UI) yenilənmir. Nəyi səhv edirəm?

💡 **Cavab**: Əgər Equatable istifadə edirsinizsə, bütün dəyişənləri props getter-inə əlavə etdiyinizə əmin olun.

✅ **Yaxşı**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // pass all properties to props
}
```

❌ **Pis**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [];
}
```

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => null;
}
```

Əlavə olaraq, bloc-unuzda vəziyyətin yeni obyektini yield etdiyinizə əmin olun.

✅ **Yaxşı**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // always create a new instance of the state you are going to yield
    yield state.copyWith(property: event.property);
}
```

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // always create a new instance of the state you are going to yield
    yield MyState(data: data);
}
```

❌ **Pis**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // never modify/mutate state
    state.property = event.property;
    // never yield the same instance of state
    yield state;
}
```

## Nə zaman Equatable istifadə etməli

❔**Question**: Equatable-dən nə zaman istifadə etməliyəm?

💡**Cavab**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

Yuxarıdakı vəziyyətdə, əgər `StateA` `Equatable`-ı extend edirsə, o zaman bir vəziyyət dəyişməsi olacaq (ikinci yield ləğv olacaq).
Ümumi olaraq, əgər yenidən yaradılmanın sayını azaldaraq kodunuzu optimizasiya etmək istəyirsinizsə, `Equatable` istifadə etməlisiniz.
Əgər eyni vəziyyətin ard-arda çoxlu transition-ları başlatmasını istəyirsinizsə, `Equatable` istifadə etməməlisiniz.

Əlavə olaraq, `Matchers` və ya `Predicates` istifadə edərək xüsusi bloc vəziyyətini gözləmək əvəzinə, `Equatable` test prosesini daha da asanlaşdırır.

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        MyStateA(),
        MyStateB(),
    ],
)
```

`Equatable` istifadə etmədən, yuxarıdakı test uğursuz olacaq və testing uğurlu olması üçün aşağıdakı kimi yazmaq lazımdır:

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```

## Bloc vs. Redux

❔ **Sual**: Bloc ilə Redux arasındakı fərq nədir?

💡 **Cavab**:

BLoC aşağıdakı qaydaların əsasında qurulan design patterndir:

1. BLoC-un giriş və çıxışları sadə Stream və Sinkdir.
2. Dependency-lər enjektə(daxil) edilə bilməli və platform aqnostik olmalıdır.
3. Heç bir platform budaqlanmasına icazə verilmir.
4. Həyata keçirmə prosesi yuxarıdakı qaydalara uyduğunuz zaman ərzində istədiyiniz şəkildə ola bilər.

İstifadəçi interfeysi (UI) qaydaları bunlardır:

1. Kifayət qədər mürəkkəb olan hər bir komponentin uyğun BLoC-u vardır.
2. Komponentlər girişləri olduğu kimi göndərməlidir.
3. Komponentlər çıxışları (outputs) olduğununa mümkün qədər yaxın göstərməlidir.
4. Bütün budaqlanmalar sadə BLoC boolean çıxışlarına əsaslanmalıdır.

Bloc kitabxanası Bloc Design Pattern-i tətbiq edir və developer-in işini rahatlaşdırmaq üçün RxDart-ı abstraktlaşdırır.

Redux-un 3 prinsipi aşağıdakılardır:

1. Tək doğruluq mənbəyi
2. Vəziyyət (state) yalnız oxuna bilər
3. Dəyişikliklər sadə funksiyalar ilə edilir

Bloc kitabxanası ilk prinsipi pozur; vəziyyət (state) bloc ilə çoxlu bloclar arasında bölüşdürülür.
Bundan əlavə, bloc-da orta hissə anlayışı yoxdur və bloc asinxron vəziyyət dəyişikliklərini asanlıqla etmək üçün qurulub və tək hadisə zamanı (event) çoxlu vəziyyəti (states) göndərməyə icazə verir.

## Bloc vs. Provider

❔ **Sual**:Bloc və Provider arasındakı fərq nədir?

💡 **Cavab**: `provider` DI (Dependency Injection) üçün yaradılıb (`InheritedWidget` istifadə edir).
Buna görə də, vəziyyəti necə idarə edəcəyinizi bilmək lazım gəlir (`ChangeNotifier`, `Bloc`, `Mobx` ilə, və s.).
Bloc kitabxanası widget ağacına bloc-u təmin etməyi və widget ağacında onu əldə etməyi rahatlaşdırma üçün daxilində `provider` istifadə edir.

## Bloc ilə Naviqasiya (Bir səhifədən digərinə keçid)

❔ **Sual**: Bloc ilə naviqasiyanı necə edim?

💡 **Cavab**: [Flutter Naviqasiya](../recipesflutternavigation.md)-nı yoxlayın.

## Bloc-u axtararkən BlocProvider.of() uğursuz olur

❔ **Sual**:`BlocProvider.of(context)` ilə bloc-u axtaran zaman tapa bilmir. Bunu necə həll edə bilərəm?

💡 **Cavab**: Eyni context ilə siz bloc-u əldə edə bilməzsiniz, belə ki, `BlocProvider.of()`-un uşaq widget-lərin `BuildContext`-ində çağrıldığına əmin olun.

✅ **Yaxşı**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      },
    )
    ...
  }
}
```

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          final blocA = BlocProvider.of<BlocA>(context);
          ...
        },
      ),
    ),
  );
}
```

❌ **Pis**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      }
    )
  );
}
```

## Proyektin Strukturu

❔ **Sual**: Proyektimi necə strukturlaşdıra bilərəm?

💡 **Cavab**: Bu suala həqiqətən doğru/yalnış cavab yoxdur, sadəcə bəzi tövsiyələr var.

- [Flutter Arxitektura Nümunələri- Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Alış-Veriş Səbəti Nümunəsi](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD (Test Driven Development) Kursu - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Ən vacib şey **tutarlı** və **məqsədli (planlaşdırılmış)** strukturuna malik olmaqdır.
