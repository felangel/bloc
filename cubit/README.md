<p align="center"><img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="100" alt="Cubit"></p>

<p align="center">
<a href="https://github.com/felangel/cubit/actions"><img src="https://github.com/felangel/cubit/workflows/build/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://github.com/felangel/cubit/blob/master/packages/cubit/coverage_badge.svg" alt="coverage"></a>
<a href="https://github.com/felangel/cubit"><img src="https://img.shields.io/github/stars/felangel/cubit.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/zepfietje/starware"><img src="https://img.shields.io/badge/Starware-%E2%AD%90-black?labelColor=%23f9b00d" alt="Starware"></a>
</p>

Cubit is a lightweight state management solution. It is a subset of the [bloc package](https://pub.dev/packages/bloc) that does not rely on events and instead uses methods to emit new states.

## Usage

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

## Packages

| Package                                                                                 | Pub                                                                                                        |
| --------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [cubit](https://github.com/felangel/cubit/tree/master/packages/cubit)                   | [![pub package](https://img.shields.io/pub/v/cubit.svg)](https://pub.dev/packages/cubit)                   |
| [cubit_test](https://github.com/felangel/cubit/tree/master/packages/cubit_test)         | [![pub package](https://img.shields.io/pub/v/cubit_test.svg)](https://pub.dev/packages/cubit_test)         |
| [flutter_cubit](https://github.com/felangel/cubit/tree/master/packages/flutter_cubit)   | [![pub package](https://img.shields.io/pub/v/flutter_cubit.svg)](https://pub.dev/packages/flutter_cubit)   |
| [angular_cubit](https://github.com/felangel/cubit/tree/master/packages/angular_cubit)   | [![pub package](https://img.shields.io/pub/v/angular_cubit.svg)](https://pub.dev/packages/angular_cubit)   |
| [hydrated_cubit](https://github.com/felangel/cubit/tree/master/packages/hydrated_cubit) | [![pub package](https://img.shields.io/pub/v/hydrated_cubit.svg)](https://pub.dev/packages/hydrated_cubit) |
| [replay_cubit](https://github.com/felangel/cubit/tree/master/packages/replay_cubit)     | [![pub package](https://img.shields.io/pub/v/replay_cubit.svg)](https://pub.dev/packages/replay_cubit)     |

## Documentation

- [Cubit Package](https://github.com/felangel/cubit/tree/master/packages/cubit/README.md)
- [Cubit Test Package](https://github.com/felangel/cubit/tree/master/packages/cubit_test/README.md)
- [Flutter Cubit Package](https://github.com/felangel/cubit/tree/master/packages/flutter_cubit/README.md)
- [Angular Cubit Package](https://github.com/felangel/cubit/tree/master/packages/angular_cubit/README.md)
- [Hydrated Cubit Package](https://github.com/felangel/cubit/tree/master/packages/hydrated_cubit/README.md)
- [Replay Cubit Package](https://github.com/felangel/cubit/tree/master/packages/replay_cubit/README.md)

## Dart Versions

- Dart 2: >= 2.7.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[![Very Good Ventures](https://raw.githubusercontent.com/felangel/cubit/master/assets/vgv_logo.png)](https://verygood.ventures)

## Starware

Cubit is Starware.  
This means you're free to use the project, as long as you star its GitHub repository.  
Your appreciation makes us grow and glow up. ⭐
