<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/cubit_full.png" height="60" alt="Cubit" />

**WARNING: This is highly experimental**

An experimental Dart library which exposes a `cubit`. A cubit is a reimagined bloc (from [package:bloc](https://pub.dev/packages/bloc)) which removes events and relies on methods to emit new states instead.

## Creating a Cubit

```dart
class CounterCubit extends Cubit<int> {
  @override
  int get initialState => 0;

  Future<void> increment() => emit(state + 1);
  Future<void> decrement() => emit(state - 1);
}
```

## Consuming a Cubit

```dart
void main() async {
  final counterCubit = CounterCubit()..listen(print);
  await counterCubit.increment();
  await counterCubit.decrement();
}
```

The above code outputs:

```sh
0
1
0
```

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)
