<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="150" alt="Cubit" />

[![Pub](https://img.shields.io/pub/v/cubit.svg)](https://pub.dev/packages/cubit)
[![build](https://github.com/felangel/cubit/workflows/build/badge.svg)](https://github.com/felangel/cubit/actions)
[![coverage](https://github.com/felangel/cubit/blob/master/packages/cubit/coverage_badge.svg)](https://github.com/felangel/cubit/actions)

**WARNING: This is highly experimental**

A `cubit` is a subset of [bloc](https://pub.dev/packages/bloc) which has no notion of events and relies on methods to `emit` new states.

Every `cubit` requires an initial state which will be the state of the `cubit` before `emit` has been called.
The current state of a `cubit` can be accessed via the `state` getter.

## Creating a Cubit

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
```

## Consuming a Cubit

```dart
void main() async {
  final cubit = CounterCubit()..increment();
  await cubit.close();
}
```

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
