# 8.1.3

- docs: remove graphql sample references from README ([#3820](https://github.com/felangel/bloc/pull/3820))
- docs: upgrade to Dart 3 ([#3809](https://github.com/felangel/bloc/pull/3820))
- refactor: standardize analysis_options ([#3809](https://github.com/felangel/bloc/pull/3820))
- refactor: update sdk constraints and fix analysis warnings ([#3809](https://github.com/felangel/bloc/pull/3820))

# 8.1.2

- chore: add screenshots to `pubspec.yaml` ([#3717](https://github.com/felangel/bloc/pull/3717))
- chore(deps): upgrade to `bloc ^8.1.1` ([#3716](https://github.com/felangel/bloc/pull/3716))
- chore: update example to Dart 2.19 ([#3715](https://github.com/felangel/bloc/pull/3715))
- refactor: `BlocObserver` instances to use `const` constructors ([#3713](https://github.com/felangel/bloc/pull/3713))
- refactor: remove unnecessary single child widget mixins ([#3675](https://github.com/felangel/bloc/pull/3675))
- refactor: upgrade to Flutter 3.7 ([#3699](https://github.com/felangel/bloc/pull/3699))
  - remove deprecated `invariant_booleans` lint rule

# 8.1.1

- chore: remove dependency overrides from example to fix pana score

# 8.1.0

- feat: upgrade to `bloc: ^8.1.0`
- chore: upgrade example to latest bloc and hydrated_bloc ([#3481](https://github.com/felangel/bloc/pull/3481))
- docs: update GetStream utm tags ([#3136](https://github.com/felangel/bloc/pull/3136))
- docs: update VGV sponsors logo ([#3125](https://github.com/felangel/bloc/pull/3125))

# 8.0.1

- refactor: use core interfaces from `bloc v8.0.2` ([#3012](https://github.com/felangel/bloc/pull/3012))
- docs: update example to follow naming conventions ([#3027](https://github.com/felangel/bloc/pull/3027))

# 8.0.0

- **BREAKING**: feat: upgrade to `bloc v8.0.0`

# 8.0.0-dev.3

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.5`

# 8.0.0-dev.2

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.3`

# 8.0.0-dev.1

- **BREAKING**: feat: upgrade to `bloc v8.0.0-dev.2`

# 7.3.3

- fix: add missing child assertion to `BlocListener` and `BlocProvider` ([#2924](https://github.com/felangel/bloc/pull/2924))

# 7.3.2

- fix: `BlocProvider` explicitly default `lazy` to `true` to support `avoid_redundant_argument_values` ([#2917](https://github.com/felangel/bloc/pull/2917))

# 7.3.1

- fix: determine bloc reference changes via `identical`
  - Previously `identityHashCode` was used to determine if the bloc reference had changed to trigger a rebuild ([#2482](https://github.com/felangel/bloc/pull/2482)) however, it's possible for different bloc references to have the same `hashCode` as a result of hash collisions. The fix uses `identical` to determine whether the bloc reference has changed.
- docs: add inline docs to library
- docs: minor improvements to example and `README`
- chore: remove unneeded imports

# 7.3.0

- feat: upgrade to `bloc: ^7.2.0`

# 7.2.0

- feat: upgrade to `provider: ^6.0.0`

# 7.1.0

- feat: add `BlocSelector` widget

# 7.0.1

- fix: `BlocConsumer`, `BlocBuilder`, and `BlocListener` depend on bloc/cubit instance
  - when a provided bloc instance changes, `BlocConsumer`, `BlocBuilder`, and `BlocListener` will all update to use the new instance
- docs: update `BlocBuilder` and `BlocListener` inline API docs to include `buildWhen` and `listenWhen`

# 7.0.0

- **BREAKING**: refactor: rename `cubit` parameter to `bloc`
  - refactor: rename `cubit` parameter in `BlocListener` to `bloc`
  - refactor: rename `cubit` parameter in `BlocBuilder` to `bloc`
  - refactor: rename `cubit` parameter in `BlocConsumer` to `bloc`
- **BREAKING**: opt into null safety
  - upgrade Dart SDK constraints to `>=2.12.0-0 <3.0.0`
- **BREAKING**: refactor: remove deprecated `context.repository`
- feat: upgrade to `bloc: ^7.0.0`
- feat: upgrade to `provider: ^5.0.0`

# 7.0.0-nullsafety.6

- chore: bump to `bloc: ^7.0.0-nullsafety.4`

# 7.0.0-nullsafety.5

- **BREAKING**: refactor: remove deprecated `context.repository`

# 7.0.0-nullsafety.4

- chore: bump to `provider: ^5.0.0`

# 7.0.0-nullsafety.3

- chore: bump to `bloc: ^7.0.0-nullsafety.3`
- chore: bump to `provider: ^5.0.0-nullsafety.5`

# 7.0.0-nullsafety.2

- chore: bump to `bloc: ^7.0.0-nullsafety.2`

# 7.0.0-nullsafety.1

- **BREAKING**: refactor: upgrade to `bloc ^7.0.0-nullsafety.1`
  - refactor: rename `cubit` parameter in `BlocListener` to `bloc`
  - refactor: rename `cubit` parameter in `BlocBuilder` to `bloc`
  - refactor: rename `cubit` parameter in `BlocConsumer` to `bloc`
- feat: upgrade to `provider ^5.0.0-nullsafety.3`

# 7.0.0-nullsafety.0

- **BREAKING**: opt into null safety
- feat!: upgrade Dart SDK constraints to `>=2.12.0-0 <3.0.0`

# 7.0.0-dev.2

- **BREAKING**: revert `7.0.0-dev.1`
- **BREAKING**: remove `context.bloc` extension
- **BREAKING**: rename `cubit` parameter in `BlocListener` to `value`
- **BREAKING**: rename `cubit` parameter in `BlocBuilder` to `value`
- **BREAKING**: rename `cubit` parameter in `BlocConsumer` to `value`
- docs: update inline API docs

# 7.0.0-dev.1

- **BREAKING**: remove dependency on `package:provider`
- feat: add optional listen to `BlocProvider`
- feat: add ListenProviderExtension
- docs: improve inline documentation for `BlocProvider` and `RepositoryProvider`

# 6.1.3

- feat: expose `ProviderNotFoundException`
- chore: upgrade to `bloc ^6.1.3`
- chore: upgrade to `provider ^4.3.3`

# 6.1.2

- fix: `BlocProvider.value` use `InheritedProvider.value`

# 6.1.1

- fix: `BlocConsumer` does not respect `buildWhen` and results in unnecessary rebuilds

# 6.1.0

- feat: add optional `listen` to `BlocProvider` and `RepositoryProvider`
- feat: add `context.select<T, R>(R Function(T value))` which allows widgets to listen to only a small part of the state of `T` (`R`)
- feat: add `context.watch<T>()` which allows widgets to listen to changes in the state of `T`
- feat: add `context.read<T>()` which allows widgets to access `T` without listening for changes
- deprecated: `context.bloc` in favor of `context.read` and `context.watch`
- deprecated: `context.repository` in favor of `context.read` and `context.watch`
- fix: rethrow `ProviderNotFoundException` from `RepositoryProvider` for external dependencies
- docs: improve inline documentation for `BlocProvider` and `RepositoryProvider`
- docs: update list of examples in `README`

# 6.0.6

- docs: improve inline documentation for `buildWhen`

# 6.0.5

- fix: `BlocBuilder` `builder` and `buildWhen` state mismatch

# 6.0.4

- fix: state synchronization issue when providing a condition

# 6.0.3

- refactor: `BlocConsumer` requires a single subscription
- refactor: `BlocBuilder` extends `BlocListener`
- refactor: `MultiRepositoryProvider` extends `MultiProvider`

# 6.0.2

- docs: fix missing API documentation generated by dartdoc

# 6.0.1

- docs: minor documentation fixes and improvements

# 6.0.0

- **BREAKING**: upgrade to `bloc ^6.0.0`
- **BREAKING**: `BlocBuilder` interop with `cubit` (`bloc` parameter renamed to `cubit`)
- **BREAKING**: `BlocListener` interop with `cubit` (`bloc` parameter renamed to `cubit`)
- **BREAKING**: `BlocConsumer` interop with `cubit` (`bloc` parameter renamed to `cubit`)
- feat: remove external dependency on [package:flutter_cubit](https://pub.dev/packages/flutter_cubit)
- docs: inline documentation updates
- docs: README updates
- docs: example application updates

# 6.0.0-dev.1

- **BREAKING**: upgrade to `bloc ^6.0.0-dev.1`
- **BREAKING**: `BlocBuilder` interop with `cubit` (`bloc` parameter renamed to `cubit`)
- **BREAKING**: `BlocListener` interop with `cubit` (`bloc` parameter renamed to `cubit`)
- **BREAKING**: `BlocConsumer` interop with `cubit` (`bloc` parameter renamed to `cubit`)
- feat: remove external dependency on [package:flutter_cubit](https://pub.dev/packages/flutter_cubit)
- docs: inline documentation updates
- docs: README updates
- docs: example application updates

# 5.0.1

- fix: upgrade to `bloc ^5.0.1`
- docs: minor documentation updates

# 5.0.0

- **BREAKING**: `condition` on `BlocBuilder` renamed to `buildWhen`
- **BREAKING**: `condition` on `BlocListener` renamed to `listenWhen`
- **BREAKING**: upgrade to `bloc v5.0.0`
- refactor: internal implementation updates to use [flutter_cubit](https://pub.dev/packages/flutter_cubit)
- docs: various improvements
- docs: logo updates

# 5.0.0-dev.5

- Update to `bloc: ^5.0.0-dev.11`
- Minor README updates

# 5.0.0-dev.4

- Update to `bloc: ^5.0.0-dev.10`
- Minor README updates

# 5.0.0-dev.3

- Update to `bloc: ^5.0.0-dev.7`

# 5.0.0-dev.2

- Update to `bloc: ^5.0.0-dev.6`
- Update to `flutter_cubit ^0.0.12`
- Various Documentation Updates

# 5.0.0-dev.1

- Update to `bloc: ^5.0.0-dev.3`
- Internal implementation updates to use [flutter_cubit](https://pub.dev/packages/flutter_cubit)

# 4.0.1

- Fix `ProviderNotFoundException` handling ([#1286](https://github.com/felangel/bloc/pull/1286))

# 4.0.0

- Update to `bloc: ^4.0.0`
- Update to `provider: ^4.0.5`

# 4.0.0-dev.4

- Update to `bloc: ^4.0.0-dev.4`

# 4.0.0-dev.3

- Update to `bloc: ^4.0.0-dev.3`

# 4.0.0-dev.2

- Update to `bloc: ^4.0.0-dev.2`

# 4.0.0-dev.1

- Update to `bloc: ^4.0.0-dev.1`

# 3.2.0

- Fix type inference for: `MultiBlocProvider`, `MultiRepositoryProvider`, `MultiBlocListener` ([#773](https://github.com/felangel/bloc/pull/773))
- Fix swallowed exceptions within `BlocProvider` and `RepositoryProvider` ([#807](https://github.com/felangel/bloc/issues/807))
- Add `BlocProviderExtension` and `RepositoryProviderExtension` on `BuildContext` ([#608](https://github.com/felangel/bloc/issues/608))

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
