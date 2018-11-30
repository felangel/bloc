# 0.1.0

Initial Version of the library.

- Includes the ability to connect presentation layer to `Bloc` by using the `BlocBuilder` Widget.
- Includes `BlocProvider`, a DI widget that allows a single instance of a bloc to be provided to multiple widgets within a subtree.

# 0.1.1

Minor Updates to Documentation

# 0.2.0

Updates to `BlocBuilder` and `BlocProvider`

- `BlocBuilder` does not automatically dispose a `Bloc`. Developers are now responsible for determining when to call `Bloc.dispose()`
- `BlocProvider` support for `of(context)` with generics
  - Support for multiple nested `BlocProviders` with different Bloc Types.

# 0.2.1

Minor Updates to Documentation

# 0.3.0

Updated to `bloc: ^0.6.0`

# 0.3.1

Minor Updates to Documentation

# 0.4.0

Updated to `bloc: ^0.7.0`

# 0.4.1

Minor Updates to Documentation

# 0.4.2

`BlocProvider` performance improvements
