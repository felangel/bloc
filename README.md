<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="80" alt="Cubit" />

[![build](https://github.com/felangel/cubit/workflows/build/badge.svg)](https://github.com/felangel/cubit/actions)
[![coverage](https://github.com/felangel/cubit/blob/master/packages/cubit/coverage_badge.svg)](https://github.com/felangel/cubit/actions)

**WARNING: This is highly experimental**

A cubit is a reimagined bloc (from [package:bloc](https://pub.dev/packages/bloc)) which removes events and relies on methods to emit new states instead.

| Package                                                                               | Pub                                                                                                      |
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [cubit](https://github.com/felangel/cubit/tree/master/packages/cubit)                 | [![pub package](https://img.shields.io/pub/v/cubit.svg)](https://pub.dev/packages/cubit)                 |
| [flutter_cubit](https://github.com/felangel/cubit/tree/master/packages/flutter_cubit) | [![pub package](https://img.shields.io/pub/v/flutter_cubit.svg)](https://pub.dev/packages/flutter_cubit) |

## Overview

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

## Documentation

- [Cubit Package](https://github.com/felangel/cubit/tree/master/packages/cubit/README.md)
- [Flutter Cubit Package](https://github.com/felangel/cubit/tree/master/packages/flutter_cubit/README.md)

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
