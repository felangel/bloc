# 0.0.7

- feat: add `onTransition` to `cubit`
- feat: `Cubit` extends `CubitStream`

# 0.0.6

- **BREAKING**: ignore duplicate states

# 0.0.5

- feat: allow `initialState` to be `null`

# 0.0.4

- **BREAKING**: use named parameter for `initialState`

# 0.0.3

- **BREAKING**: remove `initialState` getter and instead require initial state via constructor

# 0.0.2

- **BREAKING**: update `emit` to be a `void` function
- **BREAKING**: remove artifical wait to guarantee `initialState` is emitted
- **BREAKING**: `close` drains the internal `Stream`
- tests: 100% test coverage

# 0.0.1

- feat: initial release
