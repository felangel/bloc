# 3.0.0

- Upgrade to `rxdart ^0.23.0`
- Upgrade to `Dart >= 2.6.0`

# 3.0.0-dev.1

- Upgrade to `rxdart ^0.23.0`

# 2.0.0

- Allow blocs to finish processing pending events on `close` ([#639](https://github.com/felangel/bloc/issues/639))
- Documentation Updates

# 1.0.1

- Bugfix: Exceptions thrown in `onTransition` are passed to `onError` and should not break bloc functionality ([#641](https://github.com/felangel/bloc/issues/641))
- Adhere to [effective dart](https://dart.dev/guides/language/effective-dart) ([#561](https://github.com/felangel/bloc/issues/561))
- Documentation and Example Updates

# 1.0.0

- `dispatch` and `dispose` removed
- Documentation Updates

# 0.16.1

- Minor Documentation Updates

# 0.16.0

- Bloc extends `Stream<State>` ([#558](https://github.com/felangel/bloc/issues/558))
  - `bloc.state.listen` -> `bloc.listen`
  - `bloc.currentState` -> `bloc.state`
- Bloc implements `Sink<Event>` ([#558](https://github.com/felangel/bloc/issues/558))
  - `dispatch` deprecated in favor of `add`
  - `dispose` deprecated in favor of `close`
- Documentation and Example Updates

# 0.15.0

- Removed Bloc `event` Stream ([#326](https://github.com/felangel/bloc/issues/326))
- Renamed `transform` to `transformEvents`
- Added `transformStates` ([#382](https://github.com/felangel/bloc/issues/382))

# 0.14.4

Additional Dependency and Documentation Updates.

# 0.14.3

Dependency and Documentation Updates.

# 0.14.2

- Deprecated Bloc `event` Stream ([#326](https://github.com/felangel/bloc/issues/326))
- Documentation Updates

# 0.14.1

Internal `BlocDelegate` update and Documentation Updates.

# 0.14.0

`BlocDelegate` initialization improvements and Documentation Updates.

- `BlocSupervisor().delegate = ...` is now `BlocSupervisor.delegate = ...` ([#304](https://github.com/felangel/bloc/issues/304)).

# 0.13.0

`Bloc` and `BlocDelegate` Improvements, new Features, and Documentation Updates.

- Improved `dispose` to ignore pending events ([#257](https://github.com/felangel/bloc/issues/257)).
- Exposed `event` stream on `Bloc` similar to `state` stream to expose a `Stream` of `dispatched` events ([#259](https://github.com/felangel/bloc/issues/259)).
- Update to use `rxdart` version `^0.22.0` ([#265](https://github.com/felangel/bloc/issues/265)).
- `BlocDelegate` methods include a reference to the `Bloc` instance ([#259](https://github.com/felangel/bloc/issues/259)).
- Added `onEvent` to `Bloc` and `BlocDelegate` ([#259](https://github.com/felangel/bloc/issues/259)).

# 0.12.0

Updated `transform` to enable advanced event filtering and processing and Documentation Updates.

# 0.11.2

Added `BlocDelegate` `onError` and `onTransition` mustCallSuper and Documentation Updates

# 0.11.1

Added `dispose` mustCallSuper and Documentation Updates

# 0.11.0

Update `mapEventToState` to remove unnecessary argument for `currentState`

- `Stream<S> mapEventToState(S currentState, E event)` -> `Stream<S> mapEventToState(E event)`
- Documentation Updates
- Example Updates

# 0.10.0

Updated to `rxdart ^0.21.0` and Documentation Updates

# 0.9.5

Minor Enhancements to Code Style and Documentation.

# 0.9.4

Calls to `dispatch` after `dispose` has been called trigger `onError` in the `Bloc` and `BlocDelegate`.

# 0.9.3

Restrict `rxdart` to `">=0.18.1 <0.21.0"` due to breaking changes.

# 0.9.2

Additional Minor Updates to Documentation

# 0.9.1

Minor Updates to Documentation

# 0.9.0

`Bloc` and `BlocDelegate` Error Handling

- Added `onError` to `Bloc` for local error handling.
- Added `onError` to `BlocDelegate` for global error handling.

# 0.8.4

Blocs handle exceptions thrown in `mapEventToState` and documentation updates.

# 0.8.3

Minor Internal Improvements and Documentation Updates

# 0.8.2

Additional Minor Updates to Documentation

# 0.8.1

Minor Updates to Documentation

# 0.8.0

Blocs ignore duplicate states

# 0.7.8

Additional Minor Updates to Documentation

# 0.7.7

Additional Minor Updates to Documentation

# 0.7.6

Minor Updates to Documentation

# 0.7.5

Exposed `currentState` in `Bloc`

- Updates to Documentation.

# 0.7.4

Updated `mapEventToState` parameter name

- `Stream<S> mapEventToState(S state, E event)` -> `Stream<S> mapEventToState(S currentState, E event)`
- Updates to Documentation.
- Updates to Example.

# 0.7.3

Minor Updates to Documentation

# 0.7.2

`Transition` Fix

- `Bloc` with `mapEventToState` which returns multiple states per event will now correctly report the `Transitions`.

# 0.7.1

Improvements to `Bloc` usage in pure Dart applications.

- `Bloc` state is seeded with `initialState` automatically

# 0.7.0

Added `BlocSupervisor` and `BlocDelegate`.

- `BlocSupervisor` notifies `BlocDelegate` of `Transitions`
- `BlocDelegate` exposes `onTransition` which is invoked for all `Bloc` `Transitions`.

# 0.6.0

`Transitions` and `initialState` updates.

- Added `Transition`s and `onTransition`
- Made `initialState` required

# 0.5.2

Additional minor Updates to Documentation.

# 0.5.1

Minor Updates to Documentation

# 0.5.0

Moved Flutter Widgets to flutter_bloc package

# 0.4.2

Additional minor Updates to Documentation.

# 0.4.1

Minor Updates to Documentation.

# 0.4.0

Added `BlocProvider`.

- `BlocProvider.of(context)`
- Updates to Documentation.
- Updates to Example.

# 0.3.0

Updated `mapEventToState` to take current state as an argument.

- `Stream<S> mapEventToState(E event)` -> `Stream<S> mapEventToState(S state, E event)`
- Updates to Documentation.
- Updates to Example.

# 0.2.5

Additional Minor Updates to Documentation.

# 0.2.4

Additional Minor Updates to Documentation.

# 0.2.3

Additional Minor Updates to Documentation.

# 0.2.2

Additional Minor Updates to Documentation.

# 0.2.1

Minor Updates to Documentation.

# 0.2.0

Added Support for Stream Transformation

- Includes `Stream<E> transform(Stream<E> events)`
- Updates to Documentation

# 0.1.2

Additional Minor Updates to Documentation.

# 0.1.1

Minor Updates to Documentation.

# 0.1.0

Initial Version of the library.

- Includes the ability to create a custom Bloc by extending `Bloc` class.
- Includes the ability to connect presentation layer to `Bloc` by using the `BlocBuilder` Widget.
