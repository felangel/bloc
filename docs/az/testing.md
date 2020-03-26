# Testing

> Bloc test edilməsi çox rahat olacaq şəkildə hazırlanmışdır.

Sadə olması üçün,  [Əsas Konseptlər](coreconcepts.md)-də yaratdığımız `CounterBloc` üçün testlər yazaq.

Təkrar olması üçün qeyd edək ki, `CounterBloc` aşağıdakı kod şəklindədir

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

Testlərimizi yazmadan öncə dependency-lərə test üçün framework-ləri əlavə edəcəyik.

[test](https://pub.dev/packages/test) və [bloc_test](https://pub.dev/packages/bloc_test) framework-lərini `pubspec.yaml`-a əlavə etməliyik.

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```
`CounterBloc`-un testi üçün `counter_bloc_test.dart` yaradaraq və test paketini daxil edərək başlayırıq.

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

Daha sonra, `main` funksiyasını və test qrupunu yaratmağa ehtiyacımız var.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **Qeyd**: 
?> **Note**: groups are for organizing individual tests as well as for creating a context in which you can share a common `setUp` and `tearDown` across all of the individual tests.

Let's start by creating an instance of our `CounterBloc` which will be used across all of our tests.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

Now we can start writing our individual tests.

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

?> **Note**: We can run all of our tests with the `pub run test` command.

At this point we should have our first passing test! Now let's write a more complex test using the [bloc_test](https://pub.dev/packages/bloc_test) package.

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

We should be able to run the tests and see that all are passing.

That's all there is to it, testing should be a breeze and we should feel confident when making changes and refactoring our code.

You can refer to the [Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) for an example of a fully tested application.
