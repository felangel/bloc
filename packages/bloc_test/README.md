<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_test_logo_full.png" height="100" alt="Bloc Test Package" />
</p>

<p align="center">
<a href="https://pub.dev/packages/bloc_test"><img src="https://img.shields.io/pub/v/bloc_test.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

A Dart package that makes testing blocs and cubits easy. Built to work with [bloc](https://pub.dev/packages/bloc) and [mockito](https://pub.dev/packages/mockito).

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

## Create a Mock

```dart
import 'package:bloc_test/bloc_test.dart';

class MockCounterBloc extends MockBloc<int> implements CounterBloc {}
class MockCounterCubit extends MockBloc<int> implements CounterCubit {}
```

## Stub the State Stream

**whenListen** creates a stub response for the `listen` method on a bloc or cubit. Use `whenListen` if you want to return a canned `Stream` of states. `whenListen` also handles stubbing the `state` to stay in sync with the emitted state.

```dart
// Create a mock instance
final counterBloc = MockCounterBloc();

// Stub the state stream
whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));

// Assert that the stubbed stream is emitted.
await expectLater(counterBloc, emitsInOrder(<int>[0, 1, 2, 3])))

// Assert that the current state is in sync with the stubbed stream.
expect(counterBloc.state, equals(3));
```

## Unit Test with blocTest

**blocTest** creates a new `cubit`-specific test case with the given `description`. `blocTest` will handle asserting that the `cubit` emits the `expect`ed states (in order) after `act` is executed. `blocTest` also handles ensuring that no additional states are emitted by closing the `cubit` stream before evaluating the `expect`ation.

`build` should be used for all `cubit` initialization and preparation and must return the `cubit` under test as a `Future`.

`act` is an optional callback which will be invoked with the `cubit` under test and should be used to `add` events to the `cubit`.

`skip` is an optional `int` which can be used to skip any number of states. The default value is 1 which skips the `initialState` of the bloc. `skip` can be overridden to include the `initialState` by setting skip to 0.

`wait` is an optional `Duration` which can be used to wait for async operations within the `cubit` under test such as `debounceTime`.

`expect` is an optional `Iterable<State>` which the `cubit` under test is expected to emit after `act` is executed.

`verify` is an optional callback which is invoked after `expect` and can be used for additional verification/assertions. `verify` is called with the `cubit` returned by `build`.

`errors` is an optional `Iterable` of error matchers which the `cubit` under test is expected to have thrown after `act` is executed.

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
    act: (bloc) async => bloc.add(CounterEvent.increment),
    expect: [1],
  );
});
```

`blocTest` can also be used to `skip` any number of emitted states before asserting against the expected states. The default value is 0.

```dart
blocTest(
  'CounterBloc emits [1] when CounterEvent.increment is added',
  build: () async => CounterBloc(),
  act: (bloc) async => bloc..add(CounterEvent.increment)..add(CounterEvent.increment),
  skip: 1,
  expect: [1],
);
```

`blocTest` can also be used to wait for async operations like `debounceTime` by providing a `Duration` to `wait`.

```dart
blocTest(
  'CounterBloc emits [1] when CounterEvent.increment is added',
  build: () async => CounterBloc(),
  act: (bloc) async => bloc.add(CounterEvent.increment),
  wait: const Duration(milliseconds: 300),
  expect: [1],
);
```

`blocTest` can also be used to `verify` internal bloc functionality.

```dart
blocTest(
  'CounterBloc emits [1] when CounterEvent.increment is added',
  build: () async => CounterBloc(),
  act: (bloc) async => bloc.add(CounterEvent.increment),
  expect: [1],
  verify: (_) async {
    verify(repository.someMethod(any)).called(1);
  }
);
```

`blocTest` can also be used to expect that exceptions have been thrown.

```dart
blocTest(
  'CounterBloc throws Exception when null is added',
  build: () async => CounterBloc(),
  act: (bloc) async => bloc.add(null),
  errors: [
    isA<Exception>(),
  ]
);
```

**Note:** when using `blocTest` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
blocTest(
  'emits [StateB] when MyEvent is added',
  build: () async => MyBloc(),
  act: (bloc) async => bloc.add(MyEvent()),
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
    final bloc = CounterBloc()..add(CounterEvent.increment);
    await emitsExactly(bloc, [1]);
  });
});
```

`emitsExactly` also supports `Matchers` for states which don't override `==` and `hashCode`.

```dart
test('emits [StateB] when EventB is added', () async {
  final bloc = MyBloc()..add(EventB());
  await emitsExactly(bloc, [isA<StateB>()]);
});
```

`skip` is an optional `int` which defaults to 0 and can be used to skip any number of states.

```dart
test('emits [2] when CounterEvent.increment is added twice and skip is 1', () async {
  final bloc = CounterBloc()
    ..add(CounterEvent.increment)
    ..add(CounterEvent.increment);
  await emitsExactly(bloc, [2], skip: 1);
});
```

`emitsExactly` also takes an optional `duration` which is useful in cases where the `bloc` is using `debounceTime` or other similar operators.

```dart
test('emits [1] when CounterEvent.increment is added', () async {
  final bloc = CounterBloc()..add(CounterEvent.increment);
  await emitsExactly(bloc, [1], duration: const Duration(milliseconds: 300));
});
```

## Dart Versions

- Dart 2: >= 2.6.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120" />](https://verygood.ventures)
