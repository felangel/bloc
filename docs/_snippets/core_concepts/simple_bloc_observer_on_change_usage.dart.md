```dart
void main() {
  BlocOverrides.runZoned(
    () {
      CounterCubit()
        ..increment()
        ..close();
    },
    blocObserver: SimpleBlocObserver(),
  );
}
```
