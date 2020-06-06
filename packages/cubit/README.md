<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="60" alt="Cubit" />

[![Pub](https://img.shields.io/pub/v/cubit.svg)](https://pub.dev/packages/cubit)
[![build](https://github.com/felangel/cubit/workflows/build/badge.svg)](https://github.com/felangel/cubit/actions)
[![coverage](https://github.com/felangel/cubit/blob/master/packages/cubit/coverage_badge.svg)](https://github.com/felangel/cubit/actions)

**WARNING: This is highly experimental**

An experimental Dart library which exposes a `cubit`. A cubit is a reimagined bloc (from [package:bloc](https://pub.dev/packages/bloc)) which removes events and relies on methods to emit new states instead.

## Creating a Cubit

```dart
class CounterCubit extends Cubit<int> {
  @override
  int get initialState => 0;

  void increment() => emit(state + 1);
}
```

## Consuming a Cubit

```dart
void main() async {
  final cubit = CounterCubit()
    ..listen(print)
    ..increment();
  await cubit.close();
}
```

The above code outputs:

```sh
1
```

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
