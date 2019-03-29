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
