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
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

A Dart package that makes testing blocs and cubits easy. Built to work with [bloc](https://pub.dev/packages/bloc) and [mocktail](https://pub.dev/packages/mocktail).

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

---

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/felangel)]

<table>
    <tbody>
        <tr>
            <td align="center" style="background-color: white">
                <a href="https://verygood.ventures"><img src="https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png" width="225"/></a>
            </td>
            <td align="center" style="background-color: white">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc" target="_blank"><img width="250px" src="https://stream-blog.s3.amazonaws.com/blog/wp-content/uploads/fc148f0fc75d02841d017bb36e14e388/Stream-logo-with-background-.png"/></a><br/><span><a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc" target="_blank">Try the Flutter Chat Tutorial &nbsp💬</a></span>
            </td>
            <td align="center" style="background-color: white">
                <a href="https://www.miquido.com/flutter-development-company/?utm_source=github&utm_medium=sponsorship&utm_campaign=bloc-silver-tier&utm_term=flutter-development-company&utm_content=miquido-logo"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/miquido_logo.png" width="225"/></a>
            </td>
            <td align="center" style="background-color: white">
                <a href="https://bit.ly/parabeac_flutterbloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/parabeac_logo.png" width="225"/></a>
            </td>
        </tr>
    </tbody>
</table>

---

## Create a Mock

```dart
import 'package:bloc_test/bloc_test.dart';

class MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
class MockCounterCubit extends MockCubit<int> implements CounterCubit {}
```

## Stub the State Stream

**whenListen** creates a stub response for the `listen` method on a bloc or cubit. Use `whenListen` if you want to return a canned `Stream` of states. `whenListen` also handles stubbing the `state` to stay in sync with the emitted state.

```dart
// Create a mock instance
final counterBloc = MockCounterBloc();

// Stub the state stream
whenListen(
  counterBloc,
  Stream.fromIterable([0, 1, 2, 3]),
  initialState: 0,
);

// Assert that the initial state is correct.
expect(counterBloc.state, equals(0));

// Assert that the stubbed stream is emitted.
await expectLater(counterBloc.stream, emitsInOrder(<int>[0, 1, 2, 3])))

// Assert that the current state is in sync with the stubbed stream.
expect(counterBloc.state, equals(3));
```

## Unit Test with blocTest

**blocTest** creates a new `bloc`-specific test case with the given `description`.
`blocTest` will handle asserting that the `bloc` emits the `expect`ed states (in order) after `act` is executed. `blocTest` also handles ensuring that no additional states are emitted by closing the `bloc` stream before evaluating the `expect`ation.

`setUp` is optional and should be used to set up any dependencies prior to initializing the `bloc` under test. `setUp` should be used to set up state necessary for a particular test case. For common set up code, prefer to use `setUp` from `package:test/test.dart`.

`build` should construct and return the `bloc` under test.

`seed` is an optional `Function` that returns a state which will be used to seed the `bloc` before `act` is called.

`act` is an optional callback which will be invoked with the `bloc` under test and should be used to interact with the `bloc`.

`skip` is an optional `int` which can be used to skip any number of states. `skip` defaults to 0.

`wait` is an optional `Duration` which can be used to wait for async operations within the `bloc` under test such as `debounceTime`.

`expect` is an optional `Function` that returns a `Matcher` which the `bloc` under test is expected to emit after `act` is executed.

`verify` is an optional callback which is invoked after `expect` and can be used for additional verification/assertions. `verify` is called with the `bloc` returned by `build`.

`errors` is an optional `Function` that returns a `Matcher` which the `bloc` under test is expected to throw after `act` is executed.

`tearDown` is optional and can be used to execute any code after the test has run. `tearDown` should be used to clean up after a particular test case. For common tear down code, prefer to use `tearDown` from `package:test/test.dart`.

`tags` is optional and if it is passed, it declares user-defined tags that are applied to the test. These tags can be used to select or skip the test on the command line, or to do bulk test configuration.

```dart
group('CounterBloc', () {
  blocTest(
    'emits [] when nothing is added',
    build: () => CounterBloc(),
    expect: () => [],
  );

  blocTest(
    'emits [1] when CounterIncrementPressed is added',
    build: () => CounterBloc(),
    act: (bloc) => bloc.add(CounterIncrementPressed()),
    expect: () => [1],
  );
});
```

`blocTest` can optionally be used with a seeded state.

```dart
blocTest(
  'emits [10] when seeded with 9',
  build: () => CounterBloc(),
  seed: () => 9,
  act: (bloc) => bloc.add(CounterIncrementPressed()),
  expect: () => [10],
);
```

`blocTest` can also be used to `skip` any number of emitted states before asserting against the expected states. The default value is 0.

```dart
blocTest(
  'emits [2] when CounterIncrementPressed is added twice',
  build: () => CounterBloc(),
  act: (bloc) => bloc..add(CounterIncrementPressed())..add(CounterIncrementPressed()),
  skip: 1,
  expect: () => [2],
);
```

`blocTest` can also be used to wait for async operations like `debounceTime` by providing a `Duration` to `wait`.

```dart
blocTest(
  'emits [MyState] when MyEvent is added',
  build: () => MyBloc(),
  act: (bloc) => bloc.add(MyEvent()),
  wait: const Duration(milliseconds: 300),
  expect: () => [isA<MyState>()],
);
```

`blocTest` can also be used to `verify` internal bloc functionality.

```dart
blocTest(
  'emits [MyState] when MyEvent is added',
  build: () => MyBloc(),
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [isA<MyState>()],
  verify: (_) {
    verify(() => repository.someMethod(any())).called(1);
  }
);
```

`blocTest` can also be used to expect that exceptions have been thrown.

```dart
blocTest(
  'throws Exception when null is added',
  build: () => MyBloc(),
  act: (bloc) => bloc.add(null),
  errors: () => [isA<Exception>()]
);
```

**Note:** when using `blocTest` with state classes which don't override `==` and `hashCode` you can provide an `Iterable` of matchers instead of explicit state instances.

```dart
blocTest(
  'emits [MyState] when MyEvent is added',
  build: () => MyBloc(),
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [isA<MyState>()],
);
```

## Dart Versions

- Dart 2: >= 2.12

## Maintainers

- [Felix Angelov](https://github.com/felangel)
