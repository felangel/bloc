<p align="center"><img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="100" alt="Cubit"></p>

<p align="center">
<a href="https://pub.dev/packages/cubit"><img src="https://img.shields.io/pub/v/cubit.svg" alt="Pub"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://github.com/felangel/cubit/workflows/build/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://raw.githubusercontent.com/felangel/cubit/master/packages/cubit/coverage_badge.svg" alt="coverage"></a>
<a href="https://github.com/felangel/cubit"><img src="https://img.shields.io/github/stars/felangel/cubit.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/zepfietje/starware"><img src="https://img.shields.io/badge/Starware-%E2%AD%90-black?labelColor=%23f9b00d" alt="Starware"></a>
</p>

Cubit is a lightweight state management solution. It is a subset of the [bloc package](https://pub.dev/packages/bloc) that does not rely on events and instead uses methods to emit new states.

Every `cubit` requires an initial state which will be the state of the `cubit` before `emit` has been called.
The current state of a `cubit` can be accessed via the `state` getter.

## Creating a Cubit

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
```

## Using a Cubit

```dart
void main() async {
  final cubit = CounterCubit()..increment();
  await cubit.close();
}
```

## Observing a Cubit

`onTransition` can be overridden to observe state changes for a single cubit.

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  @override
  void onTransition(Transition<int> transition) {
    print(transition);
    super.onTransition(transition);
  }
}
```

`CubitObserver` can be used to observe state changes for all cubits.

```dart
class MyCubitObserver extends CubitObserver {
  @override
  void onTransition(Cubit cubit, Transition transition) {
    print(transition);
    super.onTransition(cubit, transition);
  }
}
```

```dart
void main() {
  Cubit.observer = MyCubitObserver();
  // Use cubits...
}
```

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
