# 0.1.0

Initial Version of the library.

- Includes the ability to create a custom Bloc by extending `Bloc` class.
- Includes the ability to connect presentation layer to `Bloc` by using the `BlocBuilder` Widget.

# 0.1.1

Minor Updates to Documentation.

# 0.1.2

Additional Minor Updates to Documentation.

# 0.2.0

Added Support for Stream Transformation

- Includes `Stream<E> transform(Stream<E> events)`
- Updates to Documentation

# 0.2.1

Minor Updates to Documentation.

# 0.2.2

Additional Minor Updates to Documentation.

# 0.2.3

Additional Minor Updates to Documentation.

# 0.2.4

Additional Minor Updates to Documentation.

# 0.2.5

Additional Minor Updates to Documentation.

# 0.3.0

Updated `mapEventToState` to take current state as an argument.

- `Stream<S> mapEventToState(E event)` -> `Stream<S> mapEventToState(S state, E event)`
- Updates to Documentation.
- Updates to Example.

# 0.4.0

Added `BlocProvider`.

- `BlocProvider.of(context)`
- Updates to Documentation.
- Updates to Example.

# 0.4.1

Minor Updates to Documentation.

# 0.4.2

Additional minor Updates to Documentation.
