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
