# 9.1.5

- fix: `blocTest` supports `async` `expect` ([#3976](https://github.com/felangel/bloc/pull/3976))

# 9.1.4

- deps: support `mocktail: ^1.0.0` ([#3917](https://github.com/felangel/bloc/pull/3917))
- chore: add topics to `pubspec.yaml` ([#3914](https://github.com/felangel/bloc/pull/3914))

# 9.1.3

- fix: test timeouts due to uncaught exceptions which occur with `package:test ^1.22.2` ([#3854](https://github.com/felangel/bloc/pull/3854))

# 9.1.2

- docs: upgrade to Dart 3
- refactor: standardize analysis_options

# 9.1.1

- chore: upgrade to `bloc ^8.1.1` ([#3723](https://github.com/felangel/bloc/pull/3723))
  - refactor: `BlocObserver` instances to use `const` constructors ([#3713](https://github.com/felangel/bloc/pull/3713))
- refactor: upgrade to Dart 2.19 ([#3699](https://github.com/felangel/bloc/pull/3699))
  - remove deprecated `invariant_booleans` lint rule
- docs: fix snippet in `README` ([#3552](https://github.com/felangel/bloc/pull/3552))

# 9.1.0

- feat: upgrade to `bloc: ^8.1.0` ([#3502](https://github.com/felangel/bloc/pull/3502))

# 9.0.3

- chore: support for mocktail v0.3.0 ([#3252](https://github.com/felangel/bloc/pull/3252))
- docs: update GetStream utm tags ([#3136](https://github.com/felangel/bloc/pull/3136))
- docs: update VGV sponsors logo ([#3125](https://github.com/felangel/bloc/pull/3125))

# 9.0.2

- fix: throw uncaught exceptions ([#3070](https://github.com/felangel/bloc/pull/3070))
- chore: upgrade to `bloc v8.0.2`
- docs: update example to follow naming conventions ([#3032](https://github.com/felangel/bloc/pull/3032))

# 9.0.1

- chore: upgrade to `bloc v8.0.1`

# 9.0.0

- **BREAKING**: feat: upgrade to `bloc v8.0.0`
- feat: `MockBloc` no longer implicitly requires `registerFallbackValue` for events and states

# 9.0.0-dev.5

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.5`

# 9.0.0-dev.4

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.4`

# 9.0.0-dev.3

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.3`

# 9.0.0-dev.2

- **BREAKING**: feat: upgrade to `mocktail v0.2.0`

# 9.0.0-dev.1

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.2`
- feat: `MockBloc` no longer implicitly requires `registerFallbackValue` for events and states

# 8.5.0

- feat: prettier diffing when using `blocTest` and `expect` does not match emitted states ([#1783](https://github.com/felangel/bloc/issues/1783))

# 8.4.0

- feat: upgrade to `mocktail ^0.2.0`

# 8.3.0

- feat: accept optional tags in `blocTest`
  - `tags` is optional and if it is passed, it declares user-defined tags that are applied to the test. These tags can be used to select or skip the test on the command line, or to do bulk test configuration.

# 8.2.0

- feat: upgrade to `bloc ^7.2.0`

# 8.1.0

- feat: add `setUp` and `tearDown` to `blocTest`

# 8.0.2

- fix: revert `package:mocktail` export to reduce conflicts with `package:mockito`

# 8.0.1

- fix: allow `blocTest` to capture non-exceptions
- feat: export `package:mocktail`

# 8.0.0

- **BREAKING**: feat: opt into null safety
  - upgrade Dart SDK constraints to `>=2.12.0-0 <3.0.0`
- **BREAKING**: feat: `seed` returns a `Function` to support dynamic seed values
- **BREAKING**: refactor: remove `emitsExactly`
- **BREAKING**: feat: introduce `MockCubit`
- **BREAKING**: refactor: `MockBloc` uses [package:mocktail](https://pub.dev/packages/mocktail)
- **BREAKING**: refactor: `expect` returns a `Function` with `Matcher` support
- **BREAKING**: refactor: `errors` returns a `Function` with `Matcher` support
- **BREAKING**: refactor: `whenListen` does not stub `skip`
- feat: `MockBloc` and `MockCubit` automatically stub core API
- feat: add optional `initialState` to `whenListen`
- feat: upgrade to `bloc ^7.0.0`
- feat: upgrade to `mocktail: ^0.1.0`

# 8.0.0-nullsafety.6

- chore: upgrade to `bloc ^7.0.0-nullsafety.4`

# 8.0.0-nullsafety.5

- feat: upgrade to `mocktail: ^0.1.0`
- feat: use `package:test` instead of `package:test_api`

# 8.0.0-nullsafety.4

- **BREAKING**: feat: `seed` returns a `Function` to support dynamic seed values

# 8.0.0-nullsafety.3

- feat: upgrade to `mocktail: ">=0.0.2-dev.5 <0.0.2"`

# 8.0.0-nullsafety.2

- fix: restrict to `mocktail: ">=0.0.1-dev.12 <0.0.1"`
- feat: use `package:test_api` instead of `package:test` for sound null safety

# 8.0.0-nullsafety.1

- chore: upgrade to `bloc ^7.0.0-nullsafety.3`
- chore: upgrade to `mocktail ^0.0.1-dev.12`

# 8.0.0-nullsafety.0

- **BREAKING**: feat: opt into null safety
- **BREAKING**: feat: upgrade Dart SDK constraints to `>=2.12.0-0 <3.0.0`
- **BREAKING**: refactor: remove `emitsExactly`
- **BREAKING**: refactor: `MockBloc` uses [package:mocktail](https://pub.dev/packages/mocktail)
- **BREAKING**: feat: introduce `MockCubit` which uses [package:mocktail](https://pub.dev/packages/mocktail)
- **BREAKING**: refactor: `expect` returns a `Function` with `Matcher` support
- **BREAKING**: refactor: `errors` returns a `Function` with `Matcher` support
- **BREAKING**: refactor: `whenListen` does not stub `skip`
- feat: introduce `MockCubit`
- feat: `MockBloc` and `MockCubit` automatically stub core API
- feat: add optional `initialState` to `whenListen`

# 7.1.0

- feat: add `seed` property to `blocTest`

# 7.0.6

- chore: revert support `dart >=2.7.0`

# 7.0.5

- fix: update to `mockito ^4.1.2`
- chore: update to `dart >=2.10.0`

# 7.0.4

- feat: `blocTest` provides warning to implement deep equality when shallow equality is true

# 7.0.3

- restrict `mockito` to `<4.1.2` to prevent breaking changes due to NNBD

# 7.0.2

- fix: `blocTest` timeouts when verify fails ([#1639](https://github.com/felangel/bloc/issues/1639))
- fix: `blocTest` timeouts when expect fails ([#1645](https://github.com/felangel/bloc/issues/1645))

# 7.0.1

- chore: deprecate `emitsExactly` in favor of `blocTest`
- fix: capture uncaught exceptions in `Cubit`

# 7.0.0

- **BREAKING**: upgrade to `bloc ^6.0.0`
- **BREAKING**: `MockBloc` only requires `State` type
- **BREAKING**: `whenListen` only requires `State` type
- **BREAKING**: `blocTest` only requires `State` type
- **BREAKING**: `blocTest` `skip` defaults to `0`
- **BREAKING**: `blocTest` make `build` synchronous
- fix: `blocTest` improve `wait` behavior when debouncing, etc...
- feat: `blocTest` do not require `async` on `act` and `verify`
- feat: remove external dependency on [package:cubit_test](https://pub.dev/packages/cubit_test)
- feat: `MockBloc` is compatible with `cubit`
- feat: `whenListen` is compatible with `cubit`
- feat: `blocTest` is compatible with `cubit`

# 7.0.0-dev.2

- **BREAKING**: `blocTest` make `build` synchronous
- fix: `blocTest` improve `wait` behavior when debouncing, etc...
- feat: `blocTest` do not require `async` on `act` and `verify`

# 7.0.0-dev.1

- **BREAKING**: upgrade to `bloc ^6.0.0-dev.1`
- **BREAKING**: `MockBloc` only requires `State` type
- **BREAKING**: `whenListen` only requires `State` type
- **BREAKING**: `blocTest` only requires `State` type
- **BREAKING**: `blocTest` `skip` defaults to `0`
- feat: remove external dependency on [package:cubit_test](https://pub.dev/packages/cubit_test)
- feat: `MockBloc` is compatible with `cubit`
- feat: `whenListen` is compatible with `cubit`
- feat: `blocTest` is compatible with `cubit`

# 6.0.1

- fix: upgrade to `bloc ^5.0.1`
- fix: upgrade to `cubit_test ^0.1.1`
- docs: minor documentation updates

# 6.0.0

- feat: upgrade to `bloc ^5.0.0`
- refactor: internal implementation updates to use [cubit_test](https://pub.dev/packages/cubit_test)

# 6.0.0-dev.4

- Update to `bloc ^5.0.0-dev.11`.

# 6.0.0-dev.3

- Update to `bloc ^5.0.0-dev.10`.

# 6.0.0-dev.2

- Update to `bloc ^5.0.0-dev.7`.

# 6.0.0-dev.1

- Update to `bloc ^5.0.0-dev.6`.
- Internal implementation updates to use [cubit_test](https://pub.dev/packages/cubit_test)

# 5.1.0

- Add `errors` to `blocTest` to enable expecting unhandled exceptions within blocs.
- Update `whenListen` to also handle stubbing the state property of the bloc.

# 5.0.0

- Update to `bloc: ^4.0.0`

# 5.0.0-dev.4

- Update to `bloc: ^4.0.0-dev.4`

# 5.0.0-dev.3

- Update to `bloc: ^4.0.0-dev.3`

# 5.0.0-dev.2

- Update to `bloc: ^4.0.0-dev.2`

# 5.0.0-dev.1

- Update to `bloc: ^4.0.0-dev.1`

# 4.0.0

- `blocTest` and `emitsExactly` skip `initialState` by default and expose optional `skip` ([#910](https://github.com/felangel/bloc/issues/910))
- `blocTest` async `build` ([#910](https://github.com/felangel/bloc/issues/910))
- `blocTest` `expect` is optional ([#910](https://github.com/felangel/bloc/issues/910))
- `blocTest` `verify` includes the built bloc ([#910](https://github.com/felangel/bloc/issues/910))

# 3.1.0

- Add `verify` to `blocTest` ([#781](https://github.com/felangel/bloc/issues/781))

# 3.0.1

- Enable `blocTest` to add more than one asynchronous event at a time ([#724](https://github.com/felangel/bloc/issues/724))

# 3.0.0

- Update to `bloc: ^3.0.0`
- `emitsExactly` supports optional `duration` for async operators like `debounceTime` ([#726](https://github.com/felangel/bloc/issues/726))
- `blocTest` supports optional `wait` for async operators like `debounceTime` ([#726](https://github.com/felangel/bloc/issues/726))

# 3.0.0-dev.1

- Update to `bloc: ^3.0.0-dev.1`

# 2.2.2

- Minor internal improvements (fixed analysis warning in `emitsExactly`)

# 2.2.1

- Minor documentation improvements (syntax highlighting in README)

# 2.2.0

- `emitsExactly` and `blocTest` support `Iterable<Matcher` ([#695](https://github.com/felangel/bloc/issues/695))

# 2.1.0

- Add `MockBloc` to `bloc_test` in order to simplify bloc mocks (addresses [#636](https://github.com/felangel/bloc/issues/636))
- Documentation and example updates

# 2.0.0

- Updated to `bloc: ^2.0.0` and Documentation Updates
- Adhere to [effective dart](https://dart.dev/guides/language/effective-dart) ([#561](https://github.com/felangel/bloc/issues/561))

# 1.0.0

Updated to `bloc: ^1.0.0` and Documentation Updates

# 0.2.1

`whenListen` automatically converts `Stream` to `BroadcastStream`

# 0.2.0

`whenListen` handles internal `skip` from `BlocBuilder` and `BlocListener`

# 0.1.0

Initial Version of the library.

- Includes `whenListen` to enable mocking a `Bloc` state `Stream`.
