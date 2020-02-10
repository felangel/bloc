# Testing

> Bloc은 매우 쉽게 테스트할 수 있도록 설계되었습니다.

이 간단함을 이용해 [핵심개념](coreconcepts.md)에서 만든 `CounterBloc`에 대한 테스트 작성해봅시다.

이전 예제로 되돌아가서 `CounterBloc`의 구현 내용은 다음과 같습니다.

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

테스트를 작성하기 이전에 테스트를 위한 프레임워크를 dependency에 추가해야 합니다.

[test](https://pub.dev/packages/test)와 [bloc_test](https://pub.dev/packages/bloc_test)을 `pubspec.yaml`에 추가합니다.

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```

`CounterBloc` 테스트를 위한 `counter_bloc_test.dart`을 생성하고 test 패키지를 import합니다.

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

그 다음에, `main`에 test group을 만듭니다.

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **노트**: group은 각각의 테스트를 조직화하기 위할 뿐 아니라 동일한 `setUp`과 `tearDown`을 공유하기 위함입니다.

모든 테스트에서 사용될 `CounterBloc` instance를 만들어봅시다.

```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

이제 각각의 테스트를 작성할 수 있습니다.

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

?> **노트**: `pub run test` 명령으로 모든 테스트를 진행할 수 있습니다.

이제 처음으로 성공한 테스트가 만들어졌습니다! 그렇다면 [bloc_test](https://pub.dev/packages/bloc_test) 패키지를 이용해서 더 복잡한 테스트를 작성해봅시다.

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

우리는 모든 테스트를 진행할 수 있어야 하고 성공 여부를 알 수 있어야 합니다.

네, 이게 전부입니다. 이제 간단히 테스트를 진행함으로써 코드를 바꾸거나 리팩토링하는 것에 두려움을 가질 필요가 없습니다.

[Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)을 참고하시면 완전히 테스트된 예제를 볼 수 있습니다.
