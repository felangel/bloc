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
