# 3.1.0

- Expose lazy parameter on `RepositoryProvider` and `BlocProvider` ([#749](https://github.com/felangel/bloc/pull/749))
- Updated to `provider: ^4.0.1` ([#748](https://github.com/felangel/bloc/issues/748))
- Add `BlocConsumer` ([#545](https://github.com/felangel/bloc/issues/545))
- Export `bloc` as part of `flutter_bloc`

# 3.0.0

- Updated to `bloc: ^3.0.0` ([#700](https://github.com/felangel/bloc/pull/700))
- Updated to `flutter >=1.12.1` ([#700](https://github.com/felangel/bloc/pull/700))
- Updated to `provider: ^4.0.0` ([#700](https://github.com/felangel/bloc/pull/700), [#734](https://github.com/felangel/bloc/pull/734))
- Revert `BlocBuilder` and `BlocListener` condition behavior to set `previousState` to the previous bloc state ([#709](https://github.com/felangel/bloc/issues/709))

# 3.0.0-dev.1

- Updated to `bloc: ^3.0.0-dev.1`

# 2.1.1

- Fix internal analysis warnings
- Enforce provider `^3.2.0`

# 2.1.0

- Deprecate `builder` in `BlocProvider` in favor of `create` to align with `provider`.
- Deprecate `builder` in `RepositoryProvider` in favor of `create` to align with `provider`.

# 2.0.1

- Fix `BlocBuilder` and `BlocListener` condition behavior to set `previousState` to the previous state used by `BlocBuilder`/`BlocListener` instead of the previous state of the `bloc`.
- Minor Documentation Updates

# 2.0.0

- Updated to `bloc: ^2.0.0` and Documentation Updates
- Adhere to [effective dart](https://dart.dev/guides/language/effective-dart) ([#561](https://github.com/felangel/bloc/issues/561))

# 1.0.0

Updated to `bloc: ^1.0.0` and Documentation Updates

# 0.22.1

Minor Bugfixes and Documentation Updates

# 0.22.0

Updated to `bloc: ^0.16.0` and Documentation Updates

# 0.21.0

Updated to `bloc: ^0.15.0` and Documentation Updates

# 0.20.1

- Minor Updates to Package Dependencies
- Documentation Updates

# 0.20.0

- Add Automatic Bloc Lookup to `BlocBuilder` and `BlocListener` ([#415](https://github.com/felangel/bloc/pull/415))
- Support for `BlocProvider` instantiation and look-up within the same `BuildContext` ([#415](https://github.com/felangel/bloc/pull/415))
- Documentation Updates

# 0.19.1

Add optional `condition` to `BlocListener` to control listener calls ([#406](https://github.com/felangel/bloc/pull/406)) and Documentation Updates

# 0.19.0

Addresses [#354](https://github.com/felangel/bloc/issues/354)

#### BlocProvider

- Refactor `BlocProvider` to extend `Provider`
- Rename `BlocProviderTree` to `MultiBlocProvider`

#### ImmutableProvider

- Refactor `ImmutableProvider` to extend `Provider`
- Rename `ImmutableProvider` to `RepositoryProvider`
- Rename `ImmutableProviderTree` to `MultiRepositoryProvider`

#### BlocListener

- Rename `BlocListenerTree` to `MultiBlocListener`

#### Documentation

- Inline documentation updates/improvements

# 0.18.3

Fix `BlocProvider` bug where `copyWith` does not preserve `dispose` value ([#376](https://github.com/felangel/bloc/issues/376)).

# 0.18.2

Fix `BlocListener` bug where `listener` gets called even when no state change occurs ([#368](https://github.com/felangel/bloc/issues/368)).

# 0.18.1

Minor Documentation Updates

# 0.18.0

Expose `ImmutableProvider` & `ImmutableProviderTree` to enable developers to provide immutable values, such as repositories, throughout the widget tree ([#364](https://github.com/felangel/bloc/pull/364)) and Documentation Updates

# 0.17.0

Update `BlocProvider` to automatically `dispose` the provided bloc ([#349](https://github.com/felangel/bloc/pull/349)) and Documentation Updates

# 0.16.0

Update `BlocProvider` to expose `builder` and `dispose` ([#344](https://github.com/felangel/bloc/pull/344) and [#347](https://github.com/felangel/bloc/pull/347)) and Documentation Updates

# 0.15.1

Fix `null` initial `previousState` in `BlocBuilder` `condition` ([#328](https://github.com/felangel/bloc/issues/328)) and Documentation Updates

# 0.15.0

Added optional `condition` to `BlocBuilder` to control widget rebuilds ([#315](https://github.com/felangel/bloc/issues/315)) and Documentation Updates

# 0.14.0

Updated to `bloc: ^0.14.0` and Documentation Updates

# 0.13.0

Updated to `bloc: ^0.13.0` and Documentation Updates

# 0.12.0

Added `BlocListenerTree` and Documentation Updates

# 0.11.1

Broaden Dart version range and Minor Documentation Updates

# 0.11.0

Updated to `bloc: ^0.12.0` and Documentation Updates

# 0.10.1

Invoke `BlocWidgetListener` on initial state and Documentation Updates

# 0.10.0

Added `BlocListener` and Documentation Updates

# 0.9.1

Minor Updates to Documentation.

# 0.9.0

Updated to `bloc: ^0.11.0` and Documentation Updates

# 0.8.0

Updated to `bloc: ^0.10.0` and Documentation Updates

# 0.7.1

Minor Updates to Documentation.

# 0.7.0

Added `BlocProviderTree` and Documentation Updates

# 0.6.3

Updated to `bloc:^0.9.3` and Minor Updates to Documentation

# 0.6.2

Additional Minor Updates to Documentation

# 0.6.1

Minor Updates to Documentation

# 0.6.0

Updated to `bloc: ^0.9.0`

# 0.5.4

Additional Minor Updates to Documentation

# 0.5.3

Additional Minor Updates to Documentation

# 0.5.2

Minor Updates to Documentation

# 0.5.1

`BlocProvider` performance improvements

# 0.5.0

Updated to `bloc: ^0.8.0`

# 0.4.12

Additional Minor Updates to Documentation

# 0.4.11

Additional Minor Updates to Documentation

# 0.4.10

Additional `BlocBuilder` enhancements

- `BlocBuilder` no longer filters out States giving developers full control

Minor Updates to Documentation and Examples

# 0.4.9

Additional `BlocBuilder` enhancements

- `BlocBuilder` no longer has a dependency on `RxDart`
- Using `bloc: ">=0.7.5 <0.8.0"`

# 0.4.8

Additional `BlocProvider` performance improvements

# 0.4.7

Minor Updates to Documentation and Examples

# 0.4.6

Bug Fixes

- Fixed bug where `BlocBuilder` would return initial state instead of the latest state

# 0.4.5

Additional Minor Updates to Documentation

# 0.4.4

Minor updates to documentation and improved error reporting in `BlocProvider`

# 0.4.3

`BlocBuilder` performance improvements

# 0.4.2

`BlocProvider` performance improvements

# 0.4.1

Minor Updates to Documentation

# 0.4.0

Updated to `bloc: ^0.7.0`

# 0.3.1

Minor Updates to Documentation

# 0.3.0

Updated to `bloc: ^0.6.0`

# 0.2.1

Minor Updates to Documentation

# 0.2.0

Updates to `BlocBuilder` and `BlocProvider`

- `BlocBuilder` does not automatically dispose a `Bloc`. Developers are now responsible for determining when to call `Bloc.dispose()`
- `BlocProvider` support for `of(context)` with generics
  - Support for multiple nested `BlocProviders` with different Bloc Types.

# 0.1.1

Minor Updates to Documentation

# 0.1.0

Initial Version of the library.

- Includes the ability to connect presentation layer to `Bloc` by using the `BlocBuilder` Widget.
- Includes `BlocProvider`, a DI widget that allows a single instance of a bloc to be provided to multiple widgets within a subtree.
