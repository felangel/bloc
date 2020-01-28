# Часто задаваемые вопросы

## Состояние не обновляется

❔**Вопрос**: Я получаю состояние в своем блоке, но пользовательский интерфейс не обновляется. Что я делаю неправильно?

💡**Ответ**: Если вы используете `Equatable`, обязательно передайте суперклассу все свойства через геттер.

✅**Хорошо**

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

❌**Плохо**

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

Кроме того, убедитесь, что вы получаете новый экземпляр состояния в вашем блоке.

✅**Хорошо**

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

❌**Плохо**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // never modify/mutate state
    state.property = event.property;
    // never yield the same instance of state
    yield state;
}
```

## Когда использовать Equatable

❔**Вопрос**: Когда я должен использовать `Equatable`?

💡**Ответ**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

В приведенном выше сценарии, если `StateA` расширяет `Equatable`, произойдет только одно изменение состояния (второе получение будет игнорироваться).
В общем, вы должны использовать `Equatable`, если вы хотите оптимизировать свой код, чтобы уменьшить количество пересборок.
Вы не должны использовать `Equatable` если хотите, чтобы одно и то же состояние в `back-to-back` вызывало несколько переходов.
Кроме того, использование `Equatable` значительно облегчает тестирование блоков, так как мы можем ожидать конкретные экземпляры состояний блоков, а не использовать `Matchers` или `Predicates`.

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

Без `Equatable` вышеприведенный тест потерпит неудачу и его нужно будет переписать так:

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

## Bloc против Redux

❔**Вопрос**: В чем разница между Bloc и Redux?

💡**Ответ**: `BLoC` - это шаблон проектирования, который определяется следующими правилами:

1. Вход и выход `BLoC` - это простые `Streams` и `Sinks`.
2. Зависимости должны быть внедряемыми и независимыми от платформы.
3. Разветвление платформы не допускается.
4. Реализация может быть какая угодно, если вы будете следовать приведенным выше правилам.

Руководство по интерфейсу пользователя:

1. Каждый `достаточно сложный` компонент имеет соответствующий `BLoC`
2. Компоненты должны отправлять входные данные "как есть"
3. Компоненты должны показывать результаты как можно ближе к «как есть»
4. Все ветвления должны основываться на простых булевых выходах `BLoC`

Библиотека `Bloc` реализует шаблон проектирования `BLoC` и стремится абстрагировать `RxDart` для упрощения работы разработчика.

Три принципа Redux:

1. Единственный источник истины
2. Состояние только для чтения
3. Изменения делаются чистыми `pure` функциями

Библиотека `Bloc` нарушает первый принцип; состояние распределяется по нескольким блокам.
Кроме того, в блоке отсутствует концепция `middleware` уровня и `bloc` разработан для более простого и легкого внесения изменений в асинхронное состояние, позволяя создавать несколько состояний для одного события.

## Bloc против Provider

❔**Вопрос**: В чем разница между `Bloc` и `Provider`?

💡**Ответ**: `Provider` спроектирован для внедрения зависимостей (оборачивает `InheritedWidget`).
Вам сначала нужно выяснить как управлять вашим состоянием (через `ChangeNotifier`, `Bloc`, `Mobx` и т.д.). Библиотека `Bloc` использует `Provider` внутренне, чтобы упростить предоставление и доступ к блокам по всему дереву виджетов.

## Навигация с Bloc

❔**Вопрос**: Как мне сделать навигацию с `Bloc`?

💡**Ответ**: Ознакомьтесь с [Навигация во Flutter](ru/recipesflutternavigation.md)

## BlocProvider.of() не находит Bloc

❔**Вопрос**: При использовании `BlocProvider.of(context)` он не может найти `bloc`. Как я могу это исправить?

💡**Ответ**: Вы не можете получить доступ к `bloc` из того же контекста, в котором он был предоставлен, поэтому вы должны убедиться, что `BlocProvider.of()` вызывается внутри дочернего `BuildContext`.

✅**Хорошо**

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

❌**Плохо**

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

## Структура проекта

❔**Вопрос**: Как мне структурировать свой проект?

💡**Ответ**: Хотя на этот вопрос нет правильного/неправильного ответа, некоторые рекомендуемые ссылки приведены ниже:

- [Пример архитектуры Flutter - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter - пример корзины покупателя](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Курс - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

Наиболее важным является наличие **согласованной** и **преднамеренной** структуры проекта.
