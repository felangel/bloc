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
2. Dependency-lər enjektə edilə bilməli və platform aqnostik olmalıdır.
3. Heç bir platform budaqlanmasına icazə verilmir.
4. Həyata keçirmə prosesi yuxarıdakı qaydalara uyduğunuz zaman ərzində istədiyiniz şəkildə ola bilər.

İstifadəçi interfeysi (UI) qaydaları bunlardır:

1. Kifayət qədər mürəkkəb olan hər bir komponentin uyğun BLoC-u vardır.
2. Komponentlər girişləri olduğu kimi göndərməlidir.
3. Komponentlər çıxışları (outputs) olduğununa mümkün qədər yaxın göstərməlidir.
4. Bütün budaqlanmalar sadə BLoC boolean çıxışlarına əsaslanmalıdır.

The Bloc Library implements the BLoC Design Pattern and aims to abstract RxDart in order to simplify the developer experience.

Redux-un 3 prinsipi aşağıdakılardır:

1. Single source of truth
2. State is read-only
3. Changes are made with pure functions

The bloc library violates the first principle; with bloc state is distributed across multiple blocs.
Furthermore, there is no concept of middleware in bloc and bloc is designed to make async state changes very easy, allowing you to emit multiple states for a single event.

## Bloc vs. Provider

❔ **Question**: What's the difference between Bloc and Provider?

💡 **Answer**: `provider` is designed for dependency injection (it wraps `InheritedWidget`).
You still need to figure out how to manage your state (via `ChangeNotifier`, `Bloc`, `Mobx`, etc...).
The Bloc Library uses `provider` internally to make it easy to provide and access blocs throughout the widget tree.

## Navigation with Bloc

❔ **Question**: How do I do navigation with Bloc?

💡 **Answer**: Check out [Flutter Navigation](recipesflutternavigation.md)

## BlocProvider.of() Fails to Find Bloc

❔ **Question**: When using `BlocProvider.of(context)` it cannot find the bloc. How can I fix this?

💡 **Answer**: You cannot access a bloc from the same context in which it was provided so you must ensure `BlocProvider.of()` is called within a child `BuildContext`.

✅ **GOOD**

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

❌ **BAD**

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

## Project Structure

❔ **Question**: How should I structure my project?

💡 **Answer**: While there is really no right/wrong answer to this question, some recommended references are

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

The most important thing is having a **consistent** and **intentional** project structure.
