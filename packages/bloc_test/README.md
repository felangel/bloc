<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_test_logo_full.png" height="60" alt="Bloc Test Package" />

[![Pub](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)
[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![Flutter.io](https://img.shields.io/badge/flutter-website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/felangel/bloc)
[![Gitter](https://img.shields.io/badge/gitter-chat-hotpink.svg)](https://gitter.im/bloc_package/Lobby)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A Dart package that makes testing blocs easy. Built to work with [bloc](https://pub.dev/packages/bloc) and [mockito](https://pub.dev/packages/mockito).

## Create a Mock Bloc

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';

class MockCounterBloc extends Mock implements CounterBloc {}
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

`build` should be used for all `bloc` initialization and preparation and must return the `bloc` under test.

`act` is an optional callback which will be invoked with the `bloc` under test and should be used to `add` events to the bloc.

`expect` is an `Iterable<State>` which the `bloc` under test is expected to emit after `act` is executed.

```dart
group('CounterBloc', () {
    blocTest(
      'emits [0] when nothing is added',
      build: () => CounterBloc(),
      expect: [0],
    );

    blocTest(
      'emits [0, 1] when CounterEvent.increment is added',
      build: () => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      expect: [0, 1],
    );
});
```

## Assert with Confidence using emitsExactly

**emitsExactly** is similar to `emitsInOrder` but asserts that the provided `bloc` emits **only** the `expected` states in the **exact** order in which they were provided.

```dart
group('CounterBloc', () {
    test('emits [0] when nothing is added', () async {
      final bloc = CounterBloc();
      await emitsExactly(bloc, [0]);
    });

    test('emits [0, 1] when CounterEvent.increment is added', () async {
      final bloc = CounterBloc();
      bloc.add(CounterEvent.increment);
      await emitsExactly(bloc, [0, 1]);
    });
});
```

## Dart Versions

- Dart 2: >= 2.0.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)
