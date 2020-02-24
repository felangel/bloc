# 测试

> Bloc的设计使得其非常易于测试。

为了简单起见，让我们为在其中创建的`CounterBloc`编写测试[核心理念](coreconcepts.md).

回顾一下，`CounterBloc`的实现过程：

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

在开始编写测试之前，我们需要为依赖项添加一个测试框架。

我们需要添加 [test](https://pub.dev/packages/test) 和 [bloc_test](https://pub.dev/packages/bloc_test) 到 `pubspec.yaml`文件之中.

```yaml
dev_dependencies:
  test: ^1.3.0
  bloc_test: ^3.0.0
```

让我们开始为`CounterBloc`创建测试文件`counter_bloc_test.dart`并导入测试包当中。

```dart
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
```

接下来，我们需要创建我们的`main`和测试组。

```dart
void main() {
    group('CounterBloc', () {

    });
}
```

?> **注意**: 组是用于组织单个测试以及创建context，在该context中您可以在所有单个测试中共享通用的`setUp`和`tearDown`。

让我们开始创建一个`CounterBloc`的实例，该实例将在所有测试中使用。
```dart
group('CounterBloc', () {
    CounterBloc counterBloc;

    setUp(() {
        counterBloc = CounterBloc();
    });
});
```

现在我们可以开始编写单个的测试了。

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

?> **注意**: 我们可以通过 `pub run test` 该命令来运行我们所有的测试.

此时我们应该可以通过测试！现在，让我们使用[bloc_test](https://pub.dev/packages/bloc_test) 包.

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

我们应该能够运行测试并看到所有测试都通过了。

仅此而已，测试应该轻而易举，并且在进行更改和重构代码时我们应该充满信心。

你可以参考 [备忘录程序](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) 以获得一个完整的经过测试的程序。
