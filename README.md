<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="150" alt="Cubit" />

[![build](https://github.com/felangel/cubit/workflows/build/badge.svg)](https://github.com/felangel/cubit/actions)
[![coverage](https://github.com/felangel/cubit/blob/master/packages/cubit/coverage_badge.svg)](https://github.com/felangel/cubit/actions)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/cubit.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/felangel/cubit)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

**WARNING: This is highly experimental**

`Cubit` is a lightweight state management solution. It is a subset of the [bloc package](https://pub.dev/packages/bloc) that does not rely on events and instead uses methods to emit new states.

| Package                                                                               | Pub                                                                                                      |
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [cubit](https://github.com/felangel/cubit/tree/master/packages/cubit)                 | [![pub package](https://img.shields.io/pub/v/cubit.svg)](https://pub.dev/packages/cubit)                 |
| [cubit_test](https://github.com/felangel/cubit/tree/master/packages/cubit_test)       | [![pub package](https://img.shields.io/pub/v/cubit_test.svg)](https://pub.dev/packages/cubit_test)       |
| [flutter_cubit](https://github.com/felangel/cubit/tree/master/packages/flutter_cubit) | [![pub package](https://img.shields.io/pub/v/flutter_cubit.svg)](https://pub.dev/packages/flutter_cubit) |
| [angular_cubit](https://github.com/felangel/cubit/tree/master/packages/angular_cubit) | [![pub package](https://img.shields.io/pub/v/angular_cubit.svg)](https://pub.dev/packages/angular_cubit) |

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
- [Cubit Test Package](https://github.com/felangel/cubit/tree/master/packages/cubit_test/README.md)
- [Flutter Cubit Package](https://github.com/felangel/cubit/tree/master/packages/flutter_cubit/README.md)
- [Angular Cubit Package](https://github.com/felangel/cubit/tree/master/packages/angular_cubit/README.md)

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
