<p align="center"><img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_test_full.png" height="100" alt="Cubit Test"></p>

<p align="center">
<a href="https://pub.dev/packages/cubit_test"><img src="https://img.shields.io/pub/v/cubit_test.svg" alt="Pub"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://github.com/felangel/cubit/workflows/build/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://raw.githubusercontent.com/felangel/cubit/master/packages/cubit_test/coverage_badge.svg" alt="coverage"></a>
<a href="https://github.com/felangel/cubit"><img src="https://img.shields.io/github/stars/felangel/cubit.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/zepfietje/starware"><img src="https://img.shields.io/badge/Starware-%E2%AD%90-black?labelColor=%23f9b00d" alt="Starware"></a>
</p>

A Dart package built to make testing cubits easy. Built to work with the [cubit](https://pub.dev/packages/cubit) and [bloc](https://pub.dev/packages/bloc) state management packages.

## Create a Mock Cubit

```dart
import 'package:cubit_test/cubit_test.dart';

class MockCounterCubit extends MockCubit<int> implements CounterCubit {}
```

## Stub the Cubit Stream

**whenListen** creates a stub response for the `listen` method on a `Cubit`. Use `whenListen` if you want to return a canned `Stream` of states for a cubit instance. `whenListen` also handles stubbing the `state` of the cubit to stay in sync with the emitted state.

```dart
// Create a mock instance
final counterCubit = MockCounterCubit();

// Stub the cubit `Stream`
whenListen(counterCubit, Stream.fromIterable([0, 1, 2, 3]));

// Assert that the cubit emits the stubbed `Stream`.
await expectLater(counterCubit, emitsInOrder(<int>[0, 1, 2, 3])))

// Assert that the cubit's current state is in sync with the `Stream`.
expect(counterCubit.state, equals(3));
```

## Unit Test a Real Cubit with cubitTest

**cubitTest** creates a new `cubit`-specific test case with the given `description`. `cubitTest` will handle asserting that the `cubit` emits the `expect`ed states (in order) after `act` is executed. `cubitTest` also handles ensuring that no additional states are emitted by closing the `cubit` stream before evaluating the `expect`ation.

`build` should be used for all `cubit` initialization and preparation and must return the `cubit` under test as a `Future`.

`act` is an optional callback which will be invoked with the `cubit` under test and should be used to interact with the `cubit`.

`skip` is an optional `int` which can be used to skip any number of states. The default value is 1 which skips the `initialState` of the cubit. `skip` can be overridden to include the `initialState` by setting skip to 0.

`wait` is an optional `Duration` which can be used to wait for async operations within the `cubit` under test such as `debounceTime`.

`expect` is an optional `Iterable<State>` which the `cubit` under test is expected to emit after `act` is executed.

`verify` is an optional callback which is invoked after `expect` and can be used for additional verification/assertions. `verify` is called with the `cubit` returned by `build`.

```dart
group('CounterCubit', () {
  cubitTest(
    'emits [] when nothing is called',
    build: () async => CounterCubit(),
    expect: [],
  );

  cubitTest(
    'emits [1] when increment is called',
    build: () async => CounterCubit(),
    act: (cubit) async => cubit.increment(),
    expect: [1],
  );
});
```

`cubitTest` can also be used to `skip` any number of emitted states before asserting against the expected states. The default value is 1 which skips the `initialState` of the cubit. `skip` can be overridden to include the `initialState` by setting skip to 0.

```dart
cubitTest(
  'CounterCubit emits [0, 1] when increment is called',
  build: () async => CounterCubit(),
  act: (cubit) async => cubit.increment(),
  skip: 0,
  expect: [0, 1],
);
```

`cubitTest` can also be used to wait for async operations like `debounceTime` by providing a `Duration` to `wait`.

```dart
cubitTest(
  'CounterCubit emits [1] when increment is called',
  build: () async => CounterCubit(),
  act: (cubit) async => cubit.increment(),
  wait: const Duration(milliseconds: 300),
  expect: [1],
);
```

`cubitTest` can also be used to `verify` internal cubit functionality.

```dart
cubitTest(
  'CounterCubit emits [1] when increment is called',
  build: () async => CounterCubit(),
  act: (cubit) async => cubit.increment(),
  expect: [1],
  verify: (_) async {
    verify(repository.someMethod(any)).called(1);
  }
);
```

**Note:** when using `cubitTest` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
cubitTest(
  'emits [StateB] when emitB is called',
  build: () async => MyCubit(),
  act: (cubit) async => cubit.emitB(),
  expect: [isA<StateB>()],
);
```

## Dart Versions

- Dart 2: >= 2.7.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[![Very Good Ventures](https://raw.githubusercontent.com/felangel/cubit/master/assets/vgv_logo.png)](https://verygood.ventures)

## Starware

Cubit Test is Starware.  
This means you're free to use the project, as long as you star its GitHub repository.  
Your appreciation makes us grow and glow up. ⭐
