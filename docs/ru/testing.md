# Тестирование

> Блок был спроектирован так, чтобы его было очень легко тестировать.

Для простоты давайте напишем тесты для `CounterBloc`, который мы создали в [Основных понятиях](ru/coreconcepts.md).

Напомним, что реализация `CounterBloc` выглядит следующим образом:

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

Прежде чем мы начнем писать тесты, нам нужно добавить среду тестирования в качестве зависимости.

Нам нужно добавить [test](https://pub.dev/packages/test) и [bloc_test](https://pub.dev/packages/bloc_test) в наш `pubspec.yaml`.

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```

Давайте начнем с создания файла `counter_bloc_test.dart` для тестирования `CounterBloc` и импортируем пакет для тестирования.

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

Далее нам нужно создать `main`, а также тестовую группу.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **Примечание**: группы предназначены для организации отдельных тестов, а также для создания контекста, в котором вы можете использовать общие `setUp` и `tearDown` для всех отдельных тестов.

Давайте начнем с создания экземпляра нашего `CounterBloc`, который будет использоваться во всех наших тестах.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Теперь мы можем начать писать наши индивидуальные тесты.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });

    test('initial state is 0', () {
        expect(counterBloc.initialState, 0);
    });
});
```

?> **Примечание**: Мы можем запустить все наши тесты с помощью команды `pub run test`.

В этот момент мы должны пройти наш первый тест успешно! Теперь давайте напишем более сложный тест, используя пакет [bloc_test](https://pub.dev/packages/bloc_test).

```dart
blocTest(
    'emits [0, 1] when CounterEvent.increment is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.increment),
    expect: [0, 1],
);

blocTest(
    'emits [0, -1] when CounterEvent.decrement is added',
    build: () => counterBloc,
    act: (bloc) => bloc.add(CounterEvent.decrement),
    expect: [0, -1],
);
```

Мы должны запустить тесты и увидеть, что все прошло успешно.

Это все, что нужно сделать. Тестирование должно быть быстрым и мы должны чувствовать уверенность при внесении изменений и рефакторинга нашего кода.

Вы можете обратиться к [приложению Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) для примера полностью протестированного приложения.
