<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_test_logo_full.png" height="60" alt="Bloc Test Package" />

[![Pub](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)
[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![Flutter Website](https://img.shields.io/badge/flutter-website-deepskyblue.svg)](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/felangel/bloc)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A Dart package that makes testing blocs easy. Built to work with [bloc](https://pub.dev/packages/bloc) and [mockito](https://pub.dev/packages/mockito).

## Create a Mock Bloc

```dart
import 'package:bloc_test/bloc_test.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
```

## Stub the Bloc Stream

**whenListen** creates a stub response for the `listen` method on a `Bloc`. Use `whenListen` if you want to return a canned `Stream` of states for a bloc instance.

```dart
// Create a mock instance
final counterBloc = MockCounterBloc();

// Stub the bloc `Stream`
whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));

// Assert that the bloc emits the stubbed `Stream`.
expectLater(counterBloc, emitsInOrder(<int>[0, 1, 2, 3])))
```

## Unit Test a Real Bloc with blocTest

**blocTest** creates a new `bloc`-specific test case with the given `description`. `blocTest` will handle asserting that the `bloc` emits the `expect`ed states (in order) after `act` is executed. `blocTest` also handles ensuring that no additional states are emitted by closing the `bloc` stream before evaluating the `expect`ation.

`build` should be used for all `bloc` initialization and preparation and must return the `bloc` under test as a `Future`.

`act` is an optional callback which will be invoked with the `bloc` under test and should be used to `add` events to the `bloc`.

`skip` is an optional `int` which can be used to skip any number of states. The default value is 1 which skips the `initialState` of the bloc. `skip` can be overridden to include the `initialState` by setting skip to 0.

`wait` is an optional `Duration` which can be used to wait for async operations within the `bloc` under test such as `debounceTime`.

`expect` is an `Iterable<State>` which the `bloc` under test is expected to emit after `act` is executed.

`verify` is an optional callback which is invoked after `expect` and can be used for additional verification/assertions. `verify` is called with the `bloc` returned by `build`.

```dart
group('CounterBloc', () {
  blocTest(
    'emits [] when nothing is added',
    build: () async => CounterBloc(),
    expect: [],
  );

  blocTest(
    'emits [1] when CounterEvent.increment is added',
    build: () async => CounterBloc(),
    act: (bloc) => bloc.add(CounterEvent.increment),
    expect: [1],
  );
});
```

`blocTest` can also be used to `skip` any number of emitted states before asserting against the expected states. The default value is 1 which skips the `initialState` of the bloc. `skip` can be overridden to include the `initialState` by setting skip to 0.

```dart
blocTest(
  'CounterBloc emits [0, 1] when CounterEvent.increment is added',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  skip: 0,
  expect: [0, 1],
);
```

`blocTest` can also be used to wait for async operations like `debounceTime` by providing a `Duration` to `wait`.

```dart
blocTest(
  'CounterBloc emits [1] when CounterEvent.increment is added',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  wait: const Duration(milliseconds: 300),
  expect: [1],
);
```

`blocTest` can also be used to `verify` internal bloc functionality.

```dart
blocTest(
  'CounterBloc emits [1] when CounterEvent.increment is added',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: [1],
  verify: () async {
    verify(repository.someMethod(any)).called(1);
  }
);
```

**Note:** when using `blocTest` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
blocTest(
  'emits [StateB] when MyEvent is added',
  build: () async => MyBloc(),
  act: (bloc) => bloc.add(MyEvent()),
  expect: [isA<StateB>()],
);
```

## Assert with Confidence using emitsExactly

**emitsExactly** is similar to `emitsInOrder` but asserts that the provided `bloc` emits **only** the `expected` states in the **exact** order in which they were provided.

```dart
group('CounterBloc', () {
  test('emits [] when nothing is added', () async {
    final bloc = CounterBloc();
    await emitsExactly(bloc, []);
  });

  test('emits [1] when CounterEvent.increment is added', () async {
    final bloc = CounterBloc();
    bloc.add(CounterEvent.increment);
    await emitsExactly(bloc, [1]);
  });
});
```

`emitsExactly` also supports `Matchers` for states which don't override `==` and `hashCode`.

```dart
test('emits [StateB] when EventB is added', () async {
  final bloc = MyBloc();
  bloc.add(EventB());
  await emitsExactly(bloc, [isA<StateB>()]);
});
```

`skip` is an optional `int` which defaults to 1 and can be used to skip any number of states. The default behavior skips the `initialState` of the bloc but can be overridden to include the `initialState` by setting skip to 0.

```dart
test('emits [0, 1] when CounterEvent.increment is added', () async {
  final bloc = CounterBloc();
  bloc.add(CounterEvent.increment);
  await emitsExactly(bloc, [0, 1], skip: 0);
});
```

`emitsExactly` also takes an optional `duration` which is useful in cases where the `bloc` is using `debounceTime` or other similar operators.

```dart
test('emits [1] when CounterEvent.increment is added', () async {
  final bloc = CounterBloc();
  bloc.add(CounterEvent.increment);
  await emitsExactly(bloc, [1], duration: const Duration(milliseconds: 300));
});
```

## Dart Versions

- Dart 2: >= 2.6.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)
