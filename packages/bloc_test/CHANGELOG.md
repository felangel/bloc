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
