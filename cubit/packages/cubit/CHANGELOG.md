# 0.1.2

- revert: `v0.1.1`

# 0.1.1

- fix: offload state emission to next event loop iteration

# 0.1.0

- docs: add `onTransition` documentation to README
- docs: add `CubitObserver` documentation to README

# 0.0.14

- feat: add `CubitObserver` support
- docs: minor documentation improvements

# 0.0.13

- docs: various documentation updates

# 0.0.12

- docs: fix coverage badge

# 0.0.11

- docs: various documentation updates

# 0.0.10

- docs: various documentation updates

# 0.0.9

- docs: documentation and logo updates

# 0.0.8

- **BREAKING**: revert named `initialState` parameter ([related issue](https://github.com/dart-lang/sdk/issues/42438))
- docs: minor logo updates

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
